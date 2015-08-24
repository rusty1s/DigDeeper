//
//  GameScene.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 31.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSScene
import RSContactGrid

import CoreMotion

enum AccelerometerDirection : CGFloat {
    case Default = 1
    case Inverted = -1
}

typealias GridElementType = RotatedSquareElement<SKNode, SKNode>

class GameScene : RSScene, SKPhysicsContactDelegate {
    
    // MARK: Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tps = 15
        
        GridElementType.height = 30
        GridElementType.width = 30
        
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
    
    let playerNode = PlayerNode()
    let pathNode = PathNode()
    
    // MARK: Setup
    
    private func setupNodes() {
        // camera
        let camera = SKCameraNode()
        addChild(camera)
        self.camera = camera
        
        // player
        addChild(pathNode)
        addChild(playerNode)
        
        // material
        addMaterialNodeWithVertices([CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], position: CGPoint(x: -20, y: -200), destroyable: true)
        addMaterialNodeWithVertices([CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], position: CGPoint(x: 0, y: -500), destroyable: true)
        addMaterialNodeWithVertices([CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 50, y: -100)], position: CGPoint(x: -50, y: -800), destroyable: true)
    }
    
    private func addMaterialNodeWithVertices(vertices: [CGPoint], position: CGPoint, destroyable: Bool) {
        
        let materialNode = MaterialNode(vertices: vertices, destroyable: destroyable)
        materialNode.position = position
        addChild(materialNode)
        
        grid.addPolygon(materialNode.currentVertices) {
            var element = $0
            element.content = materialNode
            return element
        }
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
    
    override func updateGameLogic(currentTime: NSTimeInterval) {

        grid.addPolygon(playerNode.currentVertices) {
            var element = $0
       
            if let content = element.content as? MaterialNode {
                if element.contact == nil && content.destroyable {
                    element.contact = playerNode
                    content.subtractElement(element)
                }
            }
            else { element.contact = playerNode }
            
            if $0.contact == nil { pathNode.addElement(element) }
            
            return element
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
}
