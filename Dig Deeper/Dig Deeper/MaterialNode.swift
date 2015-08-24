//
//  MaterialNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 06.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSContactGrid
import RSClipperWrapper

class MaterialNode : SKShapeNode, ContactNodeType {
    
    // MARK: Initializers
    
    init(vertices: [CGPoint], destroyable: Bool) {
        self.vertices = vertices
        polygons = [vertices]
        self.destroyable = destroyable
        
        super.init()
        
        name = "material"
        
        path = CGPath.pathOfVertices(vertices)
        lineWidth = 1
        strokeColor = SKColor.whiteColor()
        
        if !destroyable {
            physicsBody = SKPhysicsBody(polygonFromPath: path!)
            physicsBody?.dynamic = false
            physicsBody?.categoryBitMask = 0x1 << 2
            physicsBody?.contactTestBitMask = 0x1 << 1
            physicsBody?.collisionBitMask = 0x1 << 1
            
            strokeColor = SKColor.redColor()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    let destroyable: Bool
    
    private var polygons: [[CGPoint]]
    
    let vertices: [CGPoint]
    
    final var currentVertices: [CGPoint] {
        return vertices.map { CGPoint(x: $0.x+position.x, y: $0.y+position.y) }
    }
    
    // MARK: Instance functions
    
    func subtractElement(element: GridElementType) {
        let polygon = element.randomVertices.map { CGPoint(x: $0.x-self.position.x, y: $0.y-self.position.y) }
        polygons = Clipper.differencePolygons(polygons, fromPolygons: [polygon])
        path = CGPath.pathOfPolygons(polygons)
    }
}
