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

typealias GridElementType = RotatedSquareElement<SKNode, SKNode>

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
        tps = 20
        
        GridElementType.height = 30
        GridElementType.width = 30
        
        maxGridElements = (GridElementType.elementsInRect(CGRect(origin: CGPointZero, size: size)) as Set<GridElementType>).count*2
        
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
    
    private var enemyNodes: [BaseEnemyNode] = []
    
    // MARK: Setup
    
    private func setupNodes() {
        // camera
        let camera = SKCameraNode()
        addChild(camera)
        self.camera = camera
        
        // player
        addChild(pathNode)
        addChild(playerNode)
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
    
    private var grid = Grid<GridElementType>()
    
    private var maxGridElements = 0
    
    override func updateGameLogic(currentTime: NSTimeInterval) {

        grid.addPolygon(playerNode.currentVertices) {
            var element = $0
       
            if element.contact == nil {
                element.contact = playerNode
                let vertices = element.randomVertices
                
                pathNode.addElement(element, withVertices: vertices)
                
                dispatch_async(dispatch_get_main_queue()) {
                    Particle.runEarthAtPosition(element.center, withAngle: self.playerNode.zPosition, inView: self)
                }
                
                if let content = element.content as? MaterialNode {
                    if content.destroyable {
                        content.subtractElement(element, withVertices: vertices)
                    }
                    else {
                        element.contact = nil
                    }
                }
            }
            
            return element
        }
        
        if grid.count > maxGridElements {
            grid = Grid(grid.filter { $0.center.y <= playerNode.position.y+size.height })
        }
    }

    // MARK: Executing the Rendering Loop
    
    private var currentPlayerDegree: CGFloat { return max(min(accelX*0.5*CGFloat.π, playerNode.maxDegree), -playerNode.maxDegree) }
    private var currentPlayerSpeed: CGVector { return CGVector(dx: sin(currentPlayerDegree)*playerNode.currentSpeed, dy: -cos(currentPlayerDegree)*playerNode.currentSpeed) }

    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        if let accelerometerData = motionManager.accelerometerData {
            accelX = (CGFloat(accelerometerData.acceleration.x) + calibration) * direction.rawValue * highPassFilterFactor + accelX * (1.0 - highPassFilterFactor)
        }
        
        playerNode.physicsBody?.applyImpulse(currentPlayerSpeed)
        playerNode.zRotation = currentPlayerDegree

        camera?.runAction(SKAction.moveTo(CGPoint(x: playerNode.position.x, y: playerNode.position.y-playerNode.size.height/2), duration: 5/60))
    }
    
    override func didSimulatePhysics() {
        var velocity = playerNode.physicsBody!.velocity
        if currentPlayerSpeed.dx >= 0 { velocity.dx = min(velocity.dx, currentPlayerSpeed.dx) }
        if currentPlayerSpeed.dx <= 0 { velocity.dx = max(velocity.dx, currentPlayerSpeed.dx) }
        if currentPlayerSpeed.dy >= 0 { velocity.dy = min(velocity.dy, currentPlayerSpeed.dy) }
        if currentPlayerSpeed.dy <= 0 { velocity.dy = max(velocity.dy, currentPlayerSpeed.dy) }
        playerNode.physicsBody?.velocity = velocity
    }
    
    // MARK: Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
    }
    
    // MARK: Adding material
    
    func addMaterial(material: MaterialNode, atPosition position: CGPoint) {
        material.position = position
        addChild(material)
        
        grid.addPolygon(material.currentVertices) {
            var element = $0
            element.content = material
            return element
        }
    }
    
    // MARK: Adding enemies
    
    func addEnemy(enemy: BaseEnemyNode, atPosition position: CGPoint) {
        enemy.position = position
        addChild(enemy)
    }
}
