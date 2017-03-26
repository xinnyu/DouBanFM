//
//  PassURLDelegate.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/7.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import Foundation


protocol PassURLDelegate{
    func didGetURL(_ url:String)
}


protocol PassSongDetailDelegate{
    func didGetDetail(_ song:Song)
}


protocol PassDldSongDelegate{
    func didGetDldSong(_ song:DownloadSong,isPlayOnline:Bool)
}
