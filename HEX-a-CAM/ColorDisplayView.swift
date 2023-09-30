//
//  ColorDisplayView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/29/23.
//

import Foundation


import SwiftUI

struct ColorDisplayView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var buttonOffset: CGFloat = 0
    var detectedHexColor: String

    var body: some View {
        VStack {
            if let colorImage = networkManager.colorImage {
                Image(uiImage: colorImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                
            }
            Text(networkManager.colorName)
                .bold()
                .font(.system(size: 35, weight: .semibold, design: .default))
                .padding(.top, 40)
                .kerning(2.0)
            Text(detectedHexColor)
                .bold()
                .font(.system(size: 22, weight: .thin, design: .default))
                .padding(.top, 25)  // Increased padding value to move text further down
                .kerning(2.0)
        }
        .onAppear {
            networkManager.fetchColorInfo(hex: detectedHexColor)
        }
    }
}
