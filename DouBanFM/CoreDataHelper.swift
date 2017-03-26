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
    
    
    
    //搜索所有歌曲
    func searchAllSong() -> [Song]?{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        fr.sortDescriptors = [NSSortDescriptor(key: "play_count", ascending: false),NSSortDescriptor(key: "title", ascending: true)]
        
        if let result = try! context.fetch(fr) as? [Song]{
            return result
        }else{
            print("查询失败")
            return nil
        }
    }
    
    
    //按ID查询喜欢歌曲
    func searchSongWithID(_ id:String) -> Song{
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        let predicate = NSPredicate(format: "id == %@", id)
        fr.predicate = predicate
        let result = try! context.fetch(fr) as! [Song]
        return result[0]
    }
    
    
    
    
    
    /**
    查询歌曲中有没有某一首歌
    
    :param: name 歌名
    
    :returns: 返回歌曲数
    */
    
    func searchSongCountWithID(_ id:String) -> Int{
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        let predicate = NSPredicate(format: "id == %@", id)
        fr.predicate = predicate
        let result = try! context.count(for: fr)
        
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
    func saveLoveSong(_ id:String,title:String,artist:String,url:String,picURL:String,albumtitle:String,publicTime:String?,imageData:Data)->Bool{
        if searchSongCountWithID(id) == 0{
            let entity = NSEntityDescription.entity(forEntityName: "Song", in: self.context)
            let song = Song(entity: entity!, insertInto: self.context)
            song.title = title
            song.artist = artist
            song.url = url
            song.picture_url = picURL
            song.albumtitle = albumtitle
            song.is_favorite = true
            song.public_time = publicTime
            song.image = imageData
            song.play_count = NSNumber(value: 0 as Int32)
            song.id = id
            print("保存成功")
            appDelegate.saveContext()
            return true
        }else{
            print("这首歌已存在")
            return false
        }
    }
    
    
    //红心歌曲播放次数加1
    
    func loveSongPlayCountAdd(_ id:String){
        let song  = searchSongWithID(id)
        let count = song.play_count?.int32Value
        song.play_count = NSNumber(value: count! + 1 as Int32)
        
        appDelegate.saveContext()
        
    }
    
    
    
    
    
    
    
    
    // 保存下载歌曲
    
    func saveDldSong(_ id:String,title:String,artist:String,album:String,image:Data,song:Data){
        if seachDldSongWithID(id) == 0{
            let entity = NSEntityDescription.entity(forEntityName: "DownloadSong", in: context)
            let dldSong = DownloadSong(entity: entity!, insertInto: context)
            dldSong.title = title
            dldSong.artist = artist
            dldSong.album = album
            dldSong.image = image
            dldSong.song = song
            dldSong.id = id
            appDelegate.saveContext()
        }else{
            print("这首歌已下载")
        }
        
    }
    
    //按ID查询下载歌曲数
    func seachDldSongWithID(_ title:String) -> Int{
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadSong")
        fr.predicate = NSPredicate(format: "id == %@", title)
        let count = try! context.count(for: fr)
        return count
    }
    
    //查询所有下载歌曲
    func seachAllDldSong() -> [DownloadSong]{
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadSong")
        let result = try! context.fetch(fr) as! [DownloadSong]
        return result
    }
    //按ID查询下载的歌曲
    func seachTheDldSongWithID(_ id:String) -> DownloadSong{
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadSong")
        let predicate = NSPredicate(format: "id == %@", id)
        
        
        fr.predicate = predicate
        let result = try! context.fetch(fr) as! [DownloadSong]
        return result[0]
    }
    
    
    
    //删除喜欢歌曲
    
    func removeLoveSongWithIndex(_ index:Int){
        let songs = searchAllSong()
        let song = songs![index]
        context.delete(song)
        appDelegate.saveContext()
    }
    
    
    func removeLoveSongWithID(_ id:String){
        let song = searchSongWithID(id)
        context.delete(song)
        appDelegate.saveContext()
    }
    
    
    func removeAllLoveSong(){
        let songs = searchAllSong()
        for song in songs!{
            self.context.delete(song)
            self.appDelegate.saveContext()
        }
    }
    
    
    
    
    
    
    //删除下载歌曲
    
    func removeDldSongWithID(_ id:String){
        let song = seachTheDldSongWithID(id)
        context.delete(song)
        self.appDelegate.saveContext()
    }
    
    func removeAllDldSong(){
        let songs = seachAllDldSong()
        for song in songs{
            self.context.delete(song)
            self.appDelegate.saveContext()
        }
    }
    
    
    
    
}
