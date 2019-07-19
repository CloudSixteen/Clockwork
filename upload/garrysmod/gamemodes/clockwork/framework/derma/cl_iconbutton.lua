--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local derma = derma;
local vgui = vgui;

local PANEL = {};

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	if (IsValid(self.m_Image)) then
		self.m_Image:SetPos(8, (self:GetTall() - self.m_Image:GetTall()) * 0.5);
		self:SetTextInset(self.m_Image:GetWide() + 24, 0);
	end;
	
	DLabel.PerformLayout(self);
end;
	
vgui.Register("cwIconButton", PANEL, "DButton");