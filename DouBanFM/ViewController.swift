//
//  ViewController.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/6.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import CoreData
import BTNavigationDropdownMenu
import AVFoundation
import Alamofire


var isPlayOffline = false
var isFromDld = false
var dataMusicIsPlaying = false
var isRandomPlayOffline = false
var isRandomPlayOnline = false
var isRepeatPlay = false


class ViewController: UIViewController ,PassURLDelegate,NetWorkStarkDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate{
    
    //当前播放网络歌曲实例
    var currentNetSong = NetSong()
    
    //当前本地歌曲实例
    var currentDataSong:DownloadSong!
    
    //当前播放音乐信息
    var currentSongTitle:String!
    
    var currentSongArtist:String!
    
    var currentSongPic:UIImage!
    
    var currentTime:NSNumber!
    
    var currentSongId:String!
    
    var curtentSongStr:String!
    
    //网络操作类实例
    var netWorkStack = NetWorkStark()
    
    //请求歌曲详情的URL
    var getSongURL = "http://douban.fm/j/mine/playlist?type=n&channel=\(Int(arc4random()%10))&from=mainsite"
    
    //appdelegate的单例
    let appDelegate = AppDelegate.shareAppDelegate()
    
    //喜欢歌曲类的单例
    var loveSongsHelper:LoveSongsHelper = LoveSongsHelper.shareLoveSong()
    var loveSongsArray:[Song]!
    
    //下载歌曲类的实例
    var dldSongHelper = DldSongsHelper.shareDldSongs()
    var dldSongArray:[DownloadSong]!
    
    //CoreData操作类实例
    let coreDataHelper = CoreDataHelper()
    
    var musicPlayer:AVPlayer!
    
    @IBOutlet var rotationImage1: XYCircleAndRotationImageView!
    
    @IBOutlet var rotationImage2: XYCircleAndRotationImageView!
    
    @IBOutlet var changPianZhen: UIImageView!
    
    @IBOutlet var bgImage: UIImageView!
    
    @IBOutlet var pauseBtn: UIButton!
    
    @IBOutlet var loveBtn: UIButton!

    @IBOutlet var topAnimationBtn: UIBarButtonItem!
    
    @IBOutlet var listBtn: UIButton!
    
    @IBOutlet var bigBlurView: UIVisualEffectView!
    
    @IBOutlet weak var moreBtn: UIBarButtonItem!
    
    @IBOutlet var maskView: UIView!
    
    @IBOutlet var detailBlurView: UIVisualEffectView!
    
    @IBOutlet var detailText: UITextView!
    
    var animationImageView = AnimationImageView.shareAnimationImageView()
    
    var dataMusicplayer = AVAudioPlayer()
    
    var playBtn:UIButton!
    
    var blurView:UIVisualEffectView!
    
    var BTView:BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置网络操作代理
        netWorkStack.delegate = self
        
        self.netWorkStack.getResult(getSongURL)
       
