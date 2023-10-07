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
    let gifFrames: [Image] // This array should contain all frames of your GIF as Image objects
    @State private var currentFrameIndex = 0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var menuScale: CGFloat = 0.01  // Add this state variable to handle scaling

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Close") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.menuScale = 0.01  // Scale down when the close button is pressed
                        isMenuVisible.toggle()
                        hexagonScale = 1.0
                    }
                }
                .padding()
            }

            Text("My Colors")
                .font(.largeTitle)
                .bold()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(0..<9) { _ in
                    SpinningHexagonScene()
                        .frame(width: 100, height: 100)
                        .background(Color.clear)
                }
            }
            Spacer()
        }
        .padding()
        .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
        .cornerRadius(20)
        .scaleEffect(menuScale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                self.menuScale = 1.0  // Scale up when the view appears
            }
        }
    }
}

struct MyColorsMenu_Previews: PreviewProvider {
    static var previews: some View {
        MyColorsMenu(
            isMenuVisible: .constant(true),
            hexagonScale: .constant(1.0),  // Dummy value for hexagonScale
            gifFrames: [Image("frame1"), Image("frame2")]
        )
    }
}
