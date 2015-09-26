//
//  EnemyNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 05.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class EnemyNode : AbstractEnemyNode {
    
    init() {
        super.init(vertices: [CGPoint(x: -20, y: 40), CGPoint(x: 20, y: 40)], defaultSpeed: 5, maxSpeed: CGFloat.max)
        
        let drillNode = SKShapeNode(rect: CGRect(x: -20, y: 20, width: 40, height: 20))
        drillNode.lineWidth = 0
        drillNode.fillColor = SKColor.grayColor()
        addChild(drillNode)
        
        let bodyNode = SKShapeNode(rect: CGRect(x: -20, y: -40, width: 40, height: 60))
        bodyNode.lineWidth = 0
        bodyNode.fillColor = SKColor.blueColor()
        addChild(bodyNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
