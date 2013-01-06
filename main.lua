function love.load()
	atl     = require 'libs.ATL'
	atlMap  = atl.Loader.load 'testmap/map.tmx'
	atlMap:autoDrawRange(800,600,1,0)
	
	entity  = require 'libs.entity'
	p1      = require 'player'
	
	velocity = 400
	
	function p1:isResolvable(side,gx,gy,tile)
		local tp = tile.properties
		if tp.type == 1 then return true end
		if (tp.type == 2 or tp.type == 3) and side == 'floor' then return true end
		if (tp.type == 4 or tp.type == 5) and side == 'ceiling' then return true end
	end
	
	local h = {}; local h2 = {}
	
	for i = 0,32 do
		h[i] = i
	end
	
	for i = 0,32 do
		h2[i] = 32-i
	end
	
	atlMap.tiles[2].properties.verticalHeightMap = h
	atlMap.tiles[3].properties.verticalHeightMap = h2
	atlMap.tiles[5].properties.verticalHeightMap = h
	atlMap.tiles[4].properties.verticalHeightMap = h2
end

function love.draw()
	love.graphics.setColor(255,255,255)
	atlMap:draw()
	p1:draw('fill')
end

function love.update(dt)
	
	-- movement for p1
	if love.keyboard.isDown('left') then
		newx = -velocity*dt+p1.x
		-- p1:moveTo(-velocity*dt+p1.x,p1.y)
	elseif love.keyboard.isDown('right') then
		newx = velocity*dt+p1.x
		-- p1:moveTo(velocity*dt+p1.x,p1.y)
	else
		newx = p1.x
	end
	
	-- p1:resolveX()
	
	if love.keyboard.isDown('up') then
		newy = -velocity*dt+p1.y
	elseif love.keyboard.isDown('down') then
		newy = velocity*dt+p1.y
	else
		newy = p1.y
	end
	-- p1:resolveY()
	
	p1:moveTo(newx,newy)
end