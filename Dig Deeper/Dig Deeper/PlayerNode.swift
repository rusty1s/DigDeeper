//
//  PlayerNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class PlayerNode : MovingNode {
    
    // MARK: Initializers
    
    init() {
        super.init(texture: nil, color: SKColor.redColor(), size: CGSize(width: 50, height: 100))
        
        name = "player"
        
        maxSpeed = CGFloat.max
        currentSpeed = 150
        maxDegree = 0.25*CGFloat.π
        
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 50, height: 100))
        physicsBody?.allowsRotation = false
        physicsBody?.mass = 1
        physicsBody?.friction = 0
        physicsBody?.restitution = 2
        physicsBody?.angularDamping = 0
        physicsBody?.linearDamping = 1
        
        physicsBody?.categoryBitMask = 0x1 << 1
        physicsBody?.contactTestBitMask = 0x1 << 2
        physicsBody?.collisionBitMask = 0x1 << 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    var maxDegree: CGFloat {
        set { _maxDegree = abs(newValue) }
        get { return _maxDegree }
    }
    private var _maxDegree: CGFloat = 0.5*CGFloat.π
    
    override var vertices: [CGPoint] {
        return [CGPoint(x: -25, y: -50), CGPoint(x: -25, y: 50), CGPoint(x: 25, y: 50), CGPoint(x: 25, y: -50)]
    }
}
