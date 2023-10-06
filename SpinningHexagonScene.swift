//
//  SpinningHexagonScene.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//


import SwiftUI
import SpriteKit

struct SpinningHexagonScene: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.backgroundColor = .clear
        return view
        
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
           let scene = MyScene(size: CGSize(width: 300, height: 300))
           scene.backgroundColor = .clear
           uiView.presentScene(scene)
       }
   }

struct SpinningHexagonScene_Previews: PreviewProvider {
    static var previews: some View {
        SpinningHexagonScene()
    }
}
