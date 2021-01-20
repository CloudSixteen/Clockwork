--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local PANEL = {};

function PANEL:Init()
	self.htmlPanel = vgui.Create("DHTML");
 	self.htmlPanel:SetParent(self);
	self.htmlPanel:OpenURL("https://eden.cloudsixteen.com/p/1-clockwork-news");
	
	local width = ScrW() * 0.6;
	local height = ScrH() * 0.8;
	local halfW = ScrW() * 0.5;
	local halfH = ScrH() * 0.5;
	
	self:SetSize(width, height);
	self:SetPos(halfW - (width * 0.5), halfH - (height * 0.5));
	self:MakePopup();
	
	self.button = vgui.Create("DButton", self);
	self.button:SetText("Close");
	self.button:SetSize(100, 32);
	self.button:SetPos((width * 0.5) - 50, height - 48);
	
	function self.button.DoClick(button)
		if (self.callback) then
			self.callback();
		end;
		
		self:Remove();
	end;
end;

function PANEL:SetCallback(callback)
	self.callback = callback;
end;

function PANEL:PerformLayout()
	local height = ScrH() * 0.8;
	local width = ScrW() * 0.6;
	
	self.htmlPanel:SetPos(4, 4);
	self.htmlPanel:SetSize(width - 8, height - 64);
	
	derma.SkinHook("Layout", "Frame", self);
end;

vgui.Register("cwAdminNews", PANEL, "DPanel");