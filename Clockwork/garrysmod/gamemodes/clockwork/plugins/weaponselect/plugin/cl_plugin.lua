--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.config:AddToSystem("Weapon selection multi", "weapon_selection_multi", "Should the weapon selection be hidden if the player has only one weapon.");

-- A function to draw a weapon's information.
function cwWeaponSelect:DrawWeaponInformation(itemTable, weapon, x, y, alpha)
	local informationColor = Clockwork.option:GetColor("information");
	local clipTwoAmount = Clockwork.Client:GetAmmoCount(weapon:GetSecondaryAmmoType());
	local clipOneAmount = Clockwork.Client:GetAmmoCount(weapon:GetPrimaryAmmoType());
	local mainTextFont = Clockwork.option:GetFont("main_text");
	local secondaryAmmo = nil;
	local primaryAmmo = nil;
	local clipTwo = weapon:Clip2();
	local clipOne = weapon:Clip1();
	
	if (!weapon.Primary or !weapon.Primary.ClipSize or weapon.Primary.ClipSize > 0) then
		if (clipOne >= 0) then
			primaryAmmo = "Primary: "..clipOne.."/"..clipOneAmount..".";
		end;
	end;
	
	if (!weapon.Secondary or !weapon.Secondary.ClipSize or weapon.Secondary.ClipSize > 0) then
		if (clipTwo >= 0) then
			secondaryAmmo = "Secondary: "..clipTwo.."/"..clipTwoAmount..".";
		end;
	end;
	
	if (!weapon.Instructions) then weapon.Instructions = ""; end;
	if (!weapon.Purpose) then weapon.Purpose = ""; end;
	if (!weapon.Contact) then weapon.Contact = ""; end;
	if (!weapon.Author) then weapon.Author = ""; end;
	
	if (itemTable or primaryAmmo or secondaryAmmo or (weapon.DrawWeaponInfoBox
	and (weapon.Author != "" or weapon.Contact != "" or weapon.Purpose != ""
	or weapon.Instructions != ""))) then
		local text = "<font="..mainTextFont..">";
		local textColor = "<color=255,255,255,255>";
		local titleColor = "<color=230,230,230,255>";
		
		if (informationColor) then
			titleColor = "<color="..informationColor.r..","..informationColor.g..","..informationColor.b..",255>";
		end;
		
		if (itemTable and itemTable("description") != "") then
			text = text..titleColor.."DESCRIPTIPON</color>\n"..textColor..Clockwork.config:Parse(itemTable("description")).."</color>\n";
		end;
		
		if (primaryAmmo or secondaryAmmo) then
			text = text..titleColor.."AMMUNITION</color>\n";
			
			if (secondaryAmmo) then
				text = text..textColor..secondaryAmmo.."</color>\n";
			end;
			
			if (primaryAmmo) then
				text = text..textColor..primaryAmmo.."</color>\n";
			end;
		end;
		
		if (weapon.Instructions != "") then
			text = text..titleColor.."INSTRUCTIONS</color>\n"..textColor..weapon.Instructions.."</color>\n";
		end;
		
		if (weapon.Purpose != "") then
			text = text..titleColor.."PURPOSE</color>\n"..textColor..weapon.Purpose.."</color>\n";
		end;
		
		if (weapon.Contact != "") then
			text = text..titleColor.."CONTACT</color>\n"..textColor..weapon.Contact.."</color>\n";
		end;
		
		if (weapon.Author != "") then
			text = text..titleColor.."AUTHOR</color>\n"..textColor..weapon.Author.."</color>\n";
		end;
		
		weapon.InfoMarkup = markup.Parse(text.."</font>", 248);
		Clockwork.kernel:OverrideMarkupDraw(weapon.InfoMarkup);
		
		local weaponMarkupHeight = weapon.InfoMarkup:GetHeight();
		local realY = y - (weaponMarkupHeight / 2);
		local info = {
			drawBackground = false,
			weapon = weapon,
			height = weaponMarkupHeight + 8,
			width = 260,
			alpha = alpha,
			x = x - 4,
			y = realY
		};
		
		Clockwork.plugin:Call("PreDrawWeaponSelectionInfo", info);
		
		if (info.drawBackground) then
			Clockwork.kernel:DrawGradient(
				GRADIENT_CENTER, x - 64, realY, 320, weaponMarkupHeight + 8, Color(100, 100, 100, alpha)
			);
		end;
		
		if (weapon.InfoMarkup) then
			weapon.InfoMarkup:Draw(x + 4, realY + 4, nil, nil, alpha);
		end;
	end;
end;

-- A function to get a weapon's print name.
function cwWeaponSelect:GetWeaponPrintName(weapon)
	local printName = weapon:GetPrintName();
	local class = string.lower(weapon:GetClass());
	
	if (printName and printName != "") then
		self.weaponPrintNames[class] = printName;
	end;
	
	return self.weaponPrintNames[class] or printName;
end;