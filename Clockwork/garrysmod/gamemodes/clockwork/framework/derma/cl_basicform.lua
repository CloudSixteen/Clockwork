--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local vgui = vgui;

local PANEL = {};

-- A function to set the panel's Callback.
function PANEL:SetText(text, fontName, color)
	local label = self.Label;
	local wasCreated = false;
	
	if (not label) then
		label = vgui.Create("DLabel", self);
		wasCreated = true;
	end;
	
	if (fontName) then
		label:SetFont(fontName);
	end;
	
	if (color) then
		label:SetTextColor(color);
	else
		label:SetTextColor(Clockwork.option:GetColor("basic_form_color"));
	end;
	
	label:SetText(text);
	label:SizeToContents();
	
	if (wasCreated) then
		self:AddItem(label);
	end;
end;

vgui.Register("cwBasicForm", PANEL, "DPanelList");