//
//  Extensions.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 01.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit

// MARK: CGFloat

extension CGFloat {
    
    static var π: CGFloat { return CGFloat(M_PI) }
    
    static var e: CGFloat { return CGFloat(M_E) }
}

// MARK: Operator functions

func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x+vector.dx, y: point.y+vector.dy)
}

func - (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x-vector.dx, y: point.y-vector.dy)
}
