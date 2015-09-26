# RSContactGrid

`RSContactGrid` is a grid tile map for holding tiles that can be addressed by coordinates implemented in **Swift 2.0**. Actual there are four different grid tile types to choose from (triangular, square, rotated square and hexagonal).

`RSContactGrid` also implements a contact detection for all four different tile types. That means the framework detects the tiles in the grid which are overlayed by any path defined over a finite sequence of `CGPoint`. The images below showcase the different tile types and the contact detection:

![alt Triangular grid](triangular-tile-grid.png)
![alt Square grid](square-tile-grid.png)
![alt Rotated square grid](rotated-square-tile-grid.png)
![alt Hexagonal grid](hexagonal-tile-grid.png)

`RSContactGrid` is totally easy to use:

1. Choose a grid tile type.
	* `TriangularTile`
	* `SquareTile`
	* `RotatedSquareTile`
	* `HexagonalTile`
2. Set its width and height, e.g.: `SquareTile<Bool, Bool>.width = 40.0`. Note the generic type of `SquareTile`. The first type declares the type of the `content` of the element, the second declares the type of the `contact`.
3. Set up the grid: `let grid = Grid<SquareTile<Bool, Bool>>()`
4. Add elements to the grid: `grid.insertAtX(0, y: 0)`
5. **Do the contact detection!**

````
let path = [CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 50), CGPoint(x: 80, y: -20)]
grid.detectContactedTilesOfPath(path, closedPath: true, allowInsertingTiles: false) {
    $0.data.contact = true
}
````
Your tile at `(0,0)` should now be marked as contacted: `grid[0, 0]!.data.contact == true`

For more information browse the documentation section or play with the example project as described in the section below.

## Example project

You can play with the different grid tile types in the example project by just switching the typealias for `TileType` in `GameScene.swift`.

E.g. if you want to play with a triangular tile grid, just change line 24 in `GameScene.swift` to:

	typealias TileType = TriangularTileType

## Installation

`RSContactGrid` is not yet released on CocoaPod. Instead use

```
use_frameworks!

pod 'RSContactGrid', :git => 'https://github.com/rusty1s/RSContactGrid.git'
```

in your Podfile and run `pod install`.

## Documentation

`RSContactGrid` is programmed the *protocol orientated* way introduced by Swift 2.0. That means you can easily switch the implementations by just conforming to the protocols `GridType` and `TileType`.

### GridType

	protocol GridType { ... }

A tile map that holds tiles conforming to `TileType` and addresses these by coordinates `x` and `y`.  Implements a contact detection for any path with the tiles in the grid.

#### Implementations:

* `Grid`
	
#### Inheritance

* `Hashable`
* `Equatable`
* `SequenceType`
* `ArrayLiteralConvertible`
* `CustomStringConvertible`
* `CustomDebugStringConvertible`

#### Associated types
    
	typealias ElementType: TileType
	
#### Initializers

	init()

Create an empty `GridType`.

    init(minimumCapacity: Int)

Create an empty `GridType` with at least the given number of tiles worth of storage.  The actual capacity will be the smallest power of 2 that's >= `minimumCapacity`.
 
    init<S : SequenceType where S.Generator.Element == ElementType>(_ sequence: S)

Create a `GridType` from a finite sequence of tiles.
	
#### Instance variables
   
    var count: Int { get }

Returns the number of elements.
  
#### Instance methods

    mutating func insert(element: ElementType)

Insert a tile into the grid.

	mutating func remove(element: ElementType) -> ElementType?

Remove the tile from the grid and return it if it was present.

    mutating func removeAll(keepCapacity keepCapacity: Bool)

Erase all tiles.  If `keepCapacity` is `true`, `capacity` will not decrease.

#### Subscripts
   
    subscript(x: Int, y: Int) -> ElementType? { get }

Returns the tile of a given position, or `nil` if the position is not present in the grid.

#### Default implementations

	var isEmpty: Bool { get }

`true` if the grid is empty.
 
    mutating func insertAtX(x: Int, y: Int)

