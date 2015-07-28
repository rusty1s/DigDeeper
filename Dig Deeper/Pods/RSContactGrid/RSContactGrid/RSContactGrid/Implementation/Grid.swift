//
//  Grid.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 24.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

public struct Grid<T : GridElementType> : GridType {
    
    // MARK: Associated types
    
    public typealias ElementType = T
    
    // MARK: Instance variables
    
    private var elements: Set<ElementType>
    
    public var delegate: GridDelegate?
}

// MARK: Initializers

extension Grid {
    
    public init() {
        elements = Set()
    }
    
    public init(minimumCapacity: Int) {
        elements = Set(minimumCapacity: minimumCapacity)
    }
    
    public init<S : SequenceType where S.Generator.Element == ElementType>(_ sequence: S) {
        elements = Set(sequence)
    }
}

// MARK: Instance variables

extension Grid {
    
    public var count: Int { return elements.count }
}

// MARK: Instance methods

extension Grid {

    public mutating func insert(element: ElementType) { elements.insert(element) }
    
    public mutating func remove(element: ElementType) -> ElementType? { return elements.remove(element) }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        elements.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: Subscripts

extension Grid {

    public subscript(x: Int, y: Int) -> ElementType? {
        let element = ElementType(x: x, y: y)
        
        guard let index = elements.indexOf(element) else { return nil }
        return elements[index]
    }
}

// MARK: Hashable

extension Grid {
    
    public var hashValue: Int { return elements.hashValue }
}

// MARK: Equatable

extension Grid {}
public func == <T: GridElementType>(lhs: Grid<T>, rhs: Grid<T>) -> Bool {
    return lhs.elements == rhs.elements
}

// MARK: SequenceType

extension Grid {
    
    public typealias Generator = SetGenerator<ElementType>
    
    public func generate() -> Generator {
        return elements.generate()
    }
}

// MARK: CustomDebugStringConvertible

extension Grid {
    
    public var debugDescription: String { return "Grid(\(self)" }
}
