//
//  PathNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 01.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit

class PathNode : SKNode {
    
    class PathLineNode : SKShapeNode {
        
        var mutablePath: CGMutablePath = CGPathCreateMutable()
        
        override init() {
            super.init()
            
            fillColor = UIColor.yellowColor()
            lineWidth = 0
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: Attributes
    
    private struct Static {
        static let maxPaths: Int = 20
    }
    
    private var pathDictionary = Dictionary<Int, (CGFloat, PathLineNode)>()
    
    // MARK: Initializiers
    
    override init() {
        super.init()
        
        name = "path"
        zPosition = -100
        alpha = 0.5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Appending path
    
    func appendPathAtSegment(segment: Grid.Segment) {
        let index = abs(Int(segment.point.y)%Static.maxPaths)
        
        if let (realY, pathLineNode) = pathDictionary[index] {
            if realY != segment.point.y {
                pathLineNode.mutablePath = CGPathCreateMutable()
            }
            CGPathAddPath(pathLineNode.mutablePath, nil, CGPath.closedPathWithPoints(segment.pointsOfContactedEdges))
            pathLineNode.path = pathLineNode.mutablePath
            pathDictionary[index] = (segment.point.y, pathLineNode)
        }
        else {
            let pathLineNode = PathLineNode()
            addChild(pathLineNode)
            CGPathAddPath(pathLineNode.mutablePath, nil, CGPath.closedPathWithPoints(segment.pointsOfContactedEdges))
            pathLineNode.path = pathLineNode.mutablePath
            pathDictionary[index] = (segment.point.y, pathLineNode)
        }
    }
}
