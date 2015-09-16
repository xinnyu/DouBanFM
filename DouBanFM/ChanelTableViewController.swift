//
//  ChanelTableViewController.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/6.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit
import CoreData
import MJRefresh

class ChanelTableViewController: UITableViewController, NetWorkStarkDelegate ,UINavigationControllerDelegate {
    
    
    //创建一个AppDelegate实例
    let appDelegate = AppDelegate.shareAppDelegate()
    
    //定义一个Chanel的数组
    var chanels:[Chanel] = []
    
    //定义NetWorkStark的实例
    let netWorkStack = NetWorkStark()
    
    //请求频道的URL
    let chanelsURL = "http://www.douban.com/j/app/radio/channels"
    
    //请求歌曲详情的URL
    var songsURL:String!
    
    var delegate:PassURLDelegate?
    
    //定义一个NSFetchedResultsController实例
    var fetchedResultsController:NSFetchedResultsController?

    @IBOutlet var backBtn: UIBarButtonItem!
    
    //频道列表界面返回按钮的点击事件
    
    
    // MARK: - 配置MJRefresh
    func configureMJRefresh(){
        self.tableView.header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.netWorkStack.getResult(self.chanelsURL)
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netWorkStack.delegate = self
        configureMJRefresh()
        getChanelFromCoreData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isFromDld = false
        let cells = tableView.visibleCells
        for cell in cells{
            cell.transform = CGAffineTransformMakeTranslation( UIScreen.mainScreen().bounds.size.width, 0)
        }
        
        for i in 0 ..< cells.count{
            UIView.animateWithDuration(0.3, delay: Double(i) * 0.1, usingSpringWithDamping: 14, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                cells[i].transform = CGAffineTransformMakeTranslation( 0, 0)
                }, completion: nil)
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
    
    // MARK: - 从CoreData中获取频道数据
    func getChanelFromCoreData(){
        let context = appDelegate.managedObjectContext
        let fr = NSFetchRequest(entityName: "Chanel")
        if let result = try! context.executeFetchRequest(fr) as? [Chanel] {
            chanels = result
            self.tableView.reloadData()
        }
    }

    
    
    
    
    // MARK: - NetWorkStarkDelegate
    
    func didGetResult(data: NSData) {
        removeAllChanelsToCoreData()
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Chanel", inManagedObjectContext: context)
        if let jsonDic = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
            print(jsonDic)
            let json = JSON(jsonDic)
            let chanelArray = json["channels"].array
            for chanel in chanelArray! {
                let name = chanel["name"].string
                let chanel = Chanel(entity: entity!, insertIntoManagedObjectContext: context)
                chanel.name = name
                appDelegate.saveContext()
                self.tableView.header.endRefreshing()
                self.getChanelFromCoreData()
            }
            
        }else{
            ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
        }
    }
    
    func didGetError(err: ErrorType?) {
        ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
    }
    
    
    
    
    
    
    //删除CoreData中的所有数据
    func removeAllChanelsToCoreData(){
        let context = appDelegate.managedObjectContext
        let fq = NSFetchRequest(entityName: "Chanel")

        if let result = try! context.executeFetchRequest(fq) as? [Chanel]{
            if result.count != 0 {
                for r in result{
                    context.deleteObject(r)
                }
//                let chanel = Chanel(entity: entity!, insertIntoManagedObjectContext: context)
//                chanel.name = name
//                appDelegate.saveContext()
            }else{
                print("没有数据！")
            }
        }
    }
    
    
    

    // MARK: - Table view data source



    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chanels.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)

        cell.textLabel?.text = chanels[indexPath.row].name

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.songsURL = "http://douban.fm/j/mine/playlist?type=n&channel=\(indexPath.row)&from=mainsite"
        delegate?.didGetURL(self.songsURL)
        
        isFromDld = false
        isPlayOffline = false
        isRandomPlayOnline = false
        isRandomPlayOffline = false
        self.navigationController?.popViewControllerAnimated(true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        isFromDld = false
        
    }
}



