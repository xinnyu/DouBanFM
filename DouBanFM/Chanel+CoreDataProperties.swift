//
//  Chanel+CoreDataProperties.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/6.
//  Copyright © 2015年 潘新宇. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Chanel {

    @NSManaged var name: String?
    @NSManaged var id: String?
    @NSManaged var songs: NSOrderedSet?

}
