//
//  TriangularTile.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 16.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

private struct TriangularTileData {
    
    private static var width: CGFloat = 20

    private static var height: CGFloat = 20
}

public struct TriangularTile<T, S> : TileType {
    
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
    public static var width: CGFloat {
        set { TriangularTileData.width = max(1, newValue) }
        get { return TriangularTileData.width }
    }
    
    /// The height of the tile.  The height has a minimum value of 1.
    /// The default value is 20.0.
    public static var height: CGFloat {
        set { TriangularTileData.height = max(1, newValue) }
        get { return TriangularTileData.height }
    }
}

// MARK: Instance variables

extension TriangularTile {
    
    public var frame: CGRect {
        let originX: CGFloat
        
        // apex of the triangle is on the top
        if (x+y)%2 == 0 {
            originX = y%2 == 0 ? TriangularTile<T, S>.width * CGFloat(x/2) : TriangularTile<T, S>.width * (CGFloat((x+1)/2)-0.5)
        }
        // apex of the triangle is at the bottom
        else {
            originX = y%2 == 0 ? TriangularTile<T, S>.width * (CGFloat((x+1)/2) - 0.5) : TriangularTile<T, S>.width * CGFloat(x/2)
        }
        
        return CGRect(x: originX,
            y: CGFloat(y)*TriangularTile<T, S>.height,
            width: TriangularTile<T, S>.width,
            height: TriangularTile<T, S>.height)
    }
    
    public var vertices: [CGPoint] {
        let frame = self.frame
        
        // apex of the triangle is on the top
        if (x+y)%2 == 0 {
            return [CGPoint(x: frame.origin.x, y: frame.origin.y),
                CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height),
                CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y)]
        }
        // apex of the triangle is at the bottom
        else {
            return [CGPoint(x: frame.origin.x, y: frame.origin.y+frame.size.height),
                CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y+frame.size.height),
                CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y)]
        }
    }
}

// MARK: Instance functions

extension TriangularTile {
    
    public func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool {
        // apex of the triangle is on the top
        if (x+y)%2 == 0 {
            // top left
            if point1.x < 0.5 && point1.y > 2*point1.x && point2.x < 0.5 && point2.y > 2*point2.x { return false }
            // top right
            if point1.x > 0.5 && point1.y > 2*(1-point1.x) && point2.x > 0.5 && point2.y > 2*(1-point2.x) { return false }
        }
        // apex of the triangle is at the bottom
        else {
            // bottom left
            if point1.x < 0.5 && (1-point1.y) > 2*point1.x && point2.x < 0.5 && (1-point2.y) > 2*point2.x { return false }
            // bottom right
            if point1.x > 0.5 && (1-point1.y) > 2*(1-point1.x) && point2.x > 0.5 && (1-point2.y) > 2*(1-point2.x) { return false }
        }
        
        return true
    }
}

// MARK: Static functions

extension TriangularTile {
    
    public static func tilesInRect<T, S>(rect: CGRect) -> Set<TriangularTile<T, S>> {
        
        let startX = segmentXOfCoordinate(rect.origin.x)
        let startY = segmentYOfCoordinate(rect.origin.y)
        let endX = segmentXOfCoordinate(rect.origin.x+rect.size.width)+1
        let endY = segmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        var elements = Set<TriangularTile<T, S>>(minimumCapacity: (1+endX-startX)*(1+endY-startY))
        for x in startX...endX {
            for y in startY...endY {
                elements.insert(TriangularTile<T, S>(x: x, y: y))
            }
        }
        return elements
    }
    
    private static func segmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, width/2) != 0 ? Int(coordinate/(width/2))-2 : Int(coordinate/(width/2))-1
    }
    
    private static func segmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, height) != 0 ? Int(coordinate/height)-1 : Int(coordinate/height)
    }
}

// MARK: Comparable

extension TriangularTile {}
public func == <T, S>(lhs: TriangularTile<T, S>, rhs: TriangularTile<T, S>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func < <T, S>(lhs: TriangularTile<T, S>, rhs: TriangularTile<T, S>) -> Bool {
    return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
}

// MARK: CustomDebugStringConvertible

extension TriangularTile {
    
    public var debugDescription: String { return "TriangularTile(\(self)" }
}
