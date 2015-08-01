//
//  RSScene.swift
//  RSScene
//
//  Created by Matthias Fey on 28.07.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

/// `RSScene` inherits `SKScene` by adding a game logic loop to
/// the runtime of a scene. `RSScene` distinguishs between a rendering
/// loop (fps) and a loop, that calls game update logic (tps = ticks
/// per seconds). Because games don't need to update its logic that
/// often, the logic loop typically runs much slower than the rendering
/// loop. This guarantees great performance for all kind of games!
public class RSScene : SKScene {
    
    // MARK: Instance variables
    
    /// The amount of times the game logic is called per second.  The
    /// default value is 30 ticks per seconds.
    public var tps: Int {
        set {
            _tps = max(0, newValue)
            currentTPS = 0
            setTpsLabelCount(0)
        }
        get { return _tps }
    }
    private var _tps: Int = 30
    
    /// A Boolean value that indicates whether the scene's view displays
    /// a game logic rate indicator.
    public var showsTPS: Bool = false {
        didSet { tpsLabel?.hidden = !showsTPS }
    }
    
    /// The quality of service you want to give to the logic loop
    /// executed in the global queue.  The default value is
    /// `QOS_CLASS_BACKGROUND`.
    public var priority: qos_class_t = QOS_CLASS_BACKGROUND
    
    /// A delegate to be called during the logic loop. When the delegate
    /// is present, your delegate is called instead of the corresponding
    /// method on the scene object.
    public var logicDelegate: RSSceneDelegate?
    
    // MARK: Helper instance variables
    
    private var inGameLogic: Bool = false
    
    private var currentTPS: Int = 0
    
    private var startTimeInterval: NSTimeInterval = 0
    
    private var currentTime: NSTimeInterval = 0
    
    private weak var tpsLabel: UILabel?
    
    // MARK: Presenting a scene
    
    /// Called immediately after a scene is presented by a view.
    /// Note that when you override this method, you need to call
    /// its super method.
    public override func didMoveToView(view: SKView) {
        setupTpsLabel()
        tpsLabel?.hidden = !showsTPS
        setTpsLabelCount(0)
    }
    
    /// Called immediately before a scene is removed from a view.
    /// Note that when you override this method, you need to call
    /// its super method.
    public override func willMoveFromView(view: SKView) {
        tpsLabel?.removeFromSuperview()
    }
    
    // MARK: Executing the Game Logic Loop
    
    /// Performs any game-logic-specific updates.
    public func updateGameLogic(currentTime: NSTimeInterval) {}
    
    // MARK: Executing the Animation Loop
    
    /// Performs any scene-specific updates that need to occur before
    /// scene actions are evaluated.  Note that when you override this
    /// method, you need to call its super method.
    public override func update(currentTime: NSTimeInterval) {
        
        // save the current time in a local variable
        self.currentTime = currentTime
        
        // setup the start time interval, if not set yet
        if startTimeInterval == 0 { startTimeInterval = currentTime }
        
        // wait for the execution of the game logic to finish
        if !inGameLogic && tps > 0 {
            
            // wait for the game logic interval to pass the tps
            if currentTime - startTimeInterval > Double(currentTPS)*(1.0/Double(tps)) {
            
                // execute the game logic
                inGameLogic = true
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    if self.logicDelegate != nil {
                        self.logicDelegate?.updateGameLogic(self.currentTime, forScene: self)
                    }
                    else {
                        self.updateGameLogic(self.currentTime)
                    }
                    
                    self.currentTPS++
                    // if a second has passed, reset local variables
                    if self.currentTime > 1.0+self.startTimeInterval {
                        let tps = min(self.currentTPS, self.tps)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.setTpsLabelCount(tps)
                        }
                        self.currentTPS = 0
                        self.startTimeInterval = self.currentTime
                    }
                    
                    self.inGameLogic = false
                }
            }
        }
    }
    
    // MARK: Helper
    
    private func setupTpsLabel() {
        let label = UILabel(frame: CGRect(x: 4, y: 20, width: 60, height: 15))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Menlo", size: 10)
        view?.addSubview(label)
        
        tpsLabel?.removeFromSuperview()
        tpsLabel = label
    }
    
    private func setTpsLabelCount(count: Int) {
        tpsLabel?.text = "tps: \(count).0"
    }
}
