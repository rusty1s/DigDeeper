//
//  RandomPolygon.swift
//  RSRandomPolygon
//
//  Created by Matthias Fey on 12.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit

public class RandomPolygon {
    
    public class func generateWithRadius(var radius: CGFloat, var numberOfVertices number: Int, var xScale: CGFloat = 1, var yScale: CGFloat = 1, var irregularity: CGFloat, var spikeyness: CGFloat) -> [CGPoint] {
    
        radius = abs(radius)
        number = max(abs(number), 3)
        xScale = abs(xScale)
        yScale = abs(yScale)
        
        irregularity = max(min(irregularity, 1), 0) * 2*CGFloat(M_PI) / CGFloat(number)
        spikeyness = max(min(spikeyness, 1), 0)
        
        // generate n angle steps
        let lower = 2*CGFloat(M_PI) / CGFloat(number) - irregularity
        var angles: [CGFloat] = []
        var sum: CGFloat = 0
        for _ in 0..<number {
            let angle = (CGFloat(arc4random())/CGFloat(UInt32.max))*2*irregularity+lower
            angles.append(angle)
            sum += angle
        }
        
        // normalize the steps so that point 0 and point n+1 are the same
        let k = sum/(2*CGFloat(M_PI))
        for i in 0...number-1 { angles[i] /= k }
        
        // now generate the vertices
        var vertices: [CGPoint] = []
        var angle = (CGFloat(arc4random())/CGFloat(UInt32.max))*2*CGFloat(M_PI)
        for i in 0..<number {
            let randomSpikeyness = (CGFloat(arc4random())/CGFloat(UInt32.max))*2*spikeyness-spikeyness
            
            let xRadius: CGFloat = xScale*radius+(xScale*radius)*randomSpikeyness
            let yRadius: CGFloat = yScale*radius+(yScale*radius)*randomSpikeyness
            
            vertices.append(CGPoint(x: xRadius*cos(angle), y: yRadius*sin(angle)))
            angle += angles[i]
        }
        
        return vertices
    }
    
    public enum Algorithm {
        case ConvexBottom
        case ConvexTop
        case ConvexLeft
        case ConvexRight
        case SpacePartitioning
        case SteadyGrowth
        case TwoOptMoves
        case TwoPeasantsX
        case TwoPeasantsY
        
        static var allValues: Set<Algorithm> {
            return Set([Algorithm.ConvexBottom, .ConvexTop, .ConvexLeft, .ConvexRight, .SpacePartitioning, .SteadyGrowth, .TwoOptMoves, .TwoPeasantsX, .TwoPeasantsY])
        }
        
        static var random: Algorithm { return Array(allValues)[Int(arc4random()) % allValues.count] }
    }
    
    public class func generateWithSize(size: CGSize, var numberOfVertices number: Int, algorithm: Algorithm) -> [CGPoint] {
        
        number = max(abs(number), 3)
        let vertices = (0..<number).map { Int -> CGPoint in
            return CGPoint(x: (CGFloat(arc4random())/CGFloat(UInt32.max))*size.width,
                y: (CGFloat(arc4random())/CGFloat(UInt32.max))*size.height)
        }

