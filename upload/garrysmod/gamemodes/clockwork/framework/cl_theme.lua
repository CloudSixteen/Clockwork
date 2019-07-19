--[[ 
    © CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
--]]

local THEME = Clockwork.theme:New("Clockwork");

-- Called when fonts should be created.
function THEME:CreateFonts()
	Clockwork.fonts:Add("cwMainText", 
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(7),
		weight		= 700
	});
	Clockwork.fonts:Add("cwESPText", 
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(5.5),
		weight		= 700
	});
	Clockwork.fonts:Add("cwTooltip", 
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(5),
		weight		= 700
	});
	Clockwork.fonts:Add("cwMenuTextBig",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(18),
		weight		= 700
	});
	Clockwork.fonts:Add("cwMenuTextTiny",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(7),
		weight		= 700
	});
	Clockwork.fonts:Add("cwInfoTextFont",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(6),
		weight		= 700
	});
	Clockwork.fonts:Add("cwMenuTextHuge",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(30),
		weight		= 700
	});
	Clockwork.fonts:Add("cwMenuTextSmall",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(10),
		weight		= 700
	});
	Clockwork.fonts:Add("cwIntroTextBig",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(18),
		weight		= 700
	});
	Clockwork.fonts:Add("cwIntroTextTiny",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(9),
		weight		= 700
	});
	Clockwork.fonts:Add("cwIntroTextSmall",
	{
		font		= "Arial",
		size		= Clockwork.kernel:FontScreenScale(7),
		weight		= 700
	});
	Clockwork.fonts:Add("cwLarge3D2D",
	{
		font		= "Arial",
		size		= Clockwork.kernel:GetFontSize3D(),
		weight		= 700
	});
	Clockwork.fonts:Add("cwScoreboardName",
	{
		font		= "Arial",
		size		= 20,
		weight		= 600
	});
	Clockwork.fonts:Add("cwScoreboardDesc",
	{
		font		= "Arial",
		size		= 16,
		weight		= 600
	});
	Clockwork.fonts:Add("cwScoreboardClass",
	{
		font		= "Arial",
		size		= 25,
		weight		= 700
	});
	Clockwork.fonts:Add("cwCinematicText",
	{
		font		= "Trebuchet",
		size		= Clockwork.kernel:FontScreenScale(8),
		weight		= 700
	});
	Clockwork.fonts:Add("cwChatSyntax",
	{
		font		= "Courier New",
		size		= Clockwork.kernel:FontScreenScale(7),
		weight		= 600
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	Clockwork.option:SetKey("icon_data_classes", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_settings", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_donations", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_system", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_scoreboard", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_inventory", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_directory", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_attributes", {path = "", size = nil});
	Clockwork.option:SetKey("icon_data_business", {path = "", size = nil});
	
	Clockwork.option:SetKey("top_bar_width_scale", 0.3);
	
	Clockwork.option:SetKey("info_text_icon_size", 20);
	Clockwork.option:SetKey("info_text_red_icon", "icon16/exclamation.png");
	Clockwork.option:SetKey("info_text_green_icon", "icon16/tick.png");
	Clockwork.option:SetKey("info_text_orange_icon", "icon16/error.png");
	Clockwork.option:SetKey("info_text_blue_icon", "icon16/information.png");

	Clockwork.option:SetKey("gradient", "gui/gradient_up");
	
	Clockwork.option:SetColor("columnsheet_shadow_normal", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("columnsheet_text_normal", Color(255, 255, 255, 255));
	Clockwork.option:SetColor("columnsheet_shadow_active", Color(255, 255, 255, 255));
	Clockwork.option:SetColor("columnsheet_text_active", Color(50, 50, 50, 255));
	
	Clockwork.option:SetColor("basic_form_highlight", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("basic_form_color", Color(0, 0, 0, 255));
	
	Clockwork.option:SetColor("scoreboard_name", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("scoreboard_desc", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("scoreboard_item_background", Color(255, 255, 255, 255));
	
	Clockwork.option:SetColor("positive_hint", Color(100, 175, 100, 255));
	Clockwork.option:SetColor("negative_hint", Color(175, 100, 100, 255));
	Clockwork.option:SetColor("background", Color(0, 0, 0, 125));
	Clockwork.option:SetColor("foreground", Color(50, 50, 50, 125));
	Clockwork.option:SetColor("target_id", Color(50, 75, 100, 255));
	Clockwork.option:SetColor("white", Color(255, 255, 255, 255));
	
	Clockwork.option:SetFont("schema_description", "cwMainText");
	Clockwork.option:SetFont("scoreboard_desc", "cwScoreboardDesc");
	Clockwork.option:SetFont("scoreboard_name", "cwScoreboardName");
	Clockwork.option:SetFont("scoreboard_class", "cwScoreboardClass");
	Clockwork.option:SetFont("player_info_text", "cwMainText");
	Clockwork.option:SetFont("intro_text_small", "cwIntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "cwIntroTextTiny");
	Clockwork.option:SetFont("menu_text_small", "cwMenuTextSmall");
	Clockwork.option:SetFont("chat_box_syntax", "cwChatSyntax");
	Clockwork.option:SetFont("menu_text_huge", "cwMenuTextHuge");
	Clockwork.option:SetFont("intro_text_big", "cwIntroTextBig");
	Clockwork.option:SetFont("info_text_font", "cwInfoTextFont");
	Clockwork.option:SetFont("menu_text_tiny", "cwMenuTextTiny");
	Clockwork.option:SetFont("date_time_text", "cwMenuTextSmall");
	Clockwork.option:SetFont("cinematic_text", "cwCinematicText");
	Clockwork.option:SetFont("target_id_text", "cwMainText");
	Clockwork.option:SetFont("auto_bar_text", "cwMainText");
	Clockwork.option:SetFont("menu_text_big", "cwMenuTextBig");
	Clockwork.option:SetFont("chat_box_text", "cwMainText");
	Clockwork.option:SetFont("large_3d_2d", "cwLarge3D2D");
	Clockwork.option:SetFont("hints_text", "cwIntroTextTiny");
	Clockwork.option:SetFont("main_text", "cwMainText");
	Clockwork.option:SetFont("bar_text", "cwMainText");
	Clockwork.option:SetFont("esp_text", "cwESPText");
	
	Clockwork.option:SetSound("click_release", "ui/buttonclickrelease.wav");
	Clockwork.option:SetSound("rollover", "ui/buttonrollover.wav");
	Clockwork.option:SetSound("click", "ui/buttonclick.wav");
	Clockwork.option:SetSound("tick", "common/talk.wav");
	
	SMALL_BAR_BG = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	SMALL_BAR_FG = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	INFOTEXT_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	MENU_ITEM_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	SLICED_SMALL_TINT = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	SLICED_INFO_MENU_INSIDE = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	PANEL_LIST_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	DERMA_SLICED_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	SLICED_LARGE_DEFAULT = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	SLICED_PROGRESS_BAR = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	SLICED_PLAYER_INFO = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	SLICED_INFO_MENU_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	CUSTOM_BUSINESS_ITEM_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
	SLICED_COLUMNSHEET_BUTTON = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
	
	Clockwork.bars.height = 12;
	Clockwork.bars.padding = 14;
end;

-- Called when the menu is closed.
function THEME.module:MenuClosed()
	if (Clockwork.Client:HasInitialized()) then
		Clockwork.kernel:RemoveBackgroundBlur("MainMenu");
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
