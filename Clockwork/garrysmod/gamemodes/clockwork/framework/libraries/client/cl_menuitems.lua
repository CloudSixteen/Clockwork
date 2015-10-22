--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

--[[
	@codebase Client
	@details Provides an interface to the Menu Items.
	@field stored A table containing a list of stored menu items.
--]]
Clockwork.menuitems = Clockwork.kernel:NewLibrary("MenuItems");
Clockwork.menuitems.stored = Clockwork.menuitems.stored or {};

-- A function to get a menu item.
function Clockwork.menuitems:Get(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			return v;
		end;
	end;
end;

-- A function to add a menu item.
function Clockwork.menuitems:Add(text, panel, tip, iconData)
	self.stored[#self.stored + 1] = {text = text, panel = panel, tip = tip, iconData = iconData};
end;

-- A function to destroy a menu item.
function Clockwork.menuitems:Destroy(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			table.remove(self.stored, k);
		end;
	end;
end;