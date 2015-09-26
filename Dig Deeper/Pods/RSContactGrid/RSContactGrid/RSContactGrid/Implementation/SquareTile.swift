//
//  SquareTile.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 24.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

private struct SquareTileData {
    
    private static var width: CGFloat = 20
    
    private static var height: CGFloat = 20
}

public struct SquareTile<T, S> : TileType {
    
    // MARK: Associated typed
    
    public typealias DataType = Data<T, S>
    
    // MARK: Initializers
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
        self.data = DataType()
    }
    
    // MARK: Instance variables
    
    public let x: Int
    
    public let y: Int
    
    public let data: DataType
    
    // MARK: Static variables
    
    /// The width of the tile.  The width has a minimum value of 1.
    /// The default value is 20.0.
    public static var width: CGFloat {
        set { SquareTileData.width = max(1, newValue) }
        get { return SquareTileData.width }
    }
    
    /// The height of the tile.  The height has a minimum value of 1.
    /// The default value is 20.0.
    public static var height: CGFloat {
        set { SquareTileData.height = max(1, newValue) }
        get { return SquareTileData.height }
    }
}

// MARK: Instance variables

extension SquareTile {
    
    public var frame: CGRect {
        return CGRect(x: CGFloat(x)*SquareTile<T, S>.width,
            y: CGFloat(y)*SquareTile<T, S>.height,
            width: SquareTile<T, S>.width,
            height: SquareTile<T, S>.height)
    }

    public var vertices: [CGPoint] {
        let frame = self.frame
        
        return [frame.origin,
            CGPoint(x: frame.origin.x, y: frame.origin.y+frame.size.height),
            CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y+frame.size.height),
            CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y)]
    }
}

// MARK: Instance functions

extension SquareTile {
    
    public func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool {
        return true
    }
}

// MARK: Static functions

extension SquareTile {

    public static func tilesInRect<T, S>(rect: CGRect) -> Set<SquareTile<T, S>> {
        
        let startX = segmentXOfCoordinate(rect.origin.x)
        let startY = segmentYOfCoordinate(rect.origin.y)
        let endX = segmentXOfCoordinate(rect.origin.x+rect.size.width)
        let endY = segmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        var elements = Set<SquareTile<T, S>>(minimumCapacity: (1+endX-startX)*(1+endY-startY))
        for x in startX...endX {
            for y in startY...endY {
                elements.insert(SquareTile<T, S>(x: x, y: y))
            }
        }
        return elements
    }
    
    private static func segmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, width) != 0 ? Int(coordinate/width)-1 : Int(coordinate/width)
    }
    
    private static func segmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, height) != 0 ? Int(coordinate/height)-1 : Int(coordinate/height)
    }
}

// MARK: Comparable

extension SquareTile {}
public func == <T, S>(lhs: SquareTile<T, S>, rhs: SquareTile<T, S>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func < <T, S>(lhs: SquareTile<T, S>, rhs: SquareTile<T, S>) -> Bool {
    return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
}

// MARK: CustomDebugStringConvertible

extension SquareTile {

    public var debugDescription: String { return "SquareTile(\(self)" }
}
