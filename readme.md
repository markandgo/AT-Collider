# Advanced Tiled Collider

Advanced Tiled Collider (ATC) is a collision class for Advanced Tiled Loader (ATL) [Link](https://github.com/Kadoba/Advanced-Tiled-Loader).

Check out the demo branch for example LOVE files: [Demo](https://github.com/markandgo/AT-Collider/tree/demo)

Features:

* Requires ATL 0.12 (Untested for other versions)
* Customizable collision callback for all sorts of possibilities
* Supports the use of vertical/horizontal height maps for slopes
* Continuous collision detection ensures that nothing is missed

Limitations:

* Isometric orientation is not supported
* ATL offsets ( **offsetX** and **offsetY** ) aren't handled correctly

To load the class and create a new collision object:  
````lua
atc     = require 'atc'
object  = atc.new(x,y,width,height,map,tileLayer)
````

## Properties

The collision class creates a collision object that can interact with an ATL map. The object is a rectangle and has the following properties:

**atc.x** (`default: nil`)
The top left x position of the rectangle

**atc.y** (`default: nil`) 
The top left y position of the rectangle

**atc.w** (`default: nil`)
The width of the rectangle

**atc.h** (`default: nil`) 
The height of the rectangle

**atc.map** (`default: nil`) 
The associated ATL map for collision detection

**atc.tileLayer** (`default: nil`) 
The associated tile layer for collision detection

**atc.isActive** (`default: true`)    
If `false`, the object ignores all tile collision with **atc.move** or **atc.moveTo** 

**atc.isBullet** (`default: false`)  
If `true`, use continuous collision detection with **atc.move** or **atc.moveTo**. `false` is default for best performance.

## Height Maps

Vertical and horizontal height maps are supported for slopes. Just define an array (`verticalHeightMap` or `horizontalHeightMap`) of height values for each tile under `tile.properties`. For an object's position, vertical height maps adjust it vertically, while horizontal height maps adjust it horizontally. A tile can have both height maps at the same time. See the following for how it works.

````
ASCII ART EXAMPLE

The following art shows the shape of a slope tile depending on which side touches it.
=================
4x4 tile example

tile.properties.verticalHeightMap = {1,2,3,4}

**Vertical Height Map**

"bottom"
4       |
3     | |
2   | | |
1 | | | |
  1 2 3 4

"top"
1 | | | |
2   | | |
3     | |
4       |
  1 2 3 4

**Horizontal Height Map**

tile.properties.horizontalHeightMap = {1,2,3,4}

"left"
1 =
2 = =
3 = = =
4 = = = =
  1 2 3 4

"right"
1       =
2     = =
3   = = =
4 = = = =
  4 3 2 1
````

## Public Functions

**NOTE**  
All objects inherit the class functions and data. One function of particular importance is **isResolvable**; one can define it in **atc** or define it per **object**.

`boolean` = **atc.isResolvable**`(object,side,gx,gy,tile)`  
Collision callback for when a rectangle's `side` overlaps with a slope or tile. Returns true if the collision should be resolved. The `side` parameter is the side of the rectangle that detected the tile. `gx` and `gy` are the grid coordinates of the tile. The `side` parameter affects the direction the rectangle is moved to resolve the collision. For example, if `side` is `right`, the rectangle will be moved left.

Valid `side`:  
* `left`
* `right`
* `top`
* `bottom`

**NOTE**  
It's possible for multiple sides to overlap the same tile. One can fall into the trap of resolving a tile collision more than once or with the wrong side! It's possible to avoid this by setting tiles to be floor, ceiling, or wall tiles and resolve collisions with specific sides. Another method is to resolve collision with specific sides depending on the direction of your movement.

**atc.moveTo**`(object,x,y)`  
Move the object to `x`,`y` and resolve all collisions. If `atc.isBullet` is `true`, continuous collision detection is used to prevent tunneling through tiles. Horizontal movements are applied before vertical movements.

**atc.move**`(object,dx,dy)`  
Move the object by `dx`,`dy` amounts and resolve all collisions.

**atc.draw**`(object,mode)`  
Draw the object where mode is `fill` or `line`.

## Private Functions

`gx,gy,gx2,gy2` = **atc.getTileRange**`(object)`  
Returns `gx`,`gy`,`gx2`,`gy2`, which are the tile range occupied by the rectangle. `gx` and `gy` is the top left corner, `gx2`,`gy2` is the bottom right corner.

**atc.rightSideResolve**`(object)`  
Resolve right side collision. For **rightSideResolve**, any tile that overlaps the rectangle's right line is checked for collision.

**atc.leftSideResolve**`(object)`  
...

**atc.topSideResolve**`(object)`  
...

**atc.bottomSideResolve**`(object)`  
....

**atc.resolveX**`(object)`  
Resolve right and left side collisions

**atc.resolveY**`(object)`  
Resolve top and bottom side collisions
