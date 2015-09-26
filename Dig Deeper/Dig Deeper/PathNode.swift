//
//  PathNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 24.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSShapeNode
import RSClipperWrapper

class PathNode : SKNode, PolygonType {
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Polygon type
    
    private var unusedPathNodes: [RSShapeNode] = []
    
    private var polygonsToClip: [[CGPoint]] = []
    
    func addPolygonToClip(polygon: [CGPoint]) {
        polygonsToClip.append(polygon)
    }
    
    func applyClipping() {
        if !polygonsToClip.isEmpty {
            if let position = scene?.camera?.position, let size = scene?.size {
                
                if !children.isEmpty {
                    for child in children as! [RSShapeNode] {
                        if child.position.y > position.y+size.height {
                            child.removeFromParent()
                            unusedPathNodes.append(child)
                        }
                    }
                }
                
                let polygons = Clipper.unionPolygons(polygonsToClip.map { $0.map { CGPoint(x: $0.x-position.x, y: $0.y-position.y) } }, subjFillType: .NonZero, withPolygons: [], clipFillType: .NonZero)
                
                let pathNode: RSShapeNode
                if unusedPathNodes.isEmpty {
                    pathNode = RSShapeNode()
                    pathNode.lineWidth = 0
                    pathNode.blendMode = .Add
                    pathNode.fillColor = SKColor.blackColor()
                    
                }
                else { pathNode = unusedPathNodes.removeFirst() }
                
                pathNode.path = CGPath.pathOfPolygons(polygons, closed: true)
                pathNode.position = position
                addChild(pathNode)
            }
            polygonsToClip.removeAll(keepCapacity: true)
        }
    }
}
