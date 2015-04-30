//
//  Grid.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 01.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit

protocol GridContactDelegate {
    func didBeginResolveContacts()
    func didResolveContactInSegment(segment: Grid.Segment)
    func didEndResolveContacts()
}

class Grid {

    class Segment : Equatable, Hashable {
            
        enum Edge : Printable {
            case Left, Right, Bottom, Top
            static let allValues: Set = [Left, Right, Bottom, Top]
            
            private static let topLeftPoint = CGPoint(x: 0, y: Segment.height)
            private static let topRightPoint = CGPoint(x:Segment.width, y: Segment.height)
            private static let bottomLeftPoint = CGPointZero
            private static let bottomRightPoint = CGPoint(x: Segment.width, y: 0)
            private static let middlePoint = CGPoint(x: Segment.width/2, y: Segment.height/2)
            
            var description: String {
                switch self {
                case .Left: return "left"
                case .Right: return "right"
                case .Bottom: return "bottom"
                case .Top: return "top"
                }
            }
        }
        
        class EdgeContact : Equatable, Hashable {
            
            // MARK: Attributes
            
            let edge: Edge
            
            var contactedObject: AnyObject?
            var contacted: Bool { return contactedObject != nil }
            
            var content: AnyObject?
            var hasContent: Bool { return content != nil }
            
            var hashValue: Int { return edge.hashValue }
            
            // MARK: Initializers
            
            init(edge: Edge) {
                self.edge = edge
            }
        }
        
        private struct Intersection {
            
            // MARK: Attributes
            
            var edge1: Grid.Segment.Edge
            var cut1: CGFloat
            
            var edge2: Grid.Segment.Edge
            var cut2: CGFloat
            
            var contactedEdges: Set<Grid.Segment.Edge> {
                switch (edge1, edge2) {
                    
                case (.Left, .Top): return Set(Edge.allValues)
                case (.Left, .Bottom): return [.Left, .Bottom]
                case (.Left, .Right):
                    var set: Set = [Edge.Left, .Right, .Bottom]
                    if (cut1+cut2)/2 > 0.5 { set.insert(.Top) }
                    return set
                    
                case (.Top, .Right): return Set(Edge.allValues)
                case (.Top, .Left): return [.Top, .Left]
                case (.Top, .Bottom):
                    var set: Set = [Edge.Top, .Bottom, .Left]
                    if (cut1+cut2)/2 > 0.5 { set.insert(.Right) }
                    return set
                    
                case (.Right, .Bottom): return Set(Edge.allValues)
                case (.Right, .Top): return [.Right, .Top]
                case (.Right, .Left):
                    var set: Set = [Edge.Right, .Left, .Top]
                    if (cut1+cut2)/2 < 0.5 { set.insert(.Bottom) }
                    return set
                    
                case (.Bottom, .Left): return Set(Edge.allValues)
                case (.Bottom, .Right): return [.Bottom, .Right]
                case (.Bottom, .Top):
                    var set: Set = [Edge.Bottom, .Top, .Right]
                    if (cut1+cut2)/2 < 0.5 { set.insert(.Left) }
                    return set
                    
                default: return []
                }
            }
            
            // MARK: Initializers
            
            init(edge1: Grid.Segment.Edge, cut1: CGFloat, edge2: Grid.Segment.Edge, cut2: CGFloat) {
                assert(edge1 != edge2, "edges can not be equal")
                
                assert(cut1 >= 0 && cut1 <= 1, "cut needs to be between 0 and 1")
                assert(cut2 >= 0 && cut2 <= 1, "cut needs to be between 0 and 1")
                
                self.edge1 = edge1
                self.cut1 = cut1
                
                self.edge2 = edge2
                self.cut2 = cut2
            }
        }
        
        // MARK: Attributes
        
        private struct Static {
            static let width: CGFloat = 20
            static let height: CGFloat = 20
        }
        
        class var width: CGFloat { return Static.width }
        class var height: CGFloat { return Static.height }
        
        let point: CGPoint
        var position: CGPoint { return Segment.positionOfSegmentPoint(point) }
        var frame: CGRect { return CGRect(origin: position, size: CGSize(width: Static.width, height: Static.height)) }
        
        private(set) var edgeContacts: Set<EdgeContact> = Set(Array(Edge.allValues).map { EdgeContact(edge: $0) })
        var edges: Set<Edge> { return edgeContacts.map { $0.edge }}
        
