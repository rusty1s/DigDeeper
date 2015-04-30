//
//  OreNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 11.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit

class OreNode : SKNode, ContactNode {
    
    // MARK: Attributes
    
    private struct Static {
        static let view = SKView()
    }
    
    var passable: Bool { return true }
    
    private var polygonSet: PolygonSet
    
    private let vertices_: [CGPoint]
    var vertices: [CGPoint] { return vertices_.map { $0+self.position } }
    
    override var frame: CGRect {
        var minX = CGFloat.max
        var maxX = CGFloat.min
        var minY = CGFloat.max
        var maxY = CGFloat.min
        
        for polygon in polygonSet.polygons {
            for point in polygon.points {
                minX = min(minX, point.x)
                maxX = max(maxX, point.x)
                minY = min(minY, point.y)
                maxY = max(maxY, point.y)
            }
        }
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    private let contourNode = SKShapeNode()
    private let maskNode = SKSpriteNode()
    private let maskShapeNode = SKShapeNode()
    
    // MARK: Initializers
    
    init(points: [CGPoint]) {
        assert(points.count > 2, "points must at least form a triangle")
        
        polygonSet = PolygonSet(polygon: Polygon(points: points))
        vertices_ = points
        
        super.init()
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        name = "ore"
        let frame = self.frame
        
        contourNode.name = "contour"
        contourNode.zPosition = 2
        contourNode.path = polygonSet.path
        contourNode.strokeColor = UIColor.greenColor()
        contourNode.lineWidth = 2
        addChild(contourNode)
        
        let cropNode = SKCropNode()
        cropNode.name = "crop"
        cropNode.zPosition = 1
        addChild(cropNode)
        
        maskShapeNode.name = "maskShape"
        maskShapeNode.path = contourNode.path
        maskShapeNode.fillColor = UIColor.blackColor()
        maskShapeNode.lineWidth = 0
        
        maskNode.name = "mask"
        maskNode.texture = Static.view.textureFromNode(maskShapeNode)
        maskNode.size = maskNode.texture!.size()
        maskNode.position = CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
        cropNode.maskNode = maskNode
        
        let textureNode = SKSpriteNode(color: UIColor.redColor(), size: frame.size)
        textureNode.name = "texture"
        textureNode.position = CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
        cropNode.addChild(textureNode)
    }
    
    // MARK: Removing edges
    
    private var subtractPolygonSet = PolygonSet()
    
    func addSegmentToSubtraction(segment: Grid.Segment) {
        subtractPolygonSet.addPolygon(Polygon(points: segment.pointsOfContactedEdges.map { $0-self.position }))
    }
    
    func subtractAddedSegments() {
        if !subtractPolygonSet.isEmpty {
            polygonSet = polygonSet.differenceWithPolygonSet(subtractPolygonSet)
            
            for var i: Int32 = Int32(polygonSet.count)-1; i >= 0; i-- {
                if polygonSet.polygonAtIndex(i).count <= 2 { polygonSet.removePolygonAtIndex(i) }
            }

            if !polygonSet.isEmpty { contourNode.path = polygonSet.path }
            else { contourNode.path = nil }
            maskShapeNode.path = contourNode.path
            
            maskNode.texture = Static.view.textureFromNode(maskShapeNode)
            maskNode.size = maskNode.texture!.size()
            let frame = self.frame
            maskNode.position = CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
            
            subtractPolygonSet = PolygonSet()
        }
    }
}
