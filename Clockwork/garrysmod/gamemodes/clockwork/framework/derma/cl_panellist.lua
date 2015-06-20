--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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

function PANEL:HideBackground()
	self.backgroundHidden = true;
end;

function PANEL:SetSpacing(spacing)
	self.defaultSpacing = spacing;
end;

function PANEL:EnableVerticalScrollbar() end;

function PANEL:AddItem(item, bottomMargin)
	bottomMargin = bottomMargin or self.defaultSpacing or 8;
	
	item:Dock(TOP);
	item:DockMargin(0, 0, 0, bottomMargin);
	
	DCategoryList.AddItem(self, item);
	
	-- TODO: Maybe not have this.
	self:InvalidateLayout(true);
end;

-- Called when the panel should be painted.
function PANEL:Paint(width, height)
	if (!self.backgroundHidden) then
		PANEL_LIST_SLICED:Draw(0, 0, width, height, 8, self.backgroundColor);
	end;
	
	return true;
end;

vgui.Register("cwPanelList", PANEL, "DCategoryList");