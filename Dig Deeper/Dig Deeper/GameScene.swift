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

class GameScene : RSScene, GridDelegate {
    
    // MARK: Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tps = 10
        grid.delegate = self
        
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
    
    // MARK: Setup
    
    private func setupNodes() {
        let world = SKNode()
        world.name = "world"
        addChild(world)
        
        world.addChild(playerNode)
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
    
    private var grid = Grid<HexagonalElement<SKNode, SKNode>>()
    
    override func updateGameLogic(currentTime: NSTimeInterval) {
    
        grid.addPolygon(playerNode.currentVertices) {
            var element = $0
            element.contact = playerNode
            return element
        }
        
        print(grid.count)
    }

    // MARK: Executing the Animation Loop
    
    private var currentPlayerDegree: CGFloat { return max(min(accelX*0.5*CGFloat.π, playerNode.maxDegree), -playerNode.maxDegree) }
    private var currentPlayerSpeed: CGVector { return CGVector(dx: sin(currentPlayerDegree)*playerNode.currentSpeed, dy: -cos(currentPlayerDegree)*playerNode.currentSpeed) }

    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        if let accelerometerData = motionManager.accelerometerData {
            accelX = (CGFloat(accelerometerData.acceleration.x) + calibration) * direction.rawValue * highPassFilterFactor + accelX * (1.0 - highPassFilterFactor)
        }
        
        playerNode.zRotation = currentPlayerDegree
        playerNode.position = playerNode.position+currentPlayerSpeed
    }
    
    // MARK: Grid delegate
    
    func didBeginResolveContacts() {}
    
    func didResolveContactInElement(element: Any) {}
    
    func didEndResolveContacts() {}
}
