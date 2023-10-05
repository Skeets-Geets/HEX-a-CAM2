//
//  HEX_a_CAMApp.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//

import SwiftUI

@main
struct HEX_a_CAMApp: App {
    var cameraViewModel = CameraViewModel() // Create an instance of CameraViewModel
    
    var body: some Scene {
        WindowGroup {
            ContentView(cameraViewModel: cameraViewModel) // Pass the instance here
        }
    }
}
//test
