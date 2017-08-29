--[[ 
    © CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
--]]

local THEME = Clockwork.theme:New("Cider Two");

-- Called when fonts should be created.
function THEME:CreateFonts()
	Clockwork.fonts:Add("cid_Large3D2D", {
		size = Clockwork.kernel:FontScreenScale(2048),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_IntroTextSmall", {
		size = Clockwork.kernel:FontScreenScale(12),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_IntroTextTiny", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_CinematicText", {
		size = Clockwork.kernel:FontScreenScale(14),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_IntroTextBig", {
		size = Clockwork.kernel:FontScreenScale(14),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_TargetIDText", {
		size = Clockwork.kernel:FontScreenScale(10),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_MenuTextHuge", {
		size = Clockwork.kernel:FontScreenScale(18),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_MenuTextBig", {
		size = Clockwork.kernel:FontScreenScale(16),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_MainText", {
		size = Clockwork.kernel:FontScreenScale(8),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_BillboardSmall", {
		size = Clockwork.kernel:FontScreenScale(10),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_BillboardBig", {
		size = Clockwork.kernel:FontScreenScale(36),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_SmallBarText", {
		size = Clockwork.kernel:FontScreenScale(5),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});

	Clockwork.fonts:Add("cid_PlayerInfoText", {
		size = Clockwork.kernel:FontScreenScale(10),
		weight = 600,
		antialias = true,
		font = "Sansation"
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	Clockwork.option:SetColor("information", Color(200, 100, 100, 255));
	
	Clockwork.option:SetFont("bar_text", "cid_TargetIDText");
	Clockwork.option:SetFont("main_text", "cid_MainText");
	Clockwork.option:SetFont("hints_text", "cid_IntroTextTiny");
	Clockwork.option:SetFont("large_3d_2d", "cid_Large3D2D");
	Clockwork.option:SetFont("auto_bar_text", "cid_SmallBarText");
	Clockwork.option:SetFont("target_id_text", "cid_TargetIDText");
	Clockwork.option:SetFont("cinematic_text", "cid_CinematicText");
	Clockwork.option:SetFont("date_time_text", "cid_IntroTextSmall");
	Clockwork.option:SetFont("menu_text_big", "cid_MenuTextBig");
	Clockwork.option:SetFont("menu_text_huge", "cid_MenuTextHuge");
	Clockwork.option:SetFont("menu_text_tiny", "cid_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_big", "cid_IntroTextBig");
	Clockwork.option:SetFont("menu_text_small", "cid_IntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "cid_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_small", "cid_IntroTextSmall");
	Clockwork.option:SetFont("player_info_text", "cid_PlayerInfoText");

	Clockwork.option:SetKey("gradient", "cidertwo/cidertwo_gradient_1");
end;

local DIRTY_TEXTURE = Material("cidertwo/cidertwo_gradient_1.png");
local SCRATCH_TEXTURE = Material("cidertwo/cidertwo_gradient_1.png");

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