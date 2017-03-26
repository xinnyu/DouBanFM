//
//  NetSong.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/7.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class NetSong: NSObject {
    
    var name:String?
    var artistName:String?
    var url:String?
    var picURL:String?
    var songID:String?
    var publicTime:String?
    var albumtitle:String?
    
    
    
    var image:UIImage {
        if picURL != nil{
            return UIImage(data: try! Data(contentsOf: URL(string: picURL!)!))!
        }else{
            return UIImage(named: "cutegirl")!
        }
    }
}
