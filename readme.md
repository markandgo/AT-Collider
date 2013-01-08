# Advanced Tiled Collider

Advanced Tiled Collider (ATC) is a collision module for Advanced Tiled Loader (ATL) [Link](https://github.com/Kadoba/Advanced-Tiled-Loader).

Check out the demo branch for example LOVE files: [Demo](https://github.com/markandgo/AT-Collider/tree/demo)

Features:

* Fully compatible with ATL 0.12 (Untested for other versions)
* Customizable collision callback for all sorts of possibilities
* Supports the use of vertical/horizontal height maps for slopes
* Continuous collision detection ensures that nothing is missed

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
If false, the object ignores all tile collision

## Height Maps

Vertical and horizontal height maps are supported for slopes. Just define an array (`verticalHeightMap` or `horizontalHeightMap`) of height values for each tile under `tile.properties`. The height value to be used is checked by the ends of each side. So for vertical height maps, the endpoints of the `bottom` or `top` sides are used to index the height values. For horizontal height maps, The endpoints of the `left` or `right` sides are used. Arrays must include **0** as a valid index.

````lua
-- create a 45 degree slope for a 32x32 tile
local h = {}
for i = 0,32 do
	h[i] = i
end

-- set vertical and horizontal height maps
tile.properties.verticalHeightMap   = h
tile.properties.horizontalHeightMap = h
````

## Public Functions

**object.setMapAndLayer**`(self,map,layer)`  
Set the map and tile layer to be used.

**object.isResolvable**`(self,side,gx,gy,tile)`  
Collision callback for when the rectangle's **edges** overlap with a slope or tile. Returns true if the collision should be resolved. The `side` parameter is the side of the rectangle that detected the tile. `gx` and `gy` are the grid coordinates of the tile. The `side` parameter affects the direction the rectangle is moved to resolve the collision. For example, if `side` is `right`, the rectangle will be moved left.

Valid `side`:  
* `left`
* `right`
* `top`
* `bottom`

**object.moveTo**`(self,x,y)`  
Move the object to `x`,`y` and resolve all collisions. No continuous collision detection is used.

**object.move**`(self,dx,dy)`  
Move the object by `dx`,`dy` amounts and resolve all collisions. Continuous collision detection is used to prevent tunneling through tiles at extreme speeds. Note that movements are broken down into horizontal and vertical movements. Horizontal movements are applied before vertical movements.

**object.draw**`(self,mode)`  
Draw the object where mode is `fill` or `line`.

## Private Functions

**object.getRange**`(self)`  
Returns `gx`,`gy`,`gx2`,`gy2`, which are the tile range occupied by the rectangle. `gx` and `gy` is the top left corner, `gx2`,`gy2` is the bottom right corner.

**object.rightSideResolve**`(self,gx,gy,gw,gh)`  
Resolve right side collision based on grid line. Either `gw` or `gh` must be 0.

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