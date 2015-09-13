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
    
    var dldSongArray = [DownloadSong]()
    var dldSongHelper = DldSongsHelper.shareDldSongs()
    var dldSongTitles = Set<String>()
    
    
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
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.editButtonItem().tintColor = UIColor.blackColor()
        
        self.backBtn.customView = AnimationImageView.shareAnimationImageView()
        
        setFootView()
        
    }
    
    

    
    //设置tableView下面空白
    
    func setFootView(){
        let view = UIView()
        self.tableView.tableFooterView = view
    }
    
    
    
    
    
    //为跳动View添加点击事件
    
    func addSingleFingerOneClick(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleClick")
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.backBtn.customView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func singleClick(){
        isFromDld = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        addSingleFingerOneClick()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1{
            return loveSongArray.count
        }else if section == 0{
            return 1
        }else{
            return 0
        }
    }
    
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        

        if indexPath.section == 0{
            let dldCell = tableView.dequeueReusableCellWithIdentifier("dldMusicCell", forIndexPath: indexPath)
            dldCell.detailTextLabel?.text = "\(self.dldSongArray.count)首"
            return dldCell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! SongListCell
            cell.songImage.image = UIImage(data: loveSongArray[indexPath.row].image!)
            cell.songNameLabel.text = loveSongArray[indexPath.row].title
            cell.artistNameLabel.text = loveSongArray[indexPath.row].artist! + " - " + loveSongArray[indexPath.row].albumtitle!
            cell.dldBtn.tag = indexPath.row
            
            if self.dldSongTitles.contains(cell.songNameLabel.text!) {
                cell.dldBtn.setImage(UIImage(named: "cm2_icn_dlded"), forState: UIControlState.Normal)
                cell.dldBtn.enabled = false
            }else{
                cell.dldBtn.setImage(UIImage(named: "cm2_icn_dld"), forState: UIControlState.Normal)
                cell.dldBtn.enabled = true
            }
            
        
            
            cell.dldBtn.addTarget(self, action: "dldBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
        
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 26))
            let label = UILabel(frame: CGRectMake(8, 3, self.view.frame.width - 8, 20))
            view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
            label.text = "我喜欢的音乐(\(self.loveSongArray.count))"
            view.alpha = 0.9
            
            label.font = UIFont.systemFontOfSize(12)
            view.addSubview(label)
            return view
        }else{
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 26
        }else{
            return 0
        }
        
    }
    
    
    
    //下载按钮动作
    func dldBtnClick(sender:UIButton){
        print("\(sender.tag)")
        self.noticeTop("已加入下载", autoClear: true)
        let song = loveSongArray[sender.tag]
        let url = song.url
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let songData = NSData(contentsOfURL: NSURL(string: url!)!)!
            self.coreDataHelper.saveDldSong(song.title!, artist: song.artist!, album: song.albumtitle!, image: song.image!, song: songData)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.successNotice("下载完成", autoClear: true)
                sender.setImage(UIImage(named: "cm2_icn_dlded"), forState: UIControlState.Normal)
                sender.enabled = false
                self.dldSongArray = self.dldSongHelper.dldSongs
                self.dldSongTitles = self.dldSongHelper.dldSongsTitle
            })
        }
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == 1{
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongListCell
            let title = cell.songNameLabel.text!
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.coreDataHelper.loveSongPlayCountAdd(title)
            })
            
            
            
            isFromDld = false
            isPlayOffline = false
            
            self.dismissViewControllerAnimated(true, completion: nil)
            passDetailDelegate?.didGetDetail(loveSongArray[indexPath.row])
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 1{
            return true
        }else{
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.loveSongArray = LoveSongsHelper.shareLoveSong().loveSongs
            self.loveSongArray.removeAtIndex(indexPath.row)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongListCell
            let title = cell.songNameLabel.text!
            self.coreDataHelper.removeLoveSongWithTitle(title)
            
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDldTableView" {
            let vc = segue.destinationViewController as! DldSongListTableViewController
            self.dldSongArray = DldSongsHelper.shareDldSongs().dldSongs
            vc.dldSongs = self.dldSongArray
        }
        
    }


}




