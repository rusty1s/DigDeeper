//
//  BaseEnemyNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 02.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class BaseEnemyNode : BaseMovingNode {
    
    // MARK: Initializers
    
    override init(vertices: [CGPoint], maxSpeed: CGFloat) {
        super.init(vertices: vertices, maxSpeed: maxSpeed)
        
        name = "enemy"
        
        physicsBody = SKPhysicsBody(polygonFromPath: CGPath.pathOfVertices(vertices)!)
        physicsBody?.categoryBitMask = GameScene.BitMask.enemy
        physicsBody?.contactTestBitMask = GameScene.BitMask.player
        physicsBody?.collisionBitMask = GameScene.BitMask.nothing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
