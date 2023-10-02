//
//  CoreDataStack.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/1/23.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveColor(name: String, hexCode: String) {
        let color = NSEntityDescription.insertNewObject(forEntityName: "SavedColor", into: context) as! SavedColor
        color.colorName = name
        color.hexCode = hexCode

        saveContext()
    }

    
    func fetchSavedColors() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedColor")
        
        do {
            let savedColors = try context.fetch(fetchRequest)
            return savedColors
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
}
