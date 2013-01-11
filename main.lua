-- SIMPLE PLATFORMER EXAMPLE

function love.load()
	-- load libs and map
	atl     = require 'libs.ATL'
	atlMap  = atl.Loader.load 'map/map.tmx'
	entity  = require 'libs.atc.atc'
	
	-- create player at x = 32, y = 32, width = 20, height = 20
	-- also we need to specify the map and tile layer for collision
	player  = entity.new(32,32,20,20,atlMap,select(2,next(atlMap.layers)))
	
-------------------------------------------------------------------------------
	-- set up collision callback
	-- this gets called whenever a side detects a tile/slope
	-- callback needs to return true if you want the collision to be resolved
	-- note that multiple sides can overlap the same tile
	-- (!) so it's possible that a tile is detected more than once per movement (!)
	-- (!) so be careful of resolving a tile collision more than once (!)
	function player:isResolvable(side,gx,gy,tile)
		-- all the following tile properties can be set in Tiled
		-- in this demo, I gave each tile a "type" value to differentiate them
		local tp = tile.properties
		
		if tp.type  == 'solid' then
			-- set to ground state if bottom sensor
			if side == 'bottom' then inAir = false; vy = 0 end
			return true
		end
		
		-- A TILE CAN HAVE BOTH TYPES OF HEIGHT MAPS AT THE SAME TIME!
		-- slope checks:
		
		-- in this demo, we give floor slopes vertical height maps
		-- vertical height maps adjust an object's position vertically
		if  (tp.type == 'slopeUp' or tp.type == 'slopeDown') and  side == 'bottom' then 
			-- change to ground state
			vy    = 0
			inAir = false
			return true 
		end
		
		-- in this demo, we give ceiling slopes horizontal height maps		
		-- horizontal height maps adjust an object's position horizontally
		if tp.type == 'ceilingDown' and side == 'right' then 
			return true 
		end
		
		if tp.type == 'ceilingUp' and side == 'left' then 
			return true 
		end
	end
-------------------------------------------------------------------------------	
	-- set up heightmaps
	-- Inspiration:
	-- http://info.sonicretro.org/SPG:Solid_Tiles
	-- 45 degree angle:
	local h = {}; local h2 = {}
	for i = 1,32 do
		h[i] = i
	end
	for i = 1,32 do
		h2[i] = 33-i
	end
	
	-- assign height maps to approriate tiles
	for id,tile in pairs(atlMap.tiles) do
		local tp = tile.properties
		if tp.type == 'slopeUp' then
			tp.verticalHeightMap   = h
		elseif tp.type == 'slopeDown' then
			tp.verticalHeightMap   = h2
		elseif tp.type == 'ceilingUp' then
			tp.horizontalHeightMap = h2
		elseif tp.type == 'ceilingDown' then
			tp.horizontalHeightMap = h2
		end
	end
-------------------------------------------------------------------------------		
	-- player initial velocity
	vx,vy    = 200,0
	-- gravity
	gravity  = 300
end
-------------------------------------------------------------------------------
function love.draw()
	atlMap:draw()
	player:draw('fill')
	love.graphics.print('Left mouse click to reposition the player',32,500)
	love.graphics.print('Arrows to move',32,512)
end
-------------------------------------------------------------------------------
function love.mousepressed(x,y,k)
	if k == 'l' then player.x = x-player.w/2; player.y = y-player.h/2 end
end
-------------------------------------------------------------------------------
local jump_time = 0
function love.update(dt)
	-- movement for player
	if love.keyboard.isDown('left') then
		dx   = -vx*dt
	elseif love.keyboard.isDown('right') then
		dx   = vx*dt
	else
		dx   = 0
	end
	
	-- apply gravity
	vy = vy + gravity*dt
	dy = vy*dt+gravity*dt^2/2
	
	-- prevent jumping more than once
	if not inAir and love.keyboard.isDown('up') then
		inAir = true
		vy    = -vx
		dy    = vy*dt
	end
	player:move(dx,dy)
end