//
//  SavedColor.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/1/23.
//

import Foundation

// Example Core Data Entity
@Entity
struct SavedColor: Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var hexCode: String
    @NSManaged public var colorName: String
}

// Example function to save a color
func saveColor(hexCode: String, colorName: String, context: NSManagedObjectContext) {
    let newColor = SavedColor(context: context)
    newColor.id = UUID()
    newColor.hexCode = hexCode
    newColor.colorName = colorName
    try? context.save()
}
