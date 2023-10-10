//
//  SpinningHexagonScene.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//

import SwiftUI
import SpriteKit

struct SpinningHexagonScene: UIViewRepresentable {
    var colorInfo: ColorInfo  // Add this line

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.backgroundColor = UIColor.clear  // Modify this line
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        let scene = MyScene(size: CGSize(width: 300, height: 300), colorInfo: colorInfo)  // Modify this line
        scene.backgroundColor = UIColor.clear  // Modify this line
        uiView.presentScene(scene)
    }
}

struct SpinningHexagonScene_Previews: PreviewProvider {
    static var previews: some View {
        SpinningHexagonScene(colorInfo: ColorInfo(colorName: "Red", hexCode: "#FF0000", color: Color.red))  // Modify this line
    }
}
