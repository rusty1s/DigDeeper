//
//  PlayerNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 25.02.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit

class PlayerNode : MovingNode {
    
    // MARK: Attributes
    
    private(set) var maxDegree: CGFloat = 0.25*CGFloat.π   // 45°
    
    // MARK: Initializers
    
    init() {
        super.init(size: CGSize(width: 50, height: 100), maxSpeed: 5)
        
        name = "player"
        color = UIColor.redColor()
        actSpeed = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
