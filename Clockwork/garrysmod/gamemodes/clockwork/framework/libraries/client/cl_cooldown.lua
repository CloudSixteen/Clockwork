--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local surface = surface;
local table = table;
local math = math;

--[[
	@codebase Client
	@details Allows the drawing of polygon based cooldown boxes.
	@field sizes A table containing a list of stored cooldown sizes.
--]]
Clockwork.cooldown = Clockwork.kernel:NewLibrary("Cooldown");
Clockwork.cooldown.sizes = Clockwork.cooldown.sizes or {};

--[[
	@codebase Client
	@details Get a cooldown table from the list.
	@param {Number} The width of the cooldown box.
	@param {Number} The height of the cooldown box.
	@param {Bool} Whether or not to add the size if it doesn't exist.
	@returns {Table} The cooldown table matching the specified size.
--]]
function Clockwork.cooldown:GetTable(width, height, bAdd)
	local cooldownTable = self.sizes[width.." "..height];
	
	if (cooldownTable) then
		return cooldownTable;
	elseif (bAdd) then
		return self:AddSize(width, height);
	end;
end;

--[[
	@codebase Client
	@details Add a new cooldown size to the list.
	@param {Number} The width of the cooldown box.
	@param {Number} The height of the cooldown box.
	@returns {Table} The newly added cooldown table.
--]]
function Clockwork.cooldown:AddSize(width, height)
	local verticies = {
		{
			{x = 0, y = -(height / 2), u = 0.5, v = 0},
			{x = width / 2, y = -(height / 2), u = 1, v = 0, c = function()
				return -(width / 2), 0;
			end},
		},
		{
			{x = width / 2, y = -(height / 2), u = 1, v = 0},
			{x = width / 2, y = 0, u = 1, v = 0.5, c = function()
				return 0, -(height / 2);
			end},
		},
		{
			{x = width / 2, y = 0, u = 1, v = 0.5},
			{x = width / 2, y = height / 2, u = 1, v = 1, c = function()
				return 0, -(height / 2);
			end},
		},
		{
			{x = width / 2, y = height / 2, u = 1, v = 1},
			{x = 0, y = height / 2, u = 0.5, v = 1, c = function()
				return width / 2, 0;
			end},
		},
		{
			{x = 0, y = height / 2, u = 0.5, v = 1},
			{x = -(width / 2), y = height / 2, u = 0, v = 1, c = function()
				return width / 2, 0;
			end},
		},
		{
			{x = -(width / 2), y = height / 2, u = 0, v = 1},
			{x = -(width / 2), y = 0, u = 0, v = 0.5, c = function()
				return 0, height / 2;
			end},
		},
		{
			{x = -(width / 2), y = 0, u = 0, v = 0.5},
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0, c = function()
				return 0, height / 2;
			end},
		},
		{
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0},
			{x = 0, y = -(height / 2), u = 0.5, v = 0, c = function()
				return -(width / 2), 0;
			end},
		},
	};

	local editTable = table.Copy(verticies);
	
	self.sizes[width.." "..height] = {
		verticies = verticies,
		editTable = editTable
	};
	
	return self.sizes[width.." "..height];
end;

--[[
	@codebase Client
	@details Draw a cooldown box at a position.
	@param {Number} The horizontal position of the box.
	@param {Number} The vertical position of the box.
	@param {Number} The width of the cooldown box.
	@param {Number} The height of the cooldown box.
	@param {Float} The current progress of the cooldown.
	@param {Color} The color of the cooldown box.
	@param {Number} The texture ID to use when drawing.
	@param {Bool} Whether or not to center the box.
--]]
function Clockwork.cooldown:DrawBox(x, y, width, height, progress, color, textureID, bCenter)
	local cooldownTable = self:GetTable(width, height, true);
	local octant = math.Clamp((8 / 100) * progress, 0, 8);
	
	if (!bCenter) then
		x = x + (width / 2);
		y = y + (height / 2);
	end;
	
	surface.SetTexture(textureID);
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	
	local polygons = {{x = x, y = y, u = 0.5, v = 0.5}};
	
	for i = 1, 8 do
		if (math.ceil(octant) == i) then
			local fraction = 1 - (i - octant);
			local nx, ny = cooldownTable.editTable[i][2].c();
			
			cooldownTable.editTable[i][2].x = x + cooldownTable.verticies[i][2].x + nx + (-nx * fraction);
			cooldownTable.editTable[i][2].y = y + cooldownTable.verticies[i][2].y + ny + (-ny * fraction);
			cooldownTable.editTable[i][1].x = x + cooldownTable.verticies[i][1].x;
			cooldownTable.editTable[i][1].y = y + cooldownTable.verticies[i][1].y;
			
			table.Add(polygons, cooldownTable.editTable[i]);
		elseif (octant > i) then
			for j = 1, 2 do
				cooldownTable.editTable[i][j].x = x + cooldownTable.verticies[i][j].x;
				cooldownTable.editTable[i][j].y = y + cooldownTable.verticies[i][j].y;
			end;
			
			table.Add(polygons, cooldownTable.editTable[i]);
		end;
	end;
	
	surface.DrawPoly(polygons);
end;

Clockwork.cooldown:AddSize(64, 64);
Clockwork.cooldown:AddSize(32, 32);