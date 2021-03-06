//
//  DldSongListTableViewController.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/11.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class DldSongListTableViewController: UITableViewController,UIGestureRecognizerDelegate {

    var dldSongs:[DownloadSong]?
    
    var delegate:PassDldSongDelegate?
    
    var coreDataHelper:CoreDataHelper = CoreDataHelper()
    
    var currentSongID:String!
    
    @IBOutlet var animationBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        configureAnimationBtn()
        setFootView()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationItem.backBarButtonItem?.title = " "
        
    }
    
    func setFootView(){
        let view = UIView()
        self.tableView.tableFooterView = view
    }

    func configureAnimationBtn(){
        animationBtn.customView = AnimationImageView.shareAnimationImageView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DldSongListTableViewController.singleClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        self.animationBtn.customView?.addGestureRecognizer(tapGestureRecognizer)
        
    }

    func singleClick(){
        isFromDld = false
        dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dldSongs!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dldCell", for: indexPath) as! DldSongListCell
        cell.markImage.isHidden = true
        cell.numLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = dldSongs![indexPath.row].title
        cell.artistLabel.text = dldSongs![indexPath.row].artist
        
        
        self.dldSongs = DldSongsHelper.shareDldSongs().dldSongs
        let id  = dldSongs![indexPath.row].id
        
        if id == currentSongID{
            let image = UIImage(named: "cm2_discover_icn_idol")
            let image1 = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.markImage.image = image1
            if color != UIColor(red:0.97, green:0.97, blue:0.97, alpha:1){
                cell.markImage.tintColor = color
            }
            cell.numLabel.isHidden = true
            cell.markImage.isHidden = false
            
        }else{
            cell.numLabel.isHidden = false
            cell.markImage.isHidden = true
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isPlayOffline = true
        isFromDld = true
        
        
        let song = CurrentDataSong.shareCurrentDataSong()
        song.song = dldSongs![indexPath.row]
        song.index = indexPath.row
        
        dismiss(animated: true, completion: nil)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        //let cell = tableView.dequeueReusableCellWithIdentifier("dldCell", forIndexPath: indexPath) as! DldSongListCell
        
        return true
        
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dldSongs = DldSongsHelper.shareDldSongs().dldSongs
            
            let id = self.dldSongs![indexPath.row].id
            
            self.dldSongs!.remove(at: indexPath.row)
            
            
            self.coreDataHelper.removeDldSongWithID(id!)
            
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
