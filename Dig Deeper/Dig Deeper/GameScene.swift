//
//  GameScene.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import CoreMotion
import RSScene
import RSContactGrid

enum AccelerometerDirection : CGFloat {
    case Default = 1
    case Inverted = -1
}

typealias GridTileType = SquareTile<SKNode, SKNode>

class GameScene : RSScene, SKPhysicsContactDelegate {
    
    // MARK: Bit masks
    
    struct BitMask {
        static let nothing: UInt32 = 0x1 << 0
        static let player: UInt32 = 0x1 << 1
        static let enemy: UInt32 = 0x1 << 2
        static let material: UInt32 = 0x1 << 3
    }
    
    // MARK: Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tps = 60
        
        GridTileType.height = 30
        GridTileType.width = 30
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        setupNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    var direction = AccelerometerDirection.Default
    
    var calibration: CGFloat = 0.0
    
    // MARK: Nodes
    
    private let playerNode = PlayerNode()
    private let pathNode = PathNode()
    
    private var movingNodes: [AbstractMovingNode] = []
    private var enemyNodes: [AbstractEnemyNode] = []
    
    // MARK: Setup
    
    private func setupNodes() {
        // camera
        let camera = SKCameraNode()
        addChild(camera)
        self.camera = camera
        
        // player
        addChild(pathNode)
        addChild(playerNode)
        movingNodes.append(playerNode)
    }
        
    // MARK: Presenting a scene
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        startAccelerometer()
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        
        stopAccelerometer()
    }
    
    // MARK: Motion manager
    
    private let motionManager = CMMotionManager()
    
    private let highPassFilterFactor: CGFloat = 0.1
    private var accelX: CGFloat = 0.0
    
    private func startAccelerometer() {
        if motionManager.accelerometerAvailable && !motionManager.accelerometerActive { motionManager.startAccelerometerUpdates() }
    }
    
    private func stopAccelerometer() {
        if motionManager.accelerometerActive { motionManager.stopAccelerometerUpdates() }
    }
    
    // MARK: Executing the Game Logic Loop
    
    private var grid = Grid<GridTileType>()
    
    override func updateGameLogic(currentTime: NSTimeInterval) {
        
        var detectedMineralNodes = Set<MineralNode>()
        
        for movingNode in movingNodes {
            grid.detectContactedTilesOfPath(movingNode.currentVertices, closedPath: false, allowInsertingTiles: true) {
                if $0.data.contact == nil {
                    $0.data.contact = playerNode
                    let vertices = $0.randomVertices
                    
                    pathNode.addPolygonToClip(vertices)
                    
                    if let content = $0.data.content as? MineralNode {
                        if movingNode != playerNode || content.destroyable {
                            detectedMineralNodes.insert(content)
                            content.addPolygonToClip(vertices)
                        }
                        else {
                            $0.data.contact = nil
                        }
                    }
                }
            }
        }
        
        pathNode.applyClipping()
        for mineralNode in detectedMineralNodes { mineralNode.applyClipping() }
    }

    // MARK: Executing the Rendering Loop
    
    private var currentPlayerDegree: CGFloat { return max(min(accelX*0.5*CGFloat.π, playerNode.maxDegree), -playerNode.maxDegree) }
    private var currentPlayerSpeed: CGVector { return CGVector(dx: sin(currentPlayerDegree)*playerNode.currentSpeed, dy: -cos(currentPlayerDegree)*playerNode.currentSpeed) }

    override func update(currentTime: NSTimeInterval) {
        if let accelerometerData = motionManager.accelerometerData {
            accelX = (CGFloat(accelerometerData.acceleration.x) + calibration) * direction.rawValue * highPassFilterFactor + accelX * (1.0 - highPassFilterFactor)
        }
        
        playerNode.position += currentPlayerSpeed
        playerNode.zRotation = currentPlayerDegree
        camera?.position = playerNode.position
        
        for enemyNode in enemyNodes { enemyNode.attackPlayer(playerNode) }
        
        super.update(currentTime)
    }
    
    // MARK: Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
    }
    
    // MARK: Adding minerals
    
    func addMineralNode(mineralNode: MineralNode, atPosition position: CGPoint) {
        mineralNode.position = position
        addChild(mineralNode)
        
        grid.detectContactedTilesOfPath(mineralNode.currentVertices, closedPath: true, allowInsertingTiles: true) { $0.data.content = mineralNode
        }
    }
    
    // MARK: Adding enemies
    
    func addEnemyNode(enemyNode: AbstractEnemyNode, atPosition position: CGPoint) {
        enemyNode.position = position
        addChild(enemyNode)
        movingNodes.append(enemyNode)
        enemyNodes.append(enemyNode)
    }
}
