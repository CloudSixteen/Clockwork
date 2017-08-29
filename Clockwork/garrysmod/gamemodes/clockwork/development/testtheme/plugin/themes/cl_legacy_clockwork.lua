--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = Clockwork.theme:New("Legacy Clockwork", nil);

-- Called when to initialize the theme.
function THEME:Initialize()
end;

function THEME.module:PreDrawWeaponList(x, y, weaponLimit, displayAlpha, beforeWeapons, currentWeapon, afterWeapons, newWeapons)
	local colorWhite = Clockwork.option:GetColor("white");
	local informationColor = Clockwork.option:GetColor("information");

	if (#beforeWeapons > 1) then
		for k, v in pairs(beforeWeapons) do
			local weaponAlpha = math.min((255 / weaponLimit) * k, displayAlpha);
					
			y = Clockwork.kernel:DrawInfo(
				string.upper(cwWeaponSelect:GetWeaponPrintName(v)), x, y, colorWhite, weaponAlpha, true,
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
		local currentWeaponName = string.upper(cwWeaponSelect:GetWeaponPrintName(currentWeapon));
		local weaponInfoY = y;
		local weaponInfoX = x + 196;
			
		y = Clockwork.kernel:DrawInfo(
			currentWeaponName, x, y, colorWhite, displayAlpha, true,
			function(x, y, width, height)
				Clockwork.kernel:DrawGradient(
					GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(
						informationColor.r, informationColor.g, informationColor.b, displayAlpha
					)
				);
				
				return x, y;
			end
		) + 3;
			
		Clockwork.kernel:OverrideMainFont(false);
			cwWeaponSelect:DrawWeaponInformation(
				Clockwork.item:GetByWeapon(currentWeapon), currentWeapon, weaponInfoX, weaponInfoY, displayAlpha
			);
				
			if (#newWeapons == 1) then
				y = Clockwork.kernel:DrawInfo(
					"There are no other weapons.", x, y, colorWhite, displayAlpha, true,
					function(x, y, width, height)
						Clockwork.kernel:DrawGradient(
							GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(100, 100, 100, displayAlpha)
						);
						
						return x, y;
					end
				) + 3;
			end;
		Clockwork.kernel:OverrideMainFont(Clockwork.option:GetFont("menu_text_tiny"));
	end;
		
	if (#newWeapons > 1) then
		for k, v in pairs(afterWeapons) do
			local weaponAlpha = math.min(255 - ((255 / weaponLimit) * k), displayAlpha);
			
			y = Clockwork.kernel:DrawInfo(
				string.upper(cwWeaponSelect:GetWeaponPrintName(v)), x, y, colorWhite, weaponAlpha, true,
				function(x, y, width, height)
					Clockwork.kernel:DrawGradient(
						GRADIENT_RIGHT, x - 2, y - 1, 128, height + 2, Color(100, 100, 100, weaponAlpha)
					);
					
					return x, y;
				end
			) + 3;
		end;
	end;
end;

-- Called after the character menu has initialized.
function THEME.hooks:PostCharacterMenuInit(panel) end;

-- Called every frame that the character menu is open.
function THEME.hooks:PostCharacterMenuThink(panel) end;

-- Called after the character menu is painted.
function THEME.hooks:PostCharacterMenuPaint(panel) end;

-- Called after a character menu panel is opened.
function THEME.hooks:PostCharacterMenuOpenPanel(panel) end;

-- Called after the main menu has initialized.
function THEME.hooks:PostMainMenuInit(panel) end;

-- Called after the main menu is rebuilt.
function THEME.hooks:PostMainMenuRebuild(panel) end;

-- Called after a main menu panel is opened.
function THEME.hooks:PostMainMenuOpenPanel(panel, panelToOpen) end;

-- Called after the main menu is painted.
function THEME.hooks:PostMainMenuPaint(panel) end;

-- Called every frame that the main menu is open.
function THEME.hooks:PostMainMenuThink(panel) end;

Clockwork.theme:Register();