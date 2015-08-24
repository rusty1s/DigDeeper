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
}
