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
import SwiftyJSON

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
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?

    @IBOutlet var backBtn: UIBarButtonItem!
    
    //频道列表界面返回按钮的点击事件
    
    
    // MARK: - 配置MJRefresh
    func configureMJRefresh(){
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.netWorkStack.getResult(self.chanelsURL)
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netWorkStack.delegate = self
        configureMJRefresh()
        getChanelFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFromDld = false
        let cells = tableView.visibleCells
        for cell in cells{
            cell.transform = CGAffineTransform( translationX: UIScreen.main.bounds.size.width, y: 0)
        }
        
        for i in 0 ..< cells.count{
            UIView.animate(withDuration: 0.3, delay: Double(i) * 0.1, usingSpringWithDamping: 14, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: { () -> Void in
                cells[i].transform = CGAffineTransform( translationX: 0, y: 0)
                }, completion: nil)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    
    // MARK: - 从CoreData中获取频道数据
    func getChanelFromCoreData(){
        let context = appDelegate.managedObjectContext
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Chanel")
        if let result = try! context.fetch(fr) as? [Chanel] {
            chanels = result
            self.tableView.reloadData()
        }
    }

    
    
    
    
    // MARK: - NetWorkStarkDelegate
    
    func didGetResult(_ data: Data) {
        removeAllChanelsToCoreData()
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Chanel", in: context)
        if let jsonDic = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
            print(jsonDic)
            let json = JSON(jsonDic)
            let chanelArray = json["channels"].array
            for chanel in chanelArray! {
                let name = chanel["name"].string
                let chanel = Chanel(entity: entity!, insertInto: context)
                chanel.name = name
                appDelegate.saveContext()
                self.tableView.mj_header.endRefreshing()
                self.getChanelFromCoreData()
            }
            
        }else{
            ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
        }
    }
    
    func didGetError(_ err: Error?) {
        ProgressHUD.showError("网络连接错误，可以播放已下载的歌曲", interaction: true)
    }
    
    
    
    
    
    
    //删除CoreData中的所有数据
    func removeAllChanelsToCoreData(){
        let context = appDelegate.managedObjectContext
        let fq = NSFetchRequest<NSFetchRequestResult>(entityName: "Chanel")

        if let result = try! context.fetch(fq) as? [Chanel]{
            if result.count != 0 {
                for r in result{
                    context.delete(r)
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



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chanels.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        cell.textLabel?.text = chanels[indexPath.row].name

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.songsURL = "http://douban.fm/j/mine/playlist?type=n&channel=\(indexPath.row)&from=mainsite"
        delegate?.didGetURL(self.songsURL)
        
        isFromDld = false
        isPlayOffline = false
        isRandomPlayOnline = false
        isRandomPlayOffline = false
        self.navigationController?.popViewController(animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        isFromDld = false
        
    }
}



