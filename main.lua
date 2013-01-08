function love.load()
	atl     = require 'libs.ATL'
	atlMap  = atl.Loader.load 'map/map.tmx'
	entity  = require 'libs.atc.atc'
	player  = entity.new(32,32,31,31,atlMap,select(2,next(atlMap.layers)))
	
	-- set up collision callbacks
	function player:isResolvable(side,gx,gy,tile)
		-- use tile properties for our collision type
		local tp = tile.properties
		-- 1 is solid block
		if tp.type  == 1 then return true end
		
		-- 2 is rising floor slope, 3 is lowering floor slope (left to right)
		-- 4 is lowering ceiling slope, 5 is rising ceiling slope
		
		-- for vertical height maps
		if enableVerticalHeightMap then 
			if (tp.type == 2 or tp.type == 3) and side == 'bottom' then return true end
			if (tp.type == 4 or tp.type == 5) and side == 'top' then return true end
		end
		
		-- for horizontal height maps
		if enableHorizontalHeightMap then
			if (tp.type == 2 or tp.type == 4) and side == 'right' then return true end
			if (tp.type == 5 or tp.type == 3) and side == 'left' then return true end
		end
	end
	
	-- set up heightmaps
	local h = {}; local h2 = {}
	for i = 0,32 do
		h[i] = i
	end
	for i = 0,32 do
		h2[i] = 32-i
	end
	
	atlMap.tiles[2].properties.horizontalHeightMap = h
	atlMap.tiles[3].properties.horizontalHeightMap = h
	atlMap.tiles[4].properties.horizontalHeightMap = h2
	atlMap.tiles[5].properties.horizontalHeightMap = h2	
	
	atlMap.tiles[2].properties.verticalHeightMap = h
	atlMap.tiles[3].properties.verticalHeightMap = h2
	atlMap.tiles[5].properties.verticalHeightMap = h
	atlMap.tiles[4].properties.verticalHeightMap = h2	
	
	-- turn height detection on
	enableHorizontalHeightMap = true
	enableVerticalHeightMap   = true
	
	-- entity velocity
	velocity = 400	
end

function love.draw()
	love.graphics.setColor(255,255,255)
	atlMap:draw()
	player:draw('fill')
	
	love.graphics.translate(0,500)
	love.graphics.setColor(255,255,255)
	
	love.graphics.print('Mouse wheel to change speed',32,0)
	love.graphics.print('1 or 2 to toggle height maps',32,12)
	love.graphics.print('Horizontal height map enable: ' .. tostring(enableHorizontalHeightMap),32,24)
	love.graphics.print('Vertical height map enable: ' .. tostring(enableVerticalHeightMap),32,36)
	love.graphics.print('velocity: '.. velocity,32,48)
end

function love.keypressed(k)
	if k == '1' then enableHorizontalHeightMap  = not enableHorizontalHeightMap end
	if k == '2' then enableVerticalHeightMap    = not enableVerticalHeightMap   end
end

function love.mousepressed(x,y,k)
	if k == 'l' then player.x = x-player.w/2; player.y = y-player.h/2 end
	if k == 'wu' then velocity = velocity + 100 end
	if k == 'wd' then velocity = velocity - 100 end
end

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