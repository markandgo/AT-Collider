--[[
Advanced Tiled Collider Version 0.11
Copyright (c) 2013 Minh Ngo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
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
	local gy2     = gy+gh
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
			if gy   ~= ty then ti = 1   else ti = floor(self.y-ty*mh)+1  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			minx = min(self.x,(tx+1)*mw-self.w-hmap[ti],(tx+1)*mw-self.w-hmap[bi])
			if minx ~= self.x and self:isResolvable('right',tx,ty,tile) then
				newx = min(minx,newx)
			end
		elseif self:isResolvable('right',tx,ty,tile) then
			newx = (tx*mw)-self.w
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:leftSideResolve(gx,gy,gw,gh)
	local gy2     = gy+gh
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newx    = self.x
	-- left sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.horizontalHeightMap then
			local maxx = self.x
			local hmap = tile.properties.horizontalHeightMap
			local ti,bi
			if gy   ~= ty then ti = 1   else ti = floor(self.y-ty*mh)+1  end
			if gy2  ~= ty then bi = mh  else bi = ceil(self.y+self.h-ty*mh) end
			maxx = max(self.x,tx*mw+hmap[ti],tx*mw+hmap[bi])
			if maxx ~= self.x and self:isResolvable('left',tx,ty,tile) then
				newx = max(maxx,newx)
			end
		elseif self:isResolvable('left',tx,ty,tile) then
			newx = (tx+1)*mw
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:bottomSideResolve(gx,gy,gw,gh)
	local gx2     = gx+gw
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	-- bottom sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.verticalHeightMap then
			local miny = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 1   else li = floor(self.x-tx*mw)+1 end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			miny = min(self.y,(ty+1)*mh-self.h-hmap[li],(ty+1)*mh-self.h-hmap[ri])
			if miny ~= self.y and self:isResolvable('bottom',tx,ty,tile) then
				newy = min(miny,newy)
			end
		elseif self:isResolvable('bottom',tx,ty,tile) then
			newy = ty*mh-self.h
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:topSideResolve(gx,gy,gw,gh)
	local gx2     = gx+gw
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	-- top sensor check
	for tx,ty,tile in self.tileLayer:rectangle(gx,gy,gw,gh) do
		if tile.properties.verticalHeightMap then
			local maxy = self.y
			local hmap = tile.properties.verticalHeightMap
			local li,ri
			if gx   ~= tx then li = 1   else li = floor(self.x-tx*mw)+1 end
			if gx2  ~= tx then ri = mw  else ri = ceil((self.x+self.w)-tx*mw ) end
			maxy = max(self.y,ty*mh+hmap[li],ty*mh+hmap[ri])
			if maxy ~= self.y and self:isResolvable('top',tx,ty,tile) then
				newy = max(maxy,newy)
			end
		elseif self:isResolvable('top',tx,ty,tile) then
			newy = (ty+1)*mh
		end
	end
	self.y = newy
end
-----------------------------------------------------------
-- resolve x position
function e:resolveX()
	local gx,gy,gx2,gy2 = self:getRange()
	self:rightSideResolve(gx2,gy,0,gy2-gy)
	gx,gy,gx2,gy2 = self:getRange()
	self:leftSideResolve(gx,gy,0,gy2-gy)
end
-----------------------------------------------------------
-- resolve y position
function e:resolveY()
	local gx,gy,gx2,gy2 = self:getRange()
	self:bottomSideResolve(gx,gy2,gx2-gx,0)
	gx,gy,gx2,gy2 = self:getRange()
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
	local mw,mh         = self.map.tileWidth,self.map.tileHeight
	-----------------------------------------------------------
	-- x direction collision detection
	local gx,gy,gx2,gy2 = self:getRange()
	local x,oldx        = self.x,self.x
	
	local gd,least
	if dx >= 0 then
		least   = min
		gx,gx2  = gx2,ceil((x+self.w+dx)/mw)-1
		gd      = 1
	elseif dx < 0 then
		least   = max
		gx2     = floor((x+dx)/mw)
		gd      = -1
	end
		
	-- continuous collision detection by moving cell by cell
	for tx = gx,gx2,gd do
		-- take shortest path from dx or snapping to grid
		if dx >= 0 then 
			self.x = least((tx+1)*mw-self.w,oldx+dx) 
		else 
			self.x = least(tx*mw,oldx+dx) 
		end
		local newx  = self.x
		self:resolveX()
		-- if there was a collision, quit movement
		if self.x ~= newx then break end
		local oldy = self.y
		-- height correction so we can continue moving horizontally
		self:resolveY()
		-- if there was a slope collision, get new height range
		if self.y ~= oldy then 
			_,gy,_,gy2 = self:getRange()
		end
	end	
	-----------------------------------------------------------
	-- y direction collision detection
	local gx,gy,gx2,gy2 = self:getRange()
	local y,oldy        = self.y,self.y
	
	local gd,least
	if dy >= 0 then
		least   = min
		gy,gy2  = gy2,ceil((y+self.h+dy)/mh)-1
		gd      = 1
	elseif dy < 0 then
		least   = max
		gy2     = floor((y+dy)/mh)
		gd      = -1
	end
		
	for ty = gy,gy2,gd do
		if dy >= 0 then 
			self.y = least((ty+1)*mh-self.h,oldy+dy) 
		else 
			self.y = least(ty*mh,oldy+dy) 
		end
		local newy  = self.y
		self:resolveY()
		if self.y ~= newy then break end
		local oldx = self.x
		self:resolveX()
		if self.x ~= oldx then
			gx,_,gx2,_ = self:getRange()
		end
	end	
end
-----------------------------------------------------------
function e:draw(mode)
	love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end
-----------------------------------------------------------
return e