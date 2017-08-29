--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = Clockwork.theme:New("Legacy Phase Four", "Legacy Clockwork", true);

-- Called when fonts should be created.
function THEME:CreateFonts()
	Clockwork.fonts:Add("lab_Large3D2D", {
		size = Clockwork.kernel:FontScreenScale(2048),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_IntroTextSmall", {
		size = Clockwork.kernel:FontScreenScale(10),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_IntroTextTiny", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_CinematicText", {
		size = Clockwork.kernel:FontScreenScale(24),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_IntroTextBig", {
		size = Clockwork.kernel:FontScreenScale(18),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_TargetIDText", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_SmallBarText", {
		size = Clockwork.kernel:FontScreenScale(12),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_MenuTextHuge", {
		size = Clockwork.kernel:FontScreenScale(32),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_MenuTextBig", {
		size = Clockwork.kernel:FontScreenScale(22),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_PlayerInfoText", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});

	Clockwork.fonts:Add("lab_MainText", {
		size = Clockwork.kernel:FontScreenScale(9),
		weight = 600, 
		antialias = true,
		font = "Dirty Ego"
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	Clockwork.option:SetFont("bar_text", "lab_TargetIDText");
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
	
	Clockwork.option:SetColor("information", Color(132, 219, 232, 255));
	Clockwork.option:SetColor("foreground", Color(50, 50, 50, 125));
	Clockwork.option:SetColor("target_id", Color(88, 155, 221, 255));
end;

local DIRTY_TEXTURE = Material("phasefour/dirty.png");
local SCRATCH_TEXTURE = Material("phasefour/scratch.png");

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo)
	surface.SetDrawColor(255, 255, 255, 150);
		surface.SetMaterial(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.width, barInfo.height);
	
	barInfo.drawBackground = false;
	barInfo.drawProgress = false;
	
	if (barInfo.text) then
		barInfo.text = string.upper(barInfo.text);
	end;
end;

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo)
	surface.SetDrawColor(barInfo.color.r, barInfo.color.g, barInfo.color.b, barInfo.color.a);
		surface.SetMaterial(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.progressWidth, barInfo.height);
end;

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info)
	surface.SetDrawColor(255, 255, 255, math.min(200, info.alpha));
		surface.SetMaterial(DIRTY_TEXTURE);
	surface.DrawTexturedRect(info.x, info.y, info.width, info.height);
	
	info.drawBackground = false;
end;

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation)
	surface.SetDrawColor(255, 255, 255, 100);
		surface.SetMaterial(DIRTY_TEXTURE);
	surface.DrawTexturedRect(boxInfo.x, boxInfo.y, boxInfo.width, boxInfo.height);
	
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