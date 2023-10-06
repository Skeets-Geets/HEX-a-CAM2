//
//  MyScene.swift
//  HEX-a-CAM
//
//  Created by GEET on 10/4/23.
//

import Foundation
import SpriteKit

class MyScene: SKScene {
    var hexagon: SKShapeNode!
    var rotationAngle: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear  

        let path = UIBezierPath()
        let numberOfSides = 6
        for i in 0...numberOfSides {
            let theta = CGFloat(i) * (2.0 * .pi / CGFloat(numberOfSides))
            let x = cos(theta) * 100
            let y = sin(theta) * 100
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        hexagon = SKShapeNode(path: path.cgPath)
        hexagon.fillColor = .red
        hexagon.lineWidth = 0
        hexagon.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(hexagon)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let dx = location.x - previousLocation.x
        rotationAngle += dx * 0.05
        hexagon.xScale = cos(rotationAngle)
    }
}

