//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 16/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var id: String?
    @NSManaged var photoData: NSData?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var pin: Pin?

}
