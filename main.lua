function love.load()
	-- load libs and map
	atl     = require 'libs.ATL'
	atlMap  = atl.Loader.load 'map/map.tmx'
	entity  = require 'libs.atc.atc'
	
	-- create player at x = 32, y = 32, width = 32, height = 32
	-- also we need to specify the map and tile layer for collision
	player  = entity.new(32,32,32,32,atlMap,select(2,next(atlMap.layers)))
	
-------------------------------------------------------------------------------
	-- set up collision callback
	-- this gets called whenever a side detects a tile/slope
	-- callback needs to return true if you want the collision to be resolved
	-- note that multiple sides can overlap the same tile
	-- so it's up to you to determine which way you want to be "popped out"
	-- because you don't know which side will invoke the callback first
	function player:isResolvable(side,gx,gy,tile)
		-- all the following tile properties can be set in Tiled
		-- in this demo, I gave each tile a "type" value to differentiate them
		local tp = tile.properties
		
		if tp.type  == 'solid' then
			-- if the object isn't moving, just pop out from whichever side touches it first
			if dx == 0 and dy == 0 then return true end
			-- pop out in a specific direction depending on movement
			-- we do dx,dy check because multiple sides can overlap the same tile
			if dx > 0 and side == 'right' then return true end
			if dx <  0 and side == 'left' then return true end
			if dy > 0 and side == 'bottom' then return true end
			if dy <  0 and side == 'top' then return true end
		end
		
		-- slope checks:
		
		-- for vertical height maps
		-- vertical height maps adjust an object's position vertically
		if enableVerticalHeightMap then
			if (tp.type == 'slopeUp' or tp.type == 'slopeDown') and side == 'bottom' then return true end
			if (tp.type == 'ceilingUp' or tp.type == 'ceilingDown') and side == 'top' then return true end
		end
		
		-- for horizontal height maps
		-- horizontal height maps adjust an object's position horizontally
		if enableHorizontalHeightMap then
			if (tp.type == 'slopeUp' or tp.type == 'ceilingDown') and side == 'right' then return true end
			if (tp.type == 'slopeDown' or tp.type == 'ceilingUp') and side == 'left' then return true end
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
			tp.horizontalHeightMap = h
			tp.verticalHeightMap   = h
		elseif tp.type == 'slopeDown' then
			tp.horizontalHeightMap = h
			tp.verticalHeightMap   = h2
		elseif tp.type == 'ceilingUp' then
			tp.horizontalHeightMap = h2
			tp.verticalHeightMap   = h2		
		elseif tp.type == 'ceilingDown' then
			tp.horizontalHeightMap = h2
			tp.verticalHeightMap   = h
		end
	end
-------------------------------------------------------------------------------	
	-- turn height detection on
	enableHorizontalHeightMap = true
	enableVerticalHeightMap   = true
	
	-- player initial velocity
	velocity = 400	
end
-------------------------------------------------------------------------------
function love.draw()
	love.graphics.setColor(255,255,255)
	atlMap:draw()
	player:draw('fill')
	
	love.graphics.translate(0,500)
	love.graphics.setColor(255,255,255)
	
	love.graphics.print('Mouse wheel to change speed',32,0)
	love.graphics.print('1 or 2 to toggle height maps. 3 to toggle collision detection',32,12)
	love.graphics.print('Horizontal height map enable: ' .. tostring(enableHorizontalHeightMap),32,24)
	love.graphics.print('Vertical height map enable: ' .. tostring(enableVerticalHeightMap),32,36)
	love.graphics.print('Is active?: ' .. tostring(player.isActive),32,48)
	love.graphics.print('velocity: '.. velocity,32,60)
end
-------------------------------------------------------------------------------
function love.keypressed(k)
	if k == '1' then enableHorizontalHeightMap  = not enableHorizontalHeightMap end
	if k == '2' then enableVerticalHeightMap    = not enableVerticalHeightMap   end
	if k == '3' then player.isActive            = not player.isActive           end
end
-------------------------------------------------------------------------------
function love.mousepressed(x,y,k)
	if k == 'l' then player.x = x-player.w/2; player.y = y-player.h/2 end
	if k == 'wu' then velocity = velocity + 100 end
	if k == 'wd' then velocity = velocity - 100 end
end
-------------------------------------------------------------------------------
function love.update(dt)
	-- movement for player
	if love.keyboard.isDown('left') then
		dx   = -velocity*dt
	elseif love.keyboard.isDown('right') then
		dx   = velocity*dt
	else
		dx   = 0
	end
	
	if love.keyboard.isDown('up') then
		dy   = -velocity*dt
	elseif love.keyboard.isDown('down') then
		dy   = velocity*dt
	else
		dy   = 0
	end
	player:move(dx,dy)
end