--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local Color = Color;
local surface = surface;
local vgui = vgui;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.backgroundColor = Color(255, 255, 255, 255);
end;

-- A function to set the background color.
function PANEL:SetBackgroundColor(color)
	self.backgroundColor = color;
end;

-- Called when the panel should be painted.
function PANEL:Paint(width, height)
	surface.SetDrawColor(self.backgroundColor);
	surface.DrawRect(0, 0, width, height);

	derma.SkinHook("Paint", "cwPanelList", self, width, height);
end;

vgui.Register("cwPanelList", PANEL, "DPanelList");