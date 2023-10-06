//
//  ColorDisplayView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/29/23.
//

import SwiftUI


struct StrokedButton: View {
    var title: String
    var action: () -> Void
    var strokeColor: Color
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .frame(width: 145, height: 30)
                    .cornerRadius(30)
                Text(title)
                    .foregroundColor(.primary)
                    .bold()
                    .kerning(2.0)
            }
            .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(strokeColor, lineWidth: 2))
        }
    }
}


struct ColorDisplayView: View {
    @ObservedObject var networkManager: NetworkManager
    var detectedHexColor: String
    var strokeColor: Color
    
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
                .padding(.top, 25)
                .kerning(2.0)
        }
        .onAppear {
            networkManager.fetchColorInfo(hex: detectedHexColor)
        }
        .zIndex(2)
    }
}
