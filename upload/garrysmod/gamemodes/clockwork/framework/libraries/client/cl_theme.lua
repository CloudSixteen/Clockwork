--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local isfunction = isfunction;
local istable = istable;
local debug = debug;
local table = table;
local pairs = pairs;
local derma = derma;
local vgui = vgui;
local type = type;

--[[
	@codebase Client
	@details Provides functions and methods for customizing Clockwork's GUI,
	along with the ability to create and switch between available GUI themes.
--]]
Clockwork.theme = Clockwork.kernel:NewLibrary("Theme");

local newTheme = nil;
local stored = {};

--[[ Use a debug hack to get the panel factory. --]]
local sTabName, tPanelFactory = debug.getupvalue(vgui.Create, 1);

if (sTabName == "PanelFactory" and type(tPanelFactory) == "table") then
	Clockwork.theme.factory = tPanelFactory;
	Clockwork.theme.backupFactory = Clockwork.theme.backupFactory or table.Copy(tPanelFactory);
else
	Clockwork.theme.factory = Clockwork.theme.factory or {};
	Clockwork.theme.backupFactory = Clockwork.theme.backupFactory or {};
end;

--[[
	Make new derma panels get saved to the backup factory so that panels 
	made after the backup is made can be freely changed and switched from.

	This method will also revert any changes made by overwriting vgui tables with 
	vgui.Register in a theme file when a theme is changed.
--]]
local oldRegister = vgui.Register;

function vgui.Register(className, panelTable, baseName)
	local backup = Clockwork.theme.backupFactory;

	if (backup[className] and newTheme) then
		backup = newTheme.factory;
	end;

	backup[className] = {};

	local base = backup[baseName];

	if (base) then
		table.Merge(base, panelTable);

		for k, v in pairs(base) do
			backup[className][k] = function(vguiObject, ...)
				v(vguiObject, ...);
			end;
		end;
	else
		for k, v in pairs(panelTable) do
			backup[className][k] = function(vguiObject, ...)
				v(vguiObject, ...);
			end;
		end;
	end;

	oldRegister(className, panelTable, baseName);
end;

--[[
	@codebase Client
	@details A function to replace a Derma panel's hook.
	@params String The name of the panel with the hook to replace.
	@params String The name of the hook that is being replaced.
	@params Function The function to replace the Derma panel's hook with.	
--]]
function Clockwork.theme:HookReplace(vguiName, functionName, callback)
	if (!self.factory[vguiName]) then
		return;
	end;

	if (newTheme) then
		local factory = newTheme.factory;
		
		factory[vguiName] = factory[vguiName] or {};
		factory[vguiName][functionName] = function(vguiObject, ...)
			callback(vguiObject, ...);
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to add a hook to be called before a Derma panel's hook is called.
	@params String The name of the panel with the hook to hook before.
	@params String The name of the hook to add a hook before.
	@params Function The function that will be called before the panel's hook is called.	
--]] 
function Clockwork.theme:HookBefore(vguiName, functionName, callback)
	if (not self.factory[vguiName]) then
		return;
	end;
	
	local oldFunction = self.factory[vguiName][functionName];
	
	if (oldFunction == nil) then
		return;
	end;

	if (newTheme) then
		local factory = newTheme.factory;
		
		factory[vguiName] = factory[vguiName] or {};
		factory[vguiName][functionName] = function(vguiObject, ...)
			callback(vguiObject, ...);
			oldFunction(vguiObject, ...);
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to add a hook to be called after a Derma panel's hook is called.
	@params String The name of the panel with the hook to hook after.
	@params String The name of the hook to add a hook after.
	@params Function The function that will be called after the panel's hook is called.
--]] 
function Clockwork.theme:HookAfter(vguiName, functionName, callback)
	if (not self.factory[vguiName]) then
		return;
	end;
	
	local oldFunction = self.factory[vguiName][functionName];
	
	if (oldFunction == nil) then
		return;
	end;
	
	if (newTheme) then
		local factory = newTheme.factory;

		factory[vguiName] = factory[vguiName] or {};
		factory[vguiName][functionName] = function(vguiObject, ...)
			oldFunction(vguiObject, ...);
			callback(vguiObject, ...);
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to return all of the stored themes that have been created.
	@returns {Table} The table containing all of the currently created themes.
--]] 
function Clockwork.theme:GetAll()
	return stored;
end;

--[[
	@codebase Client
	@details A function to find a specific theme by the name it was created with.
	@params String The name to search for.
	@returns {Table} The theme table if found, returns nil if it doesn't exist.
--]] 
function Clockwork.theme:FindByID(id)
	return stored[id];
end;

--[[
	@codebase Client
	@details A function to find if a specific theme exists by the name it was created with.
	@params String The name to search for.
	@returns {Bool} Whether or not the theme searched for exists.
--]] 
function Clockwork.theme:Exists(id)
	return (IsValid(stored[id]));
end;

--[[
	@codebase Client
	@details A deprecated function used to create a new theme.
	@params Bool Whether or not the theme will not allow players to change the information color in settings.
	@params String The name of the new theme to be created.
	@params String The name of the base theme to derive from.
	@returns {Table} The newly created theme table.
--]] 
function Clockwork.theme:Begin(isFixed, name, baseName)
	return self:New(name, baseName, isFixed);
end;

--[[
	@codebase Client
	@details A function used to create a new theme.
	@params String The name of the new theme to be created.
	@params String The name of the base theme to derive from.
	@params Bool Whether or not the theme will not allow players to change the information color in settings.
	@returns {Table} The newly created theme table.
--]]
function Clockwork.theme:New(themeName, baseName, isFixed)
	if (baseName) then
		local base = self:FindByID(baseName);

		if (base) then
			newTheme = table.Copy(base);
		end;

		newTheme.base = baseName;
	elseif (themeName != "Clockwork") then
		local base = self:FindByID("Clockwork");

		if (base) then
			newTheme = table.Copy(base);
		end;

		newTheme.base = "Clockwork";
	end;

	if (!newTheme) then
		newTheme = {
			factory = {},
			module = {},
			hooks = {},
			skin = {}
		};
	end;

	newTheme.name = themeName or "Schema";
	newTheme.isFixed = isFixed;

	return newTheme;
end;

--[[
	@codebase Client
	@details A function to get the currently active theme.
	@returns {Table} The active theme currently in use.
--]]
function Clockwork.theme:Get()
	return self.active;
end;

--[[
	@codebase Client
	@details A function to get whether the currently active theme allows clients to change the information color.
	@returns {Bool} Whether or not the active theme has a fixed information color or not. Returns false if players can change the color.
--]]
function Clockwork.theme:IsFixed()
	return (self.active and self.active.isFixed);
end;

--[[
	@codebase Client
	@details A function to copy the currently active theme's skin to the Clockwork derma skin.
--]]
function Clockwork.theme:CopySkin()
	local skinTable = derma.GetNamedSkin("Clockwork");
	
	if (self.active and skinTable) then
		for k, v in pairs(self.active.skin) do
			if (!skinTable["__"..k]) then
				skinTable["__"..k] = v;
			end;
			
			skinTable[k] = v;
		end;
	end;
	
	derma.RefreshSkins();
end;

--[[
	@codebase Client
	@details A function to initialize the theme library, called when Clockwork is initializing.
--]]
function Clockwork.theme:Initialize()
	local theme = self:Get();
	local defaultTheme = Clockwork.config:Get("default_theme"):Get();

	if (defaultTheme) then
		theme = defaultTheme;
	end;

	if (Clockwork.config:Get("modify_themes"):GetBoolean()) then
		local convarTheme = self:FindByID(GetConVar("cwActiveTheme"):GetString());
		
		if (convarTheme) then
			theme = convarTheme;
		end;
	end;

	if (!theme) then
		theme = "Clockwork";
	end;

	Clockwork.theme:SetActive(theme, true);
end;

--[[
	@codebase Client
	@details A function to save a new theme into the theme library, uses the Finish method.
	@params Bool Whether or not you want to switch to the newly created theme upon creation.
	@returns {String} The name of the new theme that was saved.
--]]
function Clockwork.theme:Register(switchTo)
	if (newTheme) then
		local name = newTheme.name;
		
		Clockwork.theme:Finish(newTheme, !switchTo);
	
		return name;
	end;
end;

--[[
	@codebase Client
	@details A deprecated function to save a new theme into the theme library.
	@params Table The theme table to be saved.
	@params Bool Whether or not you want to switch to the newly created theme upon creation.
--]]
function Clockwork.theme:Finish(themeTable, noSwitch)
	stored[themeTable.name] = themeTable;

	if (!noSwitch) then
		self:SetActive(themeTable);
	end;

	newTheme = nil;
end;

--[[
	@codebase Client
	@details A function to smoothly transition between themes, and call the hooks for loading and unloading them.
	@params String The name of the theme to be loaded, can also be the theme table itself.
	@params Bool Whether or not this is the first theme being loaded, used by Clockwork when initializing. Do NOT set to true.
--]]
function Clockwork.theme:SetActive(theme, firstLoad)
	if (istable(theme)) then
		if (self:Get() and !firstLoad) then
			self:UnloadTheme();
		end;

		self.active = theme;
		self:LoadTheme(theme);
	else
		local themeTable = self:FindByID(theme);

		if (themeTable) then
			self:SetActive(themeTable, firstLoad);
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to load a theme and initialize it. Do not call this, as it will not unload the previous theme.
	@params Table The theme table to load.
--]]
function Clockwork.theme:LoadTheme(themeTable, isBase)
	local baseName = themeTable.base;

	if (baseName) then
		local base = self:FindByID(baseName);

		if (base) then
			self:LoadTheme(base, true);
		end;
	end;

	if (themeTable.CreateFonts) then
		themeTable:CreateFonts();
	end;

	if (themeTable.Initialize) then
		themeTable:Initialize();
	end;

	if (themeTable.PostInitialize) then
		themeTable:PostInitialize();
	end;

	if (!isBase) then
		Clockwork.plugin:Add("Theme", themeTable.module);

		local factory = themeTable.factory;

		if (factory != {}) then
			table.Merge(self.factory, factory);
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to unload the current theme. Do not call this, as it will not load another theme.
--]]
function Clockwork.theme:UnloadTheme(theme, isBase)
	local themeTable = theme or self.active;
	local baseName = themeTable.base;

	if (baseName) then
		local base = self:FindByID(baseName);

		if (base) then
			self:UnloadTheme(base, true);
		end;
	end;

	if (themeTable.OnUnloaded) then
		themeTable:OnUnloaded();
	end;

	if (!isBase) then
		Clockwork.plugin:Remove("Theme");

		local factory = themeTable.factory;

		if (factory != {}) then
			for k, v in pairs(factory) do
				for k2, v2 in pairs(factory[k]) do
					if (isfunction(v2)) then
						self.factory[k][k2] = function(vguiObject, ...)
							self.backupFactory[k][k2](vguiObject, ...);
						end;
					else
						self.factory[k][k2] = self.backupFactory[k][k2];
					end;
				end;
			end;
		end;

		self.active = nil;
	end;
	
	local skinTable = derma.GetNamedSkin("Clockwork");
	
	if (skinTable) then
		for k, v in pairs(themeTable.skin) do
			if (skinTable["__"..k]) then
				skinTable[k] = skinTable["__"..k];
			end;
		end;
	end;
	
	derma.RefreshSkins();
end;

--[[
	@codebase Client
	@details A function call a hook from the currently active theme, along with any arguments.
	@params String The name of the hook to call.
	@params VarArg The arguments to call the hook with.
	@returns {Mixed} The results of the hook call.
--]]
function Clockwork.theme:Call(hookName, ...)
	if (self.active and self.active.hooks[hookName]) then
		return self.active.hooks[hookName](self.active.hooks, ...);
	end;
end;

local MARKUP_OBJECT = {__index = MARKUP_OBJECT, text = ""};

--[[
	@codebase Client
	@details A function to add new text to the markup object.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for color.
	@param {Unknown} Missing description for scale.
	@param {Unknown} Missing description for noNewLine.
	@returns {Unknown}
--]]
function MARKUP_OBJECT:Add(text, color, scale, noNewLine)
	if (self.text != "" and !noNewLine) then
		self.text = self.text.."\n";
	end;
	
	self.text = self.text..Clockwork.kernel:MarkupTextWithColor(Clockwork.config:Parse(text), color, scale);
end;

--[[
	@codebase Client
	@details A function to add a new title to the markup object.
	@param {Unknown} Missing description for title.
	@param {Unknown} Missing description for color.
	@param {Unknown} Missing description for scale.
	@returns {Unknown}
--]]
function MARKUP_OBJECT:Title(title, color, scale)
	self:Add(title, Clockwork.option:GetColor("information"), 1.2);
end;

--[[
	@codebase Client
	@details A function to get the markup object's text.
	@returns {Unknown}
--]]
function MARKUP_OBJECT:GetText()
	return self.text;
end;

--[[
	@codebase Client
	@details A function get a new markup object for rendering.
	@returns {MarkupObject} The new markup object.
--]]
function Clockwork.theme:GetMarkupObject()
	return Clockwork.kernel:NewMetaTable(MARKUP_OBJECT);
end;

--[[ 
	The following are available hooks for Clockwork.theme library:
	
	Hooks with a [/] after them mean that returning true
	overrides the default action.
	
	PreCharacterMenuInit(panel) [/]
	PostCharacterMenuInit(panel)
	
	PreCharacterMenuThink(panel) [/]
	PostCharacterMenuThink(panel)
	
	PreCharacterMenuPaint(panel) [/]
	PostCharacterMenuPaint(panel)
	
	PreCharacterMenuOpenPanel(panel, vguiName, childData, Callback) [/]
	PostCharacterMenuOpenPanel(panel)
	
	PreMainMenuInit(panel) [/]
	PostMainMenuInit(panel)
	
	PreMainMenuRebuild(panel) [/]
	PostMainMenuRebuild(panel)
	
	PreMainMenuOpenPanel(panel, panelToOpen) [/]
	PostMainMenuOpenPanel(panel, panelToOpen)
	
	PreMainMenuPaint(panel) [/]
	PostMainMenuPaint(panel)
	
	PreMainMenuThink(panel) [/]
	PostMainMenuThink(panel)
--]]
