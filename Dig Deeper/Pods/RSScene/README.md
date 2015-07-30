# RSScene

`RSScene` inherits `SKScene` by adding a game logic loop to the runtime of a scene implemented in **Swift**. `RSScene` distinguishs between a rendering loop (fps) and a loop, that calls game update logic. The logic loop typically runs much slower than the rendering loop, because games don't need to update its logic that often. This guarantees great performance for all kind of games!

## Usage

1. Let your scene implementation inherits `RSScene` instead of `SKScene`.
2. Set the logic loop rate, called `tps` (ticks per seconds), e.g. `self.tps = 10`.
3. You can display the current tps of your scene by writing `self.showsTPS = true`, suitable for debugging.
4. Update your game logic in `updateGameLogic(currentTime: NSTimeInterval)`.

**Info:** When overriding your scene methods `didMoveToView`, `willMoveFromView` or `update`, you need to call its super methods first!

## Installation

`RSScene` is not yet released on CocoaPod. Instead use

```
use_frameworks!

pod 'RSScene', :git => 'https://github.com/rusty1s/RSScene.git'
```

in your Podfile and run `pod install`.

## Documentation

### RSScene

	class RSScene { ... }

#### Inheritance

* `SKScene`

#### Instance variables

	var tps: Int { get set }

The amount of times the game logic is called per second. The default value is 30 ticks per seconds.

	var showsTPS: Bool { get set }

A Boolean value that indicates whether the scene's view displays a game logic rate indicator.

	var priority: qos_class_t { get set }

The quality of service you want to give to the logic loop executed in the global queue. The default value is `QOS_CLASS_BACKGROUND`.

	var logicDelegate: RSSceneDelegate? { get set }

A delegate to be called during the logic loop. When the delegate is present, your delegate is called instead of the corresponding method on the scene object.

#### Executing the Game Logic Loop
   
    public func updateGameLogic(currentTime: NSTimeInterval)

Performs any game-logic-specific updates.

### RSSceneDelegate

The `RSSceneDelegate` protocol is used to implement a delegate to be called whenever the logic of the scene is being calculated. Typically, you supply a delegate when you want to use a scene without requiring the scene to be subclassed. The method in this protocol correspond to the method implemented by the `RSScene` class. If the delegate is present, the method is called instead of the corresponding method on the scene object.

	protocol RSSceneDelegate { ... }

#### Instance methods

    func updateGameLogic(currentTime: NSTimeInterval, forScene scene: RSScene)

Performs any game-logic-specific updates.

## Additional information

`RSScene` was developed and implemented for the use in *Dig Deeper - the Mining / Crafting / Trading game*. *Dig Depper* is currently in developement and has its own *GitHub* project [here](../../../DigDeeper).

![alt Dig Deeper](../../../DigDeeper/blob/master/logo.png)

## License

Copyright (c) 2015 Matthias Fey <matthias.fey@tu-dortmund.de>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.