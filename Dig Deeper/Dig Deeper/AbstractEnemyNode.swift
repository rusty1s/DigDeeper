//
//  AbstractEnemyNode.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 02.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSShapeNode

class AbstractEnemyNode : AbstractMovingNode {
    
    enum Stage {
        case Patrol
        case Attack
        case Surrender
        case Dead
    }
    
    enum Intelligence {
        case Weak
        case Intermediate
        case Strong
    }
    
    enum AttackRange {
        case Melee
        case Ranged
    }
    
    private struct Action {
        static let key = "baseMovement"
    }
    
    // MARK: Initializers
    
    override init(vertices: [CGPoint], defaultSpeed: CGFloat, maxSpeed: CGFloat) {
        super.init(vertices: vertices, defaultSpeed: defaultSpeed, maxSpeed: maxSpeed)
        
        name = "enemy"
        
        self.patrolPath = [CGPoint(x: -100, y: 0), CGPoint(x: 0, y: 100), CGPoint(x: 100, y: -100)]
        patrol()
        
        CGPathCreateWithEllipseInRect(CGRect(x: -spotRadius, y: -spotRadius, width: 2*spotRadius, height: 2*spotRadius), nil)
        
        let spotRadiusNode = RSShapeNode()
        spotRadiusNode.lineWidth = 0
        spotRadiusNode.fillColor = SKColor.whiteColor()
        spotRadiusNode.blendMode = SKBlendMode.Add
        spotRadiusNode.alpha = 0.05
        spotRadiusNode.path = CGPathCreateWithEllipseInRect(CGRect(x: -spotRadius, y: -spotRadius, width: 2*spotRadius, height: 2*spotRadius), nil)
        //addChild(spotRadiusNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance variables
    
    let attackRange: AttackRange = .Melee
    
    let intelligence: Intelligence = .Weak
    
    private(set) var stage = Stage.Patrol {
        didSet { removeActionForKey(Action.key) }
    }
    
    // MARK: Patrol variables
    
    private(set) var patrolPath: [CGPoint] {
        set {
            let offset = newValue.count > 2 ? CGPoint(x: (newValue.first!.x+newValue.last!.x)/CGFloat(2), y: (newValue.first!.y+newValue.last!.y)/CGFloat(2)) : newValue[0]
            _patrolPath = newValue.map { CGPoint(x: $0.x-offset.x, y: $0.y-offset.y) }
        }
        get { return _patrolPath }
    }
    private var _patrolPath: [CGPoint] = []
    
    // MARK: Attack variables
    
    private let spotRadius: CGFloat = 400
    
    private let attackRadius: CGFloat = 100
    
    private let minRadius: CGFloat = 10
    
    // MARK: Surrender variables
    
    private let surrenderDuration: NSTimeInterval = 2
    
    private let waitDuration: NSTimeInterval = 0
    
    // MARK: Instance functions
    
    private func patrol() {
        stage = .Patrol
  
        runAction(SKAction.repeatActionForever(SKAction.followPath(CGPath.smoothPathOfVertices(patrolPath, closed: true), asOffset: true, orientToPath: true, speed: defaultSpeed*60.0)), withKey: Action.key)
    }
    
    func attackPlayer(player: AbstractPlayerNode) {
        if (player.position-position).length > spotRadius { return }
        
        stage = .Attack
        
        let toPoint: CGPoint
        switch intelligence {
        case .Weak: toPoint = player.position
        case .Intermediate: toPoint = player.position
        case .Strong: toPoint = player.position
        }
        
        let angle = acos((toPoint-position).toLength(currentSpeed).dy/currentSpeed)
        print(angle)
        //let maxRotationStep: CGFloat = 0.03*currentSpeed
        zRotation = angle//+= max(min(angle-self.zRotation, maxRotationStep), -maxRotationStep)
       
        position += CGVector(dx: -currentSpeed*sin(zRotation), dy: currentSpeed*cos(zRotation))
    }
    
    private func surrender() {
        stage = .Surrender
        
        var sequence: [SKAction] = []
        if stage == .Attack {
            let runOut = SKAction.moveBy(CGVector(dx: -sin(zRotation)*defaultSpeed*CGFloat(60.0*surrenderDuration), dy: -cos(zRotation)*defaultSpeed*CGFloat(60.0*surrenderDuration)), duration: surrenderDuration)
            sequence.append(runOut)
        }
        sequence.append(SKAction.waitForDuration(waitDuration))
        sequence.append(SKAction.runBlock { self.patrol() })
        
        runAction(SKAction.sequence(sequence), withKey: Action.key)
    }
    
    private func die() {
        stage = .Dead
    }
}
