//
//  Extensions.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 01.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit
import RSContactGrid
import RSClipperWrapper

// MARK: CGFloat

extension CGFloat {
    
    static var π: CGFloat { return CGFloat(M_PI) }
    
    static var e: CGFloat { return CGFloat(M_E) }
}

// MARK: CGPath

extension CGPath {
    
    class func pathOfVertices(vertices: [CGPoint]) -> CGPath {
        let path = CGPathCreateMutable()
        for (index, vertex) in vertices.enumerate() {
            if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
            else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
        }
        if vertices.count > 2 { CGPathCloseSubpath(path) }
        
        return path
    }
    
    class func pathOfPolygons(polygons: [[CGPoint]]) -> CGPath {
        let path = CGPathCreateMutable()
        for polygon in polygons {
            if polygon.count > 2 {
                for (index, vertex) in polygon.enumerate() {
                    if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
                    else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
                }
                CGPathCloseSubpath(path)
            }
        }
        
        return path
    }
}

// MARK: CGVector operator functions

func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x+vector.dx, y: point.y+vector.dy)
}

func - (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x-vector.dx, y: point.y-vector.dy)
}

func += (inout point: CGPoint, vector: CGVector) {
    point = point + vector
}

func -= (inout point: CGPoint, vector: CGVector) {
    point = point - vector
}

// MARK: RotatedSquareElement

extension RotatedSquareElement {
    
    var randomVertices: [CGPoint] {
        let vertices = self.vertices
        //return vertices
        return [CGPoint(x: vertices[0].x-1, y: vertices[0].y), CGPoint(x: vertices[1].x, y: vertices[1].y+1), CGPoint(x: vertices[2].x+1, y: vertices[2].y), CGPoint(x: vertices[3].x, y: vertices[3].y-1)]
    }
}
