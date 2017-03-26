//
//  CurrentDataSong.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/12.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class CurrentDataSong: NSObject {

    private static var __once: () = { () -> Void in
            singleTon.currentDataSong = CurrentDataSong()
        }()

    var song:DownloadSong?
    var bool = false
    var index = 0
    
    
    struct singleTon {
        static var once_t:Int = 0
        static var currentDataSong:CurrentDataSong?
    }
    
    class func shareCurrentDataSong()->CurrentDataSong{
        _ = CurrentDataSong.__once
        return singleTon.currentDataSong!
    }
    
    
}
