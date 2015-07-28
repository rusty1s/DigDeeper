//
//  RotatedSquareElement.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 18.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

private struct RotatedSquareElementData {
    
    private static var width: CGFloat = 20
    
    private static var height: CGFloat = 20
}

public struct RotatedSquareElement<T, S> : GridElementType {
    
    // MARK: Initializers
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Create a `RotatedSquareElement` at x- and y-coordinates with specific
    /// content and contact.
    public init(x: Int, y: Int, content: T?, contact: S?) {
        self.init(x: x, y: y)
        self.content = content
        self.contact = contact
    }
    
    // MARK: Instance variables
    
    public let x: Int
    
    public let y: Int
    
    /// The content stored by the element.
    public var content: T?
    
    /// The contact stored by the element.
    public var contact: S?
    
    // MARK: Static variables
    
    // The width of the element.  The width has a minimum value of 1.
    public static var width: CGFloat {
        set { RotatedSquareElementData.width = max(1, newValue) }
        get { return RotatedSquareElementData.width }
    }
    
    // The height of the element.  The height has a minimum value of 1.
    public static var height: CGFloat {
        set { RotatedSquareElementData.height = max(1, newValue) }
        get { return RotatedSquareElementData.height }
    }
}

// MARK: Instance variables

extension RotatedSquareElement {
    
    public var frame: CGRect {
        return CGRect(x: CGFloat(x)*RotatedSquareElement<T, S>.width + (abs(y)%2 == 1 ? RotatedSquareElement<T, S>.width/2 : 0),
            y: y%2 == 0 ? CGFloat(y/2)*RotatedSquareElement<T, S>.height : (CGFloat((y+1)/2)-0.5)*RotatedSquareElement<T, S>.height,
            width: RotatedSquareElement<T, S>.width,
            height: RotatedSquareElement<T, S>.height)
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

extension RotatedSquareElement {
    
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

extension RotatedSquareElement {
    
    public static func elementsInRect<T, S>(rect: CGRect) -> Set<RotatedSquareElement<T, S>> {
        
        let evenStartX = evenSegmentXOfCoordinate(rect.origin.x)
        let evenStartY = evenSegmentYOfCoordinate(rect.origin.y)
        let evenEndX = evenSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let evenEndY = evenSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        let oddStartX = oddSegmentXOfCoordinate(rect.origin.x)
        let oddStartY = oddSegmentYOfCoordinate(rect.origin.y)
        let oddEndX = oddSegmentXOfCoordinate(rect.origin.x+rect.size.width)
        let oddEndY = oddSegmentYOfCoordinate(rect.origin.y+rect.size.height)
        
        var elements = Set<RotatedSquareElement<T, S>>(minimumCapacity: (1+evenEndX-evenStartX)*(1+(evenEndY-evenStartY)/2)+(1+oddEndX-oddStartX)*(1+(oddEndY-oddStartY)/2))
        
        for x in evenStartX...evenEndX {
            for var y = evenStartY; y <= evenEndY; y+=2 {
                elements.insert(RotatedSquareElement<T, S>(x: x, y: y))
            }
        }
        
        for x in oddStartX...oddEndX {
            for var y = oddStartY; y <= oddEndY; y+=2 {
                elements.insert(RotatedSquareElement<T, S>(x: x, y: y))
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

extension RotatedSquareElement {}
public func == <T, S>(lhs: RotatedSquareElement<T, S>, rhs: RotatedSquareElement<T, S>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func < <T, S>(lhs: RotatedSquareElement<T, S>, rhs: RotatedSquareElement<T, S>) -> Bool {
    return lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
}

// MARK: CustomDebugStringConvertible

extension RotatedSquareElement {
    
    public var debugDescription: String { return "RotatedSquareElement(\(self)" }
}
