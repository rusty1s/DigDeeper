//
//  PathNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 24.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSClipperWrapper

class PathNode : SKNode {
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Instance variables
    
    private var polygons: [[CGPoint]] = []
    
    // MARK: Instance functions
    
    func addElement(element: GridElementType, withVertices vertices: [CGPoint]) {
        
        polygons = Clipper.unionPolygons(polygons, subjFillType: .Positive, withPolygons: [vertices], clipFillType: .EvenOdd)
        
        if let position = scene?.camera?.position {
            polygons = Clipper.differencePolygons(polygons, subjFillType: .Positive, fromPolygons: [[CGPoint(x: position.x-1000, y: position.y+350), CGPoint(x: position.x-1000, y: position.y+1000), CGPoint(x: position.x+1000, y: position.y+1000), CGPoint(x: position.x+1000, y: position.y+350)]], clipFillType: .EvenOdd)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            for child in self.children { (child as? SKShapeNode)?.path = nil }
            self.removeAllChildren()
            for polygon in self.polygons { self.addChildWithVertices(polygon) }
        }
    }
    
    private func addChildWithVertices(vertices: [CGPoint]) {
        let node = SKShapeNode()
        node.lineWidth = 1
        node.strokeColor = SKColor.redColor()
        node.path = CGPath.pathOfVertices(vertices)
        addChild(node)
    }
}
