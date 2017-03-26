//
//  LoveSong.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/9.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class LoveSongsHelper: NSObject {
    
    private static var __once: () = { () -> Void in
            singleTon.loveSong = LoveSongsHelper()
        }()
    
    class func shareLoveSong() -> LoveSongsHelper{
        _ = LoveSongsHelper.__once
        return singleTon.loveSong
    }
    
    struct singleTon {
        static var loveSong:LoveSongsHelper!
        static var once_t:Int = 0
    }
    
    
    var loveSongs:[Song]{
        let songs = coreDataHelper.searchAllSong()
        if songs!.count != 0{
            for song in songs! {
                loveSongsID.insert(song.id!)
            }
        }
        
        return coreDataHelper.searchAllSong()!
    }
    
    var loveSongsID:Set<String> = []
    
    var coreDataHelper = CoreDataHelper()
    
    override init(){
        super.init()
        
    }
    
}
