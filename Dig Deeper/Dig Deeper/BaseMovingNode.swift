//
//  BaseMovingNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class BaseMovingNode : SKNode, MovingNodeType, ContactNodeType {
    
    // MARK: Initializers
    
    init(vertices: [CGPoint], maxSpeed: CGFloat) {
        self.vertices = vertices
        self.maxSpeed = abs(maxSpeed)
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    let maxSpeed: CGFloat
    
    final var currentSpeed: CGFloat {
        set { _currentSpeed = max(min(newValue, maxSpeed), 0) }
        get { return _currentSpeed }
    }
    private var _currentSpeed: CGFloat = 0
    
    let vertices: [CGPoint]
    
    final var currentVertices: [CGPoint] {
        let currentSin = sin(zRotation)
        let currentCos = cos(zRotation)
        return vertices.map {
            CGPoint(x: position.x+$0.x*currentCos-$0.y*currentSin,
                y: position.y+$0.x*currentSin+$0.y*currentCos)
        }
    }
}
