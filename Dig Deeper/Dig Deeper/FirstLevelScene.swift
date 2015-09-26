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
    
        addEnemyNode(EnemyNode(), atPosition: CGPoint(x: 100, y: 100))
        
        addMineralNode(MineralNode(item: Item(), size: CGSize(width: 50, height: 70), numberOfVertices: 20, destroyable: true), atPosition: CGPoint(x: -60, y: -500))
        
        addMineralNode(MineralNode(item: Item(), size: CGSize(width: 50, height: 50), numberOfVertices: 20, destroyable: true), atPosition: CGPoint(x: 30, y: -1000))
        
        addMineralNode(MineralNode(item: Item(), size: CGSize(width: 70, height: 70), numberOfVertices: 20, destroyable: true), atPosition: CGPoint(x: -50, y: -1500))
        
        addMineralNode(MineralNode(item: Item(), size: CGSize(width: 100, height: 100), numberOfVertices: 20, destroyable: true), atPosition: CGPoint(x: 10, y: -2000))
        
        addMineralNode(MineralNode(item: Item(), size: CGSize(width: 80, height: 100), numberOfVertices: 20, destroyable: true), atPosition: CGPoint(x: -20, y: -2500))
    }
}
