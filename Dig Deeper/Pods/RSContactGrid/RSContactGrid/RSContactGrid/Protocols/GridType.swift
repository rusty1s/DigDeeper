//
//  GridType.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 25.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

/// A datastructure that holds elements conforming to `GridElementType` and
/// addresses these elements by coordinates `x` and `y`.  Implements a collision
/// detection for any polygon with the elements in the grid.
public protocol GridType : Hashable, Equatable, SequenceType, ArrayLiteralConvertible, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Associated types
    
    typealias ElementType: GridElementType
    
    // MARK: Initializers
    
    /// Create an empty `GridType`.
    init()
    
    /// Create an empty `GridType` with at least the given number of
    /// elements worth of storage.  The actual capacity will be the
    /// smallest power of 2 that's >= `minimumCapacity`.
    init(minimumCapacity: Int)
    
    /// Create a `GridType` from a finite sequence of elements.
    init<S : SequenceType where S.Generator.Element == ElementType>(_ sequence: S)
    
    // MARK: Instance variables
    
    /// Returns the number of elements.
    var count: Int { get }
    
    /// A delegate that is called when a polygon is added into the grid
    /// and possibly overlays elements.
    var delegate: GridDelegate? { get set }
    
    // MARK: Instance methods
    
    /// Insert a element into the grid.
    mutating func insert(element: ElementType)
    
    /// Remove the element from the grid and return it if it was present.
    mutating func remove(element: ElementType) -> ElementType?
    
    /// Erase all elements.  If `keepCapacity` is `true`, `capacity`
    /// will not decrease.
    mutating func removeAll(keepCapacity keepCapacity: Bool)
    
    // MARK: Subscripts
    
    /// Returns the element of a given position, or `nil` if the position is not
    /// present in the grid.
    subscript(x: Int, y: Int) -> ElementType? { get }
}

// MARK: Default implementations

extension GridType {
    
    /// `true` if the grid is empty.
    final public var isEmpty: Bool { return count == 0 }
    
    /// Insert an initial element at position `x`, `y` into the grid.
    final public mutating func insertAtX(x: Int, y: Int) { insert(ElementType(x: x, y: y)) }
    
    /// Remove the element at position `x`, `y` from the grid and return it if
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
