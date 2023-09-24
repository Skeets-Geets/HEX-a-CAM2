//
//  HEX_a_CAMApp.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//

import SwiftUI

@main
struct HEX_a_CAMApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
//test
