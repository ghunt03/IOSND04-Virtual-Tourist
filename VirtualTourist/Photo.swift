//
//  Photo.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 11/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(id: String, photoURL: String, title: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity:ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.url = photoURL
            self.title = title
        } else {
            fatalError("Unable to find entity name!")
        }
    }
}
