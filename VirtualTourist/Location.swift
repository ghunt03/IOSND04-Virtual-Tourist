//
//  Location.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 9/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
import CoreData


class Location: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(latitude:Double, longitude:Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Location", inManagedObjectContext: context) {
            self.init(entity:ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find entity name!")
        }
    }
    
    
}