        //var orderedVertices: [CGPoint] = []
        switch algorithm {
        case .ConvexBottom:
            // determine the two extreme points regarding x coordinate
            let (lowest, highest) = extremePointsRegardingXCoordinate(vertices)
            
            // divide the point set into an upper and lower half
            let (lowerHalf, _) = dividePoints(vertices, byLineAtPoint: highest, direction: CGVector(dx: lowest.x-highest.x, dy: lowest.y-highest.y))
            
            // calculate convex hull of lower half
            let convexBottom: [CGPoint] = convexHullOfPoints(lowerHalf).sort { $0.x > $1.x }
            
            // sort remaining points form left to right by x coordinate
            let remainingVertices = vertices.filter { !convexBottom.contains($0) }.sort { $0.x < $1.x }
            
            // construct polygon
            return remainingVertices + convexBottom
            
        case .ConvexTop:
            // determine the two extreme points regarding x coordinate
            let (lowest, highest) = extremePointsRegardingXCoordinate(vertices)
            
            // divide the point set into an upper and lower half
            let (upperHalf, _) = dividePoints(vertices, byLineAtPoint: lowest, direction: CGVector(dx: highest.x-lowest.x, dy: highest.y-lowest.y))
            
            // calculate convex hull of upper half
            let convexTop: [CGPoint] = convexHullOfPoints(upperHalf).sort { $0.x < $1.x }
            
            // sort remaining points form right to left by x coordinate
            let remainingVertices = vertices.filter { !convexTop.contains($0) }.sort { $0.x > $1.x }
            
            // construct polygon
            return remainingVertices + convexTop
            
        case .ConvexLeft:
            // determine the two extreme points regarding y coordinate
            let (lowest, highest) = extremePointsRegardingYCoordinate(vertices)
            
            // divide the point set into a left and right half
            let (leftHalf, _) = dividePoints(vertices, byLineAtPoint: lowest, direction: CGVector(dx: highest.x-lowest.x, dy: highest.y-lowest.y))
            
            // calculate convex hull of left half
            let convexLeft: [CGPoint] = convexHullOfPoints(leftHalf).sort { $0.y > $1.y }

            // sort remaining points form top to bottom by y coordinate
            let remainingVertices = vertices.filter { !convexLeft.contains($0) }.sort { $0.y < $1.y }
            
            // construct polygon
            return remainingVertices + convexLeft
            
        case .ConvexRight:
            // determine the two extreme points regarding y coordinate
            let (lowest, highest) = extremePointsRegardingYCoordinate(vertices)
            
            // divide the point set into a left and right half
            let (rightHalf, _) = dividePoints(vertices, byLineAtPoint: highest, direction: CGVector(dx: lowest.x-highest.x, dy: lowest.y-highest.y))
            
            // calculate convex hull of right half
            let convexRight: [CGPoint] = convexHullOfPoints(rightHalf).sort { $0.y < $1.y }
            
            // sort remaining points form bottom to top by y coordinate
            let remainingVertices = vertices.filter { !convexRight.contains($0) }.sort { $0.y > $1.y }
            
            // construct polygon
            return remainingVertices + convexRight
            
        case .SpacePartitioning:
            func recursiveSpacePartitioning(points: [CGPoint]) -> [CGPoint] {
                let convexHull = convexHullOfPoints(points)
                if points.count == convexHull.count { return convexHull }
                
                // filter the points which are not contained in the convex hull
                let remainingPoints = points.filter { !convexHull.contains($0) }
                
                // determine two points in the set
                let point1: CGPoint
                let point2: CGPoint
                if remainingPoints.count >= 2 {
                    point1 = remainingPoints.first!
                    point2 = remainingPoints[remainingPoints.count/2]
                }
                else {  // remainingPoints.count == 1
                    point1 = remainingPoints.first!
                    point2 = convexHull.first!
                }
                
                // divide the point set into a left and right half
                var (leftHalf, rightHalf) = dividePoints(points, byLineAtPoint: point1, direction: CGVector(dx: point2.x-point1.x, dy: point2.y-point1.y))
                rightHalf.append(point1)
                rightHalf.append(point2)
                
                // recursively division so that their convex hulls are disjoint and have only one edge in common
                leftHalf = recursiveSpacePartitioning(leftHalf)
                rightHalf = recursiveSpacePartitioning(rightHalf)
                
                // find the half where point2 is directly after point1 and call it first half
                let index1 = leftHalf.indexOf(point1)!
                let index2 = leftHalf.indexOf(point2)!
                var firstHalf: [CGPoint]
                var secondHalf: [CGPoint]
                if (index2 == index1+1)||(index1==leftHalf.count-1 && index2 == 0) {
                    firstHalf = leftHalf
                    secondHalf = rightHalf
                } else {
                    firstHalf = rightHalf
                    secondHalf = leftHalf
                }
                
                // sort the first half so that point1 is the last element
                var index = firstHalf.indexOf(point1)!
                if index != firstHalf.count-1 {
                    let temp = firstHalf[index+1..<firstHalf.count]
                    firstHalf.removeRange(index+1..<firstHalf.count)
                    firstHalf = temp + firstHalf
                }
                
                // sort the second half so that point1 is the first element
                index = secondHalf.indexOf(point1)!
                if index != 0 {
                    let temp = secondHalf[0..<index]
                    secondHalf.removeRange(0..<index)
                    secondHalf += temp
                }
                
                firstHalf.removeLast()
                secondHalf.removeLast()
                
                // construct polygon
                return (firstHalf + secondHalf)
            }
            
            return recursiveSpacePartitioning(vertices)
            
        case .SteadyGrowth:
            print("todo")
            return []
            
        case .TwoOptMoves:
            var noIntersections = false
            while !noIntersections {
                
                noIntersections = true
                
                for i in 0..<vertices.count {
                    let startPoint1 = vertices[i]
                    let endPoint1 = vertices[(i+1)%vertices.count]
                    let direction1 = CGVector(dx: endPoint1.x-startPoint1.x, dy: endPoint1.y-startPoint1.y)
                    
                    for j in 0..<vertices.count {
                        if j >= i-1 && j <= i+1 { continue }
                        
                        let startPoint2 = vertices[j]
                        let endPoint2 = vertices[(j+1)%vertices.count]
                        let direction2 = CGVector(dx: endPoint2.x-startPoint2.x, dy: endPoint2.y-startPoint2.y)
                        
                        
                    }
                }
                
                
            }
            
            print("todo")
            return []
            
        case .TwoPeasantsX:
            // determine the two extreme points regarding x coordinate
            let (lowest, highest) = extremePointsRegardingXCoordinate(vertices)
            
            // divide the point set into an upper and lower half
            let (upperHalf, lowerHalf) = dividePoints(vertices, byLineAtPoint: lowest, direction: CGVector(dx: highest.x-lowest.x, dy: highest.y-lowest.y))
            
            // construct polygon
            return upperHalf.sort { $0.x < $1.x } + lowerHalf.sort { $0.x > $1.x }
            
        case .TwoPeasantsY:
            // determine the two extreme points regarding y coordinate
            let (lowest, highest) = extremePointsRegardingYCoordinate(vertices)
            
            // divide the point set into a left and right half
            let (leftHalf, rightHalf) = dividePoints(vertices, byLineAtPoint: lowest, direction: CGVector(dx: highest.x-lowest.x, dy: highest.y-lowest.y))
            
            // construct polygon
            return leftHalf.sort { $0.y < $1.y } + rightHalf.sort { $0.y > $1.y }
        }
    }
    
