//
//  HexagonalTile.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 18.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

private struct HexagonalTileData {
    
    private static var width: CGFloat = 20
    
    private static var height: CGFloat = 20
    
    private static var horizontalLength: CGFloat = 10
}

public struct HexagonalTile<T, S> : TileType {
    
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
    /// Adjusts the `horizontalLength` of the tile iff `width < horizontalLength`.
    /// The default value is 20.0.
    public static var width: CGFloat {
        set {
            HexagonalTileData.width = max(1, newValue)
            HexagonalTile<T, S>.horizontalLength = HexagonalTile<T, S>.horizontalLength
        }
        get { return HexagonalTileData.width }
    }
    
    /// The height of the tile.  The height has a minimum value of 1.  The default
    /// value is 20.0.
    public static var height: CGFloat {
        set { HexagonalTileData.height = max(1, newValue) }
        get { return HexagonalTileData.height }
    }
    
    /// The horizontal sites length of the tile.  The length has a value between 1
    /// and the width of the tile.  The default value is 10.0.
    public static var horizontalLength: CGFloat {
        set { HexagonalTileData.horizontalLength = min(max(1, newValue), HexagonalTile<T, S>.width) }
        get { return HexagonalTileData.horizontalLength }
    }
    
    private static var offsetX: CGFloat { return (width-horizontalLength)/2 }
}

// MARK: Instance variables

extension HexagonalTile {
    
    public var frame: CGRect {
        return CGRect(x: CGFloat(x)*(HexagonalTile<T, S>.width+HexagonalTile<T, S>.horizontalLength) + (abs(y)%2 == 1 ? HexagonalTile<T, S>.width-HexagonalTile<T, S>.offsetX : 0),
            y: y%2 == 0 ? CGFloat(y/2)*HexagonalTile<T, S>.height : (CGFloat((y+1)/2)-0.5)*HexagonalTile<T, S>.height,
            width: HexagonalTile<T, S>.width,
            height: HexagonalTile<T, S>.height)
    }
    
    public var vertices: [CGPoint] {
        let frame = self.frame
        let offsetX = HexagonalTile<T, S>.offsetX
        
        return [CGPoint(x: frame.origin.x, y: frame.origin.y+frame.size.height/2),
            CGPoint(x: frame.origin.x+offsetX, y: frame.origin.y+frame.size.height),
            CGPoint(x: frame.origin.x+frame.size.width-offsetX, y: frame.origin.y+frame.size.height),
            CGPoint(x: frame.origin.x+frame.size.width, y: frame.origin.y+frame.size.height/2),
            CGPoint(x: frame.origin.x+frame.size.width-offsetX, y: frame.origin.y),
            CGPoint(x: frame.origin.x+offsetX, y: frame.origin.y)]
    }
}

// MARK: Instance functions

extension HexagonalTile {
    
    public func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool {
        let relOffsetX = HexagonalTile<T, S>.offsetX/HexagonalTile<T, S>.width
        
        // bottom left
        if point1.x < relOffsetX && point1.y < 0.5 && point2.x < relOffsetX && point2.y < 0.5 {
            let x1 = point1.x*(1/relOffsetX)
            let y1 = 2*point1.y
            let x2 = point2.x*(1/relOffsetX)
            let y2 = 2*point2.y
            
            if y1 < 1-x1 && y2 < 1-x2 { return false }
        }
        
        // top left
        if point1.x < relOffsetX && point1.y > 0.5 && point2.x < relOffsetX && point2.y > 0.5 {
            let x1 = point1.x*(1/relOffsetX)
            let y1 = 2*(point1.y-0.5)
            let x2 = point2.x*(1/relOffsetX)
            let y2 = 2*(point2.y-0.5)
            
            if y1 > x1 && y2 > x2 { return false }
        }
        
        // bottom right
        if point1.x > 1-relOffsetX && point1.y < 0.5 && point2.x > 1-relOffsetX && point2.y < 0.5 {
            let x1 = (point1.x-(1-relOffsetX))*(1/relOffsetX)
            let y1 = 2*point1.y
            let x2 = (point2.x-(1-relOffsetX))*(1/relOffsetX)
            let y2 = 2*point2.y
            
            if y1 < x1 && y2 < x2 { return false }
        }
        
        // top right
        if point1.x > 1-relOffsetX && point1.y > 0.5 && point2.x > 1-relOffsetX && point2.y > 0.5 {
            let x1 = (point1.x-(1-relOffsetX))*(1/relOffsetX)
            let y1 = 2*(point1.y-0.5)
            let x2 = (point2.x-(1-relOffsetX))*(1/relOffsetX)
            let y2 = 2*(point2.y-0.5)
            
            if 1-y1 < x1 && 1-y2 < x2 { return false }
        }
        
        return true
    }
}

// MARK: Static functions

extension HexagonalTile {
    
    public static func tilesInRect<T, S>(rect: CGRect) -> Set<HexagonalTile<T, S>> {
        
        let evenStartX = startEvenSegmentXOfCoordinate(rect.origin.x)
        let evenStartY = evenSegmentYOfCoordinate(rect.origin.y)
        let evenEndX = endEvenSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let evenEndY = evenSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        let oddStartX = startOddSegmentXOfCoordinate(rect.origin.x)
        let oddStartY = oddSegmentYOfCoordinate(rect.origin.y)
        let oddEndX = endOddSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let oddEndY = oddSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        var elements = Set<HexagonalTile<T, S>>(minimumCapacity: (1+evenEndX-evenStartX)*(1+(evenEndY-evenStartY)/2)+(1+oddEndX-oddStartX)*(1+(oddEndY-oddStartY)/2))
        
        if evenEndX >= evenStartX {
            for x in evenStartX...evenEndX {
                for var y = evenStartY; y <= evenEndY; y+=2 {
                    elements.insert(HexagonalTile<T, S>(x: x, y: y))
                }
            }
        }
        
        if oddEndX >= oddStartX {
            for x in oddStartX...oddEndX {
                for var y = oddStartY; y <= oddEndY; y+=2 {
                    elements.insert(HexagonalTile<T, S>(x: x, y: y))
                }
            }
        }
        
        return elements
    }
    
    private static func startEvenSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return endEvenSegmentXOfCoordinate(coordinate+horizontalLength)
    }
    
    private static func endEvenSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, (width+horizontalLength)) != 0 ? Int(coordinate/(width+horizontalLength))-1 : Int(coordinate/(width+horizontalLength))
    }
    
    private static func evenSegmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return coordinate < 0 && fmod(coordinate, height) != 0 ? (Int(coordinate/height)-1)*2 : Int(coordinate/height)*2
    }
    
    private static func startOddSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return startEvenSegmentXOfCoordinate(coordinate-horizontalLength-offsetX)
    }
    
    private static func endOddSegmentXOfCoordinate(coordinate: CGFloat) -> Int {
        return endEvenSegmentXOfCoordinate(coordinate-horizontalLength-offsetX)
    }
    
    private static func oddSegmentYOfCoordinate(coordinate: CGFloat) -> Int {
        return evenSegmentYOfCoordinate(coordinate-height/2)+1
    }
}

// MARK: Comparable

extension HexagonalTile {}
public func == <T, S>(lhs: HexagonalTile<T, S>, rhs: HexagonalTile<T, S>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func < <T, S>(lhs: HexagonalTile<T, S>, rhs: HexagonalTile<T, S>) -> Bool {
    return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
}

// MARK: CustomDebugStringConvertible

extension HexagonalTile {
    
    public var debugDescription: String { return "HexagonalTile(\(self)" }
}
