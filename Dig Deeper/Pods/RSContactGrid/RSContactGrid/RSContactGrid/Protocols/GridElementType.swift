//
//  GridElementType.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 25.06.15.
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

/// An element that can be inserted into an implementation of `GridType`.
public protocol GridElementType : Hashable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Initializiers
    
    /// Create a `GridElementType` at x- and y-coordinates.
    init(x: Int, y: Int)
    
    // MARK: Instance variables
    
    /// Returns the x-coordinate of the segment.
    var x: Int { get }
    
    /// Returns the y-coordinate of the segment.
    var y: Int { get }
    
    /// The vertices of the element in its grid's coordinate system as a finite
    /// sequence of `CGPoint`.
    /// - Desirable complexity: O(1).
    var vertices: [CGPoint] { get }
    
    /// The minimal frame rectangle, which describes the element's location and
    /// size in its grid's coordinate system.  The frame contains all vertices
    /// of the element.
    /// - Desirable complexity: O(1).
    var frame: CGRect { get }
    
    // MARK: Instance functions
    
    /// `true` iff the element intersects with a line segment defined by two
    /// inner points of the element's frame.
    /// - Parameter point1: The start point of the line as a relative inner point of the
    /// element's frame.  `point1.x` and `point1.y` are restricted to a value between `0`
    /// and `1`.
    /// - Parameter point2: The end point of the line as a relative inner point of the
    /// element's frame.  Follows the same guidelines as `point1`.
    /// - Desirable complexity: O(1).
    func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool
    
    // MARK: Static functions
    
    /// Returns all inital elements that are overlayed by the rect.
    static func elementsInRect(rect: CGRect) -> Set<Self>
}

// MARK: Default implementations

extension GridElementType {
    
    public var frame: CGRect {
        var minX = CGFloat.max
        var maxX = CGFloat.min
        var minY = CGFloat.max
        var maxY = CGFloat.min
        
        for vertex in vertices {
            minX = min(minX, vertex.x)
            maxX = max(maxX, vertex.x)
            minY = min(minY, vertex.y)
            maxY = max(maxY, vertex.y)
        }
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    /// The center of the element's frame rectangle.
    final public var center: CGPoint {
        let frame = self.frame
        return CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
    }
}

// MARK: Hashable

extension GridElementType {
    
    final public var hashValue: Int { return "\(x):\(y)".hashValue }
}

// MARK: CustomStringConvertible / CustomDebugStringConvertible

extension GridElementType {
    
    public var description: String { return "{x: \(x), y: \(y)}" }
    
    public var debugDescription: String { return "GridElementType(\(self))" }
}
