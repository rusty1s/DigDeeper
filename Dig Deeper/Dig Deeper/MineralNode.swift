//
//  MineralNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 06.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSShapeNode
import RSClipperWrapper
import RSRandomPolygon

class MineralNode : RSShapeNode, ContactNodeType, PolygonType {
    
    // MARK: Initializers
    
    init(item: Item, vertices: [CGPoint], destroyable: Bool) {
        self.item = item
        self.vertices = vertices
        self.destroyable = destroyable
        self.polygons = [vertices]
        
        super.init()
        
        lineWidth = 1
        strokeColor = destroyable ? SKColor.whiteColor() : SKColor.redColor()
        fillColor = SKColor.grayColor()
        
        name = "material"
        path = CGPath.pathOfVertices(vertices, closed: true)
        
        if !destroyable {
            physicsBody = SKPhysicsBody(polygonFromPath: CGPath.pathOfVertices(vertices, closed: true))
            physicsBody?.categoryBitMask = GameScene.BitMask.material
            physicsBody?.contactTestBitMask = GameScene.BitMask.nothing
            physicsBody?.collisionBitMask = GameScene.BitMask.nothing
            
            physicsBody?.dynamic = false
        }
    }
    
    convenience init(item: Item, size: CGSize, numberOfVertices: Int, destroyable: Bool) {
        let vertices = RandomPolygon.generateWithRadius(min(size.width, size.height), numberOfVertices: 10, irregularity: 0.5, spikeyness: 0.5)
        
        self.init(item: item, vertices: vertices, destroyable: destroyable)
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
    
    // MARK: Polygon type
    
    private var polygons: [[CGPoint]]
    
    private var polygonsToClip: [[CGPoint]] = []
    
    func addPolygonToClip(polygon: [CGPoint]) {
        polygonsToClip.append(polygon.map { CGPoint(x: $0.x-position.x, y: $0.y-position.y) })
    }
    
    func applyClipping() {
        polygons = Clipper.differencePolygons(polygons, subjFillType: .EvenOdd, fromPolygons: polygonsToClip, clipFillType: .NonZero)
        polygonsToClip.removeAll(keepCapacity: true)
        
        path = CGPath.pathOfPolygons(polygons, closed: true)
    }
}
