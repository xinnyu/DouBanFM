//
//  LoveSong.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/9.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class LoveSongsHelper: NSObject {
    
    class func shareLoveSong() -> LoveSongsHelper{
        dispatch_once(&singleTon.once_t) { () -> Void in
            singleTon.loveSong = LoveSongsHelper()
        }
        return singleTon.loveSong
    }
    
    struct singleTon {
        static var loveSong:LoveSongsHelper!
        static var once_t:dispatch_once_t = 0
    }
    
    
    var loveSongs:[Song]{
        let songs = coreDataHelper.searchAllSong()
        if songs!.count != 0{
            for song in songs! {
                loveSongsTitle.insert(song.title!)
            }
        }
        
        return coreDataHelper.searchAllSong()!
    }
    
    var loveSongsTitle:Set<String> = []
    
    var coreDataHelper = CoreDataHelper()
    
    override init(){
        super.init()
        
    }
    
}
