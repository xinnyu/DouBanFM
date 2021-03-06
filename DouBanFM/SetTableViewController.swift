//
//  SetTableViewController.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/14.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

var color = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)

let colors = [UIColor(red:0.97, green:0.97, blue:0.97, alpha:1),
    UIColor(red:1, green:0.8, blue:0.4, alpha:1),
    UIColor(red:0.4, green:1, blue:0.8, alpha:1),
    UIColor(red:0.4, green:0.8, blue:1, alpha:1),
    UIColor(red:0.97, green:0.37, blue:0.45, alpha:1),
    UIColor(red:0.06, green:1, blue:0.53, alpha:1),
    UIColor(red:0.28, green:0.89, blue:0.76, alpha:1),
    UIColor(red:0.72, green:0.92, blue:0.51, alpha:1),
    UIColor(red:0.45, green:0.9, blue:0.48, alpha:1)
]



class SetTableViewController: UITableViewController {
    
    let coreDataHelper = CoreDataHelper()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = color
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 1{
            //清除缓存
            
            let alert = UIAlertController(title: "清除缓存", message: "这个操作会删除掉所有已下载的歌曲和喜欢的歌曲", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认删除", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction) -> Void in
                self.coreDataHelper.removeAllDldSong()
                self.coreDataHelper.removeAllLoveSong()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    



    @IBAction func doneBtnClick(_ sender: UIBarButtonItem) {
        
        isFromDld = false
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func whiteBtnClick(_ sender: UIButton) {
        
        color = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        
        
    }
    
    @IBAction func yellowBtnClick(_ sender: UIButton) {
        
        color = UIColor(red:1, green:0.8, blue:0.4, alpha:1)
        UIView.animate(withDuration: 4, animations: { () -> Void in
            self.navigationController?.navigationBar.barTintColor = color
        }) 
        
    }
    
    @IBAction func blueBtnClick(_ sender: UIButton) {
        color = UIColor(red:0.4, green:0.8, blue:1, alpha:1)
        UIView.animate(withDuration: 4, animations: { () -> Void in
            self.navigationController?.navigationBar.barTintColor = color
        }) 
    }
    @IBAction func greenBtnClick(_ sender: UIButton) {
        color = UIColor(red:0.4, green:1, blue:0.8, alpha:1)
        UIView.animate(withDuration: 4, animations: { () -> Void in
            self.navigationController?.navigationBar.barTintColor = color
        }) 
    }

}
