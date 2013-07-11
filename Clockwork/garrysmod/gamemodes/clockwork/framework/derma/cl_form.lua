--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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