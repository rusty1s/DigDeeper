//
//  RSSceneDelegate.swift
//  RSScene
//
//  Created by Matthias Fey on 28.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

/// The `RSSceneDelegate` protocol is used to implement a delegate
/// to be called whenever the logic of the scene is being calculated.
/// Typically, you supply a delegate when you want to use a scene without
/// requiring the scene to be subclassed. The method in this protocol
/// correspond to the method implemented by the `RSScene class. If the delegate
/// is present, the method is called instead of the corresponding method on
/// the scene object.
public protocol RSSceneDelegate {
    
    /// Performs any game-logic-specific updates.
    func updateGameLogic(currentTime: NSTimeInterval, forScene scene: RSScene)
}