        var contactedEdgeContacts: Set<EdgeContact> { return self.edgeContacts.filter { $0.contacted } }
        func contactedEdgeContactsWithContent(content: AnyObject) -> Set<EdgeContact> {
            return self.edgeContacts.filter { $0.contacted && $0.content === content }
        }
        var contactedEdges: Set<Edge> { return self.contactedEdgeContacts.map { $0.edge } }
        
        var deletedEdges: Set<Edge> { return Edge.allValues.subtract(self.edgeContacts.map { $0.edge }) }
        
        var hashValue: Int { return point.hashValue }
        
        // MARK: Initializers
        
        init(point: CGPoint) {
            self.point = CGPoint(x: Int(point.x), y: Int(point.y))
        }
        
        // MARK: Points
        
        private var topLeftPoint: CGPoint { return position+Edge.topLeftPoint }
        private var topRightPoint: CGPoint { return position+Edge.topRightPoint }
        private var bottomLeftPoint: CGPoint { return position+Edge.bottomLeftPoint }
        private var bottomRightPoint: CGPoint { return position+Edge.bottomRightPoint }
        private var middlePoint: CGPoint { return position+Edge.middlePoint }
        
        func pointsOfEdges(edges: Set<Edge>) -> [CGPoint] {
            switch edges.count {
            case 1:
                switch edges {
                case [.Left]: return [bottomLeftPoint, topLeftPoint, middlePoint]
                case [.Top]: return [topLeftPoint, topRightPoint, middlePoint]
                case [.Right]: return [topRightPoint, bottomRightPoint, middlePoint]
                case [.Bottom]: return [bottomRightPoint, bottomLeftPoint, middlePoint]
                default: fatalError()
                }
            case 2:
                switch edges {
                case [.Left, .Top]: return [bottomLeftPoint, topLeftPoint, topRightPoint]
                case [.Top, .Right]: return [topLeftPoint, topRightPoint, bottomRightPoint]
                case [.Right, .Bottom]: return [topRightPoint, bottomRightPoint, bottomLeftPoint]
                case [.Bottom, .Left]: return [bottomRightPoint, bottomLeftPoint, topLeftPoint]
                    
                case [.Left, .Right]: return [bottomLeftPoint, topLeftPoint, middlePoint, topRightPoint, bottomRightPoint, middlePoint]
                case [.Bottom, .Top]: return [bottomRightPoint, bottomLeftPoint, middlePoint, topLeftPoint, topRightPoint, middlePoint]
                    
                default: fatalError()
                }
            case 3:
                switch edges {
                case [.Left, .Top, .Right]: return [bottomLeftPoint, topLeftPoint, topRightPoint, bottomRightPoint, middlePoint]
                case [.Top, .Right, .Bottom]: return [topLeftPoint, topRightPoint, bottomRightPoint, bottomLeftPoint, middlePoint]
                case [.Right, .Bottom, .Left]: return [topRightPoint, bottomRightPoint, bottomLeftPoint, topLeftPoint, middlePoint]
                case [.Bottom, .Left, .Top]: return [bottomRightPoint, bottomLeftPoint, topLeftPoint, topRightPoint, middlePoint]
                default: fatalError()
                }
            case 4: return [topLeftPoint, topRightPoint, bottomRightPoint, bottomLeftPoint]
            default: fatalError()
            }
        }
        
        var pointsOfContactedEdges: [CGPoint] { return self.pointsOfEdges(self.contactedEdges) }
        
        // Converting
        
        class func positionOfSegmentPoint(point: CGPoint) -> CGPoint {
            return CGPoint(x: point.x*Static.width, y: point.y*Static.height)
        }
        
        class func segmentPointOfPosition(position: CGPoint) -> CGPoint {
            let x = position.x < 0 && fmod(position.x, Static.width) != 0 ? Int(position.x/Static.width)-1 : Int(position.x/Static.width)
            let y = position.y < 0 && fmod(position.y, Static.height) != 0 ? Int(position.y/Static.height)-1 : Int(position.y/Static.height)
            
            return CGPoint(x: x, y: y)
        }
        
        class func positionInGridCoordinates(position: CGPoint) -> CGPoint {
            return CGPoint(x: position.x/Static.width, y: position.y/Static.height)
        }
        
        class func segmentPlaceOfGridCoordinate(coordinate: CGFloat) -> Int {
            return coordinate < 0 && fmod(coordinate, 1) != 0 ? Int(coordinate)-1 : Int(coordinate)
        }
        class func segmentPointOfGridCoordinates(coordinates: CGPoint) -> CGPoint {
            return CGPoint(x: Segment.segmentPlaceOfGridCoordinate(coordinates.x), y: Segment.segmentPlaceOfGridCoordinate(coordinates.y))
        }
        
        class func relGridCoordinateOfGridCoordinate(coordinate: CGFloat) -> CGFloat {
            return coordinate-CGFloat(Segment.segmentPlaceOfGridCoordinate(coordinate))
        }
        class func relGridCoordinatesOfGridCoordinates(coordinates: CGPoint) -> CGPoint {
            return CGPoint(x: Segment.relGridCoordinateOfGridCoordinate(coordinates.x), y: Segment.relGridCoordinateOfGridCoordinate(coordinates.y))
        }
    }
    
    // MARK: Attributes
    
    private(set) var segments: Set<Segment> = []
    
    var delegate: GridContactDelegate?
    
    // MARK: Detect contacts
    
    func detectContactsOfPolygonFromVertices(vertices: [CGPoint], withEffect effect: (Segment.EdgeContact) -> ()) {
        assert(vertices.count > 1, "vertices must at least form a line")
        
        var contactedEdgesInGridSegmentPoints: [CGPoint : Set<Segment.Edge>] = [:]
        
        func addIntersection(intersection: Segment.Intersection, toPoint point: CGPoint) {
            if let contactedEdges = contactedEdgesInGridSegmentPoints[point] {
                contactedEdgesInGridSegmentPoints[point] = contactedEdges.intersect(intersection.contactedEdges)
            }
            else {
                contactedEdgesInGridSegmentPoints[point] = intersection.contactedEdges
            }
        }
        
        let sVertices = vertices.map { Segment.positionInGridCoordinates($0) }
        let lines = [Int](0...vertices.count-1).map { Line(point1: sVertices[$0], point2: sVertices[($0+1)%sVertices.count]) }
        
        var minX = Int.max
        var maxX = Int.min
        var minY = Int.max
        var maxY = Int.min
        
        // outer line polygon segments
        for line in lines {
            let startSegment = Segment.segmentPointOfGridCoordinates(line.point1)
            let endSegment = Segment.segmentPointOfGridCoordinates(line.point2)
            
            minX = min(minX, Int(startSegment.x), Int(endSegment.x))
            maxX = max(maxX, Int(startSegment.x), Int(endSegment.x))
            minY = min(minY, Int(startSegment.y), Int(endSegment.y))
            maxY = max(maxY, Int(startSegment.y), Int(endSegment.y))
            
            if !line.isVertical {
                let function = line.function!
                let inverseFunction = line.inverseFunction
                
                let positiveX = line.point1.x <= line.point2.x
                let positiveY = line.point1.y <= line.point2.y
                
                var prevY = Int(startSegment.y)
                for var x = Int(startSegment.x); positiveX ? x <= Int(endSegment.x) : x >= Int(endSegment.x); positiveX ? x++ : x-- {
                    var nextY = Segment.segmentPlaceOfGridCoordinate(function(positiveX ? CGFloat(x+1) : CGFloat(x)))
                    nextY = positiveY ? min(nextY, Int(endSegment.y)) : max(nextY, Int(endSegment.y))
                    // contacted grid segments (x, [prevY...nextY])
                    
                    if !line.isHorizontal {
                        
                        for var y = prevY; positiveY ? y <= nextY : y >= nextY; positiveY ? y++ : y-- {
                            // point is (x,y)
                            let realStartGridCoordinateX = inverseFunction!(positiveY ? CGFloat(y) : CGFloat(y+1))
                            let realEndGridCoordinateX = inverseFunction!(positiveY ? CGFloat(y+1) : CGFloat(y))
                            
                            let edge1: Segment.Edge
                            let cut1: CGFloat
                            if x == Segment.segmentPlaceOfGridCoordinate(realStartGridCoordinateX) {
                                // top or bottom
                                edge1 = positiveY ? Segment.Edge.Bottom : .Top
                                cut1 = Segment.relGridCoordinateOfGridCoordinate(realStartGridCoordinateX)
                            }
                            else {
                                // left or right
                                edge1 = positiveX ? Segment.Edge.Left : .Right
                                cut1 = Segment.relGridCoordinateOfGridCoordinate(function(positiveX ? CGFloat(x) : CGFloat(x+1)))
                            }
                            
                            let edge2: Segment.Edge
                            let cut2: CGFloat
                            if x == Segment.segmentPlaceOfGridCoordinate(realEndGridCoordinateX) {
                                // top or bottom
                                edge2 = positiveY ? Segment.Edge.Top : .Bottom
                                cut2 = Segment.relGridCoordinateOfGridCoordinate(realEndGridCoordinateX)
                            }
                            else {
                                // left or right
                                edge2 = positiveX ? Segment.Edge.Right : .Left
                                cut2 = Segment.relGridCoordinateOfGridCoordinate(function(positiveX ? CGFloat(x+1) : CGFloat(x)))
                            }
                            
                            addIntersection(Segment.Intersection(edge1: edge1, cut1: cut1, edge2: edge2, cut2: cut2), toPoint: CGPoint(x: x, y: y))
                        }
                    }
                    else {  // horizontal line
                        // left or right
                        let edge1 = positiveX ? Segment.Edge.Left : .Right
                        let edge2 = positiveX ? Segment.Edge.Right : .Left
                        let cut = Segment.relGridCoordinateOfGridCoordinate(function(0))
                        
                        for y in min(prevY, nextY)...max(prevY, nextY) {
                            addIntersection(Segment.Intersection(edge1: edge1, cut1: cut, edge2: edge2, cut2: cut), toPoint: CGPoint(x: x, y: y))
                        }
                    }
                    
                    prevY = nextY
                }
            }
            else {  // vertical line
                // top or bottom
                let positiveY = line.point1.y <= line.point2.y
                let inverseFunction = line.inverseFunction!
                
                let x = Segment.segmentPlaceOfGridCoordinate(inverseFunction(0))
                
                let edge1 = positiveY ? Segment.Edge.Bottom : .Top
                let edge2 = positiveY ? Segment.Edge.Top : .Bottom
                let cut = Segment.relGridCoordinateOfGridCoordinate(inverseFunction(0))
                
                for y in Int(min(startSegment.y, endSegment.y))...Int(max(startSegment.y, endSegment.y)) {
                    addIntersection(Segment.Intersection(edge1: edge1, cut1: cut, edge2: edge2, cut2: cut), toPoint: CGPoint(x: x, y: y))
                }
            }
        }
        
        // inner polygon segments
        // http://stackoverflow.com/questions/217578/point-in-polygon-aka-hit-test

        if maxX - minX > 1 && maxY - minY > 1 {
            for y in minY+1...maxY-1 {
                for x in minX+1...maxX-1 {
                    let segmentPoint = CGPoint(x: x, y: y)
                    if contactedEdgesInGridSegmentPoints[segmentPoint] == nil {
                        let testPoint = CGPoint(x: segmentPoint.x+0.5, y: segmentPoint.y+0.5)
                        var inPolygon = false
                        
                        for line in lines {
                            if ((line.point1.y>testPoint.y) != (line.point2.y>testPoint.y)) &&
                                (testPoint.x < (line.point2.x-line.point1.x) * (testPoint.y-line.point1.y)/(line.point2.y-line.point1.y) + line.point1.x) {
                                    inPolygon = !inPolygon
                            }
                        }
                        
                        if inPolygon { contactedEdgesInGridSegmentPoints[segmentPoint] = Segment.Edge.allValues }
                    }
                }
            }
        }
        
        // update grid
        for (point, contactedEdges) in contactedEdgesInGridSegmentPoints {
            var segment = Segment(point: point)
            if segments.contains(segment) {
                segment = segments[segments.indexOf(segment)!]
                for edgeContact in segment.edgeContacts.filter({ contactedEdges.contains($0.edge) }) { effect(edgeContact) }
            }
            else {
                for edgeContact in segment.edgeContacts.filter({ contactedEdges.contains($0.edge) }) { effect(edgeContact) }
                segments.insert(segment)
            }
        }
    }
    
    // MARK: Resolve contacts
    
    func resolveContacts() {
        var found = false
        for segment in segments {
            let contactedEdges = segment.contactedEdges
            
            if !contactedEdges.isEmpty {
                if !found {
                    delegate?.didBeginResolveContacts()
                    found = true
                }
                
                delegate?.didResolveContactInSegment(segment)
                segment.edgeContacts = segment.edgeContacts.subtract(segment.contactedEdgeContacts)
            }
        }
        
        if found { delegate?.didEndResolveContacts() }
    }
    
    // MARK: Remove
    
    func removeSegmentsWithFilter(filter: (Segment) -> (Bool)) {
        segments = segments.subtract(segments.filter { filter($0) })
    }
}

// MARK: Operator functions

func == (left: Grid.Segment.EdgeContact, right: Grid.Segment.EdgeContact) -> Bool {
    return left.edge == right.edge
}

func != (left: Grid.Segment.EdgeContact, right: Grid.Segment.EdgeContact) -> Bool {
    return !(left == right)
}

func == (left: Grid.Segment, right: Grid.Segment) -> Bool {
    return left.point == right.point
}

func != (left: Grid.Segment, right: Grid.Segment) -> Bool {
    return !(left == right)
}
