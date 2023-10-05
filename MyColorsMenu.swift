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
    @Binding var isMenuVisible: Bool  // To control the visibility of the menu
    @Binding var hexagonScale: CGFloat  // To control the hexagon scale
    let gifFrames: [Image]  // This array should contain all frames of your GIF as Image objects
    @State private var currentFrameIndex = 0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Close") {
                    withAnimation(.spring()) {
                        isMenuVisible = false
                        hexagonScale = 1.0
                    }
                }
                .padding()
            }
            
            Text("My Colors")
                .font(.largeTitle)
                .bold()
            
            SpinningHexagonScene()
                .ignoresSafeArea(.all)
                .frame(width: 100, height: 100)
                .background(.clear)
                .gesture(
                    DragGesture().onChanged { value in
                    }
                )
            
            Spacer()
        }
        .padding()
        .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
        .cornerRadius(20)
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
