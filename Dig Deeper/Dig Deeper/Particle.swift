//
//  Particle.swift
//  Dig Deeper
//
//  Created by Matthias Fey on 02.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

class Particle {
    
    // MARK: Paths
    
    private struct Path {
        static let earth = "Earth"
        static let smoke = "Smoke"
    }
    
    // MARK: Static functions
    
    static func particleWithName(name: String) -> SKEmitterNode? {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "sks") {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode
        }
        else { return nil }
    }
    
    static func runEarthAtPosition(position: CGPoint, withAngle angle: CGFloat, inView view: SKNode) {
        let particle = particleWithName(Path.earth)
        particle?.position = position
        particle?.emissionAngle = angle + 0.5*CGFloat.π
        
        if particle != nil { view.addChild(particle!) }
        particle?.runAction(SKAction.waitForDuration(1)) { particle?.removeFromParent() }
    }
    
    static func runSmokeParticleAtPosition(position: CGPoint, inView view: SKNode) {
        let particle = particleWithName(Path.smoke)
        particle?.position = position
        
        if particle != nil { view.addChild(particle!) }
    }
}
