//
//  MyColorsMenu.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//
import SwiftUI
import UIKit
import SpriteKit

struct MyColorsMenu: View {
    @Binding var isMenuVisible: Bool
    @Binding var hexagonScale: CGFloat
    let gifFrames: [Image]
    @State var menuScale: CGFloat = 0.01
    @State var selectedHexagon = false
    @State var rotationAngle: Double = 0
    @State var selectedIndex: Int? = nil
    @State var originalHexagonPositions: [Int: CGPoint] = [:]
    @State var rotationAngles: [Double] = Array(repeating: 0.0, count: 9)

    var body: some View {
        VStack {
            if selectedIndex == nil {
                Text("My Colors")
                    .font(.largeTitle)
                    .bold()
            }

            ZStack {
                if let index = selectedIndex {
                    SpinningHexagonWrapper(isSelected: .constant(true), rotationAngle: $rotationAngles[index])
                        .frame(width: 300, height: 300)
                        .background(Color.clear)
                        .zIndex(1)  // Make sure it appears above other elements
                        .onTapGesture {
                            withAnimation {
                                selectedIndex = nil
                            }
                        }
                        .position(x: (UIScreen.main.bounds.width / 2) - 15.0, y: 100)  // Fixed position at the center top of the menu

                    Button("Back") {
                        withAnimation {
                            selectedIndex = nil
                        }
                    }
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(Color.yellow)
                    .cornerRadius(90)
                    .position(x: 30, y: 360)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                            ForEach(0..<9) { index in
                                SpinningHexagonWrapper(isSelected: .constant(false), rotationAngle: $rotationAngles[index])
                                    .frame(width: 100, height: 100)
                                    .background(Color.clear)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedIndex = index
                                            rotationAngles[index] = 360.0
                                        }
                                    }
                                    .background(GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            originalHexagonPositions[index] = geometry.frame(in: .global).origin
                                        }
                                    })
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(height: 400)
            .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
            .cornerRadius(20)
            .scaleEffect(menuScale)
            .onAppear {
                withAnimation {
                    self.menuScale = 1.0
                }
            }
        }
    }
}


    struct MyColorsMenu_Previews: PreviewProvider {
        static var previews: some View {
            MyColorsMenu(
                isMenuVisible: .constant(true),
                hexagonScale: .constant(1.0),
                gifFrames: [Image("frame1"), Image("frame2")]
            )
        }
    }

