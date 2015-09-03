//
//  MovingNodeType.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 03.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import UIKit

protocol MovingNodeType {
    
    var maxSpeed: CGFloat { get }
    
    var currentSpeed: CGFloat { get set }
}
