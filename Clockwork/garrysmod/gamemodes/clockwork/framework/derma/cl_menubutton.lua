--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local vgui = vgui;
local math = math;

local PANEL = {};

function PANEL:Init()
	self.LabelButton = vgui.Create("cwLabelButton", self);
end;

function PANEL:SetupLabel(menuItem, panel)
	self.LabelButton:SetFont(Clockwork.option:GetFont("menu_text_tiny"));
	self.LabelButton:SetText(string.upper(menuItem.text));
	self.LabelButton:SetAlpha(0);
	self.LabelButton:FadeIn(0.5);
	self.LabelButton:SetToolTip(menuItem.tip);
	self.LabelButton:SetCallback(function(button)
		if (Clockwork.menu:GetActivePanel() != panel) then
			Clockwork.menu:GetPanel():OpenPanel(panel);
		end;
	end);
	self.LabelButton:SizeToContents();
	self.LabelButton:SetMouseInputEnabled(true);
	self.LabelButton:SetPos(8, 8);
	
	self.ContentPanel = panel;
	
	self:SetSize(200, self.LabelButton:GetTall() + 16);
end;

function PANEL:Paint(w, h)
	if (Clockwork.menu:GetActivePanel() == self.ContentPanel) then
		MENU_ITEM_SLICED:Draw(0, 0, w, h, 8, Color(200, 200, 255, 50));
	else
		MENU_ITEM_SLICED:Draw(0, 0, w, h, 8, Color(255, 255, 255, 1));
	end;
	
	return true;
end;

vgui.Register("cwMenuButton", PANEL, "DPanel");