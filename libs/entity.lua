local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-----------------------------------------------------------
-- class
local e   = {class = 'collider'}
e.__index = e
e.new     = function(x,y,w,h,map,tileLayer)
	local t =
	{
		x           = x,
		y           = y,
		w           = w,
		h           = h,
		map         = map,
		tileLayer   = tileLayer,
		isActive    = true,
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
function e:rightSideResolve(gx,gy,gw,gh)
	local gx2,gy2 = gx+gw,gy+gh
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newx    = self.x
	-- right sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		-- do two point check for slope height
		-- first point is the edge itself, second point is the opposite end of the tile
		if tile.properties.horizontalHeightMap then
			local minx = self.x
			local hmap = tile.properties.horizontalHeightMap
			local ti,bi
			if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			minx = min(self.x,(gx2+1)*mw-self.w-hmap[ti],(gx2+1)*mw-self.w-hmap[bi])
			if minx ~= self.x and self:isResolvable('right',tx,ty,tile) then
				newx = min(minx,newx)
			end
		elseif self:isResolvable('right',tx,ty,tile) then
			newx = (gx2*mw)-self.w
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:leftSideResolve(gx,gy,gw,gh)
	local gx2,gy2 = gx+gw,gy+gh
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newx    = self.x
	-- left sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.horizontalHeightMap then
			local maxx = self.x
			local hmap = tile.properties.horizontalHeightMap
			local ti,bi
			if gy   ~= ty then ti = 0   else ti = ceil(self.y-ty*mh)  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			maxx = max(self.x,gx*mw+hmap[ti],gx*mw+hmap[bi])
			if maxx ~= self.x and self:isResolvable('left',tx,ty,tile) then
				newx = max(maxx,newx)
			end
		elseif self:isResolvable('left',tx,ty,tile) then
			newx = (gx+1)*mw
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:bottomSideResolve(gx,gy,gw,gh)
	local gx2,gy2 = gx+gw,gy+gh
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	-- bottom sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.verticalHeightMap then
			local miny = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 0   else li = ceil(self.x-tx*mw ) end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			miny = min(self.y,(gy2+1)*mh-self.h-hmap[li],(gy2+1)*mh-self.h-hmap[ri])
			if miny ~= self.y and self:isResolvable('bottom',tx,ty,tile) then
				newy = min(miny,newy)
			end
		elseif self:isResolvable('bottom',tx,ty,tile) then
			newy = gy2*mh-self.h
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:topSideResolve(gx,gy,gw,gh)
	local gx2,gy2 = gx+gw,gy+gh
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	-- top sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.verticalHeightMap then
			local maxy = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 0   else li = ceil(self.x-tx*mw ) end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			maxy = max(self.y,gy*mh+hmap[li],gy*mh+hmap[ri])
			if maxy ~= self.y and self:isResolvable('top',tx,ty,tile) then
				newy = max(maxy,newy)
			end
		elseif self:isResolvable('top',tx,ty,tile) then
			newy = (gy+1)*mh
		end
	end
	self.y = newy
end
-----------------------------------------------------------
-- resolve x position
function e:resolveX()
	local gx,gy,gx2,gy2 = self:getRange()
	self:rightSideResolve(gx2,gy,0,gy2-gy)
	self:leftSideResolve(gx,gy,0,gy2-gy)
end
-----------------------------------------------------------
-- resolve y position
function e:resolveY()
	local gx,gy,gx2,gy2 = self:getRange()
	self:bottomSideResolve(gx,gy2,gx2-gx,0)
	self:topSideResolve(gx,gy,gx2-gx,0)
end
-----------------------------------------------------------
-- set position and apply collision correction if active
function e:moveTo(x,y)
	if not self.isActive then self.x,self.y = x,y return end
	self.x = x
	self:resolveX()
	self.y = y
	self:resolveY()
end
-----------------------------------------------------------
-- delta movement and apply collision correction
-- apply continuous collision detection as well
function e:move(dx,dy)
	if not self.isActive then self.x,self.y = self.x+dx,self.y+dy return end
	-----------------------------------------------------------
	-- x direction collision detection
	local gx,gy,gx2,gy2 = self:getRange()
	local x,x2,oldx     = self.x,self.x+dx,self.x
	local mw,mh         = self.map.tileWidth,self.map.tileHeight
	
	local dxRatio,xDelta,gd,least,sideResolve
	if dx >= 0 then
		least,sideResolve = min,'rightSideResolve'
		gx,gx2  = gx2,ceil((x+self.w+dx)/mw)-1
		dxRatio = dx == 0 and 1 or ((gx+1)*mw-(x+self.w))/dx
		xDelta  = dx == 0 and math.huge or mw/dx
		gd      = 1
	elseif dx < 0 then
		least,sideResolve = max,'leftSideResolve'
		gx2     = floor((x+dx)/mw)
		dxRatio = (gx*mw-x)/dx
		xDelta  = -mw/dx
		gd      = -1
	end
	if dx == 0 then sideResolve = 'resolveX' end
		
	-- continuous collision detection	
	for tx = gx,gx2,gd do
		local minDX = least(dx,dxRatio*dx)
		self.x = oldx+minDX
		x      = oldx+minDX
		self[sideResolve](self,tx,gy,0,gy2-gy)
		-- if there was a collision, quit movement
		if self.x ~= x then break end
		local oldy = self.y
		-- height correction so we can continue moving horizontally
		self:resolveY()
		-- if there was a slope collision, get new height range
		if self.y ~= oldy then 
			_,gy,_,gy2 = self:getRange()
		end
		dxRatio = dxRatio + xDelta
	end	
	-----------------------------------------------------------
	-- y direction collision detection
	local gx,gy,gx2,gy2 = self:getRange()
	local y,y2,oldy     = self.y,self.y+dy,self.y
	
	local dyRatio,yDelta,gd,least,sideResolve
	if dy >= 0 then
		least,sideResolve = min,'bottomSideResolve'
		gy,gy2  = gy2,ceil((y+self.h+dy)/mh)-1
		dyRatio = dy == 0 and 1 or ((gy+1)*mh-(y+self.h))/dy
		yDelta  = dy == 0 and math.huge or mh/dy
		gd      = 1
	elseif dy < 0 then
		least,sideResolve = max,'topSideResolve'
		gy2     = floor((y+dy)/mh)
		dyRatio = (gy*mh-y)/dy
		yDelta  = -mh/dy
		gd      = -1
	end
	if dy == 0 then sideResolve = 'resolveY' end
		
	for ty = gy,gy2,gd do
		local minDY = least(dy,dyRatio*dy)
		self.y = oldy+minDY
		y      = oldy+minDY
		self[sideResolve](self,gx,ty,gx2-gx,0)
		if self.y ~= y then break end
		local oldx = self.x
		self:resolveX()
		if self.x ~= oldx then 
			gx,_,gx2,_ = self:getRange()
		end
		dyRatio = dyRatio + yDelta
	end	
end
-----------------------------------------------------------
function e:draw(mode)
	love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end
-----------------------------------------------------------
return e