        //设置播放按钮
        setPlayBtn()
        //隐藏播放按钮和模糊效果
        self.playBtn.hidden = true
        self.blurView.hidden = true
        //设置指针图片的锚点
        self.changPianZhen.layer.anchorPoint = CGPointMake(6/22, 6/36.4)
        //设置顶部动画图片
//        self.topAnimationBtn.customView = self.animationImageView
        //添加点击动作
        addSingleFingerOneClickForChangpianzhen()
        addSingleFingerOneClickForDetailBlurView()
        //设置更多按钮
        setMoreBtn()
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
        configureBackBtn()
    }
    
    
    //定义返回按钮
    func configureBackBtn(){
        let backItem = UIBarButtonItem()
        backItem.title = " "
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        //自定义图片
//        let image = UIImage(named: "cm2_top_icn_back_prs")
//        image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
//        self.navigationController?.navigationBar.backIndicatorImage = image
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        
    }
    
    
    
    //摇一摇
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake{
            let count = UInt32(colors.count - 1)
            let random = Int(arc4random()%count)
            color = colors[random]
            UIView.animateWithDuration(3, animations: { () -> Void in
                self.navigationController?.navigationBar.barTintColor = color
            })
            BTView.cellBackgroundColor = color
            self.maskView.backgroundColor = color
            //self.playBtn.tintColor = color
            
        }else{
            
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        loveSongsArray = self.loveSongsHelper.loveSongs
        dldSongArray = self.dldSongHelper.dldSongs
        if isPlayOffline && isFromDld{
            let song = CurrentDataSong.shareCurrentDataSong().song!
            
            self.playOfflineMusic(song)
        }else{
            
        }
        
        //*****************
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = color
        
        BTView.cellBackgroundColor = color
        self.maskView.backgroundColor = color
        
        checkTheMark()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //*****************
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    //*****************
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    
    //*****************
    //锁屏控制中心点击事件
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlNextTrack {
                if isPlayOffline {
                    if isRandomPlayOffline{
                        self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
                        let song = self.dldSongArray[Int(arc4random()%UInt32(self.dldSongArray.count))]
                        playOfflineMusic(song)
                    }else{
                        print("本地播放下一首")
                        currentIndex = currentIndex + 1
                        if currentIndex > dldSongArray.count - 1{
                            currentIndex = 0
                        }
                        dldSongArray = dldSongHelper.dldSongs
                        let nextSong:DownloadSong = dldSongArray[currentIndex]
                        print(nextSong.title!)
                        
                        let image = UIImage(data: nextSong.image!)
                        setSongDetailForInterface(nextSong.id!,title:nextSong.title!, artistName: nextSong.artist!, image: image!)
                        self.dataMusicplayer = try! AVAudioPlayer(data: (nextSong.song)!)
                        dataMusicplayer.delegate = self
                        self.dataMusicplayer.play()
                    }
                    isPlayOffline = true
                    dataMusicIsPlaying = true
                    
                }else{
                    if isRandomPlayOnline{
                        self.loveSongsArray = LoveSongsHelper.shareLoveSong().loveSongs
                        let song = self.loveSongsArray[Int(arc4random()%UInt32(self.loveSongsArray.count))]
                        playOnlineMusic(song)
                    }else{
                        self.musicPlayer.pause()
                        needleAnimationNotBack()
                        rotationImage1.stopRotation()
                        rotationImage2.stopRotation()
                        self.animationImageView.stopAnimating()
                        self.loveBtn.setImage(UIImage(named: "no_love"), forState: UIControlState.Normal)
                        self.netWorkStack.getResult(getSongURL)
                    }
                }
                
            }else if event!.subtype == UIEventSubtype.RemoteControlPause {
                print(1)
                if dataMusicIsPlaying{
                    self.dataMusicplayer.pause()
                }
                self.musicPlayer.pause()
                
                
            }else if event!.subtype == UIEventSubtype.RemoteControlPlay {
                
                if dataMusicIsPlaying{
                    self.dataMusicplayer.play()
                }
                self.musicPlayer.play()
                
            }
        }
    }
    //*****************
    //配置音乐信息到锁屏界面
    func configNowPlayingInfoCenter(){
        if (NSClassFromString("MPNowPlayingInfoCenter") != nil) {
            
            let mArt:MPMediaItemArtwork = MPMediaItemArtwork(image: currentSongPic)
            var dic:[String : AnyObject] = [ MPMediaItemPropertyTitle : currentSongTitle,
                MPMediaItemPropertyArtist : currentSongArtist,
                MPMediaItemPropertyArtwork : mArt ]

            if dataMusicIsPlaying {
                let time = self.dataMusicplayer.currentTime
                let duration = self.dataMusicplayer.duration
                dic.updateValue(NSNumber(double: time), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime )
                dic.updateValue(NSNumber(double: duration), forKey: MPMediaItemPropertyPlaybackDuration)
                dic.updateValue(NSNumber(float: 1.0), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            }else{
                let time = self.musicPlayer.currentTime()
                let duration = self.musicPlayer.currentItem!.asset.duration
                dic.updateValue(NSNumber(double: CMTimeGetSeconds(time)), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime )
                dic.updateValue(NSNumber(double: CMTimeGetSeconds(duration)), forKey: MPMediaItemPropertyPlaybackDuration)
                dic.updateValue(NSNumber(float: 1.0), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            }
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = dic
        }
    }
    
    
    //检查mark
    func checkTheMark(){
        if isPlayOffline{
            self.BTView.is1s = true
        }else{
            self.BTView.is1s = false
        }
        if isRandomPlayOnline{
            self.BTView.is0s = true
        }else{
            self.BTView.is0s = false
        }
        if isRepeatPlay{
            self.BTView.is2s = true
        }else{
            self.BTView.is2s = false
        }
    }
    
    
    //更多按钮
    func setMoreBtn(){
        let items = ["随机播放喜欢的歌曲", "随机播放下载的歌曲", "单曲循环" ,"设置"]
        BTView = BTNavigationDropdownMenu(title: "", items: items)
        BTView.arrowImage = UIImage(named: "ar")
        BTView.arrowPadding = -15
        BTView.cellHeight = 44
        BTView.cellSeparatorColor = UIColor.clearColor()
        BTView.cellBackgroundColor = color
        BTView.checkMarkImage = UIImage(named: "checkmark")
        
        BTView.didSelectItemAtIndexHandler = {(indexPath:Int) -> () in
            isFromDld = false
            print(indexPath)
            switch indexPath{
            case 0 :
                if isRandomPlayOnline {
                    isRandomPlayOnline = false
                    
                }else{
                    isRandomPlayOnline = true
                    isRandomPlayOffline = false
                    
                    self.loveSongsArray = LoveSongsHelper.shareLoveSong().loveSongs
                    if self.loveSongsArray.count != 0 {
                        let song = self.loveSongsArray[Int(arc4random()%UInt32(self.loveSongsArray.count))]
                        self.playOnlineMusic(song)
                    }else{
                        ProgressHUD.showError("喜欢列表中没有歌曲", interaction: true)
                        isRandomPlayOnline = false
                    }
                }
                
                
                
                
            case 1 :
                if isRandomPlayOffline {
                    isRandomPlayOffline = false
                    isPlayOffline = false
                }else{
                    isRandomPlayOffline = true
                    isPlayOffline = true
                    isRandomPlayOnline = false
                    
                    self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
                    if self.dldSongArray.count != 0 {
                        let song = self.dldSongArray[Int(arc4random()%UInt32(self.dldSongArray.count))]
                        self.playOfflineMusic(song)
                    }else{
                        ProgressHUD.showError("下载列表中没有歌曲", interaction: true)
                        isRandomPlayOffline = false
                        isPlayOffline = false
                    }
                }
                
            case 2 :
                if isRepeatPlay {
                    isRepeatPlay = false
                }else{
                    isRepeatPlay = true
                }
                
                self.checkTheMark()
            case 3 :
                self.presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier("setView"))!, animated: true, completion: nil)
                
            default :
                break
            }
            
            self.checkTheMark()
        }
    
        self.moreBtn.customView = BTView
        
        
    }
    
    
    var currentIndex = CurrentDataSong.shareCurrentDataSong().index
    
    //下一首按钮
    @IBAction func btn(sender: UIButton) {
        if isPlayOffline {
            self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
            if dldSongArray.count != 0 {
                if isRandomPlayOffline{
                    self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
                    let song = self.dldSongArray[Int(arc4random()%UInt32(self.dldSongArray.count))]
                    playOfflineMusic(song)
                }else{
                    print("本地播放下一首")
                    currentIndex = currentIndex + 1
                    if currentIndex > dldSongArray.count - 1{
                        currentIndex = 0
                    }
                    dldSongArray = dldSongHelper.dldSongs
                    let nextSong:DownloadSong = dldSongArray[currentIndex]
                    print(nextSong.title!)
                    
                    let image = UIImage(data: nextSong.image!)
                    setSongDetailForInterface(nextSong.id!,title:nextSong.title!, artistName: nextSong.artist!, image: image!)
                    self.dataMusicplayer = try! AVAudioPlayer(data: (nextSong.song)!)
                    dataMusicplayer.delegate = self
                    self.dataMusicplayer.play()
                }
                isPlayOffline = true
                dataMusicIsPlaying = true
            }else{
                dataMusicplayer.pause()
                isPlayOffline = false
            }
        }else{
            if isRandomPlayOnline{
                self.loveSongsArray = LoveSongsHelper.shareLoveSong().loveSongs
                let song = self.loveSongsArray[Int(arc4random()%UInt32(self.loveSongsArray.count))]
                playOnlineMusic(song)
            }else{
                self.musicPlayer.pause()
                needleAnimationNotBack()
                rotationImage1.stopRotation()
                rotationImage2.stopRotation()
                self.animationImageView.stopAnimating()
                self.loveBtn.setImage(UIImage(named: "no_love"), forState: UIControlState.Normal)
                self.netWorkStack.getResult(getSongURL)
            }
        }
    }
    

    
    // MARK: - NetWorkStarkDelegate 相关方法
    func didGetResult(data: NSData) {
        if dataMusicIsPlaying {
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
            if let jsonDic = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                //print(jsonDic)
                let json = JSON(jsonDic!)
                let jsonArray = json["song"].array
                self.currentNetSong.name = jsonArray![0]["title"].string!
                self.currentNetSong.url = jsonArray![0]["url"].string!
                self.currentNetSong.artistName = jsonArray![0]["artist"].string!
                self.currentNetSong.picURL = jsonArray![0]["picture"].string!
                self.currentNetSong.albumtitle = jsonArray![0]["albumtitle"].string!
                self.currentNetSong.publicTime = jsonArray![0]["public_time"].string
                self.currentNetSong.songID = jsonArray![0]["aid"].string!
                if self.musicPlayer == nil{
                    self.fisrstConfigueMusicPlayer()
                }else{
                    self.playNetMusic(currentNetSong)
                }
                
                
            }else{
                ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
        }
        
    }
    
    func didGetError(err: ErrorType?) {
        ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
    }
    
    
    
    //配置歌曲详情到界面
    
    func setSongDetailForInterface(id:String,title:String,artistName:String,image:UIImage){
        
        self.title = title
        self.navigationItem.prompt = artistName
        self.bgImage.image = image
        self.rotationImage1.image = image
        
        self.isLoveSong(id)
            
        self.rotationImage1.resumeRotation()
        self.rotationImage2.resumeRotation()
        self.rotationImage1.startRotation()
        self.rotationImage2.startRotation()
            
        self.needleAnimationNoMove()
        
        self.animationImageView.startAnimating()
        
        self.playBtn.hidden = true
        self.blurView.hidden = true
        
        self.currentSongTitle = title
        self.currentSongArtist = artistName
        self.currentSongPic = image
        self.currentSongId = id
        
        configNowPlayingInfoCenter()
        
        congfigureDetailView()
    }
    
    
    //判断播放的歌是不是喜欢的歌
    func isLoveSong(id:String){
        
        loveSongsArray = loveSongsHelper.loveSongs
        if loveSongsHelper.loveSongsID.contains(id){
            self.loveBtn.setImage(UIImage(named: "love"), forState: UIControlState.Normal)
        }else{
            self.loveBtn.setImage(UIImage(named: "no_love"), forState: UIControlState.Normal)
        }
        
    }
    
    //配置音乐播放器
    func fisrstConfigueMusicPlayer(){
        let playerItem = AVPlayerItem(URL: NSURL(string: currentNetSong.url!)!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        musicPlayer = AVPlayer(playerItem: playerItem)
        let layer = AVPlayerLayer(player: musicPlayer)
        self.view.layer.addSublayer(layer)
        musicPlayer.play()
        
        self.setSongDetailForInterface(self.currentNetSong.songID!,title:self.currentNetSong.name!, artistName: self.currentNetSong.artistName!, image: self.currentNetSong.image)

        //后台播放
        var bgTask:UIBackgroundTaskIdentifier = 0
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            self.musicPlayer.play()
            let app:UIApplication = UIApplication.sharedApplication()
            let newTask:UIBackgroundTaskIdentifier = app.beginBackgroundTaskWithExpirationHandler(nil)
            if newTask != UIBackgroundTaskInvalid {
                app.endBackgroundTask(bgTask)
            }
            bgTask = newTask
        }else{
            musicPlayer.play()
        }
        
    }
    
    //有音乐播放器时直接播放下一首
    func playNextSong(){
        
        let item = AVPlayerItem(URL: NSURL(string: currentNetSong.url!)!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        musicPlayer.replaceCurrentItemWithPlayerItem(item)
        musicPlayer.play()
        self.playBtn.hidden = true
        self.blurView.hidden = true
    }
    
    //当前在线歌曲播放完成之后接受通知自动开始播放下一首歌
    func playerItemDidReachEnd(aNotification:NSNotification){
        
        if isRandomPlayOnline {
            if isRepeatPlay{
                playNetMusic(currentNetSong)
            }else{
                self.loveSongsArray = LoveSongsHelper.shareLoveSong().loveSongs
                let song = self.loveSongsArray[Int(arc4random()%UInt32(self.loveSongsArray.count))]
                self.playOnlineMusic(song)
            }
        }else{
            if isRepeatPlay{
                playNetMusic(currentNetSong)
            }else{
                rotationImage1.stopRotation()
                rotationImage2.stopRotation()
                self.netWorkStack.getResult(getSongURL)
            }
            
        }
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        if isPlayOffline{
            if isRepeatPlay {
                player.stop()
                dataMusicIsPlaying = false
                player.play()
                dataMusicIsPlaying = true
            }else{
                self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
                let song = self.dldSongArray[Int(arc4random()%UInt32(self.dldSongArray.count))]
                self.playOfflineMusic(song)
            }
        }else{
            
        }
    }
    

    
    // MARK: - PassURLDelegate 相关方法
    func didGetURL(url: String) {
        isPlayOffline = false
        getSongURL = url
        netWorkStack.getResult(url)
    }
    
    
    
    // MARK: - storyboard转场相关
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChanel"{
            let vc = segue.destinationViewController as! ChanelTableViewController
            vc.delegate = self
        }else if segue.identifier == "showSongList" {
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.topViewController as! SongListTableViewController

            vc.currentSongTitle = self.currentSongTitle
            vc.loveSongArray = self.loveSongsHelper.loveSongs
            vc.dldSongArray = self.dldSongHelper.dldSongs
            vc.dldSongsID = self.dldSongHelper.dldSongsID
            vc.passDetailDelegate = self
            vc.currentSongID = self.currentSongId
        }
    }
}

