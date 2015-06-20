--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local CurTime = CurTime;
local surface = surface;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.Icon.PaintOver = function(icon)
		local curTime = CurTime();
		
		if (self.Cooldown and self.Cooldown.expireTime > curTime) then
			local timeLeft = self.Cooldown.expireTime - curTime;
			local progress = 100 - ((100 / self.Cooldown.duration) * timeLeft);
	
			Clockwork.cooldown:DrawBox(
				self.x,
				self.y,
				self:GetWide(),
				self:GetTall(),
				progress, Color(255, 255, 255, 255 - ((255 / 100) * progress)),
				self.Cooldown.textureID
			);
		end;
		
		if (self.BorderColor) then
			local alpha = math.min(self.BorderColor.a, self:GetAlpha());
			Clockwork.SpawnIconMaterial:SetVector("$color", Vector(self.BorderColor.r / 255, self.BorderColor.g / 255, self.BorderColor.b / 255));
			Clockwork.SpawnIconMaterial:SetFloat("$alpha", alpha / 255);
				surface.SetDrawColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, alpha);
				surface.SetMaterial(Clockwork.SpawnIconMaterial);
				self:DrawTexturedRect();
			Clockwork.SpawnIconMaterial:SetFloat("$alpha", 1);
			Clockwork.SpawnIconMaterial:SetVector("$color", Vector(1, 1, 1));
		end;
	end;
end;

-- A function to set the border color.
function PANEL:SetColor(color)
	self.BorderColor = color;
end;

-- A function to set the cooldown.
function PANEL:SetCooldown(expireTime, textureID)
	self.Cooldown = {
		expireTime = expireTime,
		textureID = textureID or surface.GetTextureID("vgui/white"),
		duration = expireTime - CurTime()
	};
end;

vgui.Register("cwSpawnIcon", PANEL, "SpawnIcon");