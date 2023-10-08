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

    var body: some View {
        GeometryReader { geometry in
            SpinningHexagonScene()
                .frame(width: isSelected ? 300 : 100, height: isSelected ? 300 : 100)
                .rotation3DEffect(.degrees(isSelected ? 360 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
        }
    }
}

