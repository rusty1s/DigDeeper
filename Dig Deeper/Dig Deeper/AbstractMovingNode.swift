//
//  AbstractMovingNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class AbstractMovingNode : SKNode, MovingNodeType, ContactNodeType {
    
    // MARK: Initializers
    
    init(vertices: [CGPoint], defaultSpeed: CGFloat, maxSpeed: CGFloat) {
        self.vertices = vertices
        self.maxSpeed = abs(maxSpeed)
        self.defaultSpeed = min(abs(defaultSpeed), maxSpeed)
        
        
        if vertices.isEmpty { _size = CGSizeZero }
        else {
            let firstVertex = vertices.first!
            var minX = firstVertex.x; var maxX = firstVertex.x
            var minY = firstVertex.y; var maxY = firstVertex.y
            
            for vertex in vertices {
                minX = min(minX, vertex.x); maxX = max(maxX, vertex.x)
                minY = min(minY, vertex.y); maxY = max(maxY, vertex.y)
            }
            
            _size = CGSize(width: maxX-minX, height: maxY-minY)
        }
        
        super.init()
        
        self.currentSpeed = defaultSpeed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    let defaultSpeed: CGFloat
    
    let maxSpeed: CGFloat
    
    final var currentSpeed: CGFloat {
        set { _currentSpeed = max(min(newValue, maxSpeed), defaultSpeed) }
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
    
    final var size: CGSize { return _size }
    private let _size: CGSize
}
