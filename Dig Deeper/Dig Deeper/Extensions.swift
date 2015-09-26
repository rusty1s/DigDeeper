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
    
    class func pathOfVertices(vertices: [CGPoint], closed: Bool = false) -> CGPath {
        let path = CGPathCreateMutable()
        
        if vertices.isEmpty {
            CGPathMoveToPoint(path, nil, 0, 0)
            return path
        }
        else {
            for (index, vertex) in vertices.enumerate() {
                if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
                else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
            }
            if closed && vertices.count > 2 { CGPathCloseSubpath(path) }
            
            return path
        }
    }
    
    class func pathOfPolygons(polygons: [[CGPoint]], closed: Bool = false) -> CGPath {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        
        for polygon in polygons {
            for (index, vertex) in polygon.enumerate() {
                if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
                else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
            }
            if closed && polygon.count > 2 { CGPathCloseSubpath(path) }
        }
        
        return path
    }
    
    class func smoothPathOfVertices(vertices: [CGPoint], closed: Bool = false) -> CGPath {
        let path = CGPathCreateMutable()
        
        if vertices.isEmpty {
            CGPathMoveToPoint(path, nil, 0, 0)
            return path
        }
        else {
            var prevVertex = vertices.last!
            for (index, vertex) in vertices.enumerate() {
                let midVertex = CGPoint(x: (prevVertex.x+vertex.x)/CGFloat(2), y: (prevVertex.y+vertex.y)/CGFloat(2))
                
                if index == 0 {
                    if closed && vertices.count > 2 { CGPathMoveToPoint(path, nil, midVertex.x, midVertex.y) }
                    else { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
                }
                else {
                    CGPathAddQuadCurveToPoint(path, nil, prevVertex.x, prevVertex.y, midVertex.x, midVertex.y)
                    
                    if index == vertices.count-1 {
                        if closed && vertices.count > 2 {
                            CGPathAddQuadCurveToPoint(path, nil, vertex.x, vertex.y, (vertex.x+vertices[0].x)/CGFloat(2), (vertex.y+vertices[0].y)/CGFloat(2))
                            CGPathCloseSubpath(path)
                        }
                        else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
                    }
                }
                
                prevVertex = vertex
            }
            
            return path
        }
    }
}

// MARK: CGVector

extension CGVector {

    var length: CGFloat {
        return sqrt(dx*dx+dy*dy)
    }

    func toLength(length: CGFloat) -> CGVector {
        let actLength = self.length
        return CGVector(dx: length*dx/actLength, dy: length*dy/actLength)
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

func * (scalar: CGFloat, vector: CGVector) -> CGVector {
    return CGVector(dx: scalar*vector.dx, dy: scalar*vector.dy)
}

func - (point1: CGPoint, point2: CGPoint) -> CGVector {
    return CGVector(dx: point1.x-point2.x, dy: point1.y-point2.y)
}

// MARK: RotatedSquareElement

extension SquareTile {
    
    var randomVertices: [CGPoint] {
        let frame = self.frame
        
        let offsetX = CGFloat(arc4random())/CGFloat(UInt32.max)*frame.size.width/2-frame.size.width/4
        let offsetY = CGFloat(arc4random())/CGFloat(UInt32.max)*frame.size.height/2-frame.size.height/4
        
        let left = CGPoint(x: frame.origin.x-1-frame.size.width/2+offsetX, y: frame.origin.y+frame.size.height/2-offsetY)
        let top = CGPoint(x: frame.origin.x+frame.size.width/2-offsetX, y: frame.origin.y+frame.size.height+1+frame.size.height/2+offsetY)
        let right = CGPoint(x: frame.origin.x+frame.size.width+1+frame.size.width/2+offsetX, y: frame.origin.y+frame.size.height/2-offsetY)
        let bottom = CGPoint(x: frame.origin.x+frame.size.width/2-offsetX, y: frame.origin.y-1-frame.size.height/2+offsetY)
        
        return [left, top, right, bottom]
    }
}
