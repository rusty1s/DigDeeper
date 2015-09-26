//
//  Helper.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 21.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

/// Relative inner point of any rect.  `x` and `y` are restricted to a value
/// between `0` and `1`.
///
/// `x == 0`: left edge
/// `x == 1`: right edge
/// `y == 0`: bottom edge
/// `y == 1`: top edge
public struct RelativeRectPoint {
    
    public let x: CGFloat
    
    public let y: CGFloat
    
    public init?(x: CGFloat, y: CGFloat) {
        guard x >= 0 && x <= 1 else { return nil }
        guard y >= 0 && y <= 1 else { return nil }
        
        self.x = x
        self.y = y
    }
}

class Geometry {
    
    /// Checks if the line segment intersects the given rectangle.
    /// The line segment intersects the rectangle iff the method
    /// returns the rect's relative inner points
    /// https://gist.github.com/ChickenProp/3194723
    final class func line(startPoint startPoint: CGPoint, endPoint: CGPoint, intersectsRect rect: CGRect) -> (RelativeRectPoint, RelativeRectPoint)? {
        
        let p = [-(endPoint.x-startPoint.x), endPoint.x-startPoint.x, -(endPoint.y-startPoint.y), endPoint.y-startPoint.y]
        let q = [startPoint.x-rect.origin.x, rect.origin.x+rect.size.width-startPoint.x, startPoint.y-rect.origin.y, rect.origin.y+rect.size.height-startPoint.y]
        
        var u1 = CGFloat.min
        var u2 = CGFloat.max
        
        for i in 0...3 {
            if p[i] == 0 {
                if q[i] < 0 { return nil }
            }
            else {
                let t = q[i]/p[i]
                if p[i] < 0 && u1 < t { u1 = t }
                else if p[i] > 0 && u2 > t { u2 = t }
            }
        }
        
        // if u1 > u2, the line segment is entirely outside the rectangle
        if u1 > u2 { return nil }
        
        // if u1 == u2, the line segment intersects the rectangle in only one point
        if u1 == u2 { return nil }
        
        let intersection1 = CGPoint(x: startPoint.x+u1*(endPoint.x-startPoint.x), y: startPoint.y+u1*(endPoint.y-startPoint.y))
        let intersection2 = CGPoint(x: startPoint.x+u2*(endPoint.x-startPoint.x), y: startPoint.y+u2*(endPoint.y-startPoint.y))
        let relIntersection1 = RelativeRectPoint(x: min(max((intersection1.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((intersection1.y-rect.origin.y)/rect.size.height, 0), 1))!
        let relIntersection2 = RelativeRectPoint(x: min(max((intersection2.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((intersection2.y-rect.origin.y)/rect.size.height, 0), 1))!
        let relStart = RelativeRectPoint(x: min(max((startPoint.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((startPoint.y-rect.origin.y)/rect.size.height, 0), 1))!
        let relEnd = RelativeRectPoint(x: min(max((endPoint.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((endPoint.y-rect.origin.y)/rect.size.height, 0), 1))!
        
        // if u1 <= 0 && 1 <= u2, the line segment is entirely inside the rectangle
        if u1 <= 0 && 1 <= u2 { return (relStart, relEnd) }
        
        // if 0 < u1 < u2 < 1, the line segment both starts and finishes outside the rectangle; but they intersect with the rect
        if 0 < u1 && u1 < u2 && u2 < 1 { return (relIntersection1, relIntersection2) }
        
        // if 0 < u1 < 1, the line starts outside and moves inside, intersecting at u1
        if 0 < u1 && u1 < 1 { return (relIntersection1, relEnd) }
        
        // if 0 < u2 < 1, the line starts inside and moves outside, intersecting at u2
        if 0 < u2 && u2 < 1 { return (relStart, relIntersection2) }
        
        return nil
    }
    
    /// Checks if the point is in the polygon by ray casting to the left
    /// http://stackoverflow.com/questions/11716268/point-in-polygon-algorithm
    final class func isPoint(point: CGPoint, inPolygon polygon: [CGPoint]) -> Bool {
        var even = true
        
        for index in Array(0...polygon.count-1) {
            let startPoint = polygon[index]
            let endPoint = polygon[(index+1)%polygon.count]
            
            // point must be between start and end point y coordinates
            let pointBetweenYCoordinates = point.y <= max(startPoint.y, endPoint.y) && point.y >= min(startPoint.y, endPoint.y)
            // check if vertical line
            let verticalLine = startPoint.y == endPoint.y && point.x < min(startPoint.x, endPoint.x)
            // check if point is on the left side of the line
            let pointOnLeftSide = point.x < startPoint.x+((endPoint.x-startPoint.x)/(endPoint.y-startPoint.y))*(point.y-startPoint.y)
            
            if pointBetweenYCoordinates && (verticalLine || pointOnLeftSide) { even = !even }
        }
        
        return !even
    }
    
    /// Returns the bounding box of an array of `CGPoint`.
    final class func boundingBoxOfPoints(points: [CGPoint]) -> CGRect {
        if let first = points.first {
            var minX = first.x
            var maxX = first.x
            var minY = first.y
            var maxY = first.y
            
            for point in points {
                minX = min(minX, point.x)
                maxX = max(maxX, point.x)
                minY = min(minY, point.y)
                maxY = max(maxY, point.y)
            }
            
            return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        }
        else { return CGRectZero }
    }
}
