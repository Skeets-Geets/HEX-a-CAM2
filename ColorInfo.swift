//
//  ColorInfo.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/8/23.
//

import SwiftUI
import Foundation

struct ColorInfo: Hashable {
    var id: UUID
    let colorName: String
    let hexCode: String
    let color: Color

    init(colorName: String, hexCode: String, color: Color) {
        self.id = UUID()
        self.colorName = colorName
        self.hexCode = hexCode
        self.color = color
    }
}

