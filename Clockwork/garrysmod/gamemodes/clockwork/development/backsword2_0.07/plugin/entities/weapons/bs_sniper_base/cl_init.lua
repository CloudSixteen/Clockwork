--[[ TETA_BONITA MADE THE FADING EFFECT. THANKS TETA_BONITA IF YOU'RE STILL ALIVE, AS WELL AS FONIX, AND WORSHIPPER FOR A MAJORITY OF THIS SCOPE BASE AND ETC. --]]

include("shared.lua")

local iScreenWidth = surface.ScreenWidth()
local iScreenHeight = surface.ScreenHeight()
local SCOPEFADE_TIME = 1

function SWEP:DrawHUD()
	if self.UseScope then
		local bScope = self.Weapon:GetNetworkedBool("Scope")

		if bScope ~= self.bLastScope then
		
			self.bLastScope = bScope
			self.fScopeTime = CurTime()
				
		elseif 	bScope then
			local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")

			if fScopeZoom ~= self.fLastScopeZoom then
			
				self.fLastScopeZoom = fScopeZoom
				self.fScopeTime = CurTime()
			end;
		end;
				
		local fScopeTime = self.fScopeTime or 0

		if fScopeTime > CurTime() - SCOPEFADE_TIME then
			local Mul = 3.0

			Mul = 1 - math.Clamp((CurTime() - fScopeTime)/SCOPEFADE_TIME, 0, 1)
				
			if  self.Weapon:GetNetworkedBool("Scope") then
				self.Owner:DrawViewModel(false)
			else
				self.Owner:DrawViewModel(true)
			end;
			
			surface.SetDrawColor(0, 0, 0, 255*Mul)
			surface.DrawRect(0,0,iScreenWidth,iScreenHeight)
		end;

		if (bScope) then 

			if not (self.ScopeReddot or self.ScopeMs) then
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawLine(self.CrossHairTable.x11, self.CrossHairTable.y11, self.CrossHairTable.x12, self.CrossHairTable.y12)
				surface.DrawLine(self.CrossHairTable.x21, self.CrossHairTable.y21, self.CrossHairTable.x22, self.CrossHairTable.y22)
			end;

			surface.SetDrawColor(0, 0, 0, 255)
			
			if (self.Scope1) then
				surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			end;

			if (self.Scope2) then
				surface.SetTexture(surface.GetTextureID("scope/scope_reddot"))

				surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)
			end;
			
			if (self.Scope1) then
				surface.SetDrawColor(10, 10, 10, 255)
				surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
				surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
				surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
				surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)
			end;

			if (self.Scope2) then
				surface.SetDrawColor(10, 10, 10, 255)
				surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
				surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
				surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
				surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)    
			end;
		end;
	end;
end;