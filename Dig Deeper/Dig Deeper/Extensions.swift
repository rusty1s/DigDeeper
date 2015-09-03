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
    
    class func pathOfVertices(vertices: [CGPoint]) -> CGPath? {
        if vertices.count < 3 { return nil }
        
        let path = CGPathCreateMutable()
        for (index, vertex) in vertices.enumerate() {
            if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
            else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
        }
        CGPathCloseSubpath(path)
        
        return path
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

// MARK: RotatedSquareElement

extension RotatedSquareElement {
    
    var randomVertices: [CGPoint] {
        
        func randomPointInTriangle(point1 point1: CGPoint, point2: CGPoint, point3: CGPoint) -> CGPoint {
            
            var random1 = CGFloat(arc4random())/CGFloat(UInt32.max)
            var random2 = CGFloat(arc4random())/CGFloat(UInt32.max)
            
            if random1+random2 > 1 {
                random1 = 1 - random1
                random2 = 1 - random2
            }
            
            return point1 + random1 * CGVector(dx: point2.x-point1.x, dy: point2.y-point1.y) + random2 * CGVector(dx: point3.x-point1.x, dy: point3.y-point1.y)
        }
        
        let offset: CGFloat = 10
        
        let topRight = CGVector(dx: RotatedSquareElement<T, S>.width, dy: RotatedSquareElement<T, S>.height).toLength(offset)
        let topLeft = CGVector(dx: -topRight.dx, dy: topRight.dy)
        let bottomRight = CGVector(dx: topRight.dx, dy: -topRight.dy)
        let bottomLeft = CGVector(dx: -topRight.dx, dy: -topRight.dy)
        
        let vertices = self.vertices
        var randomVertices: [CGPoint] = []
        
        randomVertices.append(randomPointInTriangle(point1: vertices[0], point2: vertices[0]+bottomLeft, point3: vertices[0]+topLeft))
        randomVertices.append(randomPointInTriangle(point1: vertices[1], point2: vertices[1]+topLeft, point3: vertices[1]+topRight))
        randomVertices.append(randomPointInTriangle(point1: vertices[2], point2: vertices[2]+topRight, point3: vertices[2]+bottomRight))
        randomVertices.append(randomPointInTriangle(point1: vertices[3], point2: vertices[3]+bottomRight, point3: vertices[3]+bottomLeft))
        
        return randomVertices
    }
}
