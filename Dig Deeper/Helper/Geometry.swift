//
//  Geometry.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 30.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit

struct Line {
    
    // MARK: Attributes
    
    var point1: CGPoint
    var point2: CGPoint
    var segmented: Bool
    
    var direction: CGVector { return CGVector(dx: point2.x-point1.x, dy: point2.y-point1.y) }
    var length: CGFloat? { return segmented ? direction.length : nil }
    
    // MARK: Initializers
    
    init(point1: CGPoint, point2: CGPoint, segmented: Bool = false) {
        self.point1 = point1
        self.point2 = point2
        self.segmented = segmented
    }
    
    init(point: CGPoint, direction: CGVector) {
        self.init(point1: point, point2: CGPoint(x: point.x+direction.dx, y: point.y+direction.dy), segmented: false)
    }
    
    // MARK: Description
    
    var description: String {
        let description = "line (point1: \(point1), point2: \(point2), direction: (\(direction.dx), \(direction.dy))"
        return segmented ? description + ", segmented)" : description + ")"
    }
    
    // MARK: Methods
    
    var function: ((CGFloat) -> (CGFloat))? {
        if point1.x != point2.x {
            func f(x: CGFloat) -> CGFloat { return point1.y + ySlope * (x - point1.x) }
            return f
        }
        else { return nil }
    }
    
    var inverseFunction: ((CGFloat) -> (CGFloat))? {
        if point1.y != point2.y {
            func f(y: CGFloat) -> CGFloat { return point1.x + xSlope * (y - point1.y) }
            return f
        }
        else { return nil }
    }
    
    var isHorizontal: Bool { return point1.y == point2.y }
    var isVertical: Bool { return point1.x == point2.x }
    
    var xSlope: CGFloat { return (point2.x-point1.x)/(point2.y-point1.y) }
    var ySlope: CGFloat { return (point2.y-point1.y)/(point2.x-point1.x) }
}
