//
//  CoreDataHelper.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/8.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    let appDelegate = AppDelegate.shareAppDelegate()
    
    var context:NSManagedObjectContext{
        return appDelegate.managedObjectContext
    }
    
    func searchAllSong() -> [Song]?{
        
        let fr = NSFetchRequest(entityName: "Song")
        if let result = try! context.executeFetchRequest(fr) as? [Song]{
            return result
        }else{
            print("查询失败")
            return nil
        }
    }
    
    
    /**
    查询歌曲中有没有某一首歌
    
    :param: name 歌名
    
    :returns: 返回歌曲数
    */
    
    func searchSongCountWithName(name:String) -> Int{
        let fr = NSFetchRequest(entityName: "Song")
        let predicate = NSPredicate(format: "title == %@", name)
        fr.predicate = predicate
        let result = context.countForFetchRequest(fr, error: nil)
        
        return result
    }
    
    
    
    /**
    保存红心歌曲到Coredata
    
    :param: title      歌曲名称
    :param: artist     歌手
    :param: url        歌曲url
    :param: picURL     图片utl
    :param: albumtitle 专辑名
    :param: publicTime 发行时间
    */
    func saveLoveSong(title:String,artist:String,url:String,picURL:String,albumtitle:String,publicTime:String,imageData:NSData)->Bool{
        if searchSongCountWithName(title) == 0{
            let entity = NSEntityDescription.entityForName("Song", inManagedObjectContext: self.context)
            let song = Song(entity: entity!, insertIntoManagedObjectContext: self.context)
            song.title = title
            song.artist = artist
            song.url = url
            song.picture_url = picURL
            song.albumtitle = albumtitle
            song.is_favorite = true
            song.public_time = publicTime
            song.image = imageData
            print("保存成功")
            appDelegate.saveContext()
            return true
        }else{
            print("这首歌已存在")
            return false
        }
    }
    
    // 保存下载歌曲
    
    func saveDldSong(title:String,artist:String,album:String,image:NSData,song:NSData){
        if seachDldSongWithTitle(title) == 0{
            let entity = NSEntityDescription.entityForName("DownloadSong", inManagedObjectContext: context)
            let dldSong = DownloadSong(entity: entity!, insertIntoManagedObjectContext: context)
            dldSong.title = title
            dldSong.artist = artist
            dldSong.album = album
            dldSong.image = image
            dldSong.song = song
            
            appDelegate.saveContext()
        }else{
            print("这首歌已下载")
        }
        
    }
    
    //查询下载歌曲
    func seachDldSongWithTitle(title:String) -> Int{
        let fr = NSFetchRequest(entityName: "DownloadSong")
        fr.predicate = NSPredicate(format: "title == %@", title)
        let count = context.countForFetchRequest(fr, error: nil)
        return count
    }
    
    
    func seachAllDldSong() -> [DownloadSong]{
        let fr = NSFetchRequest(entityName: "DownloadSong")
        let result = try! context.executeFetchRequest(fr) as! [DownloadSong]
        return result
    }
    
    
}
