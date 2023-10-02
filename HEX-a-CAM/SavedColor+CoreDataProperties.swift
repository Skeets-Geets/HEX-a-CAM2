//
//  SavedColor+CoreDataProperties.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/1/23.
//
//

import Foundation
import CoreData


extension SavedColor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedColor> {
        return NSFetchRequest<SavedColor>(entityName: "SavedColor")
    }

    @NSManaged public var colorName: String?
    @NSManaged public var hexCode: String?

}

extension SavedColor : Identifiable {

}
