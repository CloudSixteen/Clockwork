--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
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
Clockwork.MenuItems = Clockwork.kernel:NewLibrary("MenuItems");
Clockwork.MenuItems.stored = Clockwork.MenuItems.stored or {};

--[[
	@codebase Client
	@details A function to get a menu item.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.MenuItems:Get(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			return v;
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to add a menu item.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for panel.
	@param {Unknown} Missing description for tip.
	@param {Unknown} Missing description for iconData.
	@returns {Unknown}
--]]
function Clockwork.MenuItems:Add(text, panel, tip, iconData)
	self.stored[#self.stored + 1] = {text = text, panel = panel, tip = tip, iconData = iconData};
end;

--[[
	@codebase Client
	@details A function to destroy a menu item.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.MenuItems:Destroy(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			table.remove(self.stored, k);
		end;
	end;
end;