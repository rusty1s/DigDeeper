//
//  PathNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 24.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSClipperWrapper

class PathNode : SKShapeNode {
    
    // MARK: Initializers
    
    override init() {
        super.init()
        
        strokeColor = SKColor.purpleColor()
        lineWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Instance variables
    
    private var polygons: [[CGPoint]] = []
    
    // MARK: Instance functions
    
    func addElement(element: GridElementType) {
        let polygon = element.randomVertices
        polygons = Clipper.unionPolygons(polygons, withPolygons: [polygon])
        
        let origin = element.frame.origin
        
        polygons = Clipper.differencePolygons(polygons, fromPolygons: [[CGPoint(x: origin.x-200, y: origin.y+500), CGPoint(x: origin.x-200, y: origin.y+600), CGPoint(x: origin.x+200, y: origin.y+600), CGPoint(x: origin.x+200, y: origin.y+500)]])
        path = CGPath.pathOfPolygons(polygons)
    }
}
