//
//  FirstLevelScene.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.08.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class FirstLevelScene : GameScene {
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
    
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -200))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -600))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -1000))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -1400))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -1800))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -2200))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -2600))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -3000))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -3400))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -3800))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -4200))
        addMaterial(MaterialNode(item: Item(), vertices: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], destroyable: true), atPosition: CGPoint(x: -20, y: -4600))
    }
}
