--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = Clockwork.theme:New("Phase Four", nil, true);

-- Called when fonts should be created.
function THEME:CreateFonts()
	Clockwork.fonts:Add("lab_Large3D2D", {
		size = Clockwork.kernel:FontScreenScale(2048),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_IntroTextSmall", {
		size = Clockwork.kernel:FontScreenScale(10),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_IntroTextTiny", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_CinematicText", {
		size = Clockwork.kernel:FontScreenScale(24),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_IntroTextBig", {
		size = Clockwork.kernel:FontScreenScale(28),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_TargetIDText", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_SmallBarText", {
		size = Clockwork.kernel:FontScreenScale(12),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_MenuTextHuge", {
		size = Clockwork.kernel:FontScreenScale(32),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_MenuTextBig", {
		size = Clockwork.kernel:FontScreenScale(22),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_PlayerInfoText", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});

	Clockwork.fonts:Add("lab_MainText", {
		size = Clockwork.kernel:FontScreenScale(9),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});
	
	Clockwork.fonts:Add("lab_BarText", {
		size = Clockwork.kernel:FontScreenScale(7),
		weight = 600, 
		antialias = true,
		font = "Rakesly Rg"
	});
	
	Clockwork.fonts:Add("lab_BarTextAuto", {
		size = Clockwork.kernel:FontScreenScale(5),
		weight = 600, 
		antialias = true,
		font = "Arial"
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	Clockwork.option:SetFont("bar_text", "lab_BarText");
	Clockwork.option:SetFont("auto_bar_text", "lab_BarTextAuto");
	Clockwork.option:SetFont("main_text", "lab_MainText");
	Clockwork.option:SetFont("hints_text", "lab_IntroTextTiny");
	Clockwork.option:SetFont("large_3d_2d", "lab_Large3D2D");
	Clockwork.option:SetFont("target_id_text", "lab_TargetIDText");
	Clockwork.option:SetFont("cinematic_text", "lab_CinematicText");
	Clockwork.option:SetFont("date_time_text", "lab_IntroTextSmall");
	Clockwork.option:SetFont("menu_text_big", "lab_MenuTextBig");
	Clockwork.option:SetFont("menu_text_huge", "lab_MenuTextHuge");
	Clockwork.option:SetFont("menu_text_tiny", "lab_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_big", "lab_IntroTextBig");
	Clockwork.option:SetFont("menu_text_small", "lab_IntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "lab_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_small", "lab_IntroTextSmall");
	Clockwork.option:SetFont("player_info_text", "lab_PlayerInfoText");
	
	Clockwork.option:SetColor("columnsheet_shadow_normal", Color(0, 0, 0, 0));
	Clockwork.option:SetColor("columnsheet_text_normal", Color(255, 255, 255, 255));
	Clockwork.option:SetColor("columnsheet_shadow_active", Color(0, 0, 0, 0));
	Clockwork.option:SetColor("columnsheet_text_active", Color(63, 235, 255, 255));
	
	Clockwork.option:SetColor("basic_form_highlight", Color(26, 169, 192, 255));
	
	Clockwork.option:SetKey("info_text_red_icon", "phasefour/infotext/red.png");
	Clockwork.option:SetKey("info_text_green_icon", "phasefour/infotext/green.png");
	Clockwork.option:SetKey("info_text_orange_icon", "phasefour/infotext/orange.png");
	Clockwork.option:SetKey("info_text_blue_icon", "phasefour/infotext/blue.png");
	
	Clockwork.option:SetKey("top_bar_width_scale", 0.15);
	
	--Clockwork.option:SetKey("icon_data_classes", {path = "", size = 32});
	Clockwork.option:SetKey("icon_data_settings", {path = "phasefour/menuitems/settings.png", size = 32});
	--Clockwork.option:SetKey("icon_data_donations", {path = "", size = 32});
	Clockwork.option:SetKey("icon_data_system", {path = "phasefour/menuitems/system.png", size = 32});
	Clockwork.option:SetKey("icon_data_scoreboard", {path = "phasefour/menuitems/scoreboard.png", size = 32});
	Clockwork.option:SetKey("icon_data_inventory", {path = "phasefour/menuitems/inventory.png", size = 32});
	Clockwork.option:SetKey("icon_data_directory", {path = "phasefour/menuitems/directory.png", size = 32});
	Clockwork.option:SetKey("icon_data_attributes", {path = "phasefour/menuitems/attributes.png", size = 32});
	Clockwork.option:SetKey("icon_data_business", {path = "phasefour/menuitems/crafting.png", size = 32});
	Clockwork.option:SetKey("icon_data_titles", {path = "phasefour/menuitems/titles.png", size = 32});
	Clockwork.option:SetKey("icon_data_bounties", {path = "phasefour/menuitems/bounties.png", size = 32});
	Clockwork.option:SetKey("icon_data_alliance", {path = "phasefour/menuitems/alliance.png", size = 32});
	Clockwork.option:SetKey("icon_data_augments", {path = "phasefour/menuitems/augments.png", size = 32});
	Clockwork.option:SetKey("icon_data_victories", {path = "phasefour/menuitems/victories.png", size = 32});
	Clockwork.option:SetKey("icon_data_safebox", {path = "phasefour/menuitems/safebox.png", size = 32});
	
	Clockwork.option:SetColor("information", Color(26, 169, 192, 255));
	Clockwork.option:SetColor("foreground", Color(50, 50, 50, 125));
	Clockwork.option:SetColor("target_id", Color(63, 184, 203, 255));
	
	SMALL_BAR_BG = Clockwork.render:AddSlice9("SimpleTint", "phasefour/simpletint", 6);
	SMALL_BAR_FG = Clockwork.render:AddSlice9("SimpleTint", "phasefour/simpletint", 6);
	INFOTEXT_SLICED = Clockwork.render:AddSlice9("SimpleRed", "phasefour/simplered", 28);
	MENU_ITEM_SLICED = Clockwork.render:AddSlice9("SimpleTint", "phasefour/simpletint", 6);
	SLICED_SMALL_TINT = Clockwork.render:AddSlice9("SimpleTint", "phasefour/simpletint", 6);
	SLICED_INFO_MENU_INSIDE = Clockwork.render:AddSlice9("SimpleTint", "phasefour/simpletint", 6);
	SLICED_COLUMNSHEET_BUTTON = Clockwork.render:AddSlice9("SimpleDark2", "phasefour/simpledark2", 20);
	PANEL_LIST_SLICED = Clockwork.render:AddSlice9("SimpleDark2", "phasefour/simpledark2", 20);
	DERMA_SLICED_BG = Clockwork.render:AddSlice9("SimpleDark2", "phasefour/simpledark2", 20);
	SLICED_LARGE_DEFAULT = Clockwork.render:AddSlice9("SimpleRed", "phasefour/simplered", 28);
	SLICED_PROGRESS_BAR = Clockwork.render:AddSlice9("SimpleRed", "phasefour/simplered", 28);
	SLICED_PLAYER_INFO = Clockwork.render:AddSlice9("SimpleRed", "phasefour/simplered", 28);
	SLICED_INFO_MENU_BG = Clockwork.render:AddSlice9("SimpleDark2", "phasefour/simpledark2", 20);
	
	Clockwork.bars.height = 16;
	Clockwork.bars.padding = 28;
end;

local DIRTY_TEXTURE = Material("phasefour/dirty.png");
local SCRATCH_TEXTURE = Material("phasefour/scratch.png");

local HEALTH_ICON = Material("phasefour/icons/health.png");
local VILLAIN_ICON = Material("phasefour/icons/villain.png");
local JETPACK_ICON = Material("phasefour/icons/jetpack.png");
local STAMINA_ICON = Material("phasefour/icons/stamina.png");
local ARMOR_ICON = Material("phasefour/icons/armor.png");
local HERO_ICON = Material("phasefour/icons/hero.png");

function THEME:GetBarIconFromClass(class)
	if (class == "HEALTH") then
		return HEALTH_ICON;
	elseif (class == "ARMOR") then
		return ARMOR_ICON;
	elseif (class == "STAMINA") then
		return STAMINA_ICON;
	elseif (class == "FUEL") then
		return JETPACK_ICON;
	elseif (class == "HONOR") then
		local honor = Clockwork.Client:GetSharedVar("honor");
		
		if (honor and honor >= 50) then
			return HERO_ICON;
		else
			return VILLAIN_ICON;
		end;
	end;
end;

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo)
	--[[
	surface.SetDrawColor(255, 255, 255, 150);
		surface.SetMaterial(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.width, barInfo.height);
	--]]
	
	SLICED_SMALL_TINT:Draw(barInfo.x, barInfo.y, barInfo.width, barInfo.height, 4, Color(255, 255,255, 100));
	
	barInfo.drawBackground = false;
	barInfo.drawProgress = false;
	
	if (barInfo.text) then
		barInfo.text = string.upper(barInfo.text);
	end;
end;

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo)
	local width = barInfo.progressWidth;
	
	if (width >= barInfo.width - 8) then
		width = barInfo.width;
	end;
	
	if (width > 8) then
		SLICED_SMALL_TINT:Draw(barInfo.x, barInfo.y, width, barInfo.height, 4, Color(barInfo.color.r, barInfo.color.g, barInfo.color.b, barInfo.color.a));
	end;
	
	surface.SetDrawColor(barInfo.color.r, barInfo.color.g, barInfo.color.b, barInfo.color.a * 0.4);
		surface.SetMaterial(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, width, barInfo.height);
	
	local icon = THEME:GetBarIconFromClass(barInfo.uniqueID);
	
	if (icon) then
		local iconSize = barInfo.height * 2.5;
		local halfHeight = barInfo.height * 0.5;
		
		surface.SetDrawColor(255, 255, 255, barInfo.color.a);
			surface.SetMaterial(icon);
		surface.DrawTexturedRect(barInfo.x - 8, (barInfo.y + halfHeight) - (iconSize * 0.5), iconSize, iconSize);
	end;
end;

-- Called when the menu is opened.
function THEME.module:MenuOpened()
	if (Clockwork.Client:HasInitialized()) then
		Clockwork.kernel:RegisterBackgroundBlur("MainMenu", SysTime());
	end;
end;

-- Called when the menu is closed.
function THEME.module:MenuClosed()
	if (Clockwork.Client:HasInitialized()) then
		Clockwork.kernel:RemoveBackgroundBlur("MainMenu");
	end;
end;

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info)
	--[[
	surface.SetDrawColor(255, 255, 255, math.min(200, info.alpha));
		surface.SetMaterial(DIRTY_TEXTURE);
	surface.DrawTexturedRect(info.x, info.y, info.width, info.height);
	--]]
	
	DERMA_SLICED_BG:Draw(info.x, info.y, info.width, info.height, 4, Color(255, 255,255, info.alpha));
	
	surface.SetDrawColor(255, 255, 255, math.min(50, info.alpha));
		surface.SetMaterial(DIRTY_TEXTURE);
	surface.DrawTexturedRect(info.x, info.y, info.width, info.height);
	
	info.drawBackground = false;
end;

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation)
	DERMA_SLICED_BG:Draw(boxInfo.x, boxInfo.y, boxInfo.width, boxInfo.height, 4, Color(255, 255,255, 200));
	
	surface.SetDrawColor(255, 255, 255, 50);
		surface.SetMaterial(DIRTY_TEXTURE);
	surface.DrawTexturedRect(boxInfo.x + 2, boxInfo.y + 2, boxInfo.width - 4, boxInfo.height - 4);
	
	boxInfo.drawBackground = false;
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