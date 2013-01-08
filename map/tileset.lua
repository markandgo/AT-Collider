local h   = {}
local h2  = {}
for i = 0,64 do
	h[i] = i
end

for i = 0,64 do
	h2[i] = 64-i
end

return
{
	[1] =
	{
		color = {255,255,255},
		type  = 1,
	},
	[2] =
	{
		color = {255,0,0},
		type  = 2,
	},
	[3] =
	{
		color = {255,0,255},
		type  = 3,
	},
	[4] =
	{
		color = {0,0,255},
		type  = 4,
	},
	[5] =
	{
		color = {255,255,0},
		type  = 5,
		heightmap = h,
	},
	[6] =
	{
		-- push vertically only
		color = {255,255,0},
		type  = 6,
	},
	[7] =
	{
		color = {255,255,0},
		type  = 7,
		heightmap = h2,
	},
}