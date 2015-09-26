//
//  ContactNodeType.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 06.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit

protocol ContactNodeType {
    
    var vertices: [CGPoint] { get }
    
    var currentVertices: [CGPoint] { get }
    
    var size: CGSize { get }
}

// MARK: Default implementations

extension ContactNodeType {
    
    var size: CGSize {
        if vertices.isEmpty { return CGSizeZero }
        
        let firstVertex = vertices.first!
        var minX = firstVertex.x; var maxX = firstVertex.x
        var minY = firstVertex.y; var maxY = firstVertex.y
        
        for vertex in vertices {
            minX = min(minX, vertex.x); maxX = max(maxX, vertex.x)
            minY = min(minY, vertex.y); maxY = max(maxY, vertex.y)
        }
        
        return CGSize(width: maxX-minX, height: maxY-minY)
    }
}
