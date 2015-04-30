//
//  CGPoint.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 28.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit

extension CGPoint : Hashable {
    
    public var hashValue: Int {
        return "\(x),\(y)".hashValue
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}
