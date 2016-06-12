//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 12/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photo: NSSet?

}
