//
//  ColorExtensions.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/9/23.
//

import Foundation
import SwiftUI

extension UIColor {
    convenience init(_ color: SwiftUI.Color) {
        let components = color.components()
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
}

extension Color {
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0

        scanner.scanHexInt64(&hexNumber)

        let red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        let green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
        let blue = CGFloat(hexNumber & 0x0000FF) / 255

        return (red, green, blue, 1.0)
    }
}