// MARK: - 红心按钮

extension ViewController{
    @IBAction func loveBtnClick(sender: UIButton) {
        
        if !isPlayOffline{
            sender.setImage(UIImage(named: "love"), forState: UIControlState.Normal)
            
            let myGloQueue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(myGloQueue) { () -> Void in
                let data = NSData(contentsOfURL: NSURL(string: self.currentNetSong.picURL!)!)
                if self.coreDataHelper.saveLoveSong(self.currentNetSong.songID!,title:self.currentNetSong.name!, artist: self.currentNetSong.artistName!, url: self.currentNetSong.url!, picURL: self.currentNetSong.picURL!, albumtitle: self.currentNetSong.albumtitle!, publicTime: self.currentNetSong.publicTime,imageData: data!){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertView = UIAlertController(title: "喜欢", message: "添加成功", preferredStyle: UIAlertControllerStyle.Alert)
                        alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertView, animated: true, completion: nil)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertView = UIAlertController(title: "喜欢", message: "该歌曲已存在", preferredStyle: UIAlertControllerStyle.Alert)
                        alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertView, animated: true, completion: nil)
                    })
                }
            }
        }else{
            let alertView = UIAlertController(title: "", message: "正在使用离线播放", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
} 


// MARK: - 暂停按钮
extension ViewController{
    
    @IBAction func pauseBtnClick(sender: UIButton) {
        if !isPlayOffline{
            self.musicPlayer.pause()
        }else{
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.rotationImage1.stopRotation()
        self.rotationImage2.stopRotation()
        self.animationImageView.stopAnimating()
        self.blurView.hidden = false
        self.playBtn.hidden = false
        self.playBtn.enabled = true
        self.needleAnimationNotBack()
    }
    
    func setPlayBtn(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView.frame = CGRectMake(-1, -1, 150, 150)
        self.blurView.layer.cornerRadius = 75
        self.blurView.layer.masksToBounds = true
        self.blurView.alpha = 0.8
        self.pauseBtn.addSubview(blurView)
        self.playBtn = UIButton(type: UIButtonType.System)
        self.playBtn.frame = CGRectMake(45, 45, 60, 60)
        self.playBtn.addTarget(self, action: "playBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.playBtn.tintColor = UIColor.blackColor()
        self.playBtn.setImage(UIImage(named: "btn_playblack"), forState: UIControlState.Normal)
        self.blurView.addSubview(playBtn)
    }
    
    func playBtnClick(){
        if !isPlayOffline{
            self.musicPlayer.play()
        }else{
            self.dataMusicplayer.play()
            dataMusicIsPlaying = true
        }
        self.rotationImage1.resumeRotation()
        self.rotationImage2.resumeRotation()
        self.animationImageView.startAnimating()
        self.playBtn.hidden = true
        self.blurView.hidden = true
        needleAnimationNoMove()
    }
}


// MARK: - 指针动画相关

extension ViewController{
    
    //    func needleAnimation(){
    //        let rotation = CABasicAnimation(keyPath: "transform.rotation")
    //
    //
    //        rotation.duration = 1.8
    //        rotation.fromValue = 0
    //        rotation.toValue = -M_PI/3
    //
    //        self.changPianZhen.layer.addAnimation(rotation, forKey: "rotation1")
    //
    //    }
   
    
    func needleAnimationNotBack(){
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotation.duration = 1
        rotation.fromValue = 0
        rotation.toValue = -M_PI/4
        
        rotation.fillMode = kCAFillModeForwards
        rotation.removedOnCompletion = false
        
        self.changPianZhen.layer.addAnimation(rotation, forKey: "rotation1")
        
    }
    
    func needleAnimationNoMove(){
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotation.duration = 0.8
        rotation.fromValue = -M_PI/8
        rotation.toValue = M_PI/40
        
        rotation.fillMode = kCAFillModeForwards
        rotation.removedOnCompletion = false
        
        self.changPianZhen.layer.addAnimation(rotation, forKey: "rotation1")
        
    }
    
    
     func addSingleFingerOneClickForChangpianzhen(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleClick")
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.bigBlurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func singleClick(){
        self.detailBlurView.hidden = false
    }
    
}


// MARK: - 从喜欢的歌曲列表播放

extension ViewController:PassSongDetailDelegate{
    func didGetDetail(song: Song) {
        self.playOnlineMusic(song)
    }
}


// MARK: - 音乐播放相关扩展

extension ViewController{
    
    func playOfflineMusic(song:DownloadSong) {
        //isPlayOffline = true
        if dataMusicIsPlaying {
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.musicPlayer.pause()
        self.currentDataSong = song
        self.dataMusicplayer = try! AVAudioPlayer(data: song.song!)
        self.dataMusicplayer.delegate = self
        self.dataMusicplayer.play()
        dataMusicIsPlaying = true
        self.setSongDetailForInterface(song.id! ,title: song.title!, artistName: song.artist!, image: UIImage(data: song.image!)!)
        self.currentSongTitle = song.title
        self.currentSongId = song.id
    }
    
    func playOnlineMusic(song:Song){
        isPlayOffline = false
        if dataMusicIsPlaying{
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.musicPlayer.pause()
        self.currentNetSong.name = song.title
        self.currentNetSong.artistName = song.artist
        self.currentNetSong.picURL = song.picture_url
        self.currentNetSong.url = song.url
        self.currentNetSong.publicTime = song.public_time
        self.currentNetSong.songID = song.id
        
        let playerItem = AVPlayerItem(URL: NSURL(string: self.currentNetSong.url!)!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        self.musicPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        
        self.musicPlayer.play()
        self.setSongDetailForInterface(song.id! ,title: song.title!, artistName: song.artist!, image: UIImage(data: song.image!)!)
        self.currentSongTitle = song.title
        self.currentSongId =  song.id
    }
    
    func playNetMusic(song:NetSong){
        isPlayOffline = false
        if dataMusicIsPlaying{
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.musicPlayer.pause()
        let playerItem = AVPlayerItem(URL: NSURL(string: self.currentNetSong.url!)!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        self.musicPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        
        self.musicPlayer.play()
        self.setSongDetailForInterface(song.songID!,title:song.name!, artistName: song.artistName!, image: song.image)
        self.currentSongTitle = song.name
        self.currentSongId =  song.songID
    }
}


extension ViewController {
    
    func congfigureDetailView(){
        detailText.text = "暂时没有专辑详情"
        getStr()
        detailText.tintColor = UIColor(red:0.97, green:0.37, blue:0.45, alpha:1)
        
    }
    
    
    func getStr() {
        if currentSongId != nil {
            let url = "https://api.douban.com/v2/music/\(currentSongId)"
            // My API (GET https://api.douban.com/v2/music/3986489)
            // Fetch Request
            Alamofire.request(.GET, url).response(completionHandler: { (_, _, data, err) -> Void in
                if err == nil {
                    if let jsonDic = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                        let json = JSON(jsonDic!)
                        let str = json["summary"].string
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.detailText.text = str! + "\n豆瓣音乐：http://m.douban.com/music/subject/\(self.currentSongId)"
                            
                        })
                    }
                }
            })
        }
    }
    
    func addSingleFingerOneClickForDetailBlurView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "detailSingleClick")
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.detailBlurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func detailSingleClick(){
        self.detailBlurView.hidden = true
        congfigureDetailView()
    }
    
}








