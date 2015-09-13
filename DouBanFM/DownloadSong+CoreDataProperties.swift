//
//  DownloadSong+CoreDataProperties.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/9.
//  Copyright © 2015年 潘新宇. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DownloadSong {

    @NSManaged var song: NSData?
    @NSManaged var image: NSData?
    @NSManaged var title: String?
    @NSManaged var artist: String?
    @NSManaged var album: String?

}
