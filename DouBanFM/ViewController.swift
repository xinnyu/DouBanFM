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


var isPlayOffline = false
var isFromDld = false
var dataMusicIsPlaying = false


class ViewController: UIViewController ,PassURLDelegate,NetWorkStarkDelegate,UIGestureRecognizerDelegate{
    
    //当前播放网络歌曲实例
    var currentNetSong = NetSong()
    
    //当前本地歌曲实例
    
    var currentDataSong = DownloadSong()
    
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
    
    
    
    //var musicPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
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
    var animationImageView = AnimationImageView.shareAnimationImageView()
    
    
    
    var dataMusicplayer = AVAudioPlayer()
    
    
    var playBtn:UIButton!
    
    var blurView:UIVisualEffectView!
    
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
        

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = color
        setMoreBtn()
        
        loveSongsArray = self.loveSongsHelper.loveSongs
        dldSongArray = self.dldSongHelper.dldSongs
        if isPlayOffline && isFromDld{
            let currentDataSong = CurrentDataSong.shareCurrentDataSong().song!
            let image = UIImage(data: currentDataSong.image!)
            
            setSongDetailForInterface(currentDataSong.title!, artistName: currentDataSong.artist!, image: image!)
            
            self.musicPlayer.pause()
            self.dataMusicplayer = try! AVAudioPlayer(data: (currentDataSong.song)!)
            self.dataMusicplayer.play()
            dataMusicIsPlaying = true
        }else{
            
        }
    }
    
    
    //更多按钮
    
    func setMoreBtn(){
        
        let items = ["随机播放喜欢的歌曲", "随机播放下载的歌曲", "单曲循环" ,"设置"]
        
        
        let view = BTNavigationDropdownMenu(title: "", items: items)
        
        view.arrowImage = UIImage(named: "ar")
        view.arrowPadding = -15
        view.cellHeight = 44
        view.cellSeparatorColor = UIColor.clearColor()
        
        view.cellBackgroundColor = color
        
        view.checkMarkImage = UIImage(named: "checkmark")
        self.moreBtn.customView = view
        
        view.didSelectItemAtIndexHandler = {(indexPath:Int) -> () in
            
            print(indexPath)
            switch indexPath{
            case 0 :
                print(0)
            case 1 :
                print(1)
            case 2 :
                print(2)
            case 3 :
                self.presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier("setView"))!, animated: true, completion: nil)
            default :
                break
            }
        }
    }
    
    
    
    
    
    var currentIndex = CurrentDataSong.shareCurrentDataSong().index
    //下一首按钮
    @IBAction func btn(sender: UIButton) {
        if isPlayOffline {
            print("本地播放下一首")
            
            currentIndex = currentIndex + 1
            
            if currentIndex > dldSongArray.count - 1{
                currentIndex = 0
            }
            
            dldSongArray = dldSongHelper.dldSongs
            
            let nextSong:DownloadSong = dldSongArray[currentIndex]
            
            print(nextSong.title!)
            
            
            let image = UIImage(data: nextSong.image!)
            
            setSongDetailForInterface(nextSong.title!, artistName: nextSong.artist!, image: image!)
            
            
            self.dataMusicplayer = try! AVAudioPlayer(data: (nextSong.song)!)
            self.dataMusicplayer.play()
            
            
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
                self.currentNetSong.publicTime = jsonArray![0]["public_time"].string!
                
                if self.musicPlayer == nil{
                    self.fisrstConfigueMusicPlayer()
                }else{
                    self.playNextSong()
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setSongDetailForInterface(self.currentNetSong.name!, artistName: self.currentNetSong.artistName!, image: self.currentNetSong.image)
                })
            }
    }
    
    //配置歌曲详情到界面
    
    func setSongDetailForInterface(title:String,artistName:String,image:UIImage){
        
        self.title = title
        self.navigationItem.prompt = artistName
        self.bgImage.image = image
        self.rotationImage1.image = image
        
        self.isLoveSong(title)
            
        self.rotationImage1.resumeRotation()
        self.rotationImage2.resumeRotation()
        self.rotationImage1.startRotation()
        self.rotationImage2.startRotation()
            
        self.needleAnimationNoMove()
        
        self.animationImageView.startAnimating()
        
        self.playBtn.hidden = true
        self.blurView.hidden = true
        
        
    }
    
    
    //判断播放的歌是不是喜欢的歌
    func isLoveSong(name:String){
        
        loveSongsArray = loveSongsHelper.loveSongs
        
        
        if loveSongsHelper.loveSongsTitle.contains(name){
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

        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
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
        
        rotationImage1.stopRotation()
        rotationImage2.stopRotation()
        self.netWorkStack.getResult(getSongURL)
        
        print("播放完了")
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

            vc.currentSongTitle = self.currentNetSong.name
            vc.loveSongArray = self.loveSongsHelper.loveSongs
            vc.dldSongArray = self.dldSongHelper.dldSongs
            vc.dldSongTitles = self.dldSongHelper.dldSongsTitle
            vc.passDetailDelegate = self
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
                if self.coreDataHelper.saveLoveSong(self.currentNetSong.name!, artist: self.currentNetSong.artistName!, url: self.currentNetSong.url!, picURL: self.currentNetSong.picURL!, albumtitle: self.currentNetSong.albumtitle!, publicTime: self.currentNetSong.publicTime!,imageData: data!){
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
        
        needleAnimationNotBack()
    }
    
    func setPlayBtn(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRectMake(-1, -1, 150, 150)
        blurView.layer.cornerRadius = 75
        blurView.layer.masksToBounds = true
        blurView.alpha = 0.8
        
        self.pauseBtn.addSubview(blurView)
        
        self.playBtn = UIButton(frame: CGRectMake(45, 45, 60, 60))
        self.playBtn.addTarget(self, action: "playBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        playBtn.tintColor = UIColor.blackColor()
        playBtn.setImage(UIImage(named: "btn_playblack"), forState: UIControlState.Normal)
        blurView.addSubview(playBtn)
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
        print("点击了")
    }
    
    
}


// MARK: - 从喜欢的歌曲列表播放

extension ViewController:PassSongDetailDelegate{
    func didGetDetail(song: Song) {
        
        if dataMusicIsPlaying{
            self.dataMusicplayer.pause()
        }
        
        
        currentNetSong.name = song.title
        currentNetSong.artistName = song.artist
        currentNetSong.picURL = song.picture_url
        currentNetSong.url = song.url
        currentNetSong.publicTime = song.public_time
        
        let playerItem = AVPlayerItem(URL: NSURL(string: song.url!)!)
        musicPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        musicPlayer.play()
        setSongDetailForInterface(song.title!, artistName: song.artist!, image: UIImage(data: song.image!)!)
        //print(loveSongs.loveSongsTitle)
    }
}



//extension ViewController{
//    func cdOut(){
////        self.rotationImage1.stopRotation()
////        self.rotationImage2.stopRotation()
//        
//        let moveAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionX)
//        moveAnimation.toValue = 450
//        moveAnimation.duration = 2
//        self.rotationImage2.layer.pop_addAnimation(moveAnimation, forKey: "move")
//        self.rotationImage1.layer.pop_addAnimation(moveAnimation, forKey: "move2")
//        
////        let moveAnimation2 = POPBasicAnimation(propertyNamed: kPOPLayerPositionX)
////        moveAnimation2.toValue = 300
////        moveAnimation2.fromValue = -100
////        //self.rotationImage2.layer.pop_addAnimation(moveAnimation2, forKey: "move")
////        self.rotationImage1.layer.pop_addAnimation(moveAnimation2, forKey: "move2")
//        
//        
//    }
//}




