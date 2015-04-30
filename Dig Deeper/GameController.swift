//
//  GameController.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 21.02.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import UIKit
import SpriteKit

class GameController : UIViewController {
    
    // MARK: Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true
        
        let scene = GameScene()
        scene.showsGrid = true
        scene.scaleMode = .AspectFill
        view.presentScene(scene)
    }
}
