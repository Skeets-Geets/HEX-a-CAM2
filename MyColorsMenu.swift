//
//  MyColorsMenu.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//
//
//  MyColorsMenu.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//
import SwiftUI
import UIKit
import SpriteKit

struct HexagonRow: View {
    var colorInfo: ColorInfo
    @Binding var selectedIndex: UUID?
    @Binding var rotationAngle: Double
    @State var originalPosition: CGPoint? = nil

    var body: some View {
        VStack {
            SpinningHexagonWrapper(isSelected: .constant(selectedIndex == colorInfo.id), rotationAngle: $rotationAngle, hexagonColor: colorInfo.color, swatchImage: nil, colorInfo: colorInfo)
                .frame(width: selectedIndex == colorInfo.id ? 200 : 70, height: selectedIndex == colorInfo.id ? 200 : 70)
                .background(Color.clear)
                .onTapGesture {
                    withAnimation {
                        selectedIndex = colorInfo.id
                    }
                }
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        self.originalPosition = geometry.frame(in: .global).origin
                    }
                })
                .animation(.spring(), value: selectedIndex)

            Text(colorInfo.colorName)
                .font(.caption)
                .foregroundColor(.white)
                .opacity(selectedIndex == nil || selectedIndex == colorInfo.id ? 1 : 0)

            Text(colorInfo.hexCode)
                .font(.caption)
                .foregroundColor(.white)
                .opacity(selectedIndex == nil || selectedIndex == colorInfo.id ? 1 : 0)
        }
    }
}


struct MyColorsMenu: View {
    @Binding var isMenuVisible: Bool
    @Binding var hexagonScale: CGFloat
    let gifFrames: [Image] // New property

    @State var menuScale: CGFloat = 0.01
    @State var selectedHexagon = false
    @State var rotationAngle: Double = 0
    @State var selectedIndex: UUID? = nil
    @Binding var savedColors: [ColorInfo]?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Close") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.menuScale = 0.01
                        isMenuVisible.toggle()
                        hexagonScale = 1.0
                    }
                }
                .padding()
            }

            Text("My Colors")
                .font(.largeTitle)
                .bold()
                .opacity(selectedIndex == nil ? 1 : 0)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(savedColors ?? [], id: \.self) { colorInfo in
                    HexagonRow(colorInfo: colorInfo, selectedIndex: $selectedIndex, rotationAngle: $rotationAngle)
                }
            }
            .padding()
            .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
            .cornerRadius(20)
            .scaleEffect(menuScale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                    self.menuScale = 1.0
                }
            }
        }
    }
}
