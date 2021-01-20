--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local PANEL = {};

function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.htmlPanel = vgui.Create("DHTML");
 	self.htmlPanel:SetParent(self);
	
	self:Rebuild();
end;

function PANEL:IsButtonVisible()
	return true;
end;

function PANEL:Rebuild()
	self.htmlPanel:OpenURL("https://eden.cloudsixteen.com");
end;

function PANEL:OnMenuOpened()
	self:Rebuild();
end;

function PANEL:OnSelected() self:Rebuild(); end;

function PANEL:PerformLayout(w, h)
	self.htmlPanel:StretchToParent(4, 4, 4, 4);
end;

function PANEL:Paint(w, h)
	Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, w, h, Color(0, 0, 0, 255));
	draw.SimpleText("Please wait...", Clockwork.option:GetFont("menu_text_big"), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1);
	
	return true;
end;

function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwCloudSixteenForums", PANEL, "EditablePanel");