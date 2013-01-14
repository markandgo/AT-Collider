# Advanced Tiled Collider

Advanced Tiled Collider (ATC) is a collision module for Advanced Tiled Loader (ATL) [Link](https://github.com/Kadoba/Advanced-Tiled-Loader).

Check out the demo branch for example LOVE files: [Demo](https://github.com/markandgo/AT-Collider/tree/demo)

Features:

* Requires ATL 0.12 (Untested for other versions)
* Customizable collision callback for all sorts of possibilities
* Supports the use of vertical/horizontal height maps for slopes
* Continuous collision detection ensures that nothing is missed

Limitations:

* Isometric orientation is not supported
* ATL offsets ( **offsetX** and **offsetY** ) aren't handled correctly

To load and create a new collision object:

````lua
atc     = require 'atc'
object  = atc.new(x,y,width,height,map,tileLayer)
````

## Properties

The collision module creates a collision object that can interact with an ATL map. The object is a rectangle and has the following properties:

**object.x**  
The top left x position of the rectangle

**object.y**  
The top left y position of the rectangle

**object.w**  
The width of the rectangle

**object.h**  
The height of the rectangle

**object.map**  
The associated ATL map for collision detection

**object.tileLayer**  
The associated tile layer for collision detection

**object.isActive** (`default: true`)    
If `false`, the object ignores all tile collision with **object.move** or **object.moveTo** 

**object.isBullet** (`default: false`)  
If `true`, use continuous collision detection with **object.move** or **object.moveTo**. `false` is default for best performance.

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

**object.isResolvable**`(self,side,gx,gy,tile)`  
Collision callback for when a rectangle's `side` overlaps with a slope or tile. Returns true if the collision should be resolved. The `side` parameter is the side of the rectangle that detected the tile. `gx` and `gy` are the grid coordinates of the tile. The `side` parameter affects the direction the rectangle is moved to resolve the collision. For example, if `side` is `right`, the rectangle will be moved left.

Valid `side`:  
* `left`
* `right`
* `top`
* `bottom`

**NOTE**  
It's possible for multiple sides to overlap the same tile. One can fall into the trap of resolving a tile collision more than once or with the wrong side! It's possible to avoid this by setting tiles to be floor, ceiling, or wall tiles and resolve collisions with specific sides. Another method is to resolve collision with specific sides depending on the direction of your movement.

**object.moveTo**`(self,x,y)`  
Move the object to `x`,`y` and resolve all collisions. If `object.isBullet` is `true`, continuous collision detection is used to prevent tunneling through tiles. Horizontal movements are applied before vertical movements.

**object.move**`(self,dx,dy)`  
Move the object by `dx`,`dy` amounts and resolve all collisions.

**object.draw**`(self,mode)`  
Draw the object where mode is `fill` or `line`.

## Private Functions

**object.getRange**`(self)`  
Returns `gx`,`gy`,`gx2`,`gy2`, which are the tile range occupied by the rectangle. `gx` and `gy` is the top left corner, `gx2`,`gy2` is the bottom right corner.

**object.rightSideResolve**`(self,gx,gy,gw,gh)`  
Resolve right side collision with a specified line of tiles. Either `gw` or `gh` must be 0. So for **rightSideResolve**, the grid line is vertical with `gw = 0`.

**object.leftSideResolve**`(self,gx,gy,gw,gh)`  
...

**object.topSideResolve**`(self,gx,gy,gw,gh)`  
...

**object.bottomSideResolve**`(self,gx,gy,gw,gh)`  
....

**object.resolveX**`(self)`  
Resolve right and left side collisions

**object.resolveY**`(self)`  
Resolve top and bottom side collisions
