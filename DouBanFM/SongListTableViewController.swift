//
//  SongListTableViewController.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/7.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import AVKit
import Alamofire
import MJRefresh

class SongListTableViewController: UITableViewController, UIGestureRecognizerDelegate{

    var loveSongArray = [Song]()
    
     var currentSongTitle:String?
    
    var currentSongID:String?
    
    var dldSongArray = [DownloadSong]()
    
    var dldSongHelper = DldSongsHelper.shareDldSongs()
    
    var dldSongsID = Set<String>()
    
    
    @IBOutlet var backBtn: UIBarButtonItem!
    
    let appDelegate = AppDelegate.shareAppDelegate()
    
    var passDetailDelegate:PassSongDetailDelegate?
    
    let coreDataHelper = CoreDataHelper()
    
    let networkStack = NetWorkStark()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.editButtonItem.tintColor = UIColor.black
        
        self.backBtn.customView = AnimationImageView.shareAnimationImageView()
        
        setFootView()
        
        configureBackBtn()
        
    }
    
    //设置返回按钮
    func configureBackBtn(){
        let backItem = UIBarButtonItem()
        backItem.title = " "
        self.navigationItem.backBarButtonItem = backItem
        //self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        //自定义图片
//        let image = UIImage(named: "cm2_top_icn_back_prs")
//        image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
//        self.navigationController?.navigationBar.backIndicatorImage = image
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        
    }

    
    //设置tableView下面空白
    
    func setFootView(){
        let view = UIView()
        self.tableView.tableFooterView = view
    }
    
    
    
    
    
    //为跳动View添加点击事件
    
    func addSingleFingerOneClick(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SongListTableViewController.singleClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.backBtn.customView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func singleClick(){
        isFromDld = false
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addSingleFingerOneClick()
        self.navigationController?.navigationBar.barTintColor = color
        tableView.reloadData()
    }
    
    

    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1{
            return loveSongArray.count
        }else if section == 0{
            return 1
        }else{
            return 0
        }
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let dldCell = tableView.dequeueReusableCell(withIdentifier: "dldMusicCell", for: indexPath)
            dldCell.detailTextLabel?.text = "\(self.dldSongArray.count)首"
            return dldCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! SongListCell
            cell.songImage.image = UIImage(data: loveSongArray[indexPath.row].image! as Data)
            cell.songNameLabel.text = loveSongArray[indexPath.row].title
            cell.artistNameLabel.text = loveSongArray[indexPath.row].artist! + " - " + loveSongArray[indexPath.row].albumtitle!
            cell.dldBtn.tag = indexPath.row
            
            self.loveSongArray = LoveSongsHelper.shareLoveSong().loveSongs
            let song = loveSongArray[indexPath.row]
            let id = song.id
            
            if id == self.currentSongID {
                cell.playMask.isHidden = false
                
                let image = UIImage(named: "cm2_discover_icn_idol")
                let image1 = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.playMask.image = image1
                
                if color != UIColor(red:0.97, green:0.97, blue:0.97, alpha:1){
                    cell.playMask.tintColor = color
                }
                
//                cell.playMask.animationImages = [UIImage(named: "cm2_top_icn_playing_prs")!,
//                    UIImage(named: "cm2_top_icn_playing2_prs")!,
//                    UIImage(named: "cm2_top_icn_playing3_prs")!,
//                    UIImage(named: "cm2_top_icn_playing4_prs")!,
//                    UIImage(named: "cm2_top_icn_playing5_prs")!,
//                    UIImage(named: "cm2_top_icn_playing6_prs")!]
//                cell.playMask.animationDuration = 1.5
                
//                cell.playMask.startAnimating()
            }else{
                cell.playMask.isHidden = true
            }
            
            if self.dldSongsID.contains(id!) {
                cell.dldBtn.setImage(UIImage(named: "cm2_icn_dlded"), for: UIControlState())
                cell.dldBtn.isEnabled = false
            }else{
                cell.dldBtn.setImage(UIImage(named: "cm2_icn_dld"), for: UIControlState())
                cell.dldBtn.isEnabled = true
            }
            
            cell.dldBtn.addTarget(self, action: #selector(SongListTableViewController.dldBtnClick(_:)), for: UIControlEvents.touchUpInside)
            return cell
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 26))
            let label = UILabel(frame: CGRect(x: 8, y: 3, width: self.view.frame.width - 8, height: 20))
            view.backgroundColor = color
            label.text = "我喜欢的音乐(\(self.loveSongArray.count))"
            view.alpha = 0.5
            
            label.font = UIFont.systemFont(ofSize: 12)
            view.addSubview(label)
            return view
        }else{
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 26
        }else{
            return 0
        }
        
    }
    
    
    
    //下载按钮动作
    func dldBtnClick(_ sender:UIButton){
        print("\(sender.tag)")
        self.noticeTop("已加入下载", autoClear: true)
        self.loveSongArray = LoveSongsHelper.shareLoveSong().loveSongs
        let song = loveSongArray[sender.tag]
        let url = song.url
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            let songData = try! Data(contentsOf: URL(string: url!)!)
            self.coreDataHelper.saveDldSong(song.id!,title: song.title!, artist: song.artist!, album: song.albumtitle!, image: song.image!, song: songData)
            DispatchQueue.main.async(execute: { () -> Void in
                self.successNotice("下载完成", autoClear: true)
                sender.setImage(UIImage(named: "cm2_icn_dlded"), for: UIControlState())
                sender.isEnabled = false
                self.dldSongArray = self.dldSongHelper.dldSongs
                self.dldSongsID = self.dldSongHelper.dldSongsID
                self.tableView.reloadData()
            })
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 1{
            
            self.loveSongArray = LoveSongsHelper.shareLoveSong().loveSongs
            
            let id = self.loveSongArray[indexPath.row].id
            print(id)
            
            if id == currentSongID {
                isFromDld = false
                isPlayOffline = false
                dismiss(animated: true, completion: nil)
            }else{
                isFromDld = false
                isPlayOffline = false
                self.dismiss(animated: true, completion: nil)
                passDetailDelegate?.didGetDetail(loveSongArray[indexPath.row])
            }
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                self.coreDataHelper.loveSongPlayCountAdd(id!)
                print(1)
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 1{
            return true
        }else{
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.loveSongArray = LoveSongsHelper.shareLoveSong().loveSongs
            
            let id  = self.loveSongArray[indexPath.row].id
            
            self.loveSongArray.remove(at: indexPath.row)
            //print(loveSongArray.count)
            self.coreDataHelper.removeLoveSongWithID(id!)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDldTableView" {
            let vc = segue.destination as! DldSongListTableViewController
            self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
            vc.dldSongs = self.dldSongArray
            vc.currentSongID = self.currentSongID
            
        }
        
    }


}




