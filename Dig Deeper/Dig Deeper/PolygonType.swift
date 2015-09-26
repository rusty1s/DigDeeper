//
//  PolygonType.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 22.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit

protocol PolygonType {
    
    func addPolygonToClip(polygon: [CGPoint])
    
    func applyClipping()
}
