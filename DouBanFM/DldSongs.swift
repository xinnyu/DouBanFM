//
//  DldSongs.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/11.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class DldSongsHelper: NSObject {
    
    private static var __once: () = { () -> Void in
            singleTon.dldSongs = DldSongsHelper()
        }()
    
    let coreDataHelper = CoreDataHelper()
    
    var dldSongsID:Set<String> = []
    
    class func shareDldSongs() -> DldSongsHelper {
        _ = DldSongsHelper.__once
        return singleTon.dldSongs!
    }
    
    struct singleTon {
        static var dldSongs:DldSongsHelper?
        static var once_t:Int = 0
    }
    
    var dldSongs:[DownloadSong]{
        for song in coreDataHelper.seachAllDldSong(){
            dldSongsID.insert(song.id!)
        }
        
        return coreDataHelper.seachAllDldSong()
    }
}