    // MARK: Helper
    
    /// Returns a tuple of the extreme points of the points regarding x coordinate.
    /// The first point is lower than the second regarding x.
    private class func extremePointsRegardingXCoordinate(points: [CGPoint]) -> (CGPoint, CGPoint) {
        var lowest = points.first!
        var highest = points.first!
        for point in points {
            if point.x < lowest.x { lowest = point }
            if point.x > highest.x { highest = point }
        }
        return (lowest, highest)
    }
    
    /// Returns a tuple of the extreme points of the points regarding y coordinate.
    /// The first point is lower than the second regarding y.
    private class func extremePointsRegardingYCoordinate(points: [CGPoint]) -> (CGPoint, CGPoint) {
        var lowest = points.first!
        var highest = points.first!
        for point in points {
            if point.y < lowest.y { lowest = point }
            if point.y > highest.y { highest = point }
        }
        return (lowest, highest)
    }
    
    
    /// Returns a tuple of the left and right half of the points divided by the line.
    /// The first half contains the points on the line.
    private class func dividePoints(points: [CGPoint], byLineAtPoint startPoint: CGPoint, direction: CGVector) -> ([CGPoint], [CGPoint]) {
        var leftHalf: [CGPoint] = []
        var rightHalf: [CGPoint] = []
        for point in points {
            let a: CGFloat
            
            if direction.dx == 0 { a = -(point.x-startPoint.x)/direction.dy }
            else if direction.dy == 0 { a = (point.y-startPoint.y)/direction.dx }
            else { a = (-direction.dy*(point.x-startPoint.x)+direction.dx*(point.y-startPoint.y))/(direction.dy*direction.dy+direction.dx+direction.dx) }
            
            if a >= 0 { leftHalf.append(point) }
            else { rightHalf.append(point) }
        }
        
        return (leftHalf, rightHalf)
    }
    
    /// Returns a list of points on the convex hull in clockwise order.
    // https://gist.github.com/adunsmoor/e848356a57980ab9f822
    private class func convexHullOfPoints(var points: [CGPoint]) -> [CGPoint] {
        
        /// 2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
        /// Returns a positive value, if OAB makes a counter-clockwise turn,
        /// negative for clockwise turn, and zero if the points are collinear.
        func cross(P: CGPoint, A: CGPoint, B: CGPoint) -> CGFloat {
            let part1 = (A.x - P.x) * (B.y - P.y)
            let part2 = (A.y - P.y) * (B.x - P.x)
            return  part1 - part2;
        }
        
        // sort points lexicographically
        points = points.sort { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        
        // build the lower hull
        var lower: [CGPoint] = []
        for point in points {
            while lower.count >= 2 && cross(lower[lower.count-2], A: lower[lower.count-1], B: point) <= 0 { lower.removeLast() }
            lower.append(point)
        }
        
        // build upper hull
        var upper: [CGPoint] = []
        for point in points.reverse() {
            while upper.count >= 2 && cross(upper[upper.count-2], A: upper[upper.count-1], B: point) <= 0 { upper.removeLast() }
            upper.append(point)
        }
        
        // last point of upper and lower lists are omitted because it is repeated at the beginnings of the opposite lists
        upper.removeLast()
        lower.removeLast()
        
        // concatenation of the lower and upper hulls gives the convex hull
        return (upper + lower).reverse()
    }
}
