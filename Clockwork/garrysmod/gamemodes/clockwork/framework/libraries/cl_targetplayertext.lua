--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.TargetPlayerText = Clockwork.kernel:NewLibrary("TargetPlayerText");
Clockwork.TargetPlayerText.stored = {};

-- A function to add some target player text.
function Clockwork.TargetPlayerText:Add(uniqueID, text, color)
	self.stored[#self.stored + 1] = {
		uniqueID = uniqueID,
		color = color,
		text = text
	};
end;
	
-- A function to get some target player text.
function Clockwork.TargetPlayerText:Get(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			return v;
		end;
	end;
end;

-- A function to destroy some target player text.
function Clockwork.TargetPlayerText:Destroy(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.stored, k);
		end;
	end;
end;