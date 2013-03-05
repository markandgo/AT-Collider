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
If a `tileLayer` is not specified, a layer in **map.layers** will be selected for you. This is useful if your map only has one layer.

## Properties

The collision class creates a collision object that can interact with an ATL map. The object is a rectangle and has the following properties:

**object.x** (`default: nil`)
The top left x position of the rectangle

**object.y** (`default: nil`) 
The top left y position of the rectangle

**object.w** (`default: nil`)
The width of the rectangle

**object.h** (`default: nil`) 
The height of the rectangle

**object.map** (`default: nil`) 
The associated ATL map for collision detection

**object.tileLayer** (`default: nil`) 
The associated tile layer for collision detection

**object.isActive** (`default: true`)    
If `false`, the object ignores all tile collision with **object.move** or **object.moveTo** 

**object.isBullet** (`default: false`)  
If `true`, use continuous collision detection with **object.move** or **object.moveTo**. `false` is default for best performance.

## Public Functions

`boolean` = **object:isResolvable**`(side,tile,gx,gy)`  
This is the user defined collision callback. It gets called whenever a sensor overlaps with a slope or tile. The `side` parameter marks what type of sensor it is. 

Sensor types ( `side` ):
* `left`
* `right`
* `top`
* `bottom`

By default, the `left` sensor covers the left half area of the rectangle, and the `right` sensor covers the right half area. The `top` sensor covers the top half area of the rectangle, and the `bottom` sensor covers the bottom half area.

![Sensors](/sensors.png "Sensors")

The `tile` object is passed as an argument for tile specific collision. `tile` properties can be set in Tiled or in `tile.properties`. `gx` and `gy` are the grid coordinates of the tile. The `side` parameter affects the direction the object is moved to resolve the collision. For example, if `side` is `right`, the object will be moved left. The callback must return `true` for the collision to be resolved.

**Note**  
`right` is checked before `left`, and `bottom` is checked before `top` when moving. If your object is moving too fast, the `right`/`bottom` sensor could detect a tile when moving **left** / **up** and resolve the collision. One can avoid this problem by checking the direction of movement and only resolve collision with specific sensors.

Example:  
````lua
-- direction check for fast objects
function object:isResolvable(side,tile,gx,gy)
	if side == 'right' or side == 'left' then
		if dx == 0 then return true end
		if dx > 0 and side == 'right' then return true end
		if dx < 0 and side == 'left' then return true end
	end
	if side == 'bottom' or side == 'top' then
		if dy == 0 then return true end
		if dy > 0 and side == 'bottom' then return true end
		if dy < 0 and side == 'top' then return true end
	end
end
````

**object:moveTo**`(x,y)`  
Move the object to `x`,`y` and resolve all collisions. If `object.isBullet` is `true`, continuous collision detection is used to prevent tunneling through tiles. Horizontal movements are applied before vertical movements.

**object:move**`(dx,dy)`  
Move the object by `dx`,`dy` amounts and resolve all collisions.

**object:draw**`(mode)`  
Draw the object where mode is `fill` or `line`.

`object` = **object:setSize**`(width,height)`

`object` = **object:setMap**`(map)`

`object` = **object:setTileLayer**`(tileLayer)`

`object` = **object:setActive**`(boolean)`

`object` = **object:setBullet**`(boolean)`

`boolean` = **object:isActive**`()`

`boolean` = **object:isBullet**`()`

`x,y,width,height` = **object:unpack**`()`

## Private Functions

`object` = **object:rightResolve**`(x,y,w,h)`  
Resolve right sensor collision. `x,y,w,h` is the rectangular range of the sensor. All tiles overlapping the sensor is checked for collision.

`object` = **object:leftResolve**`(x,y,w,h)`  
...

`object` = **object:bottomResolve**`(x,y,w,h)`  
...

`object` = **object:topResolve**`(x,y,w,h)`  
....

`object` = **object:resolveX**`()`  
Resolve right and left sensor collisions.

`object` = **object:resolveY**`()`  
Resolve top and bottom sensor collisions.

## Height Maps

Vertical and horizontal height maps are supported for slopes. Just define an array ( `verticalHeightMap` or `horizontalHeightMap` ) of height values for each tile under tile.properties. For an object's position, vertical height maps adjust it vertically, while horizontal height maps adjust it horizontally. A tile can have both height maps at the same time. The following ASCII art shows the "shape" of a slope depending on which side touches it.

````
ASCII ART EXAMPLE
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