--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local THEME = Clockwork.theme:New("Severance", nil, true);

local sliceMat = "severance/gradient/sevdirty";

-- Called when fonts should be created.
function THEME:CreateFonts()
	Clockwork.fonts:Add("sev_Large3D2D", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:GetFontSize3D(),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_IntroTextSmall", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(13),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_IntroTextTiny", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(10),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_CinematicText", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(16),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_IntroTextBig", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(25),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_TargetIDText", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(10),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_MainText", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(8),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_MainTextTiny", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(4),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_MenuTextHuge", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(50),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_MenuTextBig", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(30),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_PlayerInfoText", 
	{
		font		= "Bebas",
		size		= Clockwork.kernel:FontScreenScale(10),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_ScoreboardName", 
	{
		font		= "Bebas",
		size		= 23,
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_ScoreboardDesc", 
	{
		font		= "Bebas",
		size		= 16,
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
	Clockwork.fonts:Add("sev_ScoreboardClass", 
	{
		font		= "Bebas",
		size		= 27,
		weight		= 600,
		antialiase	= true,
		additive 	= false
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	local infoColor = Color(100, 150, 100, 255);
	local infoColorDarkish = Color(85, 135, 85, 255);
	local infoColorDark = Color(50, 100, 50, 255);
	local colorBlack = Color(0, 0, 0, 255);

	--[[ Font Keys --]]
	Clockwork.option:SetFont("bar_text", "sev_TargetIDText");
	Clockwork.option:SetFont("main_text", "sev_MainText");
	Clockwork.option:SetFont("hints_text", "sev_IntroTextTiny");
	Clockwork.option:SetFont("large_3d_2d", "sev_Large3D2D");
	Clockwork.option:SetFont("target_id_text", "sev_TargetIDText");
	Clockwork.option:SetFont("cinematic_text", "sev_CinematicText");
	Clockwork.option:SetFont("date_time_text", "sev_IntroTextSmall");
	Clockwork.option:SetFont("menu_text_big", "sev_MenuTextBig");
	Clockwork.option:SetFont("menu_text_huge", "sev_MenuTextHuge");
	Clockwork.option:SetFont("menu_text_tiny", "sev_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_big", "sev_IntroTextBig");
	Clockwork.option:SetFont("menu_text_small", "sev_IntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "sev_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_small", "sev_IntroTextSmall");
	Clockwork.option:SetFont("player_info_text", "sev_PlayerInfoText");
	Clockwork.option:SetFont("scoreboard_desc", "sev_ScoreboardDesc");
	Clockwork.option:SetFont("scoreboard_name", "sev_ScoreboardName");
	Clockwork.option:SetFont("scoreboard_class", "sev_ScoreboardClass");

	--[[ Color Keys --]]
	Clockwork.option:SetColor("information", infoColor);

	Clockwork.option:SetColor("basic_form_highlight", infoColor);
	Clockwork.option:SetColor("basic_form_color", infoColor);

	Clockwork.option:SetColor("columnsheet_shadow_normal", colorBlack);
	Clockwork.option:SetColor("columnsheet_text_normal", infoColor);
	Clockwork.option:SetColor("columnsheet_shadow_active", colorBlack);
	Clockwork.option:SetColor("columnsheet_text_active", infoColorDark);
	
	Clockwork.option:SetColor("scoreboard_name", infoColorDarkish);
	Clockwork.option:SetColor("scoreboard_desc", infoColor);
	Clockwork.option:SetColor("scoreboard_item_background", Color(infoColorDark.r, infoColorDark.g, infoColorDark.b, 100));

	--[[ Tab Menu Option Keys. --]]
	Clockwork.option:SetKey("icon_data_classes", {path = "severance/hud/menuitems/classes.png", size = nil});
	Clockwork.option:SetKey("icon_data_settings", {path = "severance/hud/menuitems/settings.png", size = 32});
	Clockwork.option:SetKey("icon_data_donations", {path = "severance/hud/menuitems/donations.png", size = nil});
	Clockwork.option:SetKey("icon_data_system", {path = "severance/hud/menuitems/system.png", size = 32});
	Clockwork.option:SetKey("icon_data_scoreboard", {path = "severance/hud/menuitems/scoreboard.png", size = 32});
	Clockwork.option:SetKey("icon_data_inventory", {path = "severance/hud/menuitems/inventory.png", size = 32});
	Clockwork.option:SetKey("icon_data_directory", {path = "severance/hud/menuitems/directory.png", size = 32});
	Clockwork.option:SetKey("icon_data_attributes", {path = "severance/hud/menuitems/attributes.png", size = 32});
	Clockwork.option:SetKey("icon_data_business", {path = "severance/hud/menuitems/business.png", size = 32});
	Clockwork.option:SetKey("info_text_icon_size", 32);

	--[[ Misc Keys --]]
	Clockwork.option:SetKey("intro_image", "severance/sevlogo");
	Clockwork.option:SetKey("schema_logo", "severance/sevlogo");
	Clockwork.option:SetKey("name_attributes", "Stats");
	Clockwork.option:SetKey("name_attribute", "Stat");
	Clockwork.option:SetKey("name_inventory", "Backpack");
	Clockwork.option:SetKey("description_attributes", "Check on your character's stats.");
	Clockwork.option:SetKey("description_inventory", "Manage the items in your backpack.");
	Clockwork.option:SetKey("description_business", "Distribute a variety of items.");
	Clockwork.option:SetKey("name_business", "Business");
	Clockwork.option:SetKey("menu_music", "sound/sevtheme");
	Clockwork.option:SetKey("gradient", "severance/bg_sevslicedgradient");

	--[[ Render Slices --]]
	SMALL_BAR_BG = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 6);
	SMALL_BAR_FG = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 6);
	INFOTEXT_SLICED = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 28);
	MENU_ITEM_SLICED = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 6);
	SLICED_SMALL_TINT = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 6);
	SLICED_INFO_MENU_INSIDE = Clockwork.render:AddSlice9("SimpleTint", "clockwork/sliced/simpletint", 6);
	PANEL_LIST_SLICED = Clockwork.render:AddSlice9("SimpleSev", sliceMat, 20);
	DERMA_SLICED_BG = Clockwork.render:AddSlice9("SimpleSev", sliceMat, 20);
	SLICED_LARGE_DEFAULT = Clockwork.render:AddSlice9("SimpleRed", "clockwork/sliced/simplered", 28);
	SLICED_PROGRESS_BAR = Clockwork.render:AddSlice9("SimpleRed", "clockwork/sliced/simplered", 28);
	SLICED_PLAYER_INFO = Clockwork.render:AddSlice9("SimpleRed", "clockwork/sliced/simplered", 28);
	SLICED_INFO_MENU_BG = Clockwork.render:AddSlice9("SimpleSev", sliceMat, 20);
	SLICED_COLUMNSHEET_BUTTON = Clockwork.render:AddSlice9("SimpleSev", sliceMat, 20);
end;

local DIRTY_TEXTURE = Material("severance/gradient/sevdirty.png");
local SCRATCH_TEXTURE = Material("severance/gradient/sevnormal.png");

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