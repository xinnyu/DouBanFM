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
import SwiftyJSON


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
        self.playBtn.isHidden = true
        self.blurView.isHidden = true
        //设置指针图片的锚点
        self.changPianZhen.layer.anchorPoint = CGPoint(x: 6/22, y: 6/36.4)
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
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        //自定义图片
//        let image = UIImage(named: "cm2_top_icn_back_prs")
//        image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
//        self.navigationController?.navigationBar.backIndicatorImage = image
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        
    }
    
    
    
    //摇一摇
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake{
            let count = UInt32(colors.count - 1)
            let random = Int(arc4random()%count)
            color = colors[random]
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.navigationController?.navigationBar.barTintColor = color
            })
            BTView.cellBackgroundColor = color
            self.maskView.backgroundColor = color
            //self.playBtn.tintColor = color
            
        }else{
            
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        loveSongsArray = self.loveSongsHelper.loveSongs
        dldSongArray = self.dldSongHelper.dldSongs
        if isPlayOffline && isFromDld{
            let song = CurrentDataSong.shareCurrentDataSong().song!
            
            self.playOfflineMusic(song)
        }else{
            
        }
        
        //*****************
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = color
        
        BTView.cellBackgroundColor = color
        self.maskView.backgroundColor = color
        
        checkTheMark()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //*****************
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    //*****************
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    
    //*****************
    //锁屏控制中心点击事件
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEventType.remoteControl {
            if event!.subtype == UIEventSubtype.remoteControlNextTrack {
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
                        
                        let image = UIImage(data: nextSong.image! as Data)
                        setSongDetailForInterface(nextSong.id!,title:nextSong.title!, artistName: nextSong.artist!, image: image!)
                        self.dataMusicplayer = try! AVAudioPlayer(data: (nextSong.song)! as Data)
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
                        self.loveBtn.setImage(UIImage(named: "no_love"), for: UIControlState())
                        self.netWorkStack.getResult(getSongURL)
                    }
                }
                
            }else if event!.subtype == UIEventSubtype.remoteControlPause {
                print(1)
                if dataMusicIsPlaying{
                    self.dataMusicplayer.pause()
                }
                self.musicPlayer.pause()
                
                
            }else if event!.subtype == UIEventSubtype.remoteControlPlay {
                
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
            var dic:[String : AnyObject] = [ MPMediaItemPropertyTitle : currentSongTitle as AnyObject,
                MPMediaItemPropertyArtist : currentSongArtist as AnyObject,
                MPMediaItemPropertyArtwork : mArt ]

            if dataMusicIsPlaying {
                let time = self.dataMusicplayer.currentTime
                let duration = self.dataMusicplayer.duration
                dic.updateValue(NSNumber(value: time as Double), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime )
                dic.updateValue(NSNumber(value: duration as Double), forKey: MPMediaItemPropertyPlaybackDuration)
                dic.updateValue(NSNumber(value: 1.0 as Float), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            }else{
                let time = self.musicPlayer.currentTime()
                let duration = self.musicPlayer.currentItem!.asset.duration
                dic.updateValue(NSNumber(value: CMTimeGetSeconds(time) as Double), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime )
                dic.updateValue(NSNumber(value: CMTimeGetSeconds(duration) as Double), forKey: MPMediaItemPropertyPlaybackDuration)
                dic.updateValue(NSNumber(value: 1.0 as Float), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
        }
    }
    
    
    //检查mark
    func checkTheMark(){
//        if isPlayOffline{
//            self.BTView.is1s = true
//        }else{
//            self.BTView.is1s = false
//        }
//        if isRandomPlayOnline{
//            self.BTView.is0s = true
//        }else{
//            self.BTView.is0s = false
//        }
//        if isRepeatPlay{
//            self.BTView.is2s = true
//        }else{
//            self.BTView.is2s = false
//        }
    }
    
    
    //更多按钮
    func setMoreBtn(){
        let items = ["随机播放喜欢的歌曲", "随机播放下载的歌曲", "单曲循环" ,"设置"]
        BTView = BTNavigationDropdownMenu(title: "", items: items as [AnyObject])
        BTView.arrowImage = UIImage(named: "ar")
        BTView.arrowPadding = -15
        BTView.cellHeight = 44
        BTView.cellSeparatorColor = UIColor.clear
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
                self.present((self.storyboard?.instantiateViewController(withIdentifier: "setView"))!, animated: true, completion: nil)
                
            default :
                break
            }
            
            self.checkTheMark()
        }
    
        self.moreBtn.customView = BTView
        
        
    }
    
    
    var currentIndex = CurrentDataSong.shareCurrentDataSong().index
    
    //下一首按钮
    @IBAction func btn(_ sender: UIButton) {
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
                    
                    let image = UIImage(data: nextSong.image! as Data)
                    setSongDetailForInterface(nextSong.id!,title:nextSong.title!, artistName: nextSong.artist!, image: image!)
                    self.dataMusicplayer = try! AVAudioPlayer(data: (nextSong.song)! as Data)
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
                self.loveBtn.setImage(UIImage(named: "no_love"), for: UIControlState())
                self.netWorkStack.getResult(getSongURL)
            }
        }
    }
    

    
    // MARK: - NetWorkStarkDelegate 相关方法
    func didGetResult(_ data: Data) {
        if dataMusicIsPlaying {
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
            if let jsonDic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
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
    
    func didGetError(_ err: Error?) {
        ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
    }
    
    
    
    //配置歌曲详情到界面
    
    func setSongDetailForInterface(_ id:String,title:String,artistName:String,image:UIImage){
        
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
        
        self.playBtn.isHidden = true
        self.blurView.isHidden = true
        
        self.currentSongTitle = title
        self.currentSongArtist = artistName
        self.currentSongPic = image
        self.currentSongId = id
        
        configNowPlayingInfoCenter()
        
        congfigureDetailView()
    }
    
    
    //判断播放的歌是不是喜欢的歌
    func isLoveSong(_ id:String){
        
        loveSongsArray = loveSongsHelper.loveSongs
        if loveSongsHelper.loveSongsID.contains(id){
            self.loveBtn.setImage(UIImage(named: "love"), for: UIControlState())
        }else{
            self.loveBtn.setImage(UIImage(named: "no_love"), for: UIControlState())
        }
        
    }
    
    //配置音乐播放器
    func fisrstConfigueMusicPlayer(){
        let playerItem = AVPlayerItem(url: URL(string: currentNetSong.url!)!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        musicPlayer = AVPlayer(playerItem: playerItem)
        let layer = AVPlayerLayer(player: musicPlayer)
        self.view.layer.addSublayer(layer)
        musicPlayer.play()
        
        self.setSongDetailForInterface(self.currentNetSong.songID!,title:self.currentNetSong.name!, artistName: self.currentNetSong.artistName!, image: self.currentNetSong.image)

        //后台播放
        var bgTask:UIBackgroundTaskIdentifier = 0
        if UIApplication.shared.applicationState == UIApplicationState.background {
            self.musicPlayer.play()
            let app:UIApplication = UIApplication.shared
            let newTask:UIBackgroundTaskIdentifier = app.beginBackgroundTask(expirationHandler: nil)
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
        
        let item = AVPlayerItem(url: URL(string: currentNetSong.url!)!)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        musicPlayer.replaceCurrentItem(with: item)
        musicPlayer.play()
        self.playBtn.isHidden = true
        self.blurView.isHidden = true
    }
    
    //当前在线歌曲播放完成之后接受通知自动开始播放下一首歌
    func playerItemDidReachEnd(_ aNotification:Notification){
        
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
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
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
    func didGetURL(_ url: String) {
        isPlayOffline = false
        getSongURL = url
        netWorkStack.getResult(url)
    }
    
    
    
    // MARK: - storyboard转场相关
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChanel"{
            let vc = segue.destination as! ChanelTableViewController
            vc.delegate = self
        }else if segue.identifier == "showSongList" {
            let nvc = segue.destination as! UINavigationController
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
    @IBAction func loveBtnClick(_ sender: UIButton) {
        
        if !isPlayOffline{
            sender.setImage(UIImage(named: "love"), for: UIControlState())
            
            let myGloQueue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
            myGloQueue.async { () -> Void in
                let data = try? Data(contentsOf: URL(string: self.currentNetSong.picURL!)!)
                if self.coreDataHelper.saveLoveSong(self.currentNetSong.songID!,title:self.currentNetSong.name!, artist: self.currentNetSong.artistName!, url: self.currentNetSong.url!, picURL: self.currentNetSong.picURL!, albumtitle: self.currentNetSong.albumtitle!, publicTime: self.currentNetSong.publicTime,imageData: data!){
                    DispatchQueue.main.async(execute: { () -> Void in
                        let alertView = UIAlertController(title: "喜欢", message: "添加成功", preferredStyle: UIAlertControllerStyle.alert)
                        alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertView, animated: true, completion: nil)
                    })
                }else{
                    DispatchQueue.main.async(execute: { () -> Void in
                        let alertView = UIAlertController(title: "喜欢", message: "该歌曲已存在", preferredStyle: UIAlertControllerStyle.alert)
                        alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertView, animated: true, completion: nil)
                    })
                }
            }
        }else{
            let alertView = UIAlertController(title: "", message: "正在使用离线播放", preferredStyle: UIAlertControllerStyle.alert)
            alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }
    }
} 


// MARK: - 暂停按钮
extension ViewController{
    
    @IBAction func pauseBtnClick(_ sender: UIButton) {
        if !isPlayOffline{
            self.musicPlayer.pause()
        }else{
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.rotationImage1.stopRotation()
        self.rotationImage2.stopRotation()
        self.animationImageView.stopAnimating()
        self.blurView.isHidden = false
        self.playBtn.isHidden = false
        self.playBtn.isEnabled = true
        self.needleAnimationNotBack()
    }
    
    func setPlayBtn(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView.frame = CGRect(x: -1, y: -1, width: 150, height: 150)
        self.blurView.layer.cornerRadius = 75
        self.blurView.layer.masksToBounds = true
        self.blurView.alpha = 0.8
        self.pauseBtn.addSubview(blurView)
        self.playBtn = UIButton(type: UIButtonType.system)
        self.playBtn.frame = CGRect(x: 45, y: 45, width: 60, height: 60)
        self.playBtn.addTarget(self, action: #selector(ViewController.playBtnClick), for: UIControlEvents.touchUpInside)
        
        self.playBtn.tintColor = UIColor.black
        self.playBtn.setImage(UIImage(named: "btn_playblack"), for: UIControlState())
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
        self.playBtn.isHidden = true
        self.blurView.isHidden = true
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
        rotation.isRemovedOnCompletion = false
        
        self.changPianZhen.layer.add(rotation, forKey: "rotation1")
        
    }
    
    func needleAnimationNoMove(){
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotation.duration = 0.8
        rotation.fromValue = -M_PI/8
        rotation.toValue = M_PI/40
        
        rotation.fillMode = kCAFillModeForwards
        rotation.isRemovedOnCompletion = false
        
        self.changPianZhen.layer.add(rotation, forKey: "rotation1")
        
    }
    
    
     func addSingleFingerOneClickForChangpianzhen(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.singleClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.bigBlurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func singleClick(){
        self.detailBlurView.isHidden = false
    }
    
}


// MARK: - 从喜欢的歌曲列表播放

extension ViewController:PassSongDetailDelegate{
    func didGetDetail(_ song: Song) {
        self.playOnlineMusic(song)
    }
}


// MARK: - 音乐播放相关扩展

extension ViewController{
    
    func playOfflineMusic(_ song:DownloadSong) {
        //isPlayOffline = true
        if dataMusicIsPlaying {
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.musicPlayer.pause()
        self.currentDataSong = song
        self.dataMusicplayer = try! AVAudioPlayer(data: song.song! as Data)
        self.dataMusicplayer.delegate = self
        self.dataMusicplayer.play()
        dataMusicIsPlaying = true
        self.setSongDetailForInterface(song.id! ,title: song.title!, artistName: song.artist!, image: UIImage(data: song.image! as Data)!)
        self.currentSongTitle = song.title
        self.currentSongId = song.id
    }
    
    func playOnlineMusic(_ song:Song){
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
        
        let playerItem = AVPlayerItem(url: URL(string: self.currentNetSong.url!)!)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        self.musicPlayer.replaceCurrentItem(with: playerItem)
        
        self.musicPlayer.play()
        self.setSongDetailForInterface(song.id! ,title: song.title!, artistName: song.artist!, image: UIImage(data: song.image! as Data)!)
        self.currentSongTitle = song.title
        self.currentSongId =  song.id
    }
    
    func playNetMusic(_ song:NetSong){
        isPlayOffline = false
        if dataMusicIsPlaying{
            self.dataMusicplayer.pause()
            dataMusicIsPlaying = false
        }
        self.musicPlayer.pause()
        let playerItem = AVPlayerItem(url: URL(string: self.currentNetSong.url!)!)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        self.musicPlayer.replaceCurrentItem(with: playerItem)
        
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
            
            Alamofire.request(url).responseData(completionHandler: { (data) in
                if data.error == nil {
                    if let jsonDic = try? JSONSerialization.jsonObject(with: data.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                        let json = JSON(jsonDic!)
                        let str = json["summary"].string
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.detailText.text = str! + "\n豆瓣音乐：http://m.douban.com/music/subject/\(self.currentSongId)"
                            
                        })
                    }
                }
            })
            
        }
    }
    
    func addSingleFingerOneClickForDetailBlurView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.detailSingleClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.detailBlurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func detailSingleClick(){
        self.detailBlurView.isHidden = true
        congfigureDetailView()
    }
    
}








