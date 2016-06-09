//
//  Location+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 9/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

}
