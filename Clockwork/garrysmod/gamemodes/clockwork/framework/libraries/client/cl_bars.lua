--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.bars = Clockwork.kernel:NewLibrary("Bars");
Clockwork.bars.x = 0; 
Clockwork.bars.y = 0;
Clockwork.bars.width = 0;
Clockwork.bars.height = 12;
Clockwork.bars.padding = 14;
Clockwork.bars.stored = Clockwork.bars.stored or {};

--[[
	@codebase Client
	@details A function to get a top bar.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.bars:FindByID(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then return v; end;
	end;
end;
	
--[[
	@codebase Client
	@details A function to add a top bar.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for color.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for value.
	@param {Unknown} Missing description for maximum.
	@param {Unknown} Missing description for flash.
	@param {Unknown} Missing description for priority.
	@returns {Unknown}
--]]
function Clockwork.bars:Add(uniqueID, color, text, value, maximum, flash, priority)
	self.stored[#self.stored + 1] = {
		uniqueID = uniqueID,
		priority = priority or 0,
		maximum = maximum,
		color = color,
		class = class,
		value = value,
		flash = flash,
		text = text,
	};
end;

--[[
	@codebase Client
	@details A function to destroy a top bar.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.bars:Destroy(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.stored, k);
		end;
	end;
end;