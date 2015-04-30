//
//  GameScene.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 21.02.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

import SpriteKit
import CoreMotion

enum AccelerometerDirection : CGFloat {
    case Default = 1
    case Inverted = -1
}

let edgeNodeCategoryBitMask: UInt32 = 0x1 << 0
let movingNodeCategoryBitMask: UInt32 = 0x1 << 1
let playerNodeCategoryBitMask: UInt32 = 0x1 << 2
let enemyNodeCategoryBitMask: UInt32 = 0x1 << 3
let destructibleNodeCategoryBitMask: UInt32 = 0x1 << 4

class GameScene : SKScene, SKPhysicsContactDelegate, GridContactDelegate {
    
    // MARK: Attributes
    
    private let grid = Grid()
    
    private let playerNode = PlayerNode()
    private var movingNodes: Set<MovingNode> = []
    
    private let pathNode = PathNode()
    
    private var oreNodes: Set<OreNode> = []
    
    private var actDegree: CGFloat { return max(min(accelX*0.5*CGFloat.π, playerNode.maxDegree), -playerNode.maxDegree) }  // max 90°
    private var actSpeed: CGVector { return CGVector(dx: sin(actDegree)*playerNode.actSpeed, dy: -cos(actDegree)*playerNode.actSpeed) }
    
    var center: CGPoint { return childNodeWithName("//camera")!.position }
    var bounds: CGRect {
        let center = self.center
        return CGRect(x: center.x+size.width/2, y: center.y+size.height/2, width: -size.width, height: -size.height)
    }
    
    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        size = view.bounds.size
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        grid.delegate = self
        
        setupNodes()
        
        startAccelerometer()
    }
    
    private func setupNodes() {
        let world = SKNode()
        world.name = "world"
        addChild(world)
        
        let camera = SKNode()
        camera.name = "camera"
        world.addChild(camera)
        
        let gridNode = GridNode(size: self.size)
        world.addChild(gridNode)
        
        playerNode.position = CGPoint(x: 0, y: playerNode.size.height/2)
        world.addChild(playerNode)
        movingNodes.insert(playerNode)
        
        world.addChild(pathNode)
        
        let oreNode = OreNode(points: [CGPoint(x: 0, y: 0), CGPoint(x: 80, y: 0), CGPoint(x: 120, y: -30), CGPoint(x: 100, y: -70), CGPoint(x: 60, y: -60), CGPoint(x: 10, y: -80), CGPoint(x: -20, y: -40)])
        oreNode.position = CGPoint(x: -22, y: -75)
        oreNodes.insert(oreNode)
        grid.detectContactsOfPolygonFromVertices(oreNode.vertices) { $0.content = oreNode }
        world.addChild(oreNode)
        
        let oreNode2 = OreNode(points: [CGPoint(x: 1, y: -1), CGPoint(x: 39, y: -1), CGPoint(x: 39, y: -39), CGPoint(x: 1, y: -39)])
        oreNode2.position = CGPoint(x: -15, y: -202)
        oreNodes.insert(oreNode2)
        grid.detectContactsOfPolygonFromVertices(oreNode2.vertices) { $0.content = oreNode2 }
        world.addChild(oreNode2)
    }
    
    // MARK: Motion manager
    
    private let motionManager = CMMotionManager()
    
    var direction = AccelerometerDirection.Default
    var calibration: CGFloat = 0.0
    
    private let highPassFilterFactor: CGFloat = 0.1
    private var accelX: CGFloat = 0.0
    
    private func startAccelerometer() {
        if motionManager.accelerometerAvailable && !motionManager.accelerometerActive { motionManager.startAccelerometerUpdates() }
    }
    
    private func stopAccelerometer() {
        if motionManager.accelerometerActive { motionManager.stopAccelerometerUpdates() }
    }
    
    // MARK: Camera positioning
    
    private func positionCameraOnNode(node: SKNode) {
        let camera = childNodeWithName("//camera")!
        
        camera.position = node.position
        camera.parent?.position = camera.parent!.position - camera.scene!.convertPoint(camera.position, fromNode: camera.parent!)
    }
    
    // MARK: Grid management
    
    private var showsGrid_ = true
    var showsGrid: Bool {
    set {
        childNodeWithName("//grid")?.hidden = !newValue
        showsGrid_ = newValue
    }
    get { return showsGrid_ }
    }
    
    private func positionGrid() {
        childNodeWithName("//grid")?.position = Grid.Segment.positionOfSegmentPoint(Grid.Segment.segmentPointOfPosition(center))
    }
    
    // MARK: Sprite kit rendering loop
    
    override func update(currentTime: NSTimeInterval) {
        if motionManager.accelerometerData != nil {
            accelX = (CGFloat(motionManager.accelerometerData.acceleration.x) + calibration) * direction.rawValue * highPassFilterFactor + accelX * (1.0 - highPassFilterFactor)
        }
        
        playerNode.zRotation = actDegree
        playerNode.position = playerNode.position + actSpeed
    }
    
    override func didFinishUpdate() {
        positionCameraOnNode(playerNode)
        if showsGrid { positionGrid() }
    }
    
    override func didSimulatePhysics() {
        for movingNode in movingNodes {
            grid.detectContactsOfPolygonFromVertices(movingNode.vertices) { $0.contactedObject = movingNode }
        }
        
        let topLeftSegment = Grid.Segment.segmentPointOfPosition(self.bounds.origin)
        grid.removeSegmentsWithFilter { $0.point.y > topLeftSegment.y }
        
        grid.resolveContacts()
    }
    
    // MARK: Grid contact delegate
    
    func didBeginResolveContacts() {}
    
    func didResolveContactInSegment(segment: Grid.Segment) {
        pathNode.appendPathAtSegment(segment)
        
        for oreNode in oreNodes {
            if !segment.contactedEdgeContactsWithContent(oreNode).isEmpty {
                oreNode.addSegmentToSubtraction(segment)
            }
        }
    }
    
    func didEndResolveContacts() {
        for oreNode in oreNodes { oreNode.subtractAddedSegments() }
    }
    
    // MARK: Physics contact delegate
}
