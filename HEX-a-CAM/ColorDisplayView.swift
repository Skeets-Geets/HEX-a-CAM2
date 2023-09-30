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
                .font(.title)
                .padding(.top, 10)
                .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5), value: buttonOffset)
            Text(detectedHexColor)
                .bold()
                .font(.headline)
                .padding(.top, 10)
        }
        .onAppear {
            networkManager.fetchColorInfo(hex: detectedHexColor)
        }
    }
}
