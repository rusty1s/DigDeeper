//
//  MovingNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 24.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit

class MovingNode : SKSpriteNode, ContactNode {
    
    // MARK: Attributes
    
    private var maxSpeed_: CGFloat = CGFloat.max
    var maxSpeed: CGFloat {
    set {
        maxSpeed_ = max(newValue, 0)
        actSpeed_ = min(actSpeed_, maxSpeed_)
    }
    get { return maxSpeed_ }
    }
    
    private var actSpeed_: CGFloat = 0
    var actSpeed: CGFloat {
    set { actSpeed_ = max (min(newValue, maxSpeed), 0) }
    get { return actSpeed_ }
    }
    
    var vertices: [CGPoint] {
        let direction = CGVector(dx: sin(zRotation), dy: -cos(zRotation))
        let y = size.height/2*direction
        let x = size.width/2*direction.leftNormal
        
        return [position-y-x, position-y+x, position+y+x, position+y-x] // top-left, top-right, bottom-right, bottom-left
    }

    // MARK: Initializers
    
    init(size: CGSize, maxSpeed: CGFloat) {
        super.init(texture: nil, color: nil, size: size)
        self.maxSpeed = maxSpeed
        
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
        
        physicsBody?.categoryBitMask = playerNodeCategoryBitMask
        physicsBody?.contactTestBitMask = destructibleNodeCategoryBitMask
        physicsBody?.collisionBitMask = destructibleNodeCategoryBitMask
    }
    
    convenience init(size: CGSize) {
        self.init(size: size, maxSpeed: CGFloat.max)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
