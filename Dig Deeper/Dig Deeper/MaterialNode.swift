//
//  MaterialNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 06.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSClipperWrapper

class MaterialNode : SKNode, ContactNodeType {
    
    // MARK: Initializers
    
    init(item: Item, vertices: [CGPoint], destroyable: Bool) {
        self.item = item
        self.vertices = vertices
        self.destroyable = destroyable
        self.polygons = [vertices]
        
        super.init()
        
        name = "material"
        
        addChildWithVertices(vertices)
        
        if !destroyable {
            physicsBody = SKPhysicsBody(polygonFromPath: CGPath.pathOfVertices(vertices)!)
            physicsBody?.categoryBitMask = GameScene.BitMask.material
            physicsBody?.contactTestBitMask = GameScene.BitMask.nothing
            physicsBody?.collisionBitMask = GameScene.BitMask.player
            
            physicsBody?.dynamic = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    let item: Item
    
    let vertices: [CGPoint]
    
    let destroyable: Bool
    
    final var currentVertices: [CGPoint] {
        return vertices.map { CGPoint(x: $0.x+position.x, y: $0.y+position.y) }
    }
    
    private var polygons: [[CGPoint]]
    
    // MARK: Instance functions
    
    func subtractElement(element: GridElementType, withVertices vertices: [CGPoint]) {
        let polygon = vertices.map { CGPoint(x: $0.x-self.position.x, y: $0.y-self.position.y) }
        polygons = Clipper.differencePolygons(polygons, fromPolygons: [polygon])
        
        dispatch_async(dispatch_get_main_queue()) {
            self.removeAllChildren()
            for polygon in self.polygons { self.addChildWithVertices(polygon) }
        }
    }
    
    private func addChildWithVertices(vertices: [CGPoint]) {
        let node = SKShapeNode()
        node.lineWidth = 1
        node.strokeColor = destroyable ? SKColor.whiteColor() : SKColor.redColor()
        node.fillColor = SKColor.grayColor()
        node.path = CGPath.pathOfVertices(vertices)
        addChild(node)
    }
}
