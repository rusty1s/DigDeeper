//
//  CGVector.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 20.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit

extension CGVector {

    func isParallelToVector(vector: CGVector) -> Bool {
        assert(hasLength, "vector nas no length")
        assert(vector.hasLength, "vector nas no length")
        
        return dx == 0 && vector.dx == 0 || dy == 0 && vector.dy == 0 || dx/vector.dx == dy/vector.dy
    }
    
    func withLength(length: CGFloat) -> CGVector {
        assert(hasLength, "vector has no length")
        
        let oldLength = self.length
        return CGVector(dx: length*dx/oldLength, dy: length*dy/oldLength)
    }
    
    var leftNormal: CGVector {
        assert(hasLength, "vector has no length")
        
        return CGVector(dx: -self.dy, dy: self.dx)
    }
    
    var rightNormal: CGVector {
        assert(hasLength, "vector has no length")
        
        return CGVector(dx: self.dy, dy: -self.dx)
    }
    
    var length: CGFloat { return sqrt(dx*dx+dy*dy) }
    var hasLength: Bool { return dx != 0 || dy != 0 }
}

// MARK: Operator functions

func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx+right.dx, dy: left.dy+right.dy)
}

func - (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx-right.dx, dy: left.dy-right.dy)
}

prefix func - (vector: CGVector) -> CGVector {
    return CGVector(dx: -vector.dx, dy: -vector.dy)
}

func * (factor: CGFloat, vector: CGVector) -> CGVector {
    return CGVector(dx: factor*vector.dx, dy: factor*vector.dy)
}

func * (left: CGVector, right: CGVector) -> CGFloat {
    return left.dx*right.dx+left.dy+right.dy
}

func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x+vector.dx, y: point.y+vector.dy)
}

func - (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x-vector.dx, y: point.y-vector.dy)
}
