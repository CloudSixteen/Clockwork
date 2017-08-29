--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.PlayerInfoText = Clockwork.kernel:NewLibrary("PlayerInfoText");
Clockwork.PlayerInfoText.text = Clockwork.PlayerInfoText.text or {};
Clockwork.PlayerInfoText.width = Clockwork.PlayerInfoText.width or {};
Clockwork.PlayerInfoText.subText = Clockwork.PlayerInfoText.subText or {};

-- A function to get whether any player info text exists.
function Clockwork.PlayerInfoText:DoesAnyExist()
	return (#self.text > 0 or #self.subText > 0);
end;

-- A function to add some player info text.
function Clockwork.PlayerInfoText:Add(uniqueID, text)
	if (text) then
		self.text[#self.text + 1] = {
			uniqueID = uniqueID,
			text = text
		};
	end;
end;
	
-- A function to get some player info text.
function Clockwork.PlayerInfoText:Get(uniqueID)
	for k, v in pairs(self.text) do
		if (v.uniqueID == uniqueID) then
			return v;
		end;
	end;
end;

-- A function to add some sub player info text.
function Clockwork.PlayerInfoText:AddSub(uniqueID, text, priority)
	if (text) then
		self.subText[#self.subText + 1] = {
			priority = priority or 0,
			uniqueID = uniqueID,
			text = text
		};
	end;
end;
	
-- A function to get some sub player info text.
function Clockwork.PlayerInfoText:GetSub(uniqueID)
	for k, v in pairs(self.subText) do
		if (v.uniqueID == uniqueID) then
			return v;
		end;
	end;
end;

-- A function to destroy some player info text.
function Clockwork.PlayerInfoText:Destroy(uniqueID)
	for k, v in pairs(self.text) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.text, k);
		end;
	end;
end;

-- A function to destroy some sub player info text.
function Clockwork.PlayerInfoText:DestroySub(uniqueID)
	for k, v in pairs(self.subText) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.subText, k);
		end;
	end;
end;