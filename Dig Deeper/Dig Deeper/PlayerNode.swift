//
//  PlayerNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 03.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class PlayerNode : BasePlayerNode {
    
    // MARK: Initializers
    
    init() {
        let vertices = [CGPoint(x: -35, y: -20), CGPoint(x: -25, y: 20), CGPoint(x: 25, y: 20), CGPoint(x: 35, y: -20)]
        
        super.init(vertices: vertices, maxSpeed: CGFloat.max, maxDegree: 0.25*CGFloat.π)
        currentSpeed = 150
        
        let drillNode = SKShapeNode(path: CGPath.pathOfVertices(vertices)!)
        drillNode.lineWidth = 0
        drillNode.fillColor = SKColor.blueColor()
        addChild(drillNode)
        
        let bodyNode = SKShapeNode(rect: CGRect(x: -25, y: 20, width: 50, height: 60))
        bodyNode.lineWidth = 0
        bodyNode.fillColor = SKColor.redColor()
        addChild(bodyNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
