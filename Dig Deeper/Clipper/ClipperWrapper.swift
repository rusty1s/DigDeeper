//
//  ClipperWrapper.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 22.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

extension Polygon {
    
    convenience init(points: [CGPoint]) {
        self.init(points: points.map { NSValue(CGPoint: $0) })
    }
    
    func pointAtIndex(index: Int32) -> CGPoint? {
        return objectAtIndex(index)?.CGPointValue()
    }
    
    var points: [CGPoint] { return array.map { $0.CGPointValue() } }
    
    var path: CGPath { return CGPath.closedPathWithPoints(points) }
}

extension PolygonSet {
    
    convenience init(polygons: [Polygon]) {
        self.init(objects: polygons)
    }
    
    var polygons: [Polygon] { return array as! [Polygon] }
    
    var path: CGPath {
        let path = CGPathCreateMutable()
        for polygon in polygons { CGPathAddPath(path, nil, polygon.path) }
        return path
    }
}
