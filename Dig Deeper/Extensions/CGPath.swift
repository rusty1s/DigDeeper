//
//  CGPath.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 24.02.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit

extension CGPath {
    
    class func pathWithPoints(points: [CGPoint]) -> CGPath {
        return pathWithPoints(points, closeSubpath: false)
    }
    
    class func closedPathWithPoints(points: [CGPoint]) -> CGPath {
        return pathWithPoints(points, closeSubpath: true)
    }
    
    // MARK: Helper
    
    private class func pathWithPoints(points: [CGPoint], closeSubpath: Bool) -> CGPath {
        let path = CGPathCreateMutable()
        for (index, point) in enumerate(points) {
            if index == 0 { CGPathMoveToPoint(path, nil, point.x, point.y) }
            else { CGPathAddLineToPoint(path, nil, point.x, point.y) }
        }
        
        if closeSubpath { CGPathCloseSubpath(path) }
        
        return path
    }
}