//
//  CurrentDataSong.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/12.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class CurrentDataSong: NSObject {

    var song:DownloadSong?
    var bool = false
    var index = 0
    
    
    struct singleTon {
        static var once_t:dispatch_once_t = 0
        static var currentDataSong:CurrentDataSong?
    }
    
    class func shareCurrentDataSong()->CurrentDataSong{
        dispatch_once(&singleTon.once_t) { () -> Void in
            singleTon.currentDataSong = CurrentDataSong()
        }
        return singleTon.currentDataSong!
    }
    
    
}