Insert an initial tile at position `x`, `y` into the grid.
   
    mutating func removeAtX(x: Int, y: Int) -> ElementType

Remove the tile at position `x`, `y` from the grid and return it if it was present.

	init(arrayLiteral elements: ElementType...)

Create an instance initialized with elements.

	var description: String { get }

A textual representation of `self`.


	var debugDescription: String { get }

A textual representation of `self`, suitable for debugging.

	mutating func detectContactedTilesOfPath(path: [CGPoint], var closedPath: Bool = false, allowInsertingTiles: Bool = true, @noescape detected: ElementType -> ())

Detects and can add the tiles of the grid which are contacted by a path.
* **Parameter** `path`: The vertices of a path as a finite sequence of `CGPoint`.
* **Parameter** `closedPath`: Defines wheter the path is closed. The default value is `false`.
* **Parameter** `allowInsertingTiles`: Allows the grid to insert tiles which are contacted by the path but are not yet inserted into the grid. The default value is `true`.
* **Parameter** `detected`: A function that is called on every tile that is contacted by the path.

### TileType

	protocol TileType { ... }

A tile that can be inserted into an implementation of `GridType`.

#### Implementations

* `TriangularTile`
* `SquareTile`
* `RotatedSquareTile`
* `HexagonalTile`

#### Inheritance

* `Hashable`
* `Comparable`
* `CustomStringConvertible`
* `CustomDebugStringConvertible`

#### Initializiers

	init(x: Int, y: Int)

Create a `TileType` at x- and y-coordinates.
   
#### Instance variables
   
    var x: Int { get }

Returns the x-coordinate of the tile.
   
    var y: Int { get }

Returns the y-coordinate of the tile.
   
	var data: DataType { get }

Addititional information of the tile.

    var vertices: [CGPoint] { get }

The vertices of the tile in its grid's coordinate system as a finite sequence of `CGPoint`.
* **Desirable complexity:** O(1).  

#### Instance functions
   
    func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool

`true` iff the tile intersects with a line segment defined by two inner points of the tiles frame.
* **Parameter** `point1`: The start point of the line as a relative inner point of the tiles frame.  `point1.x` and `point1.y` are restricted to a value between `0` and `1`.
* **Parameter** `point2`: The end point of the line as a relative inner point of the tiles frame.  Follows the same guidelines as `point1`.
* **Desirable complexity:** O(1). 
   
#### Static functions
   
    static func tilesInRect(rect: CGRect) -> Set<Self>

Returns all inital tiles that are overlayed by the rect.

#### Default implementations

    var frame: CGRect { get }

The minimal frame rectangle which describes the tiles location and size in its grids coordinate system. The frame contains all vertices of the tile.
* **Desirable complexity:** O(1).

	var center: CGPoint { get }

The center of the tiles frame rectangle.

## Writing your own grid tile types

You can easily write your own grid tile type by conforming to the `TileType` protocol. That means you have to implement:

* `var x: Int { get }`
* `var y: Int { get }`
* `var data: DataType { get }`
* `init(x: Int, y: Int)`
* `var vertices: [CGPoint] { get }`
* a more efficient version of `var frame: CGRect { get }` (optional)
* `func intersectsRelativeLineSegment(point1 point1: RelativeRectPoint, point2: RelativeRectPoint) -> Bool`
* `static func tilesInRect(rect: CGRect) -> Set<Self>`
* `==` and `<` operands for adopting to the `Comparable` protocol

You can look up the existing tile types (`TriangularTile`, `SquareTile`, `RotatedSquareTile` and `HexagonalTile`) to give you a hint on how to conform to `TileType`.

## Additional information

`RSContactGrid` was developed and implemented for the use in *Dig Deeper - the Mining / Crafting / Trading game*. *Dig Depper* is currently in developement and has its own *GitHub* project [here](../../../DigDeeper).

![alt Dig Deeper](../../../DigDeeper/blob/master/logo.png)

## License

Copyright (c) 2015 Matthias Fey <matthias.fey@tu-dortmund.de>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.