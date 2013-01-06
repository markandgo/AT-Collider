local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-----------------------------------------------------------
-- class
local e   = {class = 'entity'}
e.__index = e
e.new     = function(x,y,w,h,map,tileLayer)
	local t =
	{
		x = x,
		y = y,
		w = w,
		h = h,
		isActive  = true,
		map       = map,
		tileLayer = tileLayer,
	}
	return setmetatable(t,e)
end
-----------------------------------------------------------
-- set map and tile layer for collision
function e:setMapAndLayer(map,tileLayer)
	self.map = map; self.tileLayer = tileLayer
end
-----------------------------------------------------------
-- get the range of tiles that are occupied
function e:getRange()
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local gx,gy   = floor(self.x/mw),floor(self.y/mh)
	local gx2,gy2 = ceil( (self.x+self.w)/mw )-1,ceil( (self.y+self.h)/mh )-1
	return gx,gy,gx2,gy2
end
-----------------------------------------------------------
-- collision callback, return true if tile/slope is collidable
function e:isResolvable(side,gx,gy,tile)
end
-----------------------------------------------------------
-- resolve x position
function e:resolveX()
	local map   = self.map
	local layer = self.tileLayer
	local mw,mh = map.tileWidth,map.tileHeight
	local gx,gy,gx2,gy2 = self:getRange()
	
	local newx = self.x
	-- right sensor check
	for tx,ty,tile in layer:rectangle(gx2,gy,0,gy2-gy) do
		-- do two point check for slope height
		-- first point is the edge itself, second point is opposite end of tile
		if tile.properties.horizontalHeightMap then
			local minx = self.x
			local hmap = tile.properties.horizontalHeightMap
			local ti,bi
			if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			minx = min(self.x,(gx2+1)*mw-self.w-hmap[ti],(gx2+1)*mw-self.w-hmap[bi])
			if minx ~= self.x and self:isResolvable('floor',tx,ty,tile) then
				newx = min(minx,newx)
			end
		elseif self:isResolvable('right',tx,ty,tile) then
			newx = (gx2*mw)-self.w
		end
	end
	
	-- left sensor check
	for tx,ty,tile in layer:rectangle(gx,gy,0,gy2-gy) do
		if tile.properties.horizontalHeightMap then
			local maxx = self.x
			local hmap = tile.properties.horizontalHeightMap
			local ti,bi
			if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			maxx = max(self.x,gx*mw+hmap[ti],gx*mw+hmap[bi])
			if maxx ~= self.x and self:isResolvable('floor',tx,ty,tile) then
				newx = max(maxx,newx)
			end
		elseif self:isResolvable('left',tx,ty,tile) then
			newx = (gx+1)*mw
		end
	end
	self.x = newx
end
-----------------------------------------------------------
-- resolve y position
function e:resolveY()
	local map   = self.map
	local layer = self.tileLayer
	local mw,mh = map.tileWidth,map.tileHeight
	local gx,gy,gx2,gy2 = self:getRange()
	
	local newy = self.y
	-- floor sensor check
	for tx,ty,tile in layer:rectangle(gx,gy2,gx2-gx,0) do
		if tile.properties.verticalHeightMap then
			local miny = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 0   else li = ceil(self.x-tx*mw ) end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			miny = min(self.y,(gy2+1)*mh-self.h-hmap[li],(gy2+1)*mh-self.h-hmap[ri])
			if miny ~= self.y and self:isResolvable('floor',tx,ty,tile) then
				newy = min(miny,newy)
			end
		elseif self:isResolvable('floor',tx,ty,tile) then
			newy = gy2*mh-self.h
		end
	end
	
	-- ceiling sensor check
	for tx,ty,tile in layer:rectangle(gx,gy,gx2-gx,0) do
		if tile.properties.verticalHeightMap then
			local maxy = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 0   else li = ceil(self.x-tx*mw ) end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			maxy = max(self.y,gy*mh+hmap[li],gy*mh+hmap[ri])
			if maxy ~= self.y and self:isResolvable('ceiling',tx,ty,tile) then
				newy = max(maxy,newy)
			end
		elseif self:isResolvable('ceiling',tx,ty,tile) then
			newy = (gy+1)*mh
		end
	end
	
	self.y = newy
end
-----------------------------------------------------------
-- set position and apply collision correction if active
function e:moveTo(x,y)
	local oldx,oldy = self.x,self.y
	if not self.isActive then 
		self.x,self.y = x,y
		return 
	end
	self.x = x
	self:resolveX()
	self.y = y
	self:resolveY()
end
-----------------------------------------------------------
-- delta movement and apply collision correction
-- apply continuous collision detection as well
---[[
function e:move(dx,dy)
	if not self.isActive then 
		self.x,self.y = self.x+dx,self.y+dy
		return 
	end
	local map   = self.map
	local layer = self.tileLayer
	local mw,mh = map.tileWidth,map.tileHeight
	local newx  = self.x+dx
	local gx,gy,gx2,gy2 = self:getRange()
	gx,gx2,side,d
	if dx >= 0 then
		gx,gx2  = floor(self.x/mw),ceil( (newx+self.w)/mw )-1
		d,side  = 1,'right'
	else
		gx,gx2  = ceil( (self.x+self.w)/mw )-1,floor(newx/mw)
		d,side  = -1,'left'
	end
	
	for tx = gx,gx2,d do
		for ty = gy,gy2 do
			local tile = layer.cells[tx][gy]
			if side == 'right' then
				if tile.properties.horizontalHeightMap then
					local minx = self.x+dx
					local hmap = tile.properties.horizontalHeightMap
					local ti,bi
					if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
					if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
					minx = min(self.x,(gx2+1)*mw-self.w-hmap[ti],(gx2+1)*mw-self.w-hmap[bi])
					if minx ~= self.x and self:isResolvable('floor',tx,ty,tile) then
						newx = min(minx,newx)
						break
					end
				elseif self:isResolvable('right',tx,ty,tile) then
					newx = (gx2*mw)-self.w
					break
				end
			else
				if tile.properties.horizontalHeightMap then
					local maxx = self.x
					local hmap = tile.properties.horizontalHeightMap
					local ti,bi
					if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
					if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
					maxx = max(self.x,gx*mw+hmap[ti],gx*mw+hmap[bi])
					if maxx ~= self.x and self:isResolvable('floor',tx,ty,tile) then
						newx = max(maxx,newx)
					end
				elseif self:isResolvable('left',tx,ty,tile) then
					newx = (gx+1)*mw
				end
			end
		end
	end
end
--]]
-----------------------------------------------------------
function e:draw(mode)
	love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end
-----------------------------------------------------------
return e