--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

local THEME = Clockwork.theme:Begin(true);

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("ExampleFont", {
		size = Clockwork.kernel:FontScreenScale(7),
		weight = 600, 
		antialias = true,
		font = "Arial"
	});
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	--[[
		Change theme options here. Look at clockwork/framework/cl_theme.lua
		to see what you can override.
	--]]
	
	Clockwork.option:SetColor("information", Color(241, 208, 94, 255));
	Clockwork.option:SetColor("background", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("target_id", Color(241, 208, 94, 255));
	Clockwork.option:SetFont("bar_text", "ExampleFont");
	Clockwork.option:SetFont("main_text", "ExampleFont");
	Clockwork.option:SetFont("hints_text", "ExampleFont");
end;

function THEME:GetBarIconFromClass(class)
	--[[
		It's possible to return an icon to use for a particular bar class.
		For example to have a health bar icon you might do:
		
		return Material("path/to/my/health/bar/icon");
	--]]
end;

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo) end;

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo) end;

-- Called when the menu is opened.
function THEME.module:MenuOpened() end;

-- Called when the menu is closed.
function THEME.module:MenuClosed() end;

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info) end;

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation) end;

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

Clockwork.theme:Finish(THEME);