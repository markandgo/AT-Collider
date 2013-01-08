function love.load()
	atl     = require 'libs.ATL'
	atlMap  = atl.Loader.load 'testmap/map.tmx'
	atlMap:autoDrawRange(800,600,1,0)
	
	entity  = require 'libs.entity'
	p1      = require 'player'
	
	-- set up collision callbacks
	function p1:isResolvable(side,gx,gy,tile)
		local tp = tile.properties
		if tp.type == 1 then 
			-- if dx == 0 or dy == 0 then return true end
			if side == 'right' and dx > 0 then return true end
			if side == 'left' and dx < 0 then return true end
			if side == 'bottom' and dy > 0 then return true end
			if side == 'top' and dy < 0 then return true end
			-- return true 
		end
		if (tp.type == 2 or tp.type == 3) and side == 'bottom' then return true end
		if (tp.type == 4 or tp.type == 5) and side == 'top' then return true end
		if (tp.type == 2 or tp.type == 4) and side == 'right' then return true end
		if (tp.type == 5 or tp.type == 3) and side == 'left' then return true end
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
	
	-- entity velocity
	velocity = 400
end

function love.draw()
	love.graphics.print('Mouse wheel to change speed',32,32)
	love.graphics.print('velocity: '.. velocity,32,44)
	love.graphics.setColor(255,255,255)
	atlMap:draw()
	p1:draw('fill')
end

function love.mousepressed(x,y,k)
	if k == 'l' then p1.x = x-p1.w/2; p1.y = y-p1.h/2 end
	if k == 'wu' then velocity = velocity + 100 end
	if k == 'wd' then velocity = velocity - 100 end
end

function love.update(dt)
	-- movement for p1
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
	
	-- p1:moveTo(p1.x+dx,p1.y+dy)
	p1:move(dx,dy)
end