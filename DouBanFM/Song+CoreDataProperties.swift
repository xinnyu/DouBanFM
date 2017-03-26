//
//  Song+CoreDataProperties.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/15.
//  Copyright © 2015年 潘新宇. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Song {

    @NSManaged var albumtitle: String?
    @NSManaged var artist: String?
    @NSManaged var image: Data?
    @NSManaged var is_favorite: NSNumber?
    @NSManaged var picture_url: String?
    @NSManaged var play_count: NSNumber?
    @NSManaged var public_time: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var id: String?
    @NSManaged var chanel: Chanel?
    @NSManaged var singer: Singer?

}
