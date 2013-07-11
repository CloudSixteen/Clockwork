--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;

local PANEL = {};

-- A function to add a text entry.
function PANEL:TextEntry(strLabel)
	local labelPanel = vgui.Create("DLabel", self);
	
	self:AddItem(labelPanel);
	
	labelPanel:SetText(strLabel);
	labelPanel:SetDark(true);
	
	local textEntryPanel = vgui.Create("DTextEntry", self);
	
	self:AddItem(textEntryPanel);

	return textEntryPanel, labelPanel;
end;

vgui.Register("cwForm", PANEL, "DForm");