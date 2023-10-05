//
//  Item.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//

// Item.swift

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    @NSManaged public var timestamp: Date
}

// Create a CoreData-compatible initializer
extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
}

