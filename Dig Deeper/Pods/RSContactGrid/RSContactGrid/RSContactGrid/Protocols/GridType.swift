//
//  GridType.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 25.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

/// A tile map that holds tiles conforming to `TileType` and
/// addresses these by coordinates `x` and `y`.  Implements a contact
/// detection for any path with the tiles in the grid.
public protocol GridType : Hashable, Equatable, SequenceType, ArrayLiteralConvertible, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Associated types
    
    typealias ElementType: TileType
    
    // MARK: Initializers
    
    /// Create an empty `GridType`.
    init()
    
    /// Create an empty `GridType` with at least the given number of
    /// tiles worth of storage.  The actual capacity will be the
    /// smallest power of 2 that's >= `minimumCapacity`.
    init(minimumCapacity: Int)
    
    /// Create a `GridType` from a finite sequence of tiles.
    init<S : SequenceType where S.Generator.Element == ElementType>(_ sequence: S)
    
    // MARK: Instance variables
    
    /// Returns the number of tiles.
    var count: Int { get }
    
    // MARK: Instance methods
    
    /// Insert a tile into the grid.
    mutating func insert(element: ElementType)
    
    /// Remove the tile from the grid and return it if it was present.
    mutating func remove(element: ElementType) -> ElementType?
    
    /// Erase all tiles.  If `keepCapacity` is `true`, `capacity`
    /// will not decrease.
    mutating func removeAll(keepCapacity keepCapacity: Bool)
    
    // MARK: Subscripts
    
    /// Returns the tile of a given position, or `nil` if the position is not
    /// present in the grid.
    subscript(x: Int, y: Int) -> ElementType? { get }
}

// MARK: Default implementations

extension GridType {
    
    /// `true` if the grid is empty.
    final public var isEmpty: Bool { return count == 0 }
    
    /// Insert an initial tile at position `x`, `y` into the grid.
    final public mutating func insertAtX(x: Int, y: Int) { insert(ElementType(x: x, y: y)) }
    
    /// Remove the tile at position `x`, `y` from the grid and return it if
    /// it was present.
    final public mutating func removeAtX(x: Int, y: Int) -> ElementType? { return remove(ElementType(x: x, y: y)) }
}

// MARK: ArrayLiteralConvertible

extension GridType {
    
    public init(arrayLiteral elements: ElementType...) { self.init(elements) }
}

// MARK: CustomStringConvertible / CustomDebugStringConvertible

extension GridType {
    
    public var description: String { return "\(Array(self))" }
    
    public var debugDescription: String { return "GridType(\(self))" }
}

// MARK: Tile contact detection

extension GridType {

    /// Detects and can add the tiles of the grid which are contacted by a path.
    /// - Parameter path: The vertices of a path as a finite
    /// sequence of `CGPoint`.
    /// - Parameter closedPath: Defines wheter the path is closed.  The default
    /// value is `false`.
    /// - Parameter allowInsertingTiles: Allows the grid to insert tiles
    /// which are contacted by the path but are not yet inserted into the grid.
    /// The default value is `true`.
    /// - Parameter detected: A function that is called on every tile that is contacted
    /// by the path.
    final public mutating func detectContactedTilesOfPath(path: [CGPoint], var closedPath: Bool = false, allowInsertingTiles: Bool = true, @noescape detected: ElementType -> ()) {
        
        if path.count == 0 { return }
        else if path.count == 1 {
            for element in ElementType.tilesInRect(CGRect(x: path.first!.x, y: path.first!.y, width: 0, height: 0)) {
                if let insertedElement = self[element.x, element.y] { detected(insertedElement) }
                else if allowInsertingTiles {
                    detected(element)
                    insert(element)
                }
            }
        }
        else {
            closedPath = closedPath && path.count > 2
            var contactedElements = Set<ElementType>()
            
            // mark all elements that intersect with the border of the polygon as contacted
            for index in 0...path.count-(closedPath ? 1 : 2) {
                let point = path[index]
                let nextPoint = path[closedPath ? (index+1)%path.count : index+1]
                
                // detect possible contacted elements by the line segment
                for element in ElementType.tilesInRect(Geometry.boundingBoxOfPoints([point, nextPoint])) {
                    // detect relative inner points of the element's frame, if line intersects
                    if let (relPoint1, relPoint2) = Geometry.line(startPoint: point, endPoint: nextPoint, intersectsRect: element.frame) {
                        // detect if the line intersects the element
                        if element.intersectsRelativeLineSegment(point1: relPoint1, point2: relPoint2) {
                            if !contactedElements.contains(element) {
                                if closedPath { contactedElements.insert(element) }
                                
                                if let insertedElement = self[element.x, element.y] { detected(insertedElement) }
                                else if allowInsertingTiles {
                                    detected(element)
                                    insert(element)
                                }
                            }
                        }
                    }
                }
            }
            
            if closedPath {
                // calculate remaining elements that may be contacted by the polygon
                var remainingElements = ElementType.tilesInRect(Geometry.boundingBoxOfPoints(path))
                remainingElements.subtractInPlace(contactedElements)
                
                // iterate through all remaining elements
                // and check if their center is inside or outside of the polygon
                // if inside, mark the element as contacted
                for element in remainingElements {
                    if Geometry.isPoint(element.center, inPolygon: path) {
                        if let insertedElement = self[element.x, element.y] { detected(insertedElement) }
                        else if allowInsertingTiles  {
                            detected(element)
                            insert(element)
                        }
                    }
                }
            }
        }
    }
}
