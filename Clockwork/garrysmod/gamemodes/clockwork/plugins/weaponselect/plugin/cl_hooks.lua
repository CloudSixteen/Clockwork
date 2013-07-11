--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a HUD element should be drawn.
function cwWeaponSelect:HUDShouldDraw(name)
	if (name == "CHudWeaponSelection") then
		return false;
	end;
end;

-- Called when the important HUD should be painted.
function cwWeaponSelect:HUDPaintImportant()
	local informationColor = Clockwork.option:GetColor("information");
	local activeWeapon = Clockwork.Client:GetActiveWeapon();
	local newWeapons = {};
	local colorWhite = Clockwork.option:GetColor("white");
	local frameTime = FrameTime();
	local weapons = Clockwork.Client:GetWeapons();
	local curTime = UnPredictedCurTime();
	local x = ScrW() / 6;
	local y = ScrH() / 4;
	
	if (!IsValid(activeWeapon) or self.displayAlpha == 0) then
		return;
	end;
	
	Clockwork.kernel:OverrideMainFont(Clockwork.option:GetFont("menu_text_tiny"));
	
	for k, v in pairs(weapons) do
		local secondaryAmmo = Clockwork.Client:GetAmmoCount(v:GetSecondaryAmmoType());
		local primaryAmmo = Clockwork.Client:GetAmmoCount(v:GetPrimaryAmmoType());
		local clipOne = v:Clip1();
		local clipTwo = v:Clip2();
		
		if (clipOne > 0 or clipTwo > 0 or (clipOne == -1 and clipTwo == -1)
		or (clipOne == -1 and clipTwo > 0 and secondaryAmmo > 0)
		or (clipTwo == -1 and clipOne > 0 and primaryAmmo > 0)
		or (clipOne != -1 and primaryAmmo > 0)
		or (clipTwo != -1 and secondaryAmmo > 0)) then
			newWeapons[#newWeapons + 1] = v;
		end;
	end;
	
	if (self.displaySlot < 1) then
		self.displaySlot = #newWeapons;
	elseif (self.displaySlot > #newWeapons) then
		self.displaySlot = 1;
	end;
	
	local currentWeapon = newWeapons[self.displaySlot];
	local beforeWeapons = {};
	local afterWeapons = {};
	local weaponLimit = math.Clamp(#newWeapons, 2, 4);
	
	if (#newWeapons > 1) then
		for k, v in pairs(newWeapons) do
			if (k < self.displaySlot) then
				beforeWeapons[#beforeWeapons + 1] = v;
			elseif (k > self.displaySlot) then
				afterWeapons[#afterWeapons + 1] = v;
			end;
		end;
		
		if (#beforeWeapons < weaponLimit) then
			local i = 0;
			
			while (#beforeWeapons < weaponLimit) do
				local possibleWeapon = newWeapons[#newWeapons - i];
				
				if (possibleWeapon) then
					table.insert(beforeWeapons, 1, possibleWeapon);
					i = i + 1;
				else
					i = 0;
				end;
			end;
		end;
		
		if (#afterWeapons < weaponLimit) then
			local i = 0;
			
			while (#afterWeapons < weaponLimit) do
				local possibleWeapon = newWeapons[1 + i];
				
				if (possibleWeapon) then
					afterWeapons[#afterWeapons + 1] = possibleWeapon;
					
					i = i + 1;
				else
					i = 0;
				end;
			end;
		end;
		
		while (#beforeWeapons > weaponLimit) do
			table.remove(beforeWeapons, 1);
		end;
		
		while (#afterWeapons > weaponLimit) do
			afterWeapons[#afterWeapons] = nil;
		end;
		
		for k, v in pairs(beforeWeapons) do
			local weaponAlpha = math.min((255 / weaponLimit) * k, self.displayAlpha);
			y = Clockwork.kernel:DrawInfo(
				string.upper(self:GetWeaponPrintName(v)), x, y, colorWhite, weaponAlpha, true,
				function(x, y, width, height)
					Clockwork.kernel:DrawGradient(
						GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(100, 100, 100, weaponAlpha)
					);
					
					return x, y;
				end
			) + 3;
		end;
	end;
	
	if (IsValid(currentWeapon)) then
		local currentWeaponName = string.upper(self:GetWeaponPrintName(currentWeapon));
		local weaponInfoY = y;
		local weaponInfoX = x + 196;
		
		y = Clockwork.kernel:DrawInfo(
			currentWeaponName, x, y, colorWhite, self.displayAlpha, true,
			function(x, y, width, height)
				Clockwork.kernel:DrawGradient(
					GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(
						informationColor.r, informationColor.g, informationColor.b, self.displayAlpha
					)
				);
				
				return x, y;
			end
		) + 3;
		
		Clockwork.kernel:OverrideMainFont(false);
			self:DrawWeaponInformation(
				Clockwork.item:GetByWeapon(currentWeapon), currentWeapon, weaponInfoX, weaponInfoY, self.displayAlpha
			);
			
			if (#newWeapons == 1) then
				y = Clockwork.kernel:DrawInfo(
					"There are no other weapons.", x, y, colorWhite, self.displayAlpha, true,
					function(x, y, width, height)
						Clockwork.kernel:DrawGradient(
							GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(100, 100, 100, self.displayAlpha)
						);
						
						return x, y;
					end
				) + 3;
			end;
		Clockwork.kernel:OverrideMainFont(Clockwork.option:GetFont("menu_text_tiny"));
	end;
	
	if (#newWeapons > 1) then
		for k, v in pairs(afterWeapons) do
			local weaponAlpha = math.min(255 - ((255 / weaponLimit) * k), self.displayAlpha);
			y = Clockwork.kernel:DrawInfo(
				string.upper(self:GetWeaponPrintName(v)), x, y, colorWhite, weaponAlpha, true,
				function(x, y, width, height)
					Clockwork.kernel:DrawGradient(
						GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(100, 100, 100, weaponAlpha)
					);
					
					return x, y;
				end
			) + 3;
		end;
	end;
	
	Clockwork.kernel:OverrideMainFont(false);
	
	if (self.displayAlpha > 0 and curTime >= self.displayFade) then
		self.displayAlpha = math.max(self.displayAlpha - (frameTime * 64), 0);
	end;
end;

-- Called when a player presses a bind at the top level.
function cwWeaponSelect:TopLevelPlayerBindPress(player, bind, bPress)
	local activeWeapon = Clockwork.Client:GetActiveWeapon();
	local newWeapons = {};
	local curTime = UnPredictedCurTime();
	local weapons = Clockwork.Client:GetWeapons();
	
	if (!IsValid(activeWeapon)) then return; end;
	if (Clockwork.Client:InVehicle()) then return; end;
	
	if (activeWeapon:GetClass() == "weapon_physgun") then
		if (player:KeyDown(IN_ATTACK)) then
			return;
		end;
	end;
	
	for k, v in pairs(weapons) do
		local secondaryAmmo = Clockwork.Client:GetAmmoCount(v:GetSecondaryAmmoType());
		local primaryAmmo = Clockwork.Client:GetAmmoCount(v:GetPrimaryAmmoType());
		local clipOne = v:Clip1();
		local clipTwo = v:Clip2();
		
		if (clipOne > 0 or clipTwo > 0 or (clipOne == -1 and clipTwo == -1)
		or (clipOne == -1 and clipTwo > 0 and secondaryAmmo > 0)
		or (clipTwo == -1 and clipOne > 0 and primaryAmmo > 0)
		or (clipOne != -1 and primaryAmmo > 0)
		or (clipTwo != -1 and secondaryAmmo > 0)) then
			newWeapons[#newWeapons + 1] = v;
		end;
	end;

	if (#newWeapons == 1 and Clockwork.config:Get("weapon_selection_multi"):Get()) then
		return;
	end;
	
	if (string.find(bind, "invnext") or string.find(bind, "slot2")) then
		if (curTime >= self.displayDelay and !bPress) then
			if (#newWeapons > 1) then
				surface.PlaySound("common/talk.wav");
			end;
			
			self.displayDelay = curTime + 0.05;
			self.displayAlpha = 255;
			self.displayFade = curTime + 2;
			self.displaySlot = self.displaySlot + 1;
			
			if (self.displaySlot > #newWeapons) then
				self.displaySlot = 1;
			end;
		end;
		
		return true;
	elseif (string.find(bind, "invprev") or string.find(bind, "slot1")) then
		if (curTime >= self.displayDelay and !bPress) then
			if (#newWeapons > 1) then
				surface.PlaySound("common/talk.wav");
			end;
			
			self.displayDelay = curTime + 0.05;
			self.displayAlpha = 255;
			self.displayFade = curTime + 2;
			self.displaySlot = self.displaySlot - 1;
			
			if (self.displaySlot < 1) then
				self.displaySlot = #newWeapons;
			end;
		end;
		
		return true;
	elseif (string.find(bind, "+attack")) then
		if (#newWeapons > 1) then
			if (self.displayAlpha >= 128 and IsValid(newWeapons[self.displaySlot])) then
				Clockwork.datastream:Start("SelectWeapon", newWeapons[self.displaySlot]:GetClass());
					Clockwork.option:PlaySound("click_release");
				self.displayAlpha = 0;
				return true
			end;
		end;
	end;
end;