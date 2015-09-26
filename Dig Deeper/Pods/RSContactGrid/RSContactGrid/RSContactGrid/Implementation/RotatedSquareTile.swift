//
//  RotatedSquareTile.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 18.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

private struct RotatedSquareTileData {
    
    private static var width: CGFloat = 20
    
    private static var height: CGFloat = 20
}

public struct RotatedSquareTile<T, S> : TileType {
    
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
        set { RotatedSquareTileData.width = max(1, newValue) }
        get { return RotatedSquareTileData.width }
    }
    
    /// The height of the tile.  The height has a minimum value of 1.
    /// The default value is 20.0.
    public static var height: CGFloat {
        set { RotatedSquareTileData.height = max(1, newValue) }
        get { return RotatedSquareTileData.height }
    }
}

// MARK: Instance variables

extension RotatedSquareTile {
    
    public var frame: CGRect {
        return CGRect(x: CGFloat(x)*RotatedSquareTile<T, S>.width + (abs(y)%2 == 1 ? RotatedSquareTile<T, S>.width/2 : 0),
            y: y%2 == 0 ? CGFloat(y/2)*RotatedSquareTile<T, S>.height : (CGFloat((y+1)/2)-0.5)*RotatedSquareTile<T, S>.height,
            width: RotatedSquareTile<T, S>.width,
            height: RotatedSquareTile<T, S>.height)
    }
    
    public var vertices: [CGPoint] {
        let frame = self.frame
        
        return [CGPoint(x: frame.origin.x, y: frame.origin.y+frame.size.height/2),
            CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height),
            CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y+frame.size.height/2),
            CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y)]
    }
}

// MARK: Instance functions

extension RotatedSquareTile {
    
    public func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool {
        // bottom left
        if point1.x < 0.5 && point1.y < 0.5 && point1.y < (0.5-point1.x) && point2.x < 0.5 && point2.y < 0.5 && point2.y < (0.5-point2.x) { return false }
        // top left
        if point1.x < 0.5 && point1.y > 0.5 && (1-point1.y) < (0.5-point1.x) && point2.x < 0.5 && point2.y > 0.5 && (1-point2.y) < (0.5-point2.x) { return false }
        // bottom right
        if point1.x > 0.5 && point1.y < 0.5 && point1.y < (point1.x-0.5) && point2.x > 0.5 && point2.y < 0.5 && point2.y < (point2.x-0.5) { return false }
        // top right
        if point1.x > 0.5 && point1.y > 0.5 && (1-point1.y) < (point1.x-0.5) && point2.x > 0.5 && point2.y > 0.5 && (1-point2.y) < (point2.x-0.5) { return false }
            
        return true
    }
}

// MARK: Static functions

extension RotatedSquareTile {
    
    public static func tilesInRect<T, S>(rect: CGRect) -> Set<RotatedSquareTile<T, S>> {
        
        let evenStartX = evenSegmentXOfCoordinate(rect.origin.x)
        let evenStartY = evenSegmentYOfCoordinate(rect.origin.y)
        let evenEndX = evenSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let evenEndY = evenSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        let oddStartX = oddSegmentXOfCoordinate(rect.origin.x)
        let oddStartY = oddSegmentYOfCoordinate(rect.origin.y)
        let oddEndX = oddSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let oddEndY = oddSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        var elements = Set<RotatedSquareTile<T, S>>(minimumCapacity: (1+evenEndX-evenStartX)*(1+(evenEndY-evenStartY)/2)+(1+oddEndX-oddStartX)*(1+(oddEndY-oddStartY)/2))
        
        for x in evenStartX...evenEndX {
            for var y = evenStartY; y <= evenEndY; y+=2 {
                elements.insert(RotatedSquareTile<T, S>(x: x, y: y))
            }
        }
        
        for x in oddStartX...oddEndX {
            for var y = oddStartY; y <= oddEndY; y+=2 {
                elements.insert(RotatedSquareTile<T, S>(x: x, y: y))
            }
        }
        
        return elements
    }
    
    private static func evenSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, width) != 0 ? Int(coordinate/width)-1 : Int(coordinate/width)
    }
    
    private static func evenSegmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, height) != 0 ? (Int(coordinate/height)-1)*2 : Int(coordinate/height)*2
    }
    
    private static func oddSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return evenSegmentXOfCoordinate(coordinate-width/2)
    }
    
    private static func oddSegmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return evenSegmentYOfCoordinate(coordinate-height/2)+1
    }
}

// MARK: Comparable

extension RotatedSquareTile {}
public func == <T, S>(lhs: RotatedSquareTile<T, S>, rhs: RotatedSquareTile<T, S>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func < <T, S>(lhs: RotatedSquareTile<T, S>, rhs: RotatedSquareTile<T, S>) -> Bool {
    return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
}

// MARK: CustomDebugStringConvertible

extension RotatedSquareTile {
    
    public var debugDescription: String { return "RotatedSquareTile(\(self)" }
}
