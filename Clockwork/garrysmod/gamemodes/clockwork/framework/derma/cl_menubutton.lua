--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
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

function PANEL:SetIcon(iconPath, size)
	self.Icon = vgui.Create("DImage", self);
	self.Icon:SetImage(iconPath);
	self.Icon:SetSize(size, size);
	self:UpdatePositioning();
end;

function PANEL:SetupLabel(menuItem, panel)
	self.LabelButton:SetFont(Clockwork.option:GetFont("menu_text_tiny"));
	self.LabelButton:SetText(string.upper(menuItem.text));
	
	if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
		self.LabelButton:SetAlpha(0);
		self.LabelButton:FadeIn(0.5);
	else
		self.LabelButton:SetAlpha(255);
	end;
	
	self.LabelButton:SetToolTip(menuItem.tip);
	self.LabelButton:SetCallback(function(button)
		if (Clockwork.menu:GetActivePanel() != panel) then
			Clockwork.menu:GetPanel():OpenPanel(panel);
		end;
	end);
	self.LabelButton:SizeToContents();
	self.LabelButton:SetMouseInputEnabled(true);
	
	if (menuItem.iconData and menuItem.iconData.path and menuItem.iconData.path != "") then
		self:SetIcon(menuItem.iconData.path, menuItem.iconData.size or (self.LabelButton:GetTall() + 8));
	end;
	
	self.ContentPanel = panel;
	self:UpdatePositioning();
end;

function PANEL:UpdatePositioning()
	if (not self.LabelButton) then
		return;
	end;
	
	if (self.Icon) then
		--self:SetSize(200, self.LabelButton:GetTall() + math.max(16, self.Icon:GetTall() / 2));
		self.Icon:SetPos(0, (self.LabelButton.y + self.LabelButton.h) - (self.Icon:GetTall() / 2));
	else
		--self:SetSize(200, self.LabelButton:GetTall() + 16);
	end;
end;

vgui.Register("cwMenuButton", PANEL, "DPanel");