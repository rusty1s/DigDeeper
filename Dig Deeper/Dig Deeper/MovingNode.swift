//
//  MovingNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class MovingNode : SKSpriteNode, ContactNodeType {
    
    // MARK: Instance variables
    
    final var maxSpeed: CGFloat {
        set {
            _maxSpeed = abs(newValue)
            currentSpeed = _currentSpeed
        }
        get { return _maxSpeed }
    }
    private var _maxSpeed: CGFloat = CGFloat.max
    
    final var currentSpeed: CGFloat {
        set { _currentSpeed = max(min(newValue, maxSpeed), -maxSpeed) }
        get { return _currentSpeed }
    }
    private var _currentSpeed: CGFloat = 0
    
    var vertices: [CGPoint] { return [] }
    
    final var currentVertices: [CGPoint] {
        let currentSin = sin(zRotation)
        let currentCos = cos(zRotation)
        return vertices.map {
            CGPoint(x: position.x+$0.x*currentCos-$0.y*currentSin,
                y: position.y+$0.x*currentSin+$0.y*currentCos)
        }
    }
}
