--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.TargetPlayerText = Clockwork.kernel:NewLibrary("TargetPlayerText");
Clockwork.TargetPlayerText.stored = Clockwork.TargetPlayerText.stored or {};

-- A function to add some target player text.
function Clockwork.TargetPlayerText:Add(uniqueID, text, color, scale)
	self.stored[#self.stored + 1] = {
		uniqueID = uniqueID,
		color = color,
		scale = scale,
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