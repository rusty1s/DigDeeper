//
//  AbstractPlayerNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class AbstractPlayerNode : AbstractMovingNode {
    
    // MARK: Initializers
    
    init(vertices: [CGPoint], defaultSpeed: CGFloat, maxSpeed: CGFloat, maxDegree: CGFloat) {
        super.init(vertices: vertices, defaultSpeed: defaultSpeed, maxSpeed: maxSpeed)
        self.maxDegree = maxDegree
        
        name = "player"
    
        /*physicsBody = SKPhysicsBody(polygonFromPath: CGPath.pathOfVertices(vertices)!)
        physicsBody?.categoryBitMask = GameScene.BitMask.player
        physicsBody?.contactTestBitMask = GameScene.BitMask.enemy
        physicsBody?.collisionBitMask = GameScene.BitMask.nothing
        
        physicsBody?.allowsRotation = false
        physicsBody?.mass = 1
        physicsBody?.friction = 0
        physicsBody?.restitution = 2
        physicsBody?.angularDamping = 0
        physicsBody?.linearDamping = 1*/
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    final var maxDegree: CGFloat {
        set { _maxDegree = min(abs(newValue), 0.5*CGFloat.π) }
        get { return _maxDegree }
    }
    private var _maxDegree: CGFloat = 0.5*CGFloat.π
}
