//
//  PlayerNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 03.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class PlayerNode : AbstractPlayerNode {
    
    // MARK: Initializers
    
    init() {
        super.init(vertices: [CGPoint(x: -20, y: -40), CGPoint(x: 20, y: -40)], defaultSpeed: 0.7, maxSpeed: CGFloat.max, maxDegree: 0.25*CGFloat.π)
        
        let drillNode = SKShapeNode(rect: CGRect(x: -20, y: -40, width: 40, height: 20))
        drillNode.lineWidth = 0
        drillNode.fillColor = SKColor.grayColor()
        addChild(drillNode)
        
        let bodyNode = SKShapeNode(rect: CGRect(x: -20, y: -20, width: 40, height: 60))
        bodyNode.lineWidth = 0
        bodyNode.fillColor = SKColor.redColor()
        addChild(bodyNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
