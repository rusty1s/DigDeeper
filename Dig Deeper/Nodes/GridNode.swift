//
//  GridNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 01.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit

class GridNode : SKShapeNode {
    
    // MARK: Intializiers
    
    override init() {
        super.init()
        setup()
    }
    
    convenience init(size: CGSize) {
        self.init()
        setupForSize(size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        name = "grid"
        zPosition = CGFloat.max
        alpha = 0.1
        lineWidth = 1
        strokeColor = UIColor.whiteColor()
    }

    func setupForSize(size: CGSize) {
        let width = size.width+2*Grid.Segment.width
        let height = size.height+2*Grid.Segment.height
        
        let gridCountX = Int(size.width/(2*Grid.Segment.width))+1
        let gridCountY = Int(size.height/(2*Grid.Segment.height))+1
        
        let path = CGPathCreateMutable()
        
        for index in -gridCountY...gridCountY {
            let position = CGPoint(x: -size.width/2-Grid.Segment.width, y: CGFloat(index)*Grid.Segment.height)
            let line = CGPath.pathWithPoints([CGPoint(x: position.x, y: position.y), CGPoint(x: position.x+width, y: position.y)])
            CGPathAddPath(path, nil, line)
        }
        
        for index in -gridCountX...gridCountX {
            let position = CGPoint(x: CGFloat(index)*Grid.Segment.width, y: -size.height/2-Grid.Segment.height)
            let line = CGPath.pathWithPoints([CGPoint(x: position.x, y: position.y), CGPoint(x: position.x, y: position.y+height)])
            CGPathAddPath(path, nil, line)
        }
        
        self.path = path
    }
}
