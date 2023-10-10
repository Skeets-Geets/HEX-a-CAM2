//
//  SpinningHexagonWrapper.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/6/23.
//



import SwiftUI

struct SpinningHexagonWrapper: View {
    @Binding var isSelected: Bool
    @Binding var rotationAngle: Double  // Make it a Binding
    var hexagonColor: Color  // Existing parameter
    var swatchImage: UIImage?  // New parameter for swatch image
    var colorInfo: ColorInfo  // New parameter for colorInfo

    var body: some View {
        GeometryReader { geometry in
            SpinningHexagonScene(colorInfo: colorInfo)  // Pass colorInfo here
                .background(
                    Image(uiImage: swatchImage ?? UIImage())  // Use swatch image as background
                        .resizable()
                )
                .foregroundColor(hexagonColor)  // Use the existing color
                .frame(width: isSelected ? 200 : 70, height: isSelected ? 200 : 70)
                .rotation3DEffect(.degrees(isSelected ? 360 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
        }
    }
}
