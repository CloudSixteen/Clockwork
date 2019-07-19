--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local CurTime = CurTime;
local surface = surface;
local vgui = vgui;
local math = math;

local borderMat = Material("gui/sm_hover.png", "nocull");
local borderSize = 4
local borderW = 5
local boxHover = GWEN.CreateTextureBorder(borderSize, borderSize, 64 - borderSize * 2, 64 - borderSize * 2, borderW, borderW, borderW, borderW, borderMat);

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.HoverColor = Clockwork.option:GetColor("information");
end;

-- Called when the panel is painted.
function PANEL:Paint()
	self.OverlayFade = math.Clamp((self.OverlayFade or 0) - RealFrameTime() * 640 * 2, 0, 255);

	if (dragndrop.IsDragging() || !self:IsHovered()) then
		return;
	end;

	self.OverlayFade = math.Clamp(self.OverlayFade + RealFrameTime() * 640 * 8, 0, 255);
end;

-- Called when the panel should be painted over.
function PANEL:PaintOver(w, h)
	local curTime = CurTime();
	
	if (self.Cooldown and self.Cooldown.expireTime > curTime) then
		local timeLeft = self.Cooldown.expireTime - curTime;
		local progress = 100 - ((100 / self.Cooldown.duration) * timeLeft);

		Clockwork.cooldown:DrawBox(
			0,
			0,
			w,
			h,
			progress, Color(255, 255, 255, 255 - ((255 / 100) * progress)),
			self.Cooldown.textureID
		);
	end;
	
	if (self.HoverColor and self.OverlayFade > 0) then
		local alpha = math.min(self.OverlayFade, self:GetAlpha());
		
		boxHover(0, 0, w, h, Color(self.HoverColor.r, self.HoverColor.g, self.HoverColor.b, alpha));
	end;
	
	if (self.BorderColor) then
		local alpha = math.min(self.BorderColor.a, self:GetAlpha());
		
		boxHover(0, 0, w, h, Color(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, alpha))
	end;
end;

-- A function to set the hover color.
function PANEL:SetHoverColor(color)
	self.HoverColor = color;
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