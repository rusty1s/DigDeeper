//
//  TileType.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 25.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

/// A tile that can be inserted into an implementation of `GridType`.
public protocol TileType : Hashable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Associated types
    
    typealias DataType
    
    // MARK: Initializiers
    
    /// Create a `TileType` at x- and y-coordinates.
    init(x: Int, y: Int)
    
    // MARK: Instance variables
    
    /// Returns the x-coordinate of the tile.
    var x: Int { get }
    
    /// Returns the y-coordinate of the tile.
    var y: Int { get }
    
    /// Addititional information of the tile.
    var data: DataType { get }
    
    /// The vertices of the tile in its grids coordinate system as a finite
    /// sequence of `CGPoint`.
    /// - Desirable complexity: O(1).
    var vertices: [CGPoint] { get }
    
    // MARK: Instance functions
    
    /// `true` iff the tile intersects with a line segment defined by two
    /// inner points of its frame.
    /// - Parameter point1: The start point of the line as a relative inner point of the
    /// tiles frame.  `point1.x` and `point1.y` are restricted to a value between `0`
    /// and `1`.
    /// - Parameter point2: The end point of the line as a relative inner point of the
    /// tiles frame.  Follows the same guidelines as `point1`.
    /// - Desirable complexity: O(1).
    func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool
    
    // MARK: Static functions
    
    /// Returns all inital tiles that are overlayed by the rect.
    static func tilesInRect(rect: CGRect) -> Set<Self>
}

// MARK: Default implementations

extension TileType {
    
    /// The minimal frame rectangle which describes the tiles location and
    /// size in its grids coordinate system.  The frame contains all vertices
    /// of the tile.
    /// - Desirable complexity: O(1).
    public var frame: CGRect { return Geometry.boundingBoxOfPoints(vertices) }
    
    /// The center of the tiles frame rectangle.
    final public var center: CGPoint {
        let frame = self.frame
        return CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
    }
}

// MARK: Hashable

extension TileType {
    
    final public var hashValue: Int { return "\(x):\(y)".hashValue }
}

// MARK: CustomStringConvertible / CustomDebugStringConvertible

extension TileType {
    
    public var description: String { return "{x: \(x), y: \(y)}" }
    
    public var debugDescription: String { return "GridElementType(\(self))" }
}
