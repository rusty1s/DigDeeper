//
//  GridContactDetection.swift
//  RSContactGrid
//
//  Created by Matthias Fey on 23.06.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

// MARK: Default implementations

extension GridType {
    
    /// Adds a virtual polygon into the grid and defines behavior for
    /// overlayed elements.
    /// - Parameter polygon: The vertices of the polygon as a finite
    /// sequence of `CGPoint`.
    /// - Parameter allowInsertingElements: Allows the grid to insert element,
    /// which are overlayed by the polygon, but are not yet inserted into the grid.
    /// - Parameter resolveContact: Returns the new behavior of a `ElementType` that
    /// is overlayed by the polygon.
    final public mutating func addPolygon(var polygon: [CGPoint], allowInsertingElements: Bool = true, @noescape resolveContact: ElementType -> ElementType) {
        
        // error handling
        guard polygon.count > 2 else { return } // polygon must at least form a triangle
        for index in Array(0...polygon.count-1).filter({ polygon[$0] == polygon[($0+1)%polygon.count] }).reverse() {
            polygon.removeAtIndex(index)    // delete equal neighbors
        }
        guard polygon.count > 2 else { return } // polygon must still at least form a triangle

        var contactedElements = Set<ElementType>()
        
        // check if the line segment intersects the given rectangle
        // if `true`, the method returns the rect's relative inner points
        // https://gist.github.com/ChickenProp/3194723
        func line(startPoint startPoint: CGPoint, endPoint: CGPoint, intersectsRect rect: CGRect) -> (RelativeRectPoint, RelativeRectPoint)? {
            
            let p = [-(endPoint.x-startPoint.x), endPoint.x-startPoint.x, -(endPoint.y-startPoint.y), endPoint.y-startPoint.y]
            let q = [startPoint.x-rect.origin.x, rect.origin.x+rect.size.width-startPoint.x, startPoint.y-rect.origin.y, rect.origin.y+rect.size.height-startPoint.y]
            
            var u1 = CGFloat.min
            var u2 = CGFloat.max
            
            for i in 0...3 {
                if p[i] == 0 {
                    if q[i] < 0 { return nil }
                }
                else {
                    let t = q[i]/p[i]
                    if p[i] < 0 && u1 < t { u1 = t }
                    else if p[i] > 0 && u2 > t { u2 = t }
                }
            }
            
            let intersection1 = CGPoint(x: startPoint.x+u1*(endPoint.x-startPoint.x), y: startPoint.y+u1*(endPoint.y-startPoint.y))
            let intersection2 = CGPoint(x: startPoint.x+u2*(endPoint.x-startPoint.x), y: startPoint.y+u2*(endPoint.y-startPoint.y))
            
            let relIntersection1 = RelativeRectPoint(x: min(max((intersection1.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((intersection1.y-rect.origin.y)/rect.size.height, 0), 1))!
            let relIntersection2 = RelativeRectPoint(x: min(max((intersection2.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((intersection2.y-rect.origin.y)/rect.size.height, 0), 1))!
            let relStart = RelativeRectPoint(x: min(max((startPoint.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((startPoint.y-rect.origin.y)/rect.size.height, 0), 1))!
            let relEnd = RelativeRectPoint(x: min(max((endPoint.x-rect.origin.x)/rect.size.width, 0), 1), y: min(max((endPoint.y-rect.origin.y)/rect.size.height, 0), 1))!
            
            // if u1 > u2, the line segment is entirely outside the rectangle
            if u1 > u2 { return nil }
            
            // if u1 == u2, the line segment intersects the rectangle in only one point
            if u1 == u2 { return nil }
            
            // if u1 <= 0 && 1 <= u2, the line segment is entirely inside the rectangle
            else if u1 <= 0 && 1 <= u2 { return (relStart, relEnd) }
            
            // if 0 < u1 < u2 < 1, the line segment both starts and finishes outside the rectangle; but they intersect with the rect
            else if 0 < u1 && u1 < u2 && u2 < 1 { return (relIntersection1, relIntersection2) }
            
            // otherwise, one end is inside and one end is outside. Two subcases:
            else {
                // if 0 < u1 < 1, the line starts outside and moves inside, intersecting at u1
                if 0 < u1 && u1 < 1 { return (relIntersection1, relEnd) }
            
                // if 0 < u2 < 1, the line starts inside and moves outside, intersecting at u2
                else if 0 < u2 && u2 < 1 { return (relStart, relIntersection2) }
            }
            
            return nil
        }
        
        // mark all elements that intersect with the polygon's border as contacted
        for index in Array(0...polygon.count-1) {
            let startPoint = polygon[index]
            let endPoint = polygon[(index+1)%polygon.count]
            
            // define rect built by the start and end points of the line segment
            let lineRect = CGRect(x: min(startPoint.x, endPoint.x),
                                  y: min(startPoint.y, endPoint.y),
                                  width: abs(endPoint.x-startPoint.x),
                                  height: abs(endPoint.y-startPoint.y))
            
            // get possible contacted elements by the line segment
            let elements = ElementType.elementsInRect(lineRect)
            for element in elements {
                // detect relative inner points of the element's frame, if line intersects
                if let points = line(startPoint: startPoint, endPoint: endPoint, intersectsRect: element.frame) {
                    // detect if the line intersects the element
                    if element.intersectsRelativeLineSegment(point1: points.0, point2: points.1) {
                        contactedElements.insert(element)
                    }
                }
            }
        }
        
        // get the frame of the polygon
        var minX = CGFloat.max
        var maxX = CGFloat.min
        var minY = CGFloat.max
        var maxY = CGFloat.min
        
        for point in polygon {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }
        let polygonFrame = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        
        // calculate remaining elements that may be contacted by the polygon
        var remainingElements = ElementType.elementsInRect(polygonFrame)
        remainingElements.subtractInPlace(contactedElements)
        
        // point in polygon test (ray casting to the left)
        // http://stackoverflow.com/questions/11716268/point-in-polygon-algorithm
        func point(point: CGPoint, inPolygon polygon: [CGPoint]) -> Bool {
            var even = true
            
            for index in Array(0...polygon.count-1) {
                let startPoint = polygon[index]
                let endPoint = polygon[(index+1)%polygon.count]
                
                // point must be between start and end point y coordinates
                let pointBetweenYCoordinates = point.y <= max(startPoint.y, endPoint.y) && point.y >= min(startPoint.y, endPoint.y)
                // check if vertical line
                let verticalLine = startPoint.y == endPoint.y && point.x < min(startPoint.x, endPoint.x)
                // check if point is on the left side of the line
                let pointOnLeftSide = point.x < startPoint.x+((endPoint.x-startPoint.x)/(endPoint.y-startPoint.y))*(point.y-startPoint.y)
                
                if pointBetweenYCoordinates && (verticalLine || pointOnLeftSide) { even = !even }
            }
            
            return !even
        }
        
        // iterate through all remaining elements
        // and check if their center is inside or outside of the polygon
        // if inside, mark the element as contacted
        for element in remainingElements {
            if point(element.center, inPolygon: polygon) { contactedElements.insert(element) }
        }
        
        // iterate through contacted elements and resolve contacts
        delegate?.didBeginResolveContacts()
        for element in contactedElements {
            if let removedElement = remove(element) {
                let resolvedElement = resolveContact(removedElement)
                insert(resolvedElement)
                delegate?.didResolveContactInElement(resolvedElement)
            }
            else {
                if allowInsertingElements {
                    let resolvedElement = resolveContact(element)
                    insert(resolvedElement)
                    delegate?.didResolveContactInElement(resolvedElement)
                }
            }
        }
        delegate?.didEndResolveContacts()
    }
}
