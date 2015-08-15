--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[ Initiate the shared booting process. --]]
include("sh_boot.lua");

--[[ Micro-optimizations --]]
local Clockwork = Clockwork;
local Derma_StringRequest = Derma_StringRequest;
local UnPredictedCurTime = UnPredictedCurTime;
local RunConsoleCommand = RunConsoleCommand;
local DrawColorModify = DrawColorModify;
local DeriveGamemode = DeriveGamemode;
local DrawMotionBlur = DrawMotionBlur;
local CloseDermaMenus = CloseDermaMenus;
local FindMetaTable = FindMetaTable;
local CreateClientConVar = CreateClientConVar;
local ChangeTooltip = ChangeTooltip;
local ScreenScale = ScreenScale;
local DermaMenu = DermaMenu;
local ErrorNoHalt = ErrorNoHalt;
local CreateSound = CreateSound;
local FrameTime = FrameTime;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local IsValid = IsValid;
local SysTime = SysTime;
local Entity = Entity;
local unpack = unpack;
local pairs = pairs;
local Color = Color;
local print = print;
local ScrW = ScrW;
local ScrH = ScrH;
local concommand = concommand;
local surface = surface;
local render = render;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local draw = draw;
local vgui = vgui;
local cam = cam;
local gui = gui;

local cwChar = Clockwork.character;
local cwPlugin = Clockwork.plugin;
local cwBars = Clockwork.bars;
local cwKernel = Clockwork.kernel;
local cwConfig = Clockwork.config;
local cwEntity = Clockwork.entity;
local cwOption = Clockwork.option;
local cwPlayer = cwPlayer;
local cwTeam = cwTeam;

Clockwork.BackgroundBlurs = Clockwork.BackgroundBlurs or {};
Clockwork.RecognisedNames = Clockwork.RecognisedNames or {};
Clockwork.NetworkProxies = Clockwork.NetworkProxies or {};
Clockwork.AccessoryData = Clockwork.AccessoryData or {};
Clockwork.InfoMenuOpen = Clockwork.InfoMenuOpen or false;
Clockwork.ColorModify = Clockwork.ColorModify or {};
Clockwork.ClothesData = Clockwork.ClothesData or {};
Clockwork.Cinematics = Clockwork.Cinematics or {};
Clockwork.kernel.ESPInfo = Clockwork.kernel.ESPInfo or {};
Clockwork.kernel.Hints = Clockwork.kernel.Hints or {};

--[[
	Derive from Sandbox, because we want the spawn menu and such!
	We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode("sandbox");

--[[
	This is a hack to allow us to call plugin hooks based
	on default GMod hooks that are called.
--]]

hook.ClockworkCall = hook.ClockworkCall or hook.Call;
hook.Timings = hook.Timings or {};

function hook.Call(name, gamemode, ...)
	if (!IsValid(Clockwork.Client)) then
		Clockwork.Client = LocalPlayer();
	end;
	
	local startTime = SysTime();
		local bStatus, value = pcall(Clockwork.plugin.RunHooks, Clockwork.plugin, name, nil, ...);
	local timeTook = SysTime() - startTime;
	
	hook.Timings[name] = timeTook;
	
	if (!bStatus) then
		MsgC(Color(255, 100, 0, 255), "[Clockwork] The '"..name.."' hook failed to run.\n"..value.."\n"..value.."\n");
	end;
	
	if (value == nil) then
		local startTime = SysTime();
			local bStatus, a, b, c = pcall(hook.ClockworkCall, name, gamemode or Clockwork, ...);
		local timeTook = SysTime() - startTime;
		
		hook.Timings[name] = timeTook;
		
		if (!bStatus) then
			MsgC(Color(255, 100, 0, 255), "[Clockwork] The '"..name.."' hook failed to run.\n"..a.."\n");
		else
			return a, b, c;
		end;
	else
		return value;
	end;
end;

--[[
	This is a hack to display world tips correctly based on their owner.
--]]

local ClockworkAddWorldTip = AddWorldTip;

function AddWorldTip(entIndex, text, dieTime, position, entity)
	local weapon = Clockwork.Client:GetActiveWeapon();
	
	if (IsValid(weapon) and string.lower(weapon:GetClass()) == "gmod_tool") then
		if (IsValid(entity) and entity.GetPlayerName) then
			if (Clockwork.Client:Name() == entity:GetPlayerName()) then
				ClockworkAddWorldTip(entIndex, text, dieTime, position, entity);
			end;
		end;
	end;
end;

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy1");
timer.Destroy("HintSystem_Annoy2");

Clockwork.datastream:Hook("RunCommand", function(data)
	RunConsoleCommand(unpack(data));
end);

Clockwork.datastream:Hook("SharedTables", function(data)
	Clockwork.SharedTables = data;
end);

Clockwork.datastream:Hook("SetSharedTableVar", function(data)
	Clockwork.SharedTables[data.sharedTable] = Clockwork.SharedTables[data.sharedTable] or {};
	Clockwork.SharedTables[data.sharedTable][data.key] = data.value;
end);

Clockwork.datastream:Hook("HiddenCommands", function(data)
	for k, v in pairs(data) do
		for k2, v2 in pairs(Clockwork.command.stored) do
			if (Clockwork.kernel:GetShortCRC(k2) == v) then
				Clockwork.command:SetHidden(k2, true);
				
				break;
			end;
		end;
	end;
end);

Clockwork.datastream:Hook("OrderTime", function(data)
	Clockwork.OrderCooldown = data;
	
	local activePanel = Clockwork.menu:GetActivePanel();
	
	if (activePanel and activePanel:GetPanelName() == Clockwork.option:GetKey("name_business")) then
		activePanel:Rebuild();
	end;
end);

Clockwork.datastream:Hook("CharacterInit", function(data)
	Clockwork.plugin:Call("PlayerCharacterInitialized", data);
end);

Clockwork.datastream:Hook("Log", function(data)
	local logType = data.logType;
	local text = data.text;
	
	Clockwork.kernel:PrintColoredText(Clockwork.kernel:GetLogTypeColor(logType), text);
end);

Clockwork.datastream:Hook("StartSound", function(data)
	if (IsValid(Clockwork.Client)) then
		local uniqueID = data.uniqueID;
		local sound = data.sound;
		local volume = data.volume;
		
		if (!Clockwork.ClientSounds) then
			Clockwork.ClientSounds = {};
		end;
		
		if (Clockwork.ClientSounds[uniqueID]) then
			Clockwork.ClientSounds[uniqueID]:Stop();
		end;
		
		Clockwork.ClientSounds[uniqueID] = CreateSound(Clockwork.Client, sound);
		Clockwork.ClientSounds[uniqueID]:PlayEx(volume, 100);
	end;
end);

Clockwork.datastream:Hook("StopSound", function(data)
	local uniqueID = data.uniqueID;
	local fadeOut = data.fadeOut;
	
	if (!Clockwork.ClientSounds) then
		Clockwork.ClientSounds = {};
	end;
	
	if (Clockwork.ClientSounds[uniqueID]) then
		if (fadeOut != 0) then
			Clockwork.ClientSounds[uniqueID]:FadeOut(fadeOut);
		else
			Clockwork.ClientSounds[uniqueID]:Stop();
		end;
		
		Clockwork.ClientSounds[uniqueID] = nil;
	end;
end);

Clockwork.datastream:Hook("InfoToggle", function(data)
	if (IsValid(Clockwork.Client) and Clockwork.Client:HasInitialized()) then
		if (!Clockwork.InfoMenuOpen) then
			Clockwork.InfoMenuOpen = true;
			Clockwork.kernel:RegisterBackgroundBlur("InfoMenu", SysTime());
		else
			Clockwork.kernel:RemoveBackgroundBlur("InfoMenu");
			Clockwork.kernel:CloseActiveDermaMenus();
			Clockwork.InfoMenuOpen = false;
		end;
	end;
end);

Clockwork.datastream:Hook("PlaySound", function(data)
	surface.PlaySound(data);
end);

Clockwork.datastream:Hook("DataStreaming", function(data)
	Clockwork.datastream:Start("DataStreamInfoSent", true);
end);

Clockwork.datastream:Hook("DataStreamed", function(data)
	Clockwork.DataHasStreamed = true;
end);

Clockwork.datastream:Hook("QuizCompleted", function(data)
	if (!data) then
		if (!Clockwork.quiz:GetCompleted()) then
			gui.EnableScreenClicker(true);
			
			Clockwork.quiz.panel = vgui.Create("cwQuiz");
			Clockwork.quiz.panel:Populate();
			Clockwork.quiz.panel:MakePopup();
		end;
	else
		local characterPanel = Clockwork.character:GetPanel();
		local quizPanel = Clockwork.quiz:GetPanel();
		
		Clockwork.quiz:SetCompleted(true);
		
		if (quizPanel) then
			quizPanel:Remove();
		end;
	end;
end);

Clockwork.datastream:Hook("RecogniseMenu", function(data)
	local menuPanel = Clockwork.kernel:AddMenuFromData(nil, {
		["All characters within whispering range."] = function()
			Clockwork.datastream:Start("RecogniseOption", "whisper");
		end,
		["All characters within yelling range."] = function()
			Clockwork.datastream:Start("RecogniseOption", "yell");
		end,
		["All characters within talking range"] = function()
			Clockwork.datastream:Start("RecogniseOption", "talk");
		end
	});
	
	if (IsValid(menuPanel)) then
		menuPanel:SetPos(
			(ScrW() / 2) - (menuPanel:GetWide() / 2), (ScrH() / 2) - (menuPanel:GetTall() / 2)
		);
	end;
	
	Clockwork.kernel:SetRecogniseMenu(menuPanel);
end);

Clockwork.datastream:Hook("ClockworkIntro", function(data)
	if (!Clockwork.ClockworkIntroFadeOut) then
		local introImage = Clockwork.option:GetKey("intro_image");
		local introSound = Clockwork.option:GetKey("intro_sound");
		local duration = 8;
		local curTime = UnPredictedCurTime();
		
		if (introImage != "") then
			duration = 16;
		end;
		
		Clockwork.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8);
		Clockwork.ClockworkIntroFadeOut = curTime + duration;
		Clockwork.ClockworkIntroSound = CreateSound(Clockwork.Client, introSound);
		Clockwork.ClockworkIntroSound:PlayEx(0.75, 100);
		
		timer.Simple(duration - 4, function()
			Clockwork.ClockworkIntroSound:FadeOut(4);
			Clockwork.ClockworkIntroSound = nil;
		end);
		
		surface.PlaySound("buttons/button1.wav");
	end;
end);

Clockwork.datastream:Hook("SharedVar", function(data)
	local key = data.key;
	local sharedVars = Clockwork.kernel:GetSharedVars():Player();
	
	if (sharedVars and sharedVars[key]) then
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData) then
			sharedVarData.value = data.value;
		end;
	end;
end);

Clockwork.datastream:Hook("HideCommand", function(data)
	local index = data.index;
	
	for k, v in pairs(Clockwork.command.stored) do
		if (Clockwork.kernel:GetShortCRC(k) == index) then
			Clockwork.command:SetHidden(k, data.hidden);
			
			break;
		end;
	end;
end);

Clockwork.datastream:Hook("CfgListVars", function(data)
	Clockwork.Client:PrintMessage(2, "######## [Clockwork] Config ########\n");
		local sSearchData = data;
		local tConfigRes = {};
		
		if (sSearchData) then
			sSearchData = string.lower(sSearchData);
		end;
		
		for k, v in pairs(Clockwork.config:GetStored()) do
			if (type(v.value) != "table" and (!sSearchData
			or string.find(string.lower(k), sSearchData)) and !v.isStatic) then
				if (v.isPrivate) then
					tConfigRes[#tConfigRes + 1] = {
						k, string.rep("*", string.utf8len(tostring(v.value)))
					};
				else
					tConfigRes[#tConfigRes + 1] = {
						k, tostring(v.value)
					};
				end;
			end;
		end;
		
		table.sort(tConfigRes, function(a, b)
			return a[1] < b[1];
		end);
		
		for k, v in pairs(tConfigRes) do
			local systemValues = Clockwork.config:GetFromSystem(v[1]);
			
			if (systemValues) then
				Clockwork.Client:PrintMessage(2, "// "..systemValues.help.."\n");
			end;
			
			Clockwork.Client:PrintMessage(2, v[1].." = \""..v[2].."\";\n");
		end;
	Clockwork.Client:PrintMessage(2, "######## [Clockwork] Config ########\n");
end);

Clockwork.datastream:Hook("ClearRecognisedNames", function(data)
	Clockwork.RecognisedNames = {};
end);

Clockwork.datastream:Hook("RecognisedName", function(data)
	local key = data.key;
	local status = data.status;
	
	if (status > 0) then
		Clockwork.RecognisedNames[key] = status;
	else
		Clockwork.RecognisedNames[key] = nil;
	end;
end);

Clockwork.datastream:Hook("Hint", function(data)
	if (data and type(data) == "table") then
		Clockwork.kernel:AddTopHint(
			Clockwork.kernel:ParseData(data.text), data.delay, data.color, data.noSound, data.showDuplicates
		);
	end;
end);

Clockwork.datastream:Hook("WeaponItemData", function(data)
	local weapon = Entity(data.weapon);

	if (IsValid(weapon)) then
		weapon.cwItemTable = Clockwork.item:CreateInstance(
			data.definition.index, data.definition.itemID, data.definition.data
		);
	end;
end);

Clockwork.datastream:Hook("CinematicText", function(data)
	if (data and type(data) == "table") then
		Clockwork.kernel:AddCinematicText(data.text, data.color, data.barLength, data.hangTime);
	end;
end);

Clockwork.datastream:Hook("AddAccessory", function(data)
	Clockwork.AccessoryData[data.itemID] = data.uniqueID;
end);

Clockwork.datastream:Hook("RemoveAccessory", function(data)
	Clockwork.AccessoryData[data.itemID] = nil;
end);

Clockwork.datastream:Hook("AllAccessories", function(data)
	Clockwork.AccessoryData = {};
	
	for k, v in pairs(data) do
		Clockwork.AccessoryData[k] = v;
	end;
end);

Clockwork.datastream:Hook("Notification", function(data)
	local text = data.text;
	local class = data.class;
	local sound = "ambient/water/drip2.wav";
	
	if (class == 1) then
		sound = "buttons/button10.wav";
	elseif (class == 2) then
		sound = "buttons/button17.wav";
	elseif (class == 3) then
		sound = "buttons/bell1.wav";
	elseif (class == 4) then
		sound = "buttons/button15.wav";
	end
	
	local info = {
		class = class,
		sound = sound,
		text = text
	};
	
	if (Clockwork.plugin:Call("NotificationAdjustInfo", info)) then
		Clockwork.kernel:AddNotify(info.text, info.class, 10);
			surface.PlaySound(info.sound);
		print(info.text);
	end;
end);

--[[
	@codebase Client
	@details Called to display a HUD notification when a weapon has been picked up. (Used to override GMOD function)
--]]
function Clockwork:HUDWeaponPickedUp(...) end;

--[[
	@codebase Client
	@details Called to display a HUD notification when an item has been picked up. (Used to override GMOD function)
--]]
function Clockwork:HUDItemPickedUp(...) end;

--[[
	@codebase Client
	@details Called to display a HUD notification when ammo has been picked up. (Used to override GMOD function)
--]]
function Clockwork:HUDAmmoPickedUp(...) end;

--[[
	@codebase Client
	@details Called when the context menu is opened.
--]]
function Clockwork:OnContextMenuOpen()
	if (cwKernel:IsUsingTool()) then
		return self.BaseClass:OnContextMenuOpen(self);
	else
		gui.EnableScreenClicker(true);
	end;
end;

--[[
	@codebase Client
	@details Called when the context menu is close.
--]]
function Clockwork:OnContextMenuClose()
	if (cwKernel:IsUsingTool()) then
		return self.BaseClass:OnContextMenuClose(self);
	else
		gui.EnableScreenClicker(false);
	end;
end;

--[[
	@codebase Client
	@details Called to determine if a player can use property.
	@param Player The player that is trying to use property.
	@param
	@param Entity The entity that is being used.
	@returns Bool Whether or not the player can use property.
--]]
function Clockwork:CanProperty(player, property, entity)
	if (!IsValid(entity)) then
		return false;
	end;
	
	local bIsAdmin = self.player:IsAdmin(player);
	
	if (!player:Alive() or player:IsRagdolled() or !bIsAdmin) then
		return false;
	end;
	
	return self.BaseClass:CanProperty(player, property, entity);
end;

--[[
	@codebase Client
	@details Called to determine if a player can drive.
	@param Player The player trying to drive.
	@param Entity The entity that the player is trying to drive.
	@return Bool Whether or not the player can drive the entity.
--]]
function Clockwork:CanDrive(player, entity)
	if (!IsValid(entity)) then
		return false;
	end;
	
	local bIsAdmin = self.player:IsAdmin(player);
	
	if (!player:Alive() or player:IsRagdolled() or !bIsAdmin) then
		return false;
	end;

	return self.BaseClass:CanDrive(player, entity);
end;

--[[
	@codebase Client
	@details Called when the directory is rebuilt.
	@param <DPanel> The directory panel.
--]]
function Clockwork:ClockworkDirectoryRebuilt(panel)
	for k, v in pairs(self.command.stored) do
		if (!self.player:HasFlags(self.Client, v.access)) then
			self.command:RemoveHelp(v);
		else
			self.command:AddHelp(v);
		end;
	end;
end;

--[[
	@codebase Client
	@details Called when the derma skin needs to be forced.
	@return String The name of the skin to be forced (nil if not forcing skin).
--]]
function Clockwork:ForceDermaSkin()
	--[[
		Disable the custom Derma skin as it needs updating to GWEN.
		return "Clockwork";
	--]]
	
	return nil;
end;

--[[
	@codebase Client
	@details Called when the local player is given an item.
	@param Table The table of the item that was given.
--]]
function Clockwork:PlayerItemGiven(itemTable)
	if (self.storage:IsStorageOpen()) then
		self.storage:GetPanel():Rebuild();
	end;
end;

--[[
	@codebase Client
	@details Called when the local player has an item taken from them.
	@param Table The table of the item that was taken.
--]]
function Clockwork:PlayerItemTaken(itemTable)
	if (self.storage:IsStorageOpen()) then
		self.storage:GetPanel():Rebuild();
	end;
end;

-- Called when the local player's character has initialized.
function Clockwork:PlayerCharacterInitialized(iCharacterKey) end;

--[[
	@codebase Client
	@details Called before the local player's storage is rebuilt.
	@param <DPanel> The player's storage panel.
--]]
function Clockwork:PlayerPreRebuildStorage(panel) end;

--[[
	@codebase Client
	@details Called when the local player's storage is rebuilt.
	@param <DPanel> The player's storage panel.
	@param Table The categories for the player's storage.
--]]
function Clockwork:PlayerStorageRebuilt(panel, categories) end;

--[[
	@codebase Client
	@details Called when the local player's business is rebuilt.
	@param <DPanel> The player's business panel.
	@param Table The categories for the player's business.
--]]
function Clockwork:PlayerBusinessRebuilt(panel, categories) end;

--[[
	@codebase Client
	@details Called when the local player's storage is rebuilt.
	@param <DPanel> The player's storage panel.
	@param Table The categories for the player's inventory.
--]]
function Clockwork:PlayerInventoryRebuilt(panel, categories) end;

--[[
	@codebase Client
	@details Called when an entity attempts to fire bullets.
	@param Entity The entity trying to fire bullets.
	@param Table The info of the bullets being fired.
--]]
function Clockwork:EntityFireBullets(entity, bulletInfo) end;

--[[
	@codebase Client
	@details Called when a player's bulletInfo needs to be adjusted.
	@param Player The player that is firing bullets.
	@param Table The info of the bullets that need to be adjusted.
--]]
function Clockwork:PlayerAdjustBulletInfo(player, bulletInfo) end;

--[[
	@codebase Client
	@details Called when clockwork's config is initialized.
	@param String The name of the config key.
	@param String The value relating to the key in the table.
--]]
function Clockwork:ClockworkConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs(self.item:GetAll()) do
			v.cost = 0;
		end;
	end;
end;

--[[
	@codebase Client
	@details Called when one of the client's console variables have been changed.
	@param String The name of the convar that was changed.
	@param String The previous value of the convar.
	@param String The new value of the convar.
--]]
function Clockwork:ClockworkConVarChanged(name, previousValue, newValue)
	local checkTable = {
		["cwTextColorR"] = true,
		["cwTextColorG"] = true,
		["cwTextColorB"] = true,
		["cwTextColorA"] = true
	}

	if (checkTable[name]) then
		Clockwork.option:SetColor(
			"information",
			Color(
				GetConVarNumber("cwTextColorR"), 
				GetConVarNumber("cwTextColorG"), 
				GetConVarNumber("cwTextColorB"), 
				GetConVarNumber("cwTextColorA")
			)
		);
	elseif (name == "cwLang") then
		Clockwork.Client:SetData("Language", newValue);
	end;
end;

--[[
	@codebase Client
	@details Called when one of the configs have been changed.
	@param String The config key that was changed.
	@param String The data provided.
	@param String The previous value of the key.
	@param String The new value of the key.
--]]
function Clockwork:ClockworkConfigChanged(key, data, previousValue, newValue) end;

--[[
	@codebase Client
	@details Called when an entity's menu options are needed.
	@param Entity The entity that is being checked for menu options.
	@param Table The table of options for the entity.
--]]
function Clockwork:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass();
	local generator = self.generator:FindByID(class);
	
	if (class == "cw_item") then
		local itemTable = nil;
		
		if (entity.GetItemTable) then
			itemTable = entity:GetItemTable();
		else
			debug.Trace();
		end;
		
		if (itemTable) then
			local useText = itemTable("useText", "Use");
			
			if (itemTable.OnUse) then
				options[useText] = "cwItemUse";
			end;
			
			if (itemTable.GetEntityMenuOptions) then
				itemTable:GetEntityMenuOptions(entity, options);
			end;
						
			options["Take"] = "cwItemTake";
			options["Examine"] = "cwItemExamine";
		end;
	elseif (class == "cw_belongings") then
		options["Open"] = "cwBelongingsOpen";
	elseif (class == "cw_shipment") then
		options["Open"] = "cwShipmentOpen";
	elseif (class == "cw_cash") then
		options["Take"] = "cwCashTake";
	elseif (generator) then
		if (!entity.CanSupply or entity:CanSupply()) then
			options["Supply"] = "cwGeneratorSupply";
		end;
	end;
end;

--[[
	@codebase Client
	@details Called when the GUI mouse has been released.
--]]
function Clockwork:GUIMouseReleased(code)
	if (!cwConfig:Get("use_opens_entity_menus"):Get()
	and vgui.CursorVisible()) then
		local trace = self.Client:GetEyeTrace();
		
		if (IsValid(trace.Entity) and trace.HitPos:Distance(self.Client:GetShootPos()) <= 80) then
			self.EntityMenu = cwKernel:HandleEntityMenu(trace.Entity);
			
			if (IsValid(self.EntityMenu)) then
				self.EntityMenu:SetPos(gui.MouseX() - (self.EntityMenu:GetWide() / 2), gui.MouseY() - (self.EntityMenu:GetTall() / 2));
			end;
		end;
	end;
end;

--[[
	@codebase Client
	@details Called when a key has been released.
	@param Player The player releasing a key.
	@param Key The key that is being released.
--]]
function Clockwork:KeyRelease(player, key)
	if (cwConfig:Get("use_opens_entity_menus"):Get()) then
		if (key == IN_USE) then
			local activeWeapon = player:GetActiveWeapon();
			local trace = self.Client:GetEyeTraceNoCursor();
			
			if (IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_physgun") then
				if (player:KeyDown(IN_ATTACK)) then
					return;
				end;
			end;
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance(self.Client:GetShootPos()) <= 80) then
				self.EntityMenu = cwKernel:HandleEntityMenu(trace.Entity);
				
				if (IsValid(self.EntityMenu)) then
					self.EntityMenu:SetPos(
						(ScrW() / 2) - (self.EntityMenu:GetWide() / 2), (ScrH() / 2) - (self.EntityMenu:GetTall() / 2)
					);
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Client
	@details Called when the local player has been created.
--]]
function Clockwork:LocalPlayerCreated()
	Clockwork.kernel:RegisterNetworkProxy(Clockwork.Client, "Clothes", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			if (newValue != "") then
				local clothesData = string.Explode(" ", newValue);
				Clockwork.ClothesData.uniqueID = clothesData[1];
				Clockwork.ClothesData.itemID = tonumber(clothesData[2]);
			else
				Clockwork.ClothesData.uniqueID = nil;
				Clockwork.ClothesData.itemID = nil;
			end;
			
			Clockwork.inventory:Rebuild();
		end;
	end);
end;

--[[
	@codebase Client
	@details Called when the client initializes.
--]]
function Clockwork:Initialize()
	CW_CONVAR_TWELVEHOURCLOCK = cwKernel:CreateClientConVar("cwTwelveHourClock", 0, true, true);
	CW_CONVAR_SHOWTIMESTAMPS = cwKernel:CreateClientConVar("cwShowTimeStamps", 0, true, true);
	CW_CONVAR_MAXCHATLINES = cwKernel:CreateClientConVar("cwMaxChatLines", 10, true, true);
	CW_CONVAR_HEADBOBSCALE = cwKernel:CreateClientConVar("cwHeadbobScale", 1, true, true);
	CW_CONVAR_SHOWSERVER = cwKernel:CreateClientConVar("cwShowServer", 1, true, true);
	CW_CONVAR_SHOWAURA = cwKernel:CreateClientConVar("cwShowClockwork", 1, true, true);
	CW_CONVAR_SHOWHINTS = cwKernel:CreateClientConVar("cwShowHints", 1, true, true);
	CW_CONVAR_SHOWLOG = cwKernel:CreateClientConVar("cwShowLog", 1, true, true);
	CW_CONVAR_SHOWOOC = cwKernel:CreateClientConVar("cwShowOOC", 1, true, true);
	CW_CONVAR_SHOWIC = cwKernel:CreateClientConVar("cwShowIC", 1, true, true);
	CW_CONVAR_LANG = cwKernel:CreateClientConVar("cwLang", "English", true, true);

	CW_CONVAR_ESPTIME = cwKernel:CreateClientConVar("cwESPTime", 1, true, true);
	CW_CONVAR_ADMINESP = cwKernel:CreateClientConVar("cwAdminESP", 0, true, true);
	CW_CONVAR_ESPBARS = cwKernel:CreateClientConVar("cwESPBars", 1, true, true);
	CW_CONVAR_ITEMESP = cwKernel:CreateClientConVar("cwItemESP", 0, false, true);
	CW_CONVAR_PROPESP = cwKernel:CreateClientConVar("cwPropESP", 0, false, true);
	CW_CONVAR_SPAWNESP = cwKernel:CreateClientConVar("cwSpawnESP", 0, false, true);
	CW_CONVAR_SALEESP = cwKernel:CreateClientConVar("cwSaleESP", 0, false, true);
	CW_CONVAR_NPCESP = cwKernel:CreateClientConVar("cwNPCESP", 0, false, true);
	
	CW_CONVAR_TEXTCOLORR = cwKernel:CreateClientConVar("cwTextColorR", 255, true, true);
	CW_CONVAR_TEXTCOLORG = cwKernel:CreateClientConVar("cwTextColorG", 200, true, true);
	CW_CONVAR_TEXTCOLORB = cwKernel:CreateClientConVar("cwTextColorB", 0, true, true);
	CW_CONVAR_TEXTCOLORA = cwKernel:CreateClientConVar("cwTextColorA", 255, true, true);
	CW_CONVAR_BACKCOLORR = cwKernel:CreateClientConVar("cwBackColorR", 40, true, true);
	CW_CONVAR_BACKCOLORG = cwKernel:CreateClientConVar("cwBackColorG", 40, true, true);
	CW_CONVAR_BACKCOLORB = cwKernel:CreateClientConVar("cwBackColorB", 40, true, true);
	CW_CONVAR_BACKCOLORA = cwKernel:CreateClientConVar("cwBackColorA", 255, true, true);
	CW_CONVAR_TABX = cwKernel:CreateClientConVar("cwTabPosX", 56, true, true);
	CW_CONVAR_TABY = cwKernel:CreateClientConVar("cwTabPosY", 112, true, true);
	CW_CONVAR_FADEPANEL = cwKernel:CreateClientConVar("cwFadePanels", 1, true, true);
	CW_CONVAR_CHARSTRING = cwKernel:CreateClientConVar("cwCharString", "CHARACTERS", true, true);
	CW_CONVAR_CLOSESTRING = cwKernel:CreateClientConVar("cwCloseString", "CLOSE MENU", true, true);
	CW_CONVAR_MATERIAL = cwKernel:CreateClientConVar("cwMaterial", "hunter/myplastic", true, true);
	CW_CONVAR_BACKX = cwKernel:CreateClientConVar("cwBackX", 61, true, true);
	CW_CONVAR_BACKY = cwKernel:CreateClientConVar("cwBackY", 109, true, true);
	CW_CONVAR_BACKW = cwKernel:CreateClientConVar("cwBackW", 321, true, true);
	CW_CONVAR_BACKH = cwKernel:CreateClientConVar("cwBackH", 109, true, true);
	CW_CONVAR_SHOWMATERIAL = cwKernel:CreateClientConVar("cwShowMaterial", 0, true, true);
	CW_CONVAR_SHOWGRADIENT = cwKernel:CreateClientConVar("cwShowGradient", 1, true, true);
	
	if (!self.chatBox.panel) then
		self.chatBox:CreateDermaAll();
	end;
	
	self.item:Initialize();
	
	if (!cwOption:GetKey("top_bars")) then
		CW_CONVAR_TOPBARS = cwKernel:CreateClientConVar("cwTopBars", 0, true, true);
	else
		self.setting:RemoveByConVar("cwTopBars");
	end;
	
	cwPlugin:Call("ClockworkKernelLoaded");
	cwPlugin:Call("ClockworkInitialized");
	
	self.theme:CreateFonts();
		-- self.theme:CopySkin();
	self.theme:Initialize();
	
	cwPlugin:CheckMismatches();
	cwPlugin:ClearHookCache();

	Clockwork.Client:SetData("Language", CW_CONVAR_LANG:GetString());

	Clockwork.option:SetColor(
		"information",
		Color(
			GetConVarNumber("cwTextColorR"), 
			GetConVarNumber("cwTextColorG"), 
			GetConVarNumber("cwTextColorB"), 
			GetConVarNumber("cwTextColorA")
		)
	);

	hook.Remove("PostDrawEffects", "RenderWidgets")
end;

--[[
	@codebase Client
	@details Called when Clockwork has initialized.
--]]
function Clockwork:ClockworkInitialized()
	local logoFile = "clockwork/logo/002.png";

	self.SpawnIconMaterial = Clockwork.kernel:GetMaterial("vgui/spawnmenu/hover");
	self.DefaultGradient = surface.GetTextureID("gui/gradient_down");
	self.GradientTexture = Clockwork.kernel:GetMaterial(cwOption:GetKey("gradient")..".png");
	self.ClockworkSplash = Clockwork.kernel:GetMaterial(logoFile);
	self.FishEyeTexture = Clockwork.kernel:GetMaterial("models/props_c17/fisheyelens");
	self.GradientCenter = surface.GetTextureID("gui/center_gradient");
	self.GradientRight = surface.GetTextureID("gui/gradient");
	self.GradientUp = surface.GetTextureID("gui/gradient_up");
	self.ScreenBlur = Clockwork.kernel:GetMaterial("pp/blurscreen");
	self.Gradients = {
		[GRADIENT_CENTER] = self.GradientCenter;
		[GRADIENT_RIGHT] = self.GradientRight;
		[GRADIENT_DOWN] = self.DefaultGradient;
		[GRADIENT_UP] = self.GradientUp;
	};
end;

--[[
	@codebase Client
	@details Called when the tool menu needs to be populated.
--]]
function Clockwork:PopulateToolMenu()
	local toolGun = weapons.GetStored("gmod_tool");

	for k, v in pairs(self.tool:GetAll()) do
		toolGun.Tool[v.Mode] = v;

		if (v.AddToMenu != false) then		
			spawnmenu.AddToolMenuOption( v.Tab or "Main",
				v.Category or "New Category", 
				k, 
				v.Name or "#"..k, 
				v.Command or "gmod_tool "..k, 
				v.ConfigName or k,
				v.BuildCPanel 
			);			
		end;

		language.Add("tool."..v.UniqueID..".name", v.Name);
		language.Add("tool."..v.UniqueID..".desc", v.Desc);
		language.Add("tool."..v.UniqueID..".0", v.HelpText);
	end;
end;

--[[
	@codebase Client
	@details Called when an Clockwork item has initialized.
	@param Table The table of the item being initialized.
--]]
function Clockwork:ClockworkItemInitialized(itemTable) end;

--[[
	@codebase Client
	@details Called when a player's phys desc override is needed.
	@param Player The player whose phys desc override is needed.
	@param String The player's physDesc.
--]]
function Clockwork:GetPlayerPhysDescOverride(player, physDesc) end;

--[[
	@codebase Client
	@details Called when a player's door access name is needed.
--]]
function Clockwork:GetPlayerDoorAccessName(player, door, owner)
	return player:Name();
end;

--[[
	@codebase Client
	@details Called when a player should show on the door access list.
--]]
function Clockwork:PlayerShouldShowOnDoorAccessList(player, door, owner)
	return true;
end;

--[[
	@codebase Client
	@details Called when a player should show on the scoreboard.
--]]
function Clockwork:PlayerShouldShowOnScoreboard(player)
	return true;
end;

--[[
	@codebase Client
	@details Called when the local player attempts to zoom.
--]]
function Clockwork:PlayerCanZoom() return true; end;

-- Called when the local player attempts to see a business item.
function Clockwork:PlayerCanSeeBusinessItem(itemTable) return true; end;

-- Called when a player's footstep sound should be played.
function Clockwork:PlayerFootstep(player, position, foot, sound, volume, recipientFilter) end;

-- Called when a player presses a bind.
function Clockwork:PlayerBindPress(player, bind, bPress)
	if (player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, "+jump")) then
		Clockwork.kernel:RunCommand("CharGetUp");
	elseif (string.find(bind, "toggle_zoom")) then
		return true;
	elseif (string.find(bind, "+zoom")) then
		if (!cwPlugin:Call("PlayerCanZoom")) then
			return true;
		end;
	end;
	
	if (string.find(bind, "+attack") or string.find(bind, "+attack2")) then
		if (self.storage:IsStorageOpen()) then
			return true;
		end;
	end;
	
	if (cwConfig:Get("block_inv_binds"):Get()) then
		if (string.find(string.lower(bind), cwConfig:Get("command_prefix"):Get().."invaction")
		or string.find(string.lower(bind), "cwcmd invaction")) then
			return true;
		end;
	end;
	
	return cwPlugin:Call("TopLevelPlayerBindPress", player, bind, bPress);
end;

-- Called when a player presses a bind at the top level.
function Clockwork:TopLevelPlayerBindPress(player, bind, bPress)
	return self.BaseClass:PlayerBindPress(player, bind, bPress);
end;

-- Called when the local player attempts to see while unconscious.
function Clockwork:PlayerCanSeeUnconscious()
	return false;
end;

-- Called when the local player's move data is created.
function Clockwork:CreateMove(userCmd)
	local ragdollEyeAngles = cwKernel:GetRagdollEyeAngles();
	
	if (ragdollEyeAngles and IsValid(self.Client)) then
		local defaultSensitivity = 0.05;
		local sensitivity = defaultSensitivity * (cwPlugin:Call("AdjustMouseSensitivity", defaultSensitivity) or defaultSensitivity);
		
		if (sensitivity <= 0) then
			sensitivity = defaultSensitivity;
		end;
		
		if (self.Client:IsRagdolled()) then
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -48, 48);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -48, 48);
		else
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -90, 90);
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -90, 90);
		end;
	end
end;

local LAST_RAISED_TARGET = 0;

-- Called when the view should be calculated.
function Clockwork:CalcView(player, origin, angles, fov)
	local scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(),0,1) or 1;

	if (self.Client:IsRagdolled()) then
		local ragdollEntity = self.Client:GetRagdollEntity();
		local ragdollState = self.Client:GetRagdollState();
		
		if (self.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
		else
			local eyes = ragdollEntity:GetAttachment(ragdollEntity:LookupAttachment("eyes"));
			
			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + cwKernel:GetRagdollEyeAngles();
				local physicsObject = ragdollEntity:GetPhysicsObject();
				
				if (IsValid(physicsObject)) then
					local velocity = physicsObject:GetVelocity().z;
					
					if (velocity <= -1000 and self.Client:GetMoveType() == MOVETYPE_WALK) then
						ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16);
					end;
				end;
				
				return {origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov};
			else
				return self.BaseClass:CalcView(player, origin, angles, fov);
			end;
		end;
	elseif (!self.Client:Alive()) then
		return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
	elseif (cwConfig:Get("enable_headbob"):Get() and scale > 0) then
		if (player:IsOnGround()) then
			local frameTime = FrameTime();
			
			if (!self.player:IsNoClipping(player)) then
				local approachTime = frameTime * 2;
				local curTime = UnPredictedCurTime();
				local info = {speed = 1, yaw = 0.5, roll = 0.1};
				
				if (!self.HeadbobAngle) then
					self.HeadbobAngle = 0;
				end;
				
				if (!self.HeadbobInfo) then
					self.HeadbobInfo = info;
				end;
				
				cwPlugin:Call("PlayerAdjustHeadbobInfo", info);
				
				self.HeadbobInfo.yaw = math.Approach(self.HeadbobInfo.yaw, info.yaw, approachTime);
				self.HeadbobInfo.roll = math.Approach(self.HeadbobInfo.roll, info.roll, approachTime);
				self.HeadbobInfo.speed = math.Approach(self.HeadbobInfo.speed, info.speed, approachTime);
				self.HeadbobAngle = self.HeadbobAngle + (self.HeadbobInfo.speed * frameTime);
				
				local yawAngle = math.sin(self.HeadbobAngle);
				local rollAngle = math.cos(self.HeadbobAngle);
				
				angles.y = angles.y + (yawAngle * self.HeadbobInfo.yaw);
				angles.r = angles.r + (rollAngle * self.HeadbobInfo.roll);

				local velocity = player:GetVelocity();
				local eyeAngles = player:EyeAngles();
				
				if (!self.VelSmooth) then self.VelSmooth = 0; end;
				if (!self.WalkTimer) then self.WalkTimer = 0; end;
				if (!self.LastStrafeRoll) then self.LastStrafeRoll = 0; end;
				
				self.VelSmooth = math.Clamp(self.VelSmooth * 0.9 + velocity:Length() * 0.1, 0, 700)
				self.WalkTimer = self.WalkTimer + self.VelSmooth * FrameTime() * 0.05
				
				self.LastStrafeRoll = (self.LastStrafeRoll * 3) + (eyeAngles:Right():DotProduct(velocity) * 0.0001 * self.VelSmooth * 0.3);
				self.LastStrafeRoll = self.LastStrafeRoll * 0.25;
				angles.r = angles.r + self.LastStrafeRoll;
				
				if (player:GetGroundEntity() != NULL) then
					angles.p = angles.p + math.cos(self.WalkTimer * 0.5) * self.VelSmooth * 0.000002 * self.VelSmooth;
					angles.r = angles.r + math.sin(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth;
					angles.y = angles.y + math.cos(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth;
				end;
				
				velocity = self.Client:GetVelocity().z;
				
				if (velocity <= -1000 and self.Client:GetMoveType() == MOVETYPE_WALK) then
					angles.p = angles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16);
				end;
			end;
		end;
	end;
	
	local view = self.BaseClass:CalcView(player, origin, angles, fov);
	
	cwPlugin:Call("CalcViewAdjustTable", view);
	
	return view;
end;

local WEAPON_LOWERED_ANGLES = Angle(30, -30, -25)

function Clockwork:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
	if (!IsValid(weapon)) then return; end;

	local client = self.Client;
	local weaponRaised = self.player:GetWeaponRaised(client);
	
	if (!self.Client:HasInitialized() or !cwConfig:HasInitialized()
	or self.Client:GetMoveType() == MOVETYPE_OBSERVER) then
		weaponRaised = nil;
	end;
	
	local targetValue = 100;
	
	if (weaponRaised) then
		targetValue = 0;
	end;

	local fraction = (client.cwRaisedFraction or 100) / 100;
	local itemTable = self.item:GetByWeapon(weapon);
	local originMod = Vector(-3.0451, -1.6419, -0.5771);
	local anglesMod = weapon.LoweredAngles or WEAPON_LOWERED_ANGLES;
	
	if (itemTable and itemTable("loweredAngles")) then
		anglesMod = itemTable("loweredAngles");
	elseif (weapon.LoweredAngles) then
		anglesMod = weapon.LoweredAngles;
	end;
	
	local viewInfo = {
		origin = originMod,
		angles = anglesMod
	};
	
	cwPlugin:Call("GetWeaponLoweredViewInfo", itemTable, weapon, viewInfo);
	
	--[[
	if (itemTable and itemTable("loweredOrigin")) then
		originMod = itemTable("loweredOrigin");
	elseif (weapon.LoweredOrigin) then
		originMod = weapon.LoweredOrigin;
	end;
	--]]
	
	eyeAngles:RotateAroundAxis(eyeAngles:Up(), viewInfo.angles.p * fraction);
	eyeAngles:RotateAroundAxis(eyeAngles:Forward(), viewInfo.angles.y * fraction);
	eyeAngles:RotateAroundAxis(eyeAngles:Right(), viewInfo.angles.r * fraction);

	client.cwRaisedFraction = Lerp(FrameTime() * 2, client.cwRaisedFraction or 100, targetValue)
	--viewModel:SetAngles(eyeAngles)

	return oldEyePos, eyeAngles;
end;

-- Called when the local player's limb damage is received.
function Clockwork:PlayerLimbDamageReceived() end;

-- Called when the local player's limb damage is reset.
function Clockwork:PlayerLimbDamageReset() end;

-- Called when the local player's limb damage is bIsHealed.
function Clockwork:PlayerLimbDamageHealed(hitGroup, amount) end;

-- Called when the local player's limb takes damage.
function Clockwork:PlayerLimbTakeDamage(hitGroup, damage) end;

-- Called when a weapon's lowered view info is needed.
function Clockwork:GetWeaponLoweredViewInfo(itemTable, weapon, viewInfo) end;

-- Called when a HUD element should be drawn.
function Clockwork:HUDShouldDraw(name)
	local blockedElements = {
		"CHudSecondaryAmmo",
		"CHudVoiceStatus",
		"CHudSuitPower",
		"CHudBattery",
		"CHudHealth",
		"CHudAmmo",
		"CHudChat"
	};
	
	if (!IsValid(self.Client) or !self.Client:HasInitialized() or cwKernel:IsChoosingCharacter()) then
		if (name != "CHudGMod") then
			return false;
		end;
	elseif (name == "CHudCrosshair") then
		return false;
	elseif (table.HasValue(blockedElements, name)) then
		return false;
	end;
	
	return self.BaseClass:HUDShouldDraw(name);
end

-- Called when the menu is opened.
function Clockwork:MenuOpened()
	for k, v in pairs(self.menu:GetItems()) do
		if (v.panel.OnMenuOpened) then
			v.panel:OnMenuOpened();
		end;
	end;
end;

-- Called when the menu is closed.
function Clockwork:MenuClosed()
	for k, v in pairs(self.menu:GetItems()) do
		if (v.panel.OnMenuClosed) then
			v.panel:OnMenuClosed();
		end;
	end;
	
	cwKernel:RemoveActiveToolTip();
	cwKernel:CloseActiveDermaMenus();
end;

-- Called when the character screen's faction characters should be sorted.
function Clockwork:CharacterScreenSortFactionCharacters(faction, a, b)
	return a.name < b.name;
end;

-- Called when the scoreboard's class players should be sorted.
function Clockwork:ScoreboardSortClassPlayers(class, a, b)
	local recogniseA = self.player:DoesRecognise(a);
	local recogniseB = self.player:DoesRecognise(b);
	
	if (recogniseA and recogniseB) then
		return a:Team() < b:Team();
	elseif (recogniseA) then
		return true;
	else
		return false;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function Clockwork:ScoreboardAdjustPlayerInfo(info) end;

-- Called when the menu's items should be adjusted.
function Clockwork:MenuItemsAdd(menuItems)
	local attributesName = cwOption:GetKey("name_attributes");
	local systemName = cwOption:GetKey("name_system");
	local scoreboardName = cwOption:GetKey("name_scoreboard");
	local directoryName = cwOption:GetKey("name_directory");
	local inventoryName = cwOption:GetKey("name_inventory");
	
	menuItems:Add("Classes", "cwClasses", "Choose from a list of available classes.");
	menuItems:Add("Settings", "cwSettings", "Configure the way Clockwork works for you.");
	menuItems:Add("Donations", "cwDonations", "Check your donation subscriptions.");
	menuItems:Add(systemName, "cwSystem", cwOption:GetKey("description_system"));
	menuItems:Add(scoreboardName, "cwScoreboard", cwOption:GetKey("name_scoreboard"));
	menuItems:Add(inventoryName, "cwInventory", cwOption:GetKey("description_inventory"));
	menuItems:Add(directoryName, "cwDirectory", cwOption:GetKey("description_directory"));
	menuItems:Add(attributesName, "cwAttributes", cwOption:GetKey("description_attributes"));
	
	if (cwConfig:Get("show_business"):GetBoolean() == true) then
		local businessName = cwOption:GetKey("name_business");
		menuItems:Add(businessName, "cwBusiness", cwOption:GetKey("description_business"));
	end;
end;

-- Called when the menu's items should be destroyed.
function Clockwork:MenuItemsDestroy(menuItems) end;

-- Called each tick.
function Clockwork:Tick()
	local realCurTime = CurTime();
	local curTime = UnPredictedCurTime();
	local cwPlyInfoText = self.PlayerInfoText;
	local cwAttriBoost = self.attributes.boosts;
	local cwClient = self.Client;
	local mathMin = math.min;
	local mathMax = math.max;
	local font = cwOption:GetFont("player_info_text");
	
	if (cwChar:IsPanelPolling()) then
		local panel = cwChar:GetPanel();
		
		if (!panel and cwPlugin:Call("ShouldCharacterMenuBeCreated")) then
			cwChar:SetPanelPolling(false);
			cwChar.isOpen = true;
			cwChar.panel = vgui.Create("cwCharacterMenu");
			cwChar.panel:MakePopup();
			cwChar.panel:ReturnToMainMenu();

			cwPlugin:Call("PlayerCharacterScreenCreated", cwChar.panel);
		end;
	end;
	
	if (IsValid(cwClient) and !cwKernel:IsChoosingCharacter()) then
		cwBars.stored = {};
		cwPlyInfoText.text = {};
		cwPlyInfoText.width = ScrW() * 0.15;
		cwPlyInfoText.subText = {};
		
		cwKernel:DrawHealthBar();
		cwKernel:DrawArmorBar();
		
		cwPlugin:Call("GetBars", cwBars);
		cwPlugin:Call("DestroyBars", cwBars);
		cwPlugin:Call("GetPlayerInfoText", cwPlyInfoText);
		cwPlugin:Call("DestroyPlayerInfoText", cwPlyInfoText);
		
		table.sort(cwBars.stored, function(a, b)
			if (a.text == "" and b.text == "") then
				return a.priority > b.priority;
			elseif (a.text == "") then
				return true;
			else
				return a.priority > b.priority;
			end;
		end);
		
		table.sort(cwPlyInfoText.subText, function(a, b)
			return a.priority > b.priority;
		end);
		
		for k, v in pairs(cwPlyInfoText.text) do
			cwPlyInfoText.width = cwKernel:AdjustMaximumWidth(font, v.text, cwPlyInfoText.width);
		end;
		
		for k, v in pairs(cwPlyInfoText.subText) do
			cwPlyInfoText.width = cwKernel:AdjustMaximumWidth(font, v.text, cwPlyInfoText.width);
		end;
		
		cwPlyInfoText.width = cwPlyInfoText.width + 16;
		
		if (cwConfig:Get("fade_dead_npcs"):Get()) then
			for k, v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
				if (!cwEntity:IsDecaying(v)) then
					cwEntity:Decay(v, 300);
				end;
			end;
		end;
		
		local playedHeartbeatSound = false;
		
		if (cwClient:Alive() and cwConfig:Get("enable_heartbeat"):Get()) then
			local maxHealth = cwClient:GetMaxHealth();
			local health = cwClient:Health();
			
			if (health < maxHealth) then
				if (!self.HeartbeatSound) then
					self.HeartbeatSound = CreateSound(cwClient, "player/heartbeat1.wav");
				end;
				
				if (!self.NextHeartbeat or curTime >= self.NextHeartbeat) then
					self.NextHeartbeat = curTime + (0.75 + ((1.25 / maxHealth) * health));
					self.HeartbeatSound:PlayEx(0.75 - ((0.7 / maxHealth) * health), 100);
				end;
				
				playedHeartbeatSound = true;
			end;
		end;
		
		if (!playedHeartbeatSound and self.HeartbeatSound) then
			self.HeartbeatSound:Stop();
		end;
	end;
	
	if (!self.NextHandleAttributeBoosts or realCurTime >= self.NextHandleAttributeBoosts) then
		self.NextHandleAttributeBoosts = realCurTime + 3;
		
		for k, v in pairs(cwAttriBoost) do
			for k2, v2 in pairs(v) do
				if (v2.duration and v2.endTime) then
					if (realCurTime > v2.endTime) then
						cwAttriBoost[k][k2] = nil;
					else
						local timeLeft = v2.endTime - realCurTime;
						
						if (timeLeft >= 0) then
							if (v2.default < 0) then
								v2.amount = mathMin((v2.default / v2.duration) * timeLeft, 0);
							else
								v2.amount = mathMax((v2.default / v2.duration) * timeLeft, 0);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	if (cwKernel:IsInfoMenuOpen() and !input.IsKeyDown(KEY_F1)) then
		cwKernel:RemoveBackgroundBlur("InfoMenu");
		cwKernel:CloseActiveDermaMenus();
		Clockwork.InfoMenuOpen = false;
		
		if (IsValid(Clockwork.InfoMenuPanel)) then
			Clockwork.InfoMenuPanel:Remove();
		end;
		
		timer.Simple(FrameTime() * 0.5, function()
			cwKernel:RemoveActiveToolTip();
		end);
	end;
	
	local menuMusic = cwOption:GetKey("menu_music");
	
	if (menuMusic != "") then
		if (IsValid(cwClient) and cwChar:IsPanelOpen()) then
			if (!self.MusicSound) then
				self.MusicSound = CreateSound(cwClient, menuMusic);
				self.MusicSound:PlayEx(0.3, 100);
				self.MusicFading = false;
			end;
		elseif (self.MusicSound and !self.MusicFading) then
			self.MusicSound:FadeOut(8);
			self.MusicFading = true;
			
			timer.Simple(8, function()
				self.MusicSound = nil;
			end);
		end;
	end;
	
	local worldEntity = game.GetWorld();
	
	for k, v in pairs(self.NetworkProxies) do
		if (IsValid(k) or k == worldEntity) then
			for k2, v2 in pairs(v) do
				local value = nil;
				
				if (k == worldEntity) then
					value = cwKernel:GetSharedVar(k2);
				else
					value = k:GetSharedVar(k2);
				end;
				
				if (value != v2.oldValue) then
					v2.Callback(k, k2, v2.oldValue, value);
					v2.oldValue = value;
				end;
			end;
		else
			self.NetworkProxies[k] = nil;
		end;
	end;
end;

-- Called when an entity is created.
--[[function Clockwork:OnEntityCreated(entity)
	if (entity == LocalPlayer() and IsValid(entity)) then
		self.Client = entity;
	end;
end;]]

function Clockwork:InitPostEntity()
	self.Client = LocalPlayer();
end;

-- Called each frame.
function Clockwork:Think()
	if (!self.CreatedLocalPlayer) then
		if (IsValid(self.Client)) then
			cwPlugin:Call("LocalPlayerCreated");
				self.datastream:Start("LocalPlayerCreated", true);
			self.CreatedLocalPlayer = true;
		end;
	end;
	
	cwKernel:CallTimerThink(CurTime());
	cwKernel:CalculateHints();
	
	if (cwKernel:IsCharacterScreenOpen()) then
		local panel = cwChar:GetPanel();
		
		if (panel) then
			panel:SetVisible(cwPlugin:Call("GetPlayerCharacterScreenVisible", panel));
			
			if (panel:IsVisible()) then
				self.HasCharacterMenuBeenVisible = true;
			end;
		end;
	end;
end;

-- Called when the character loading HUD should be painted.
function Clockwork:HUDPaintCharacterLoading(alpha) end;

-- Called when the character selection HUD should be painted.
function Clockwork:HUDPaintCharacterSelection() end;

-- Called when the important HUD should be painted.
function Clockwork:HUDPaintImportant() end;

-- Called when the top screen HUD should be painted.
function Clockwork:HUDPaintTopScreen(info) end;

local SCREEN_DAMAGE_OVERLAY = Clockwork.kernel:GetMaterial("clockwork/screendamage.png");
local VIGNETTE_OVERLAY = Clockwork.kernel:GetMaterial("clockwork/vignette.png");

-- Called when the local player's screen damage should be drawn.
function Clockwork:DrawPlayerScreenDamage(damageFraction)
	local scrW, scrH = ScrW(), ScrH();
	surface.SetDrawColor(255, 255, 255, math.Clamp(255 * damageFraction, 0, 255));
	surface.SetMaterial(SCREEN_DAMAGE_OVERLAY);
	surface.DrawTexturedRect(0, 0, scrW, scrH);
end;

--[[
	Called when the entity outlines should be added.
	The "outlines" parameter is a reference to Clockwork.outline.
--]]
function Clockwork:AddEntityOutlines(outlines)
	if (IsValid(self.EntityMenu) and IsValid(self.EntityMenu.entity)) then
		--[[ Maybe this isn't needed. --]]
		self.EntityMenu.entity:DrawModel();
		
		outlines:Add(
			self.EntityMenu.entity, Color(255, 255, 255, 255)
		);
	end;
end;

-- Called when the local player's vignette should be drawn.
function Clockwork:DrawPlayerVignette()
	local curTime = CurTime();
	
	if (!self.cwVignetteAlpha) then
		self.cwVignetteAlpha = 100;
		self.cwVignetteDelta = self.cwVignetteAlpha;
		self.cwVignetteRayTime = 0;
	end;
	
	if (curTime >= self.cwVignetteRayTime) then
		local data = {};
			data.start = self.Client:GetShootPos();
			data.endpos = data.start + (self.Client:GetUp() * 512);
			data.filter = self.Client;
		local trace = util.TraceLine(data);

		if (!trace.HitWorld and !trace.HitNonWorld) then
			self.cwVignetteAlpha = 100;
		else
			self.cwVignetteAlpha = 255;
		end;
		
		self.cwVignetteRayTime = curTime + 1;
	end;

	self.cwVignetteDelta = math.Approach(
		self.cwVignetteDelta, self.cwVignetteAlpha, FrameTime() * 70
	);

	local scrW, scrH = ScrW(), ScrH();
	surface.SetDrawColor(0, 0, 0, self.cwVignetteDelta);
	surface.SetMaterial(VIGNETTE_OVERLAY);
	surface.DrawTexturedRect(0, 0, scrW, scrH);
end;

-- Called when the foreground HUD should be painted.
function Clockwork:HUDPaintForeground()
	local backgroundColor = cwOption:GetColor("background");
	local colorWhite = cwOption:GetColor("white");
	local info = cwPlugin:Call("GetProgressBarInfo");
	
	if (info) then
		local height = 32;
		local width = (ScrW() * 0.5);
		local x = ScrW() * 0.25;
		local y = ScrH() * 0.3;
		
		SLICED_PROGRESS_BAR:Draw(x - 16, y - 16, width + 32, height + 32, 8);
		
		cwKernel:DrawBar(
			x, y, width, height, info.color or Clockwork.option:GetColor("information"),
			info.text or "Progress Bar", info.percentage or 100, 100, info.flash
		);
	else
		info = cwPlugin:Call("GetPostProgressBarInfo");
		
		if (info) then
			local height = 32;
			local width = (ScrW() / 2) - 64;
			local x = ScrW() * 0.25;
			local y = ScrH() * 0.3;
			
			SLICED_PROGRESS_BAR:Draw(x - 16, y - 16, width + 32, height + 32, 8);
			
			cwKernel:DrawBar(
				x, y, width, height, info.color or Clockwork.option:GetColor("information"),
				info.text or "Progress Bar", info.percentage or 100, 100, info.flash
			);
		end;
	end;
	
	if (self.player:IsAdmin(self.Client)) then
		if (cwPlugin:Call("PlayerCanSeeAdminESP")) then
			cwKernel:DrawAdminESP();
		end;
	end;
	
	local screenTextInfo = cwPlugin:Call("GetScreenTextInfo");
	
	if (screenTextInfo) then
		local alpha = screenTextInfo.alpha or 255;
		local y = (ScrH() / 2) - 128;
		local x = ScrW() / 2;
		
		if (screenTextInfo.title) then
			cwKernel:OverrideMainFont(cwOption:GetFont("menu_text_small"));
				y = cwKernel:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha);
			cwKernel:OverrideMainFont(false);
		end;
		
		if (screenTextInfo.text) then
			cwKernel:OverrideMainFont(cwOption:GetFont("menu_text_tiny"));
				y = cwKernel:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha);
			cwKernel:OverrideMainFont(false);
		end;
	end;
	
	self.chatBox:Paint();
	
	local info = {width = ScrW() * 0.3, x = 8, y = 8};
		cwKernel:DrawBars(info, "top");
	cwPlugin:Call("HUDPaintTopScreen", info);
end;

-- Called each frame that an item entity exists.
function Clockwork:ItemEntityThink(itemTable, entity) end;

-- Called when an item entity is drawn.
function Clockwork:ItemEntityDraw(itemTable, entity) end;

-- Called when a cash entity is drawn.
function Clockwork:CashEntityDraw(entity) end;

-- Called when a gear entity is drawn.
function Clockwork:GearEntityDraw(entity) end;

-- Called when a generator entity is drawn.
function Clockwork:GeneratorEntityDraw(entity) end;

-- Called when a shipment entity is drawn.
function Clockwork:ShipmentEntityDraw(entity) end;

-- Called when an item's network data has been updated.
function Clockwork:ItemNetworkDataUpdated(itemTable, newData)
	if (itemTable.OnNetworkDataUpdated) then
		itemTable:OnNetworkDataUpdated(newData);
	end;
end;

--[[
	@codebase Client
	@details Called when the Clockwork kernel has loaded.
--]]
function Clockwork:ClockworkKernelLoaded() end;

-- Called to get the screen text info.
function Clockwork:GetScreenTextInfo()
	local blackFadeAlpha = cwKernel:GetBlackFadeAlpha();
	
	if (self.Client:GetSharedVar("CharBanned")) then
		return {
			alpha = blackFadeAlpha,
			title = "THIS CHARACTER IS BANNED",
			text = "Go to the characters menu to make a new one."
		};
	end;
end;


-- Called after the VGUI has been rendered.
function Clockwork:PostRenderVGUI()
	local cinematic = self.Cinematics[1];
	
	if (cinematic) then
		cwKernel:DrawCinematic(cinematic, CurTime());
	end;

	local activeMarkupToolTip = Clockwork.kernel:GetActiveMarkupToolTip();

	if (activeMarkupToolTip and IsValid(activeMarkupToolTip) and activeMarkupToolTip:IsVisible()) then
		local markupToolTip = activeMarkupToolTip:GetMarkupToolTip();
		local alpha = activeMarkupToolTip:GetAlpha();
		local x, y = gui.MouseX(), gui.MouseY() + 24;
		
		if (markupToolTip) then
			cwKernel:DrawMarkupToolTip(markupToolTip.object, x, y, alpha);
		end;
	end;
end;

-- Called to get whether the local player can see the admin ESP.
function Clockwork:PlayerCanSeeAdminESP()
	if (CW_CONVAR_ADMINESP:GetInt() == 1) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to get up.
function Clockwork:PlayerCanGetUp() return true; end;

-- Called when the local player attempts to see the top bars.
function Clockwork:PlayerCanSeeBars(class)
	if (class == "tab") then
		if (CW_CONVAR_TOPBARS) then
			return (CW_CONVAR_TOPBARS:GetInt() == 0 and cwKernel:IsInfoMenuOpen());
		else
			return cwKernel:IsInfoMenuOpen();
		end;
	elseif (class == "top") then
		if (CW_CONVAR_TOPBARS) then
			return CW_CONVAR_TOPBARS:GetInt() == 1;
		else
			return true;
		end;
	else
		return true;
	end;
end;

-- Called when the local player's limb info is needed.
function Clockwork:GetPlayerLimbInfo(info) end;

-- Called when the local player attempts to see the top hints.
function Clockwork:PlayerCanSeeHints()
	return true;
end;

-- Called when the local player attempts to see their limb damage.
function Clockwork:PlayerCanSeeLimbDamage()
	if (cwKernel:IsInfoMenuOpen() and cwConfig:Get("limb_damage_system"):Get()) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to see the date and time.
function Clockwork:PlayerCanSeeDateTime()
	return cwKernel:IsInfoMenuOpen();
end;

-- Called when the local player attempts to see a class.
function Clockwork:PlayerCanSeeClass(class)
	return true;
end;

-- Called when the local player attempts to see the player info.
function Clockwork:PlayerCanSeePlayerInfo()
	return cwKernel:IsInfoMenuOpen();
end;

--
function Clockwork:AddHint(name, delay)
	if (IsValid(self.Client) and self.Client:HasInitialized()) then
		cwKernel:AddTopHint(
			cwKernel:ParseData("#Hint_"..name), delay
		);
	end;
end;

--
function Clockwork:AddNotify(text, class, length)
	return cwKernel:AddNotify(text, class, length);
end;

-- Called when the target ID HUD should be drawn.
function Clockwork:HUDDrawTargetID()
	local targetIDTextFont = cwOption:GetFont("target_id_text");
	local traceEntity = NULL;
	local colorWhite = cwOption:GetColor("white");
	
	cwKernel:OverrideMainFont(targetIDTextFont);
	
	if (IsValid(self.Client) and self.Client:Alive() and !IsValid(self.EntityMenu)) then
		if (!self.Client:IsRagdolled(RAGDOLL_FALLENOVER)) then
			local fadeDistance = 196;
			local curTime = UnPredictedCurTime();
			local trace = self.player:GetRealTrace(self.Client);
			
			if (IsValid(trace.Entity) and !trace.Entity:IsEffectActive(EF_NODRAW)) then
				if (!self.TargetIDData or self.TargetIDData.entity != trace.Entity) then
					self.TargetIDData = {
						showTime = curTime + 0.5,
						entity = trace.Entity
					};
				end;
				
				if (self.TargetIDData) then
					self.TargetIDData.trace = trace;
				end;
				
				if (!IsValid(traceEntity)) then
					traceEntity = trace.Entity;
				end;
				
				if (curTime >= self.TargetIDData.showTime) then
					if (!self.TargetIDData.fadeTime) then
						self.TargetIDData.fadeTime = curTime + 1;
					end;
					
					local class = trace.Entity:GetClass();
					local entity = cwEntity:GetPlayer(trace.Entity);
					
					if (entity) then
						fadeDistance = cwPlugin:Call("GetTargetPlayerFadeDistance", entity);
					end;
					
					local alpha = math.Clamp(cwKernel:CalculateAlphaFromDistance(fadeDistance, self.Client, trace.HitPos) * 1.5, 0, 255);
					
					if (alpha > 0) then
						alpha = math.min(alpha, math.Clamp(1 - ((self.TargetIDData.fadeTime - curTime) / 3), 0, 1) * 255);
					end;
					
					self.TargetIDData.fadeDistance = fadeDistance;
					self.TargetIDData.player = entity;
					self.TargetIDData.alpha = alpha;
					self.TargetIDData.class = class;
					
					if (entity and self.Client != entity) then
						if (cwPlugin:Call("ShouldDrawPlayerTargetID", entity)) then
							if (!self.player:IsNoClipping(entity)) then
								if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
									if (self.nextCheckRecognises and self.nextCheckRecognises[2] != entity) then
										self.Client:SetSharedVar("TargetKnows", true);
									end;
									
									local flashAlpha = nil;
									local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen();
									local x, y = toScreen.x, toScreen.y;
									
									if (!self.player:DoesTargetRecognise()) then
										flashAlpha = math.Clamp(math.sin(curTime * 2) * alpha, 0, 255);
									end;
									
									if (self.player:DoesRecognise(entity, RECOGNISE_PARTIAL)) then
										local text = string.Explode("\n", cwPlugin:Call("GetTargetPlayerName", entity));
										local newY;
										
										for k, v in pairs(text) do
											newY = cwKernel:DrawInfo(v, x, y, cwTeam.GetColor(entity:Team()), alpha);
											
											if (flashAlpha) then
												cwKernel:DrawInfo(v, x, y, colorWhite, flashAlpha);
											end;
											
											if (newY) then
												y = newY;
											end;
										end;
									else
										local unrecognisedName, usedPhysDesc = self.player:GetUnrecognisedName(entity);
										local wrappedTable = {unrecognisedName};
										local teamColor = cwTeam.GetColor(entity:Team());
										local result = cwPlugin:Call("PlayerCanShowUnrecognised", entity, x, y, unrecognisedName, teamColor, alpha, flashAlpha);
										local newY;
										
										if (type(result) == "string") then
											wrappedTable = {};
											cwKernel:WrapText(result, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										elseif (usedPhysDesc) then
											wrappedTable = {};
											cwKernel:WrapText(unrecognisedName, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										end;
										
										if (result == true or type(result) == "string") then
											for k, v in pairs(wrappedTable) do
												newY = cwKernel:DrawInfo(v, x, y, teamColor, alpha);
													
												if (flashAlpha) then
													cwKernel:DrawInfo(v, x, y, colorWhite, flashAlpha);
												end;
												
												if (newY) then
													y = newY;
												end;
											end;
										elseif (tonumber(result)) then
											y = result;
										end;
									end;
									
									self.TargetPlayerText.stored = {};
									
									cwPlugin:Call("GetTargetPlayerText", entity, self.TargetPlayerText);
									cwPlugin:Call("DestroyTargetPlayerText", entity, self.TargetPlayerText);
									
									y = cwPlugin:Call("DrawTargetPlayerStatus", entity, alpha, x, y) or y;
									
									for k, v in pairs(self.TargetPlayerText.stored) do
										y = cwKernel:DrawInfo(v.text, x, y, v.color or colorWhite, alpha);
									end;
									
									if (!self.nextCheckRecognises or curTime >= self.nextCheckRecognises[1]
									or self.nextCheckRecognises[2] != entity) then
										self.datastream:Start("GetTargetRecognises", entity);
										
										self.nextCheckRecognises = {curTime + 2, entity};
									end;
								end;
							end;
						end;
					elseif (self.generator:FindByID(class)) then
						if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local generator = self.generator:FindByID(class);
							local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen();
							local power = trace.Entity:GetPower();
							local name = generator.name;
							local x, y = toScreen.x, toScreen.y;
							
							y = cwKernel:DrawInfo(name, x, y, Color(150, 150, 100, 255), alpha);
							y = cwKernel:DrawBar(
								x - 80, y, 160, 16, Clockwork.option:GetColor("information"), generator.powerPlural,
								power, generator.power, power < (generator.power / 5)
							);
						end;
					elseif (trace.Entity:IsWeapon()) then
						if (self.Client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local active = nil;
							for k, v in pairs(cwPlayer.GetAll()) do
								if (v:GetActiveWeapon() == trace.Entity) then
									active = true;
								end;
							end;
							
							if (!active) then
								local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen();
								local x, y = toScreen.x, toScreen.y;
								
								y = cwKernel:DrawInfo("An unknown weapon", x, y, Color(200, 100, 50, 255), alpha);
								y = cwKernel:DrawInfo("Press use to equip.", x, y, colorWhite, alpha);
							end;
						end;
					elseif (trace.Entity.HUDPaintTargetID) then
						local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen();
						local x, y = toScreen.x, toScreen.y;
						trace.Entity:HUDPaintTargetID(x, y, alpha);
					else
						local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen();
						local x, y = toScreen.x, toScreen.y;
						
						hook.Call("HUDPaintEntityTargetID", Clockwork, trace.Entity, {
							alpha = alpha,
							x = x,
							y = y
						});
					end;
				end;
			end;
		end;
	end;
	
	cwKernel:OverrideMainFont(false);
	
	if (!IsValid(traceEntity)) then
		if (self.TargetIDData) then
			self.TargetIDData = nil;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function Clockwork:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = cwOption:GetColor("information");
	local gender = "He";
	
	if (target:GetGender() == GENDER_FEMALE) then
		gender = "She";
	end;
	
	if (!target:Alive()) then
		return cwKernel:DrawInfo(gender.." is clearly deceased.", x, y, informationColor, alpha);
	else
		return y;
	end;
end;

-- Called when the local player's character creation info should be adjusted.
function Clockwork:PlayerAdjustCharacterCreationInfo(panel, info) end;

-- Called when the character panel tool tip is needed.
function Clockwork:GetCharacterPanelToolTip(panel, character)
	if (table.Count(self.faction:GetAll()) > 1) then
		local numPlayers = #self.faction:GetPlayers(character.faction);
		local numLimit = self.faction:GetLimit(character.faction);
		return "There are "..numPlayers.."/"..numLimit.." characters with this faction.";
	end;
end;

-- Called when the character panel weapon model is needed.
function Clockwork:GetCharacterPanelSequence(entity, character) end;

-- Called when the character panel weapon model is needed.
function Clockwork:GetCharacterPanelWeaponModel(panel, character) end;

-- Called when a model selection's weapon model is needed.
function Clockwork:GetModelSelectWeaponModel(model) end;

-- Called when a model selection's sequence is needed.
function Clockwork:GetModelSelectSequence(entity, model) end;

--[[
    @codebase Client
    @details Finds the location of the player and packs together the info for observer ESP.
    @class Clockwork
    @param Table The current table of ESP positions/colors/names to add on to.
--]]
function Clockwork:GetAdminESPInfo(info)
	local info = info;

	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then			
			local physBone = v:LookupBone("ValveBiped.Bip01_Head1");
			local position = nil;
								
			if (physBone) then
				local bonePosition = v:GetBonePosition(physBone);
						
				if (bonePosition) then
					position = bonePosition + Vector(0, 0, 16);
				end;
			else
				position = v:GetPos() + Vector(0, 0, 80);
			end;

			local topText =  {v:Name()};

			cwPlugin:Call("GetStatusInfo", v, topText);	

			local text = {
				{table.concat(topText, " "), cwTeam.GetColor(v:Team())}
			};

			cwPlugin:Call("GetPlayerESPInfo", v, text);

			table.insert(info, {
				position = position,
				text = text
			});
		end;
	end;

	if (CW_CONVAR_SALEESP:GetInt() == 1) then
		for k, v in pairs (ents.GetAll()) do 
			if (v:GetClass() == "cw_salesman") then
				if (v:IsValid()) then
					local position = v:GetPos()
					local saleName = v:GetNetworkedString("Name");
					local color = Color(255, 150, 0, 255);

					table.insert(info, {
						position = position,
						color = color,
						text = {
							{"[Salesman]", color},
							{saleName, color}
						}
					});
				end;
			end;
		end;
	end;

	if (CW_CONVAR_ITEMESP:GetInt() == 1) then
		for k, v in pairs (ents.GetAll()) do 
			if (v:GetClass() == "cw_item") then
				if (v:IsValid()) then
					local position = v:GetPos()
					local itemTable = Clockwork.entity:FetchItemTable(v)

					if (itemTable) then
						local itemName = itemTable("name")
						local color = Color(0, 255, 255, 255);

						table.insert(info, {
							position = position,
							color = color,
							text = {
								{"[Item]", color},
								{itemName, color}
							}
						});
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's status info is needed.
function Clockwork:GetStatusInfo(player, text)
	local action = self.player:GetAction(player, true);
	
	if (action) then
		if (!player:IsRagdolled()) then
			if (action == "lock") then
				table.insert(text, "[Locking]");
			elseif (action == "unlock") then
				table.insert(text, "[Unlocking]");
			end;
		elseif (action == "unragdoll") then
			if (player:GetRagdollState() == RAGDOLL_FALLENOVER) then
				table.insert(text, "[Getting Up]");
			else
				table.insert(text, "[Unconscious]");
			end;
		elseif (!player:Alive()) then
			table.insert(text, "[Dead]");
		else
			table.insert(text, "[Performing '"..action.."']");
		end;
	end;
	
	if (player:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = player:GetSharedVar("FallenOver");
				
		if (fallenOver) then
			table.insert(text, "[Fallen Over]");			
		end;
	end;
end;

-- Called when extra player info is needed.
function Clockwork:GetPlayerESPInfo(player, text)
	if (player:IsValid()) then
		local weapon = player:GetActiveWeapon();
		local health = player:Health();
		local armor = player:Armor();
		local colorWhite = Color(255, 255, 255, 255);
		local colorRed = Color(255, 0, 0, 255);
		local colorHealth = colorWhite;
		local colorArmor = colorWhite;
		
		table.insert(text, {player:SteamName(), Color(170, 170, 170, 255), nil, nil, self.player:GetChatIcon(player)})

		if (player:Alive() and health > 0) then

			if (CW_CONVAR_ESPBARS:GetInt() == 0) then
				colorHealth = self:GetValueColor(health);
				colorArmor = self:GetValueColor(armor);
			end;

			table.insert(text, {"Health: ["..health.."]", colorHealth, {health, player:GetMaxHealth()}})
			
			if (player:Armor() > 0) then
				table.insert(text, {"Armor: ["..armor.."]", colorArmor, {armor, player:GetMaxArmor()}, Color(30, 65, 175, 255)});
			end;
		
			if (weapon and IsValid(weapon)) then			
				local raised = self.player:GetWeaponRaised(player);
				local color = colorWhite;

				if (raised == true) then
					color = colorRed;
				end;
				
				if (weapon.GetPrintName) then
					local printName = weapon:GetPrintName();

					if (printName) then
						table.insert(text, {printName, color})
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get the color of a value from green to red.
function Clockwork:GetValueColor(value)
	local red = math.floor(255 - (value * 2.55));
	local green = math.floor(value * 2.55);
	
	return Color(red, green, 0, 255);
end;

--[[
    @codebase Client
    @details This function is called after the progress bar info updates.
    @class Clockwork
--]]
function Clockwork:GetPostProgressBarInfo() end;

--[[
    @codebase Client
    @details This function is called when custom character options are needed.
    @class Clockwork
    @param Table The character whose options are needed.
    @param Table The currently available options.
    @param Table The menu itself.
--]]
function Clockwork:GetCustomCharacterOptions(character, options, menu) end;

--[[
    @codebase Client
    @details This function is called when custom character buttons are needed.
    @class Clockwork
    @param Table The character whose buttons are needed.
    @param Table The currently available buttons.
--]]
function Clockwork:GetCustomCharacterButtons(character, buttons) end;

--[[
    @codebase Client
    @details This function is called to figure out the text, percentage and flash of the current progress bar.
    @class Clockwork
    @returns Table The text, flash, and percentage of the progress bar.
--]]
function Clockwork:GetProgressBarInfo()
	local action, percentage = self.player:GetAction(self.Client, true);
	
	if (!self.Client:Alive() and action == "spawn") then
		return {text = "You will be respawned shortly.", percentage = percentage, flash = percentage < 10};
	end;
	
	if (!self.Client:IsRagdolled()) then
		if (action == "lock") then
			return {text = "The entity is being locked.", percentage = percentage, flash = percentage < 10};
		elseif (action == "unlock") then
			return {text = "The entity is being unlocked.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (action == "unragdoll") then
		if (self.Client:GetRagdollState() == RAGDOLL_FALLENOVER) then
			return {text = "You are regaining stability.", percentage = percentage, flash = percentage < 10};
		else
			return {text = "You are regaining conciousness.", percentage = percentage, flash = percentage < 10};
		end;
	elseif (self.Client:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = self.Client:GetSharedVar("FallenOver");
		
		if (fallenOver and cwPlugin:Call("PlayerCanGetUp")) then
			return {text = "Press 'jump' to get up.", percentage = 100};
		end;
	end;
end;

-- Called just before the local player's information is drawn.
function Clockwork:PreDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called just after the local player's information is drawn.
function Clockwork:PostDrawPlayerInfo(boxInfo, information, subInformation) end;

-- Called just after the date time box is drawn.
function Clockwork:PostDrawDateTimeBox(info) end;

--[[
	@codebase Client
	@details Called after the view model is drawn.
	@param Entity The viewmodel being drawn.
	@param Player The player drawing the viewmodel.
	@param Weapon The weapon table for the viewmodel.
--]]
function Clockwork:PostDrawViewModel(viewModel, player, weapon)
   	if (weapon.UseHands or !weapon:IsScripted()) then
    	local hands = Clockwork.Client:GetHands();

      	if IsValid(hands) then 
      		hands:DrawModel();
      	end;
   	end;
end;

--[[
    @codebase Client
    @details This function is called when local player info text is needed and adds onto it (F1 menu).
    @class Clockwork
    @param Table The current table of player info text to add onto.
--]]
function Clockwork:GetPlayerInfoText(playerInfoText)
	local cash = self.player:GetCash();
	local wages = self.player:GetWages();
	
	if (cwConfig:Get("cash_enabled"):Get()) then
		if (cash > 0) then
			playerInfoText:Add("CASH", cwOption:GetKey("name_cash")..": "..Clockwork.kernel:FormatCash(cash, true));
		end;
		
		if (wages > 0) then
			playerInfoText:Add("WAGES", self.Client:GetWagesName()..": "..Clockwork.kernel:FormatCash(wages));
		end;
	end;

	playerInfoText:AddSub("NAME", self.Client:Name(), 2);
	playerInfoText:AddSub("CLASS", cwTeam.GetName(self.Client:Team()), 1);
end;

--[[
    @codebase Client
    @details This function is called when the player's fade distance is needed for their target text (when you look at them).
    @class Clockwork
    @param Table The player we are finding the distance for.
    @returns Int The fade distance, defaulted at 4096.
--]]
function Clockwork:GetTargetPlayerFadeDistance(player)
	return 4096;
end;

-- Called when the player info text should be destroyed.
function Clockwork:DestroyPlayerInfoText(playerInfoText) end;

--[[
    @codebase Client
    @details This function is called when the targeted player's target text is needed.
    @class Clockwork
    @param Table The player we are finding the distance for.
    @param Table The player's current target text.
--]]
function Clockwork:GetTargetPlayerText(player, targetPlayerText)
	local targetIDTextFont = cwOption:GetFont("target_id_text");
	local physDescTable = {};
	local thirdPerson = "him";
	
	if (player:GetGender() == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if (self.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		cwKernel:WrapText(self.player:GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable);
		
		for k, v in pairs(physDescTable) do
			targetPlayerText:Add("PHYSDESC_"..k, v);
		end;
	elseif (player:Alive()) then
		targetPlayerText:Add("PHYSDESC", "You do not recognise "..thirdPerson..".");
	end;
end;

-- Called when the target player's text should be destroyed.
function Clockwork:DestroyTargetPlayerText(player, targetPlayerText) end;

-- Called when a player's scoreboard text is needed.
function Clockwork:GetPlayerScoreboardText(player)
	local thirdPerson = "him";
	
	if (player:GetGender() == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if (self.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		local physDesc = self.player:GetPhysDesc(player);
		
		if (string.utf8len(physDesc) > 64) then
			return string.utf8sub(physDesc, 1, 61).."...";
		else
			return physDesc;
		end;
	else
		return "You do not recognise "..thirdPerson..".";
	end;
end;

-- Called when the local player's character screen faction is needed.
function Clockwork:GetPlayerCharacterScreenFaction(character)
	return character.faction;
end;

-- Called to get whether the local player's character screen is visible.
function Clockwork:GetPlayerCharacterScreenVisible(panel)
	if (!self.quiz:GetEnabled() or self.quiz:GetCompleted()) then
		return true;
	else
		return false;
	end;
end;

-- Called to get whether the character menu should be created.
function Clockwork:ShouldCharacterMenuBeCreated()
	if (self.ClockworkIntroFadeOut) then
		return false;
	end;
	
	return true;
end;

-- Called when the local player's character screen is created.
function Clockwork:PlayerCharacterScreenCreated(panel)
	if (self.quiz:GetEnabled()) then
		Clockwork.datastream:Start("GetQuizStatus", true);
	end;
end;

-- Called when a player's scoreboard class is needed.
function Clockwork:GetPlayerScoreboardClass(player)
	return cwTeam.GetName(player:Team());
end;

-- Called when a player's scoreboard options are needed.
function Clockwork:GetPlayerScoreboardOptions(player, options, menu)
	local charTakeFlags = self.command:FindByID("CharTakeFlags");
	local charGiveFlags = self.command:FindByID("CharGiveFlags");
	local charGiveItem = self.command:FindByID("CharGiveItem");
	local charSetName = self.command:FindByID("CharSetName");
	local plySetGroup = self.command:FindByID("PlySetGroup");
	local plyDemote = self.command:FindByID("PlyDemote");
	local charBan = self.command:FindByID("CharBan");
	local plyKick = self.command:FindByID("PlyKick");
	local plyBan = self.command:FindByID("PlyBan");
	
	if (charBan and self.player:HasFlags(self.Client, charBan.access)) then
		options["Ban Character"] = function()
			RunConsoleCommand("cwCmd", "CharBan", player:Name());
		end;
	end;
	
	if (plyKick and self.player:HasFlags(self.Client, plyKick.access)) then
		options["Kick Player"] = function()
			Derma_StringRequest(player:Name(), "What is your reason for kicking them?", nil, function(text)
				Clockwork.kernel:RunCommand("PlyKick", player:Name(), text);
			end);
		end;
	end;
	
	if (plyBan and self.player:HasFlags(self.Client, self.command:FindByID("PlyBan").access)) then
		options["Ban Player"] = function()
			Derma_StringRequest(player:Name(), "How many minutes would you like to ban them for?", nil, function(minutes)
				Derma_StringRequest(player:Name(), "What is your reason for banning them?", nil, function(reason)
					Clockwork.kernel:RunCommand("PlyBan", player:Name(), minutes, reason);
				end);
			end);
		end;
	end;
	
	if (charGiveFlags and self.player:HasFlags(self.Client, charGiveFlags.access)) then
		options["Give Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to give them?", nil, function(text)
				Clockwork.kernel:RunCommand("CharGiveFlags", player:Name(), text);
			end);
		end;
	end;
	
	if (charTakeFlags and self.player:HasFlags(self.Client,charTakeFlags.access)) then
		options["Take Flags"] = function()
			Derma_StringRequest(player:Name(), "What flags would you like to take from them?", player:GetSharedVar("Flags"), function(text)
				Clockwork.kernel:RunCommand("CharTakeFlags", player:Name(), text);
			end);
		end;
	end;
	
	if (charSetName and self.player:HasFlags(self.Client, charSetName.access)) then
		options["Set Name"] = function()
			Derma_StringRequest(player:Name(), "What would you like to set their name to?", player:Name(), function(text)
				Clockwork.kernel:RunCommand("CharSetName", player:Name(), text);
			end);
		end;
	end;
	
	if (charGiveItem and self.player:HasFlags(self.Client, charGiveItem.access)) then
		options["Give Item"] = function()
			Derma_StringRequest(player:Name(), "What item would you like to give them?", nil, function(text)
				Clockwork.kernel:RunCommand("CharGiveItem", player:Name(), text);
			end);
		end;
	end;
	
	if (plySetGroup and self.player:HasFlags(self.Client, plySetGroup.access)) then
		options["Set Group"] = {};
		options["Set Group"]["Super Admin"] = function()
			Clockwork.kernel:RunCommand("PlySetGroup", player:Name(), "superadmin");
		end;
		options["Set Group"]["Admin"] = function()
			Clockwork.kernel:RunCommand("PlySetGroup", player:Name(), "admin");
		end;
		options["Set Group"]["Operator"] = function()
			Clockwork.kernel:RunCommand("PlySetGroup", player:Name(), "operator");
		end;
	end;
	
	if (plyDemote and self.player:HasFlags(self.Client, plyDemote.access)) then
		options["Demote"] = function()
			Clockwork.kernel:RunCommand("PlyDemote", player:Name());
		end;
	end;
	
	local canUwhitelist = false;
	local canWhitelist = false;
	local unwhitelist = self.command:FindByID("PlyUnwhitelist");
	local whitelist = self.command:FindByID("PlyWhitelist");
	
	if (whitelist and self.player:HasFlags(self.Client, whitelist.access)) then
		canWhitelist = true;
	end;
	
	if (unwhitelist and self.player:HasFlags(self.Client, unwhitelist.access)) then
		canUnwhitelist = true;
	end;
	
	if (canWhitelist or canUwhitelist) then
		local areWhitelistFactions = false;
		
		for k, v in pairs(self.faction.stored) do
			if (v.whitelist) then
				areWhitelistFactions = true;
			end;
		end;
		
		if (areWhitelistFactions) then
			if (canWhitelist) then
				options["Whitelist"] = {}; 
			end;
			
			if (canUwhitelist) then
				options["Unwhitelist"] = {};
			end;
			
			for k, v in pairs(self.faction.stored) do
				if (v.whitelist) then
					if (options["Whitelist"]) then
						options["Whitelist"][k] = function()
							Clockwork.kernel:RunCommand("PlyWhitelist", player:Name(), k);
						end;
					end;
					
					if (options["Unwhitelist"]) then
						options["Unwhitelist"][k] = function()
							Clockwork.kernel:RunCommand("PlyUnwhitelist", player:Name(), k);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when information about a door is needed.
function Clockwork:GetDoorInfo(door, information)
	local doorCost = cwConfig:Get("door_cost"):Get();
	local owner = cwEntity:GetOwner(door);
	local text = cwEntity:GetDoorText(door);
	local name = cwEntity:GetDoorName(door);
	
	if (information == DOOR_INFO_NAME) then
		if (cwEntity:IsDoorHidden(door)
		or cwEntity:IsDoorFalse(door)) then
			return false;
		elseif (name == "") then
			return "Door";
		else
			return name;
		end;
	elseif (information == DOOR_INFO_TEXT) then
		if (cwEntity:IsDoorUnownable(door)) then
			if (!cwEntity:IsDoorHidden(door)
			and !cwEntity:IsDoorFalse(door)) then
				if (text == "") then
					return "This door is unownable.";
				else
					return text;
				end;
			else
				return false;
			end;
		elseif (text != "") then
			if (!IsValid(owner)) then
				if (doorCost > 0) then
					return "This door can be purchased.";
				else
					return "This door can be owned.";
				end;
			else
				return text;
			end;
		elseif (IsValid(owner)) then
			if (doorCost > 0) then
				return "This door has been purchased.";
			else
				return "This door has been owned.";
			end;
		elseif (doorCost > 0) then
			return "This door can be purchased.";
		else
			return "This door can be owned.";
		end;
	end;
end;

-- Called to get whether or not a post process is permitted.
function Clockwork:PostProcessPermitted(class)
	return false;
end;

-- Called just after the translucent renderables have been drawn.
function Clockwork:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return; end;
	
	local colorWhite = cwOption:GetColor("white");
	local colorInfo = cwOption:GetColor("information");
	local doorFont = cwOption:GetFont("large_3d_2d");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	if (!cwKernel:IsChoosingCharacter()) then
		cam.Start3D(eyePos, eyeAngles);
			local entities = ents.FindInSphere(eyePos, 256);
			
			for k, v in pairs(entities) do
				if (IsValid(v) and cwEntity:IsDoor(v)) then
					cwKernel:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorInfo, colorWhite);
				end;
			end;
		cam.End3D();
	end;
end;

-- Called when screen space effects should be rendered.
function Clockwork:RenderScreenspaceEffects()
	if (IsValid(self.Client)) then
		local frameTime = FrameTime();
		local motionBlurs = {
			enabled = true,
			blurTable = {}
		};
		local color = 1;
		local isDrunk = self.player:GetDrunk();
		
		if (!cwKernel:IsChoosingCharacter()) then
			if (self.limb:IsActive() and self.event:CanRun("blur", "limb_damage")) then
				local headDamage = self.limb:GetDamage(HITGROUP_HEAD);
				motionBlurs.blurTable["health"] = math.Clamp(1 - (headDamage * 0.01), 0, 1);
			elseif (self.Client:Health() <= 75) then
				if (self.event:CanRun("blur", "health")) then
					motionBlurs.blurTable["health"] = math.Clamp(
						1 - ((self.Client:GetMaxHealth() - self.Client:Health()) * 0.01), 0, 1
					);
				end;
			end;
			
			if (self.Client:Alive()) then
				color = math.Clamp(color - ((self.Client:GetMaxHealth() - self.Client:Health()) * 0.01), 0, color);
			else
				color = 0;
			end;
			
			if (self.event:CanRun("blur", "isDrunk")) then
				if (isDrunk and self.DrunkBlur) then
					self.DrunkBlur = math.Clamp(self.DrunkBlur - (frameTime / 10), math.max(1 - (isDrunk / 8), 0.1), 1);					
					DrawMotionBlur(self.DrunkBlur, 1, 0);
				elseif (self.DrunkBlur and self.DrunkBlur < 1) then
					self.DrunkBlur = math.Clamp(self.DrunkBlur + (frameTime / 10), 0.1, 1);
					motionBlurs.blurTable["isDrunk"] = self.DrunkBlur;
				else
					self.DrunkBlur = 1;
				end;
			end;
		end;
		
		if (self.FishEyeTexture and self.Client:WaterLevel() > 2) then
			render.UpdateScreenEffectTexture();
				self.FishEyeTexture:SetFloat("$envmap", 0);
				self.FishEyeTexture:SetFloat("$envmaptint",	0);
				self.FishEyeTexture:SetFloat("$refractamount", 0.1);
				self.FishEyeTexture:SetInt("$ignorez", 1);
			render.SetMaterial(self.FishEyeTexture);
			render.DrawScreenQuad();
		end;
		
		self.ColorModify["$pp_colour_brightness"] = 0;
		self.ColorModify["$pp_colour_contrast"] = 1;
		self.ColorModify["$pp_colour_colour"] = color;
		self.ColorModify["$pp_colour_addr"] = 0;
		self.ColorModify["$pp_colour_addg"] = 0;
		self.ColorModify["$pp_colour_addb"] = 0;
		self.ColorModify["$pp_colour_mulr"] = 0;
		self.ColorModify["$pp_colour_mulg"] = 0;
		self.ColorModify["$pp_colour_mulb"] = 0;
		
		local systemTable = self.system:FindByID("Color Modify")
		local overrideColorMod = systemTable:GetModifyTable();

		if (overrideColorMod and overrideColorMod.enabled) then
			self.ColorModify["$pp_colour_brightness"] = overrideColorMod.brightness;
			self.ColorModify["$pp_colour_contrast"] = overrideColorMod.contrast;
			self.ColorModify["$pp_colour_colour"] = overrideColorMod.color;
			self.ColorModify["$pp_colour_addr"] = overrideColorMod.addr * 0.025;
			self.ColorModify["$pp_colour_addg"] = overrideColorMod.addg * 0.025;
			self.ColorModify["$pp_colour_addb"] = overrideColorMod.addg * 0.025;
			self.ColorModify["$pp_colour_mulr"] = overrideColorMod.mulr * 0.1;
			self.ColorModify["$pp_colour_mulg"] = overrideColorMod.mulg * 0.1;
			self.ColorModify["$pp_colour_mulb"] = overrideColorMod.mulb * 0.1;
		else
			cwPlugin:Call("PlayerSetDefaultColorModify", self.ColorModify);
		end;
		
		cwPlugin:Call("PlayerAdjustColorModify", self.ColorModify);
		cwPlugin:Call("PlayerAdjustMotionBlurs", motionBlurs);
		
		if (motionBlurs.enabled) then
			local addAlpha = nil;
			
			for k, v in pairs(motionBlurs.blurTable) do
				if (!addAlpha or v < addAlpha) then
					addAlpha = v;
				end;
			end;
			
			if (addAlpha) then
				DrawMotionBlur(math.Clamp(addAlpha, 0.1, 1), 1, 0);
			end;
		end;
		
		--[[
			Hotfix for ColorModify issues on OS X.
		--]]
		if (system.IsOSX()) then
			self.ColorModify["$pp_colour_brightness"] = 0;
			self.ColorModify["$pp_colour_contrast"] = 1;
		end;
		
		DrawColorModify(self.ColorModify);
	end;
end;

-- Called when the chat box is opened.
function Clockwork:ChatBoxOpened() end;

-- Called when the chat box is closed.
function Clockwork:ChatBoxClosed(textTyped) end;

-- Called when the chat box text has been typed.
function Clockwork:ChatBoxTextTyped(text)
	if (self.LastChatBoxText) then
		if (self.LastChatBoxText[1] == text) then
			return;
		end;
		
		if (#self.LastChatBoxText >= 25) then
			table.remove(self.LastChatBoxText, 25);
		end;
	else
		self.LastChatBoxText = {};
	end;
	
	table.insert(self.LastChatBoxText, 1, text);
end;

-- Called when the calc view table should be adjusted.
function Clockwork:CalcViewAdjustTable(view) end;

-- Called when the chat box info should be adjusted.
function Clockwork:ChatBoxAdjustInfo(info) end;

-- Called when the chat box text has changed.
function Clockwork:ChatBoxTextChanged(previousText, newText) end;

-- Called when the chat box has had a key code typed in.
function Clockwork:ChatBoxKeyCodeTyped(code, text)
	if (code == KEY_UP) then
		if (self.LastChatBoxText) then
			for k, v in pairs(self.LastChatBoxText) do
				if (v == text and self.LastChatBoxText[k + 1]) then
					return self.LastChatBoxText[k + 1];
				end;
			end;
			
			if (self.LastChatBoxText[1]) then
				return self.LastChatBoxText[1];
			end;
		end;
	elseif (code == KEY_DOWN) then
		if (self.LastChatBoxText) then
			for k, v in pairs(self.LastChatBoxText) do
				if (v == text and self.LastChatBoxText[k - 1]) then
					return self.LastChatBoxText[k - 1];
				end;
			end;
			
			if (#self.LastChatBoxText > 0) then
				return self.LastChatBoxText[#self.LastChatBoxText];
			end;
		end;
	end;
end;

-- Called when a notification should be adjusted.
function Clockwork:NotificationAdjustInfo(info)
	return true;
end;

-- Called when the local player's business item should be adjusted.
function Clockwork:PlayerAdjustBusinessItemTable(itemTable) end;

-- Called when the local player's class model info should be adjusted.
function Clockwork:PlayerAdjustClassModelInfo(class, info) end;

-- Called when the local player's headbob info should be adjusted.
function Clockwork:PlayerAdjustHeadbobInfo(info)
	local bisDrunk = self.player:GetDrunk();
	local scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(),0,1) or 1;
	
	if (self.Client:IsRunning()) then
		info.speed = (info.speed * 4) * scale;
		info.roll = (info.roll * 2) * scale;
	elseif (self.Client:IsJogging()) then
		info.speed = (info.speed * 4) * scale;
		info.roll = (info.roll * 1.5) * scale;
	elseif (self.Client:GetVelocity():Length() > 0) then
		info.speed = (info.speed * 3) * scale;
		info.roll = (info.roll * 1) * scale;
	else
		info.roll = info.roll * scale;
	end;
	
	if (isDrunk) then
		info.speed = info.speed * math.min(isDrunk * 0.25, 4);
		info.yaw = info.yaw * math.min(isDrunk, 4);
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function Clockwork:PlayerAdjustMotionBlurs(motionBlurs) end;

-- Called when the local player's item menu should be adjusted.
function Clockwork:PlayerAdjustMenuFunctions(itemTable, menuPanel, itemFunctions) end;

-- Called when the local player's item functions should be adjusted.
function Clockwork:PlayerAdjustItemFunctions(itemTable, itemFunctions) end;

-- Called when the local player's default colorify should be set.
function Clockwork:PlayerSetDefaultColorModify(colorModify) end;

-- Called when the local player's colorify should be adjusted.
function Clockwork:PlayerAdjustColorModify(colorModify) end;

-- Called to get whether a player's target ID should be drawn.
function Clockwork:ShouldDrawPlayerTargetID(player)
	return true;
end;

-- Called to get whether the local player's screen should fade black.
function Clockwork:ShouldPlayerScreenFadeBlack()
	if (!self.Client:Alive() or self.Client:IsRagdolled(RAGDOLL_FALLENOVER)) then
		if (!cwPlugin:Call("PlayerCanSeeUnconscious")) then
			return true;
		end;
	end;
	
	return false;
end;

-- Called when the menu background blur should be drawn.
function Clockwork:ShouldDrawMenuBackgroundBlur()
	return true;
end;

-- Called when the character background blur should be drawn.
function Clockwork:ShouldDrawCharacterBackgroundBlur()
	return true;
end;

-- Called when the character background should be drawn.
function Clockwork:ShouldDrawCharacterBackground()
	return true;
end;

-- Called when the character fault should be drawn.
function Clockwork:ShouldDrawCharacterFault(fault)
	return true;
end;

-- Called when the score board should be drawn.
function Clockwork:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player);
	
	local drawPendingScreenBlack = nil;
	local drawCharacterLoading = nil;
	local hasClientInitialized = self.Client:HasInitialized();
	local introTextSmallFont = cwOption:GetFont("intro_text_small");
	local colorWhite = cwOption:GetColor("white");
	local curTime = UnPredictedCurTime();
	local scrH = ScrH();
	local scrW = ScrW();
	
	if (cwKernel:IsChoosingCharacter()) then
		if (cwPlugin:Call("ShouldDrawCharacterBackground")) then
			cwKernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
		end;
		
		cwPlugin:Call("HUDPaintCharacterSelection");
	elseif (!hasClientInitialized) then
		if (!self.HasCharacterMenuBeenVisible
		and cwPlugin:Call("ShouldDrawCharacterBackground")) then
			drawPendingScreenBlack = true;
		end;
	end;
	
	if (hasClientInitialized) then
		if (!self.CharacterLoadingFinishTime) then
			local loadingTime = cwPlugin:Call("GetCharacterLoadingTime");
			self.CharacterLoadingDelay = loadingTime;
			self.CharacterLoadingFinishTime = curTime + loadingTime;
		end;
		
		if (!cwKernel:IsChoosingCharacter()) then
			cwKernel:CalculateScreenFading();
			
			if (!cwKernel:IsUsingCamera()) then
				cwPlugin:Call("HUDPaintForeground");
			end;
			
			cwPlugin:Call("HUDPaintImportant");
		end;
		
		if (self.CharacterLoadingFinishTime > curTime) then
			drawCharacterLoading = true;
		elseif (!self.CinematicScreenDone) then
			cwKernel:DrawCinematicIntro(curTime);
			cwKernel:DrawCinematicIntroBars();
		end;
	end;
	
	if (cwPlugin:Call("ShouldDrawBackgroundBlurs")) then
		cwKernel:DrawBackgroundBlurs();
	end;

	if (!self.player:HasDataStreamed()) then
		if (!self.DataStreamedAlpha) then
			self.DataStreamedAlpha = 255;
		end;
	elseif (self.DataStreamedAlpha) then
		self.DataStreamedAlpha = math.Approach(self.DataStreamedAlpha, 0, FrameTime() * 100);
		
		if (self.DataStreamedAlpha <= 0) then
			self.DataStreamedAlpha = nil;
		end;
	end;
	
	if (self.ClockworkIntroFadeOut) then
		local duration = 8;
		local introImage = cwOption:GetKey("intro_image");
		
		if (introImage != "") then
			duration = 16;
		end;
		
		local timeLeft = math.Clamp(self.ClockworkIntroFadeOut - curTime, 0, duration);
		local material = self.ClockworkIntroOverrideImage or self.ClockworkSplash;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512; --Patched
		local alpha = 384;
		
		if (!self.ClockworkIntroOverrideImage) then
			if (introImage != "" and timeLeft <= 8) then
				self.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8);
				self.ClockworkIntroOverrideImage = Clockwork.kernel:GetMaterial(introImage..".png");
				surface.PlaySound("buttons/combine_button5.wav");
			end;
		end;
		
		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft;
		end;
		
		if (timeLeft == 0) then
			self.ClockworkIntroFadeOut = nil;
			self.ClockworkIntroOverrideImage = nil;
		end;
		
		if (sineWave > 0) then
			width = width - (sineWave * 16);
			height = height - (sineWave * 4);
		end;
		
		if (curTime <= self.ClockworkIntroWhiteScreen) then
			cwKernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha));
		else
			local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2);
			
			cwKernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha));
			cwKernel:DrawGradient(
				GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
			);
			
			material:SetFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect(x, y, width, height);
		end;
		
		drawPendingScreenBlack = nil;
	end;
	
	if (cwKernel:GetSharedVar("NoMySQL") and cwKernel:GetSharedVar("NoMySQL") != "") then
		cwKernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255));
		draw.SimpleText(cwKernel:GetSharedVar("NoMySQL"), introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1);
	elseif (self.DataStreamedAlpha and self.DataStreamedAlpha > 0) then
		local textString = "LOADING...";
		
		cwKernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, self.DataStreamedAlpha));
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH * 0.75, Color(colorWhite.r, colorWhite.g, colorWhite.b, self.DataStreamedAlpha), 1, 1);
		
		drawPendingScreenBlack = nil;
	end;
	
	if (drawCharacterLoading) then
		cwPlugin:Call("HUDPaintCharacterLoading", math.Clamp((255 / self.CharacterLoadingDelay) * (self.CharacterLoadingFinishTime - curTime), 0, 255));
	elseif (drawPendingScreenBlack) then
		cwKernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
	end;
	
	if (self.CharacterLoadingFinishTime) then
		if (!self.CinematicInfoDrawn) then
			cwKernel:DrawCinematicInfo();
		end;
		
		if (!self.CinematicBarsDrawn) then
			cwKernel:DrawCinematicIntroBars();
		end;
	end;
	
	cwPlugin:Call("PostDrawBackgroundBlurs");
end;

-- Called when the background blurs should be drawn.
function Clockwork:ShouldDrawBackgroundBlurs()
	return true;
end;

-- Called just after the background blurs have been drawn.
function Clockwork:PostDrawBackgroundBlurs()
	local introTextSmallFont = cwOption:GetFont("intro_text_small");
	local position = cwPlugin:Call("GetChatBoxPosition");
	
	if (position) then
		self.chatBox:SetCustomPosition(position.x, position.y);
	end;
	
	local backgroundColor = cwOption:GetColor("background");
	local colorWhite = cwOption:GetColor("white");
	local panelInfo = self.CurrentFactionSelected;
	local menuPanel = cwKernel:GetRecogniseMenu();
	
	if (panelInfo and IsValid(panelInfo[1]) and panelInfo[1]:IsVisible()) then
		local factionTable = self.faction:FindByID(panelInfo[2]);
		
		if (factionTable and factionTable.material) then
			if (file.Exists("materials/"..factionTable.material..".png", "GAME")) then
				if (!panelInfo[3]) then
					panelInfo[3] = Clockwork.kernel:GetMaterial(factionTable.material..".png");
				end;
				
				if (cwKernel:IsCharacterScreenOpen(true)) then
					surface.SetDrawColor(255, 255, 255, panelInfo[1]:GetAlpha());
					surface.SetMaterial(panelInfo[3]);
					surface.DrawTexturedRect(panelInfo[1].x, panelInfo[1].y + panelInfo[1]:GetTall() + 16, 512, 256);
				end;
			end;
		end;
	end;
	
	if (self.TitledMenu and IsValid(self.TitledMenu.menuPanel)) then
		local menuTextTiny = cwOption:GetFont("menu_text_tiny");
		local menuPanel = self.TitledMenu.menuPanel;
		local menuTitle = self.TitledMenu.title;
		
		cwKernel:DrawSimpleGradientBox(2, menuPanel.x - 4, menuPanel.y - 4, menuPanel:GetWide() + 8, menuPanel:GetTall() + 8, backgroundColor);
		cwKernel:OverrideMainFont(menuTextTiny);
			cwKernel:DrawInfo(menuTitle, menuPanel.x, menuPanel.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4;
			end);
		cwKernel:OverrideMainFont(false);
	end;
	
	cwKernel:DrawDateTime();
end;

-- Called just before a bar is drawn.
function Clockwork:PreDrawBar(barInfo) end;

-- Called just after a bar is drawn.
function Clockwork:PostDrawBar(barInfo) end;

-- Called when the top bars are needed.
function Clockwork:GetBars(bars) end;

-- Called when the top bars should be destroyed.
function Clockwork:DestroyBars(bars) end;

-- Called when the chat box position is needed.
function Clockwork:GetChatBoxPosition()
	return {x = 8, y = ScrH() - 40};
end;

-- Called when the cinematic intro info is needed.
function Clockwork:GetCinematicIntroInfo()
	return {
		credits = "A roleplaying game designed by "..Schema:GetAuthor()..".",
		title = Schema:GetName(),
		text = Schema:GetDescription()
	};
end;

-- Called when the character loading time is needed.
function Clockwork:GetCharacterLoadingTime() return 8; end;

-- Called when a player's HUD should be painted.
function Clockwork:HUDPaintPlayer(player) end;

-- Called when the HUD should be painted.
function Clockwork:HUDPaint()
	if (!cwKernel:IsChoosingCharacter() and !cwKernel:IsUsingCamera()) then
		if (self.event:CanRun("view", "damage") and self.Client:Alive()) then
			local maxHealth = self.Client:GetMaxHealth();
			local health = self.Client:Health();
			
			if (health < maxHealth) then
				cwPlugin:Call("DrawPlayerScreenDamage", 1 - ((1 / maxHealth) * health));
			end;
		end;
		
		if (self.event:CanRun("view", "vignette") and cwConfig:Get("enable_vignette"):Get()) then
			cwPlugin:Call("DrawPlayerVignette");
		end;
		
		local weapon = self.Client:GetActiveWeapon();
		self.BaseClass:HUDPaint();
		
		if (!cwKernel:IsScreenFadedBlack()) then
			for k, v in pairs(cwPlayer.GetAll()) do
				if (v:HasInitialized() and v != self.Client) then
					cwPlugin:Call("HUDPaintPlayer", v);
				end;
			end;
		end;
		
		if (!cwKernel:IsUsingTool()) then
			cwKernel:DrawHints();
		end;
		
		if ((cwConfig:Get("enable_crosshair"):Get() or cwKernel:IsDefaultWeapon(weapon))
		and (IsValid(weapon) and weapon.DrawCrosshair != false)) then
			local info = {
				color = Color(255, 255, 255, 255),
				x = ScrW() / 2,
				y = ScrH() / 2
			};
			
			cwPlugin:Call("GetPlayerCrosshairInfo", info);
			self.CustomCrosshair = cwPlugin:Call("DrawPlayerCrosshair", info.x, info.y, info.color);
		else
			self.CustomCrosshair = false;
		end;
	end;
end;

-- Called when the local player's crosshair info is needed.
function Clockwork:GetPlayerCrosshairInfo(info)
	if (cwConfig:Get("use_free_aiming"):Get()) then
		-- Thanks to BlackOps7799 for this open source example.
		
		local traceLine = util.TraceLine({
			start = self.Client:EyePos(),
			endpos = self.Client:EyePos() + (self.Client:GetAimVector() * 1024 * 1024),
			filter = self.Client
		});
		
		local screenPos = traceLine.HitPos:ToScreen();
		
		info.x = screenPos.x;
		info.y = screenPos.y;
	end;
end;

-- Called when the local player's crosshair should be drawn.
function Clockwork:DrawPlayerCrosshair(x, y, color)
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	surface.DrawRect(x, y, 2, 2);
	surface.DrawRect(x, y + 9, 2, 2);
	surface.DrawRect(x, y - 9, 2, 2);
	surface.DrawRect(x + 9, y, 2, 2);
	surface.DrawRect(x - 9, y, 2, 2);

	return true;
end;

-- Called when a player starts using voice.
function Clockwork:PlayerStartVoice(player)
	if (cwConfig:Get("local_voice"):Get()) then
		if (player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive()) then
			return;
		end;
	end;
	
	if (self.BaseClass and self.BaseClass.PlayerStartVoice) then
		self.BaseClass:PlayerStartVoice(player);
	end;
end;

-- Called to check if a player does have an flag.
function Clockwork:PlayerDoesHaveFlag(player, flag)
	if (string.find(cwConfig:Get("default_flags"):Get(), flag)) then
		return true;
	end;
end;

-- Called to check if a player does recognise another player.
function Clockwork:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	return realValue;
end;

-- Called when a player's name should be shown as unrecognised.
function Clockwork:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	return true;
end;

-- Called when the target player's name is needed.
function Clockwork:GetTargetPlayerName(player)
	return player:Name();
end;

-- Called when a player begins typing.
function Clockwork:StartChat(team)
	return true;
end;

-- Called when a player says something.
function Clockwork:OnPlayerChat(player, text, teamOnly, playerIsDead)
	if (IsValid(player)) then
		self.chatBox:Decode(player, player:Name(), text, {}, "none");
	else
		self.chatBox:Decode(nil, "Console", text, {}, "chat");
	end;
	
	return true;
end;

-- Called when chat text is received from the server
function Clockwork:ChatText(index, name, text, class)
	if (class == "none") then
		self.chatBox:Decode(cwPlayer.GetByID(index), name, text, {}, "none");
	end;
	
	return true;
end;

-- Called when the scoreboard should be created.
function Clockwork:CreateScoreboard() end;

-- Called when the scoreboard should be shown.
function Clockwork:ScoreboardShow()
	if (self.Client:HasInitialized()) then
		if (self.plugin:Call("CanShowTabMenu")) then
			self.menu:Create();
			self.menu:SetOpen(true);
			self.menu.holdTime = UnPredictedCurTime() + 0.5;
		end;
	end;
end;

-- Called when the scoreboard should be hidden.
function Clockwork:ScoreboardHide()
	if (self.Client:HasInitialized() and self.menu.holdTime) then
		if (UnPredictedCurTime() >= self.menu.holdTime) then
			if (self.plugin:Call("CanShowTabMenu")) then
				self.menu:SetOpen(false);
			end;
		end;
	end;
end;

-- Called before the tab menu is shown.
function Clockwork:CanShowTabMenu() return true; end;

-- Overriding Garry's "grab ear" animation.
function Clockwork:GrabEarAnimation(player) end;

-- A function to register a network proxy.
function Clockwork.kernel:RegisterNetworkProxy(entity, name, Callback)
	if (!Clockwork.NetworkProxies[entity]) then
		Clockwork.NetworkProxies[entity] = {};
	end;
	
	Clockwork.NetworkProxies[entity][name] = {
		Callback = Callback,
		oldValue = nil
	};
end;
	
-- A function to get whether the info menu is open.
function Clockwork.kernel:IsInfoMenuOpen()
	return Clockwork.InfoMenuOpen;
end;

-- A function to create a client ConVar.
function Clockwork.kernel:CreateClientConVar(name, value, save, userData, Callback)
	local conVar = CreateClientConVar(name, value, save, userData);
	
	cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
		Clockwork.plugin:Call("ClockworkConVarChanged", conVar, previousValue, newValue);
		
		if (Callback) then
			Callback(conVar, previousValue, newValue);
		end;
	end);
	
	return conVar;
end;

-- A function to scale a font size to the screen.
function Clockwork.kernel:FontScreenScale(size)
	return ScreenScale(size);
end;
	
-- A function to get a material.
function Clockwork.kernel:GetMaterial(materialPath, pngParameters)
	self.CachedMaterial = self.CachedMaterial or {};

	if (!self.CachedMaterial[materialPath]) then
		self.CachedMaterial[materialPath] = Material(materialPath, pngParameters);
	end;

	return self.CachedMaterial[materialPath];
end;

-- A function to get the 3D font size.
function Clockwork.kernel:GetFontSize3D()
	return self:FontScreenScale(32);
end;

-- A function to get the size of text.
function Clockwork.kernel:GetTextSize(font, text)
	local defaultWidth, defaultHeight = self:GetCachedTextSize(font, "U");
	local height = defaultHeight;
	local width = 0;
	local textLength = 0;
	
	for i in string.gmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
		local currentCharacter = textLength + 1;
		local textWidth, textHeight = self:GetCachedTextSize(font, string.utf8sub(text, currentCharacter, currentCharacter));

		if (textWidth == 0) then
			textWidth = defaultWidth;
		end;
		
		if (textHeight > height) then
			height = textHeight;
		end;

		width = width + textWidth;
		textLength = textLength + 1;
	end;
	
	return width, height;
end;

-- A function to calculate alpha from a distance.
function Clockwork.kernel:CalculateAlphaFromDistance(maximum, start, finish)
	if (type(start) == "Player") then
		start = start:GetShootPos();
	elseif (type(start) == "Entity") then
		start = start:GetPos();
	end;
	
	if (type(finish) == "Player") then
		finish = finish:GetShootPos();
	elseif (type(finish) == "Entity") then
		finish = finish:GetPos();
	end;
	
	return math.Clamp(255 - ((255 / maximum) * (start:Distance(finish))), 0, 255);
end;

-- A function to wrap text into a table.
function Clockwork.kernel:WrapText(text, font, maximumWidth, baseTable)
	if (maximumWidth <= 0 or !text or text == "") then
		return;
	end;
	
	if (self:GetTextSize(font, text) > maximumWidth) then
		local currentWidth = 0;
		local firstText = nil;
		local secondText = nil;
		
		for i = 0, #text do
			local currentCharacter = string.utf8sub(text, i, i);
			local currentSingleWidth = Clockwork.kernel:GetTextSize(font, currentCharacter);
			
			if ((currentWidth + currentSingleWidth) >= maximumWidth) then
				baseTable[#baseTable + 1] = string.utf8sub(text, 0, (i - 1));
				text = string.utf8sub(text, i);
				
				break;
			else
				currentWidth = currentWidth + currentSingleWidth;
			end;
		end;
		
		if (self:GetTextSize(font, text) > maximumWidth) then
			self:WrapText(text, font, maximumWidth, baseTable);
		else
			baseTable[#baseTable + 1] = text;
		end;
	else
		baseTable[#baseTable + 1] = text;
	end;
end;

-- A function to handle an entity's menu.
function Clockwork.kernel:HandleEntityMenu(entity)
	local options = {};
	local itemTable = nil;
	
	Clockwork.plugin:Call("GetEntityMenuOptions", entity, options);

	if (entity:GetClass() == "cw_item") then
		itemTable = entity:GetItemTable();
		if (itemTable and itemTable:IsInstance() and itemTable.GetOptions) then
			local itemOptions = itemTable:GetOptions(entity);
			
			for k, v in pairs(itemOptions) do
				options[k] = {
					title = k,
					name = v,
					isOptionTable = true,
					isArgTable = true
				};
			end;
		end;
	end;

	if (table.Count(options) == 0) then return; end;
	
	local menuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
		if (itemTable and type(arguments) == "table" and arguments.isOptionTable) then
			menuPanel:AddOption(arguments.title, function()
				if (itemTable.HandleOptions) then
					local transmit, data = itemTable:HandleOptions(arguments.name, nil, nil, entity);
					
					if (transmit) then
						Clockwork.datastream:Start("MenuOption", {
							option = arguments.name,
							data = data,
							item = itemTable("itemID"),
							entity = entity
						});
					end;
				end;
			end)
		else
			menuPanel:AddOption(option, function()
				if (type(arguments) == "table" and arguments.isArgTable) then
					if (arguments.Callback) then
						arguments.Callback(function(arguments)
							Clockwork.entity:ForceMenuOption(
								entity, option, arguments
							);
						end);
					else
						Clockwork.entity:ForceMenuOption(
							entity, option, arguments.arguments
						);
					end;
				else
					Clockwork.entity:ForceMenuOption(
						entity, option, arguments
					);
				end;
				
				timer.Simple(FrameTime(), function()
					self:RemoveActiveToolTip();
				end);
			end);
		end;
		
		menuPanel.Items = menuPanel:GetChildren();
		local panel = menuPanel.Items[#menuPanel.Items];
		
		if (IsValid(panel)) then
			if (type(arguments) == "table") then
				if (arguments.isOrdered) then
					menuPanel.Items[#menuPanel.Items] = nil;
					table.insert(menuPanel.Items, 1, panel);
				end;
				
				if (arguments.toolTip) then
					self:CreateMarkupToolTip(panel);
					panel:SetMarkupToolTip(arguments.toolTip);
				end;
			end;
		end;
	end);
	
	self:RegisterBackgroundBlur(menuPanel, SysTime());
	self:SetTitledMenu(menuPanel, "INTERACT WITH THIS ENTITY");
	menuPanel.entity = entity;
	
	return menuPanel;
end;

-- A function to get the gradient texture.
function Clockwork.kernel:GetGradientTexture()
	return Clockwork.GradientTexture;
end;

-- A function to add a menu from data.
function Clockwork.kernel:AddMenuFromData(menuPanel, data, Callback, iMinimumWidth, bManualOpen)
	local bCreated = false;
	local options = {};
	
	if (!menuPanel) then
		bCreated = true; menuPanel = DermaMenu();
		
		if (iMinimumWidth) then
			menuPanel:SetMinimumWidth(iMinimumWidth);
		end;
	end;
	
	for k, v in pairs(data) do
		options[#options + 1] = {k, v};
	end;
	
	table.sort(options, function(a, b)
		return a[1] < b[1];
	end);
		
	for k, v in pairs(options) do
		if (type(v[2]) == "table" and !v[2].isArgTable) then
			if (table.Count(v[2]) > 0) then
				self:AddMenuFromData(menuPanel:AddSubMenu(v[1]), v[2], Callback);
			end;
		elseif (type(v[2]) == "function") then
			menuPanel:AddOption(v[1], v[2]);
		elseif (Callback) then
			Callback(menuPanel, v[1], v[2]);
		end;
	end;
	
	if (!bCreated) then return; end;
	
	if (!bManualOpen) then
		if (#options > 0) then
			menuPanel:Open();
		else
			menuPanel:Remove();
		end;
	end;
	
	return menuPanel;
end;

-- A function to adjust the width of text.
function Clockwork.kernel:AdjustMaximumWidth(font, text, width, addition, extra)
	local textString = tostring(self:Replace(text, "&", "U"));
	local textWidth = self:GetCachedTextSize(font, textString) + (extra or 0);
	
	if (textWidth > width) then
		width = textWidth + (addition or 0);
	end;
	
	return width;
end;

--[[
	A function to add a top hint. If bNoSound is false then no
	sound will play, otherwise if it is a string then it will
	play that sound.
--]]
function Clockwork.kernel:AddTopHint(text, delay, color, bNoSound, bShowDuplicates)
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (color) then
		if (type(color) == "string") then
			color = Clockwork.option:GetColor(color);
		end;
	else
		color = colorWhite;
	end;
	
	if (!bShowDuplicates) then
		for k, v in pairs(self.Hints) do
			if (v.text == text) then
				return;
			end;
		end;
	end;
	
	if (table.Count(self.Hints) == 10) then
		table.remove(self.Hints, 10);
	end;
	
	if (type(bNoSound) == "string") then
		surface.PlaySound(bNoSound);
	elseif (bNoSound == nil) then
		surface.PlaySound("hl1/fvox/blip.wav");
	end;
	
	self.Hints[#self.Hints + 1] = {
		startTime = SysTime(),
		velocityX = -5,
		velocityY = 0,
		targetAlpha = 255,
		alphaSpeed = 64,
		color = color,
		delay = delay,
		alpha = 0,
		text = text,
		y = ScrH() * 0.3,
		x = ScrW() + 200
	};
end;

local function UpdateHint(index, hintInfo, iCount)
	local hintsFont = Clockwork.option:GetFont("hints_text");
	local fontWidth, fontHeight = Clockwork.kernel:GetCachedTextSize(
		hintsFont, hintInfo.text
	);
	local height = fontHeight;
	local width = fontWidth;
	local alpha = 255;
	local x = hintInfo.x;
	local y = hintInfo.y;
	
	--[[ Work out the ideal X and Y position for the hint. --]]
	local idealY = 8 + (height * (index - 1));
	local idealX = ScrW() - width - 32;
	local timeLeft = (hintInfo.startTime - (SysTime() - hintInfo.delay) + 2);
	
	if (timeLeft < 0.7) then
		idealX = idealX - 50;
		alpha = 0;
	end;
	
	if (timeLeft < 0.2) then
		idealX = idealX + width * 2;
	end;
	
	local fSpeed = FrameTime() * 15;
		y = y + hintInfo.velocityY * fSpeed;
		x = x + hintInfo.velocityX * fSpeed;
	local distanceY = idealY - y;
	local distanceX = idealX - x;
	local distanceA = (alpha - hintInfo.alpha);
	
	hintInfo.velocityY = hintInfo.velocityY + distanceY * fSpeed * 1;
	hintInfo.velocityX = hintInfo.velocityX + distanceX * fSpeed * 1;
	
	if (math.abs(distanceY) < 2 and math.abs(hintInfo.velocityY) < 0.1) then
		hintInfo.velocityY = 0;
	end;
	
	if (math.abs(distanceX) < 2 and math.abs(hintInfo.velocityX) < 0.1) then
		hintInfo.velocityX = 0;
	end;
	
	hintInfo.velocityX = hintInfo.velocityX * (0.95 - FrameTime() * 8);
	hintInfo.velocityY = hintInfo.velocityY * (0.95 - FrameTime() * 8);
	hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1;
	hintInfo.x = x;
	hintInfo.y = y;
	
	--[[ Remove it if we're finished. --]]
	return (timeLeft < 0.1);
end;

-- A function to calculate the hints.
function Clockwork.kernel:CalculateHints()
	for k, v in pairs(self.Hints) do
		if (UpdateHint(k, v, #self.Hints)) then
			table.remove(self.Hints, k);
		end;
	end;
end;

-- A utility function to draw text within an info block.
local function Util_DrawText(info, text, color, bCentered, sFont)
	local realWidth = 0;
	
	if (sFont) then Clockwork.kernel:OverrideMainFont(sFont); end;
	
	if (!bCentered) then
		info.y, realWidth = Clockwork.kernel:DrawInfo(
			text, info.x - (info.width / 2), info.y, color, nil, true
		);
	else
		info.y, realWidth = Clockwork.kernel:DrawInfo(
			text, info.x, info.y, color
		);
	end;
	
	if (realWidth > info.width) then
		info.width = realWidth + 16;
	end;
	
	if (sFont) then
		Clockwork.kernel:OverrideMainFont(false);
	end;
end;

-- A function to draw the date and time.
function Clockwork.kernel:DrawDateTime()
	local backgroundColor = Clockwork.option:GetColor("background");
	local mainTextFont = Clockwork.option:GetFont("main_text");
	local colorWhite = Clockwork.option:GetColor("white");
	local colorInfo = Clockwork.option:GetColor("information");
	local scrW = ScrW();
	local scrH = ScrH();
	local info = {
		DrawText = Util_DrawText,
		width = math.min(scrW * 0.5, 512),
		x = scrW / 2,
		y = scrH * 0.2
	};
	
	info.originalX = info.x;
	info.originalY = info.y;
	
	if (Clockwork.LastDateTimeInfo and Clockwork.LastDateTimeInfo.y > info.y) then
		local height = (Clockwork.LastDateTimeInfo.y - info.y) + 8;
		local width = Clockwork.LastDateTimeInfo.width + 16;
		local x = Clockwork.LastDateTimeInfo.x - (Clockwork.LastDateTimeInfo.width / 2) - 8;
		local y = Clockwork.LastDateTimeInfo.y - height - 8;
		
		self:OverrideMainFont(Clockwork.option:GetFont("menu_text_tiny"));
		self:DrawInfo("CHARACTER AND ROLEPLAY INFO", x, y + 4, colorInfo, nil, true, function(x, y, width, height)
			return x, y - height;
		end);
		
		SLICED_INFO_MENU_BG:Draw(x, y + 8, width, height, 8, backgroundColor);
		y = y + height + 16;
		
		if (self:CanCreateInfoMenuPanel() and self:IsInfoMenuOpen()) then
			local menuPanelX = x;
			local menuPanelY = y;
			
			self:DrawInfo("SELECT A QUICK MENU OPTION", x, y, colorInfo, nil, true, function(x, y, width, height)
				menuPanelY = menuPanelY + height + 8;
				return x, y;
			end);
			
			self:CreateInfoMenuPanel(menuPanelX, menuPanelY, width);
			
			SLICED_INFO_MENU_INSIDE:Draw( Clockwork.InfoMenuPanel.x - 4, Clockwork.InfoMenuPanel.y - 4, Clockwork.InfoMenuPanel:GetWide() + 8, Clockwork.InfoMenuPanel:GetTall() + 8, 8, backgroundColor);
			
			--[[ Override the menu's width to fit nicely. --]]
			Clockwork.InfoMenuPanel:SetSize(width, Clockwork.InfoMenuPanel:GetTall());
			Clockwork.InfoMenuPanel:SetMinimumWidth(width);
			
			if (!Clockwork.InfoMenuPanel.VisibilitySet) then
				Clockwork.InfoMenuPanel.VisibilitySet = true;
				
				timer.Simple(FrameTime() * 2, function()
					if (IsValid(Clockwork.InfoMenuPanel)) then
						Clockwork.InfoMenuPanel:SetVisible(true);
					end;
				end);
			end;
		end;
		
		self:OverrideMainFont(false);
		Clockwork.LastDateTimeInfo.height = height;
	end;
	
	if (Clockwork.plugin:Call("PlayerCanSeeDateTime")) then
		local dateTimeFont = Clockwork.option:GetFont("date_time_text");
		local dateString = Clockwork.date:GetString();
		local timeString = Clockwork.time:GetString();
		
		if (dateString and timeString) then
			local dayName = Clockwork.time:GetDayName();
			local text = string.upper(dateString..". "..dayName..", "..timeString..".");
			
			self:OverrideMainFont(dateTimeFont);
				info.y = self:DrawInfo(text, info.x, info.y, colorWhite, 255);
			self:OverrideMainFont(false);
		end;
	end;
	
	self:DrawBars(info, "tab");
		Clockwork.PlayerInfoBox = self:DrawPlayerInfo(info);
		Clockwork.plugin:Call("PostDrawDateTimeBox", info);
	Clockwork.LastDateTimeInfo = info;
	
	if (!Clockwork.plugin:Call("PlayerCanSeeLimbDamage")) then
		return;
	end;
	
	local tipHeight = 0;
	local tipWidth = 0;
	local limbInfo = {};
	local height = 240;
	local width = 120;
	local texInfo = {
		shouldDisplay = true,
		textures = {
			[HITGROUP_RIGHTARM] = Clockwork.limb:GetTexture(HITGROUP_RIGHTARM),
			[HITGROUP_RIGHTLEG] = Clockwork.limb:GetTexture(HITGROUP_RIGHTLEG),
			[HITGROUP_LEFTARM] = Clockwork.limb:GetTexture(HITGROUP_LEFTARM),
			[HITGROUP_LEFTLEG] = Clockwork.limb:GetTexture(HITGROUP_LEFTLEG),
			[HITGROUP_STOMACH] = Clockwork.limb:GetTexture(HITGROUP_STOMACH),
			[HITGROUP_CHEST] = Clockwork.limb:GetTexture(HITGROUP_CHEST),
			[HITGROUP_HEAD] = Clockwork.limb:GetTexture(HITGROUP_HEAD),
			["body"] = Clockwork.limb:GetTexture("body")
		},
		names = {
			[HITGROUP_RIGHTARM] = Clockwork.limb:GetName(HITGROUP_RIGHTARM),
			[HITGROUP_RIGHTLEG] = Clockwork.limb:GetName(HITGROUP_RIGHTLEG),
			[HITGROUP_LEFTARM] = Clockwork.limb:GetName(HITGROUP_LEFTARM),
			[HITGROUP_LEFTLEG] = Clockwork.limb:GetName(HITGROUP_LEFTLEG),
			[HITGROUP_STOMACH] = Clockwork.limb:GetName(HITGROUP_STOMACH),
			[HITGROUP_CHEST] = Clockwork.limb:GetName(HITGROUP_CHEST),
			[HITGROUP_HEAD] = Clockwork.limb:GetName(HITGROUP_HEAD),
		}
	};
	local x = info.x + (info.width / 2) + 32;
	local y = info.originalY + 8;
		
	Clockwork.plugin:Call("GetPlayerLimbInfo", texInfo);
		
	if (texInfo.shouldDisplay) then
		surface.SetDrawColor(255, 255, 255, 150);
		surface.SetMaterial(texInfo.textures["body"]);
		surface.DrawTexturedRect(x, y, width, height);
			
		for k, v in pairs(Clockwork.limb.hitGroups) do
			local limbHealth = Clockwork.limb:GetHealth(k);
			local limbColor = Clockwork.limb:GetColor(limbHealth);
			local newIndex = #limbInfo + 1;
			
			surface.SetDrawColor(limbColor.r, limbColor.g, limbColor.b, 150);
			surface.SetMaterial(texInfo.textures[k]);
			surface.DrawTexturedRect(x, y, width, height);
				
			limbInfo[newIndex] = {
				color = limbColor,
				text = texInfo.names[k]..": "..limbHealth.."%"
			};
				
			local textWidth, textHeight = self:GetCachedTextSize(mainTextFont, limbInfo[newIndex].text);
			tipHeight = tipHeight + textHeight + 4;
				
			if (textWidth > tipWidth) then
				tipWidth = textWidth;
			end;
				
			limbInfo[newIndex].textHeight = textHeight;
		end;
			
		local mouseX = gui.MouseX();
		local mouseY = gui.MouseY();
		
		if (mouseX >= x and mouseX <= x + width
		and mouseY >= y and mouseY <= y + height) then
			local tipX = mouseX + 16;
			local tipY = mouseY + 16;
			
			self:DrawSimpleGradientBox(
				2, tipX - 8, tipY - 8, tipWidth + 16, tipHeight + 12, backgroundColor
			);
			
			for k, v in pairs(limbInfo) do
				self:DrawInfo(v.text, tipX, tipY, v.color, 255, true);
				
				if (k < #limbInfo) then
					tipY = tipY + v.textHeight + 4;
				else
					tipY = tipY + v.textHeight;
				end;
			end;
		end;
	end;
end;

-- A function to draw the top hints.
function Clockwork.kernel:DrawHints()
	if (Clockwork.plugin:Call("PlayerCanSeeHints") and #self.Hints > 0) then
		local hintsFont = Clockwork.option:GetFont("hints_text");
		
		for k, v in pairs(self.Hints) do
			self:OverrideMainFont(hintsFont);
				self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true);
			self:OverrideMainFont(false);
		end;
	end;
end;

-- A function to draw the top bars.
function Clockwork.kernel:DrawBars(info, class)
	if (Clockwork.plugin:Call("PlayerCanSeeBars", class)) then
		local barTextFont = Clockwork.option:GetFont("bar_text");
		
		Clockwork.bars.width = info.width;
		Clockwork.bars.height = 12;
		Clockwork.bars.y = info.y;
		
		if (class == "tab") then
			Clockwork.bars.x = info.x - (info.width / 2);
		else
			Clockwork.bars.x = info.x;
		end;
		
		Clockwork.option:SetFont("bar_text", Clockwork.option:GetFont("auto_bar_text"));
			for k, v in pairs(Clockwork.bars.stored) do
				Clockwork.bars.y = self:DrawBar(Clockwork.bars.x, Clockwork.bars.y, Clockwork.bars.width, Clockwork.bars.height, v.color, v.text, v.value, v.maximum, v.flash) + (Clockwork.bars.height + 2);
			end;
		Clockwork.option:SetFont("bar_text", barTextFont);
		
		info.y = Clockwork.bars.y;
	end;
end;

-- A function to get the ESP info.
function Clockwork.kernel:GetESPInfo()
	return self.ESPInfo;
end;
	
-- A function to draw the admin ESP.
function Clockwork.kernel:DrawAdminESP()
	local colorWhite = Clockwork.option:GetColor("white");
	local curTime = UnPredictedCurTime();

	if (!Clockwork.NextGetESPInfo or curTime >= Clockwork.NextGetESPInfo) then
		Clockwork.NextGetESPInfo = curTime + (CW_CONVAR_ESPTIME:GetInt() or 1);
		self.ESPInfo = {};
		
		Clockwork.plugin:Call("GetAdminESPInfo", self.ESPInfo);
	end;
	
	for k, v in pairs(self.ESPInfo) do
		local position = v.position:ToScreen();
		local text, color, height;
		
		if (position) then
			if (type(v.text) == "string") then
				self:DrawSimpleText(v.text, position.x, position.y, v.color or colorWhite, 1, 1);
			else
				for k2, v2 in ipairs(v.text) do	
					local barValue;
					local maximum = 100;

					if (type(v2) == "string") then
						text = v2;
						color = v.color;
					else
						text = v2[1];
						color = v2[2];

						local barNumbers = v2[3];

						if (type(barNumbers) == "table") then
							barValue = barNumbers[1];
							maximum = barNumbers[2];
						else
							barValue = barNumbers;
						end;
					end;
						
					if (k2 > 1) then
						self:OverrideMainFont(Clockwork.option:GetFont("esp_text"));
						height = draw.GetFontHeight(Clockwork.option:GetFont("esp_text"));
					else
						self:OverrideMainFont(false);
						height = draw.GetFontHeight(Clockwork.option:GetFont("main_text"));
					end;

					if (v2[5]) then
						local icon = "icon16/exclamation.png";
						local width = surface.GetTextSize(text);

						if (type(v2[5] == "string") and v2[5] != "") then
							icon = v2[5];
						end;

						surface.SetDrawColor(255, 255, 255, 255);
						surface.SetMaterial(Material(icon));
						surface.DrawTexturedRect(position.x - (width * 0.40) - height, position.y - height * 0.5, height, height);
					end;

					if (barValue and CW_CONVAR_ESPBARS:GetInt() == 1) then
						local barHeight = height * 0.80;
						local barColor = v2[4] or Clockwork:GetValueColor(barValue);
						local grayColor = Color( 150, 150, 150, 170);
						local progress = 100 * (barValue / maximum);

						if progress < 0 then
							progress = 0;
						end;

						draw.RoundedBox(6, position.x - 50, position.y - (barHeight * 0.45), 100, barHeight, grayColor);
						draw.RoundedBox(6, position.x - 50, position.y - (barHeight * 0.45), math.floor(progress), barHeight, barColor);
					end;

					if (type(text) == "string") then
						self:DrawSimpleText(text, position.x, position.y, color or colorWhite, 1, 1);
					end;

					position.y = position.y + height;
				end;
			end;			
		end;
	end;
end;

-- A function to draw a bar with a value and a maximum.
function Clockwork.kernel:DrawBar(x, y, width, height, color, text, value, maximum, flash, barInfo)
	local backgroundColor = Clockwork.option:GetColor("background");
	local foregroundColor = Clockwork.option:GetColor("foreground");
	local progressWidth = math.Clamp(((width - 4) / maximum) * value, 0, width - 4);
	local colorWhite = Clockwork.option:GetColor("white");
	local newBarInfo = {
		progressWidth = progressWidth,
		drawBackground = true,
		drawProgress = true,
		cornerSize = 2,
		maximum = maximum,
		height = height,
		width = width,
		color = color,
		value = value,
		flash = flash,
		text = text,
		x = x,
		y = y
	};
	
	if (barInfo) then
		for k, v in pairs(newBarInfo) do
			if (!barInfo[k]) then
				barInfo[k] = v;
			end;
		end;
	else
		barInfo = newBarInfo;
	end;
	
	if (!Clockwork.plugin:Call("PreDrawBar", barInfo)) then
		if (barInfo.drawBackground) then
			SMALL_BAR_BG:Draw(barInfo.x, barInfo.y, barInfo.width, barInfo.height, barInfo.cornerSize, backgroundColor, 50);
		end;
		
		if (barInfo.drawProgress) then
			render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.y + barInfo.height, true);
				SMALL_BAR_FG:Draw(barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4, 3, barInfo.color, 150);
			render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.height, false);
		end;
		
		if (barInfo.flash) then
			local alpha = math.Clamp(math.abs(math.sin(UnPredictedCurTime()) * 50), 0, 50);
			
			if (alpha > 0) then
				draw.RoundedBox(0, barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4,
				Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha));
			end;
		end;
	end;
		
	if (!Clockwork.plugin:Call("PostDrawBar", barInfo)) then
		if (barInfo.text and barInfo.text != "") then
			self:OverrideMainFont(Clockwork.option:GetFont("bar_text"));
			self:DrawSimpleText(
				barInfo.text, barInfo.x + (barInfo.width / 2), barInfo.y + (barInfo.height / 2),
				Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha), 1, 1

			);
			self:OverrideMainFont(false);
		end;
	end;
	
	return barInfo.y;
end;

-- A function to set the recognise menu.
function Clockwork.kernel:SetRecogniseMenu(menuPanel)
	Clockwork.RecogniseMenu = menuPanel;
	self:SetTitledMenu(menuPanel, "SELECT WHO CAN RECOGNISE YOU");
end;

-- A function to get the recognise menu.
function Clockwork.kernel:GetRecogniseMenu(menuPanel)
	return Clockwork.RecogniseMenu;
end;

-- A function to override the main font.
function Clockwork.kernel:OverrideMainFont(font)
	if (font) then
		if (!Clockwork.PreviousMainFont) then
			Clockwork.PreviousMainFont = Clockwork.option:GetFont("main_text");
		end;
		
		Clockwork.option:SetFont("main_text", font);
	elseif (Clockwork.PreviousMainFont) then
		Clockwork.option:SetFont("main_text", Clockwork.PreviousMainFont)
	end;
end;

-- A function to get the screen's center.
function Clockwork.kernel:GetScreenCenter()
	return ScrW() / 2, (ScrH() / 2) + 32;
end;

-- A function to draw some simple text.
function Clockwork.kernel:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless, shadowDepth)
	local mainTextFont = Clockwork.option:GetFont("main_text");
	local realX = math.Round(x);
	local realY = math.Round(y);
	
	if (!shadowless) then
		local outlineColor = Color(25, 25, 25, math.min(225, color.a));
		
		for i = 1, (shadowDepth or 1) do
			draw.SimpleText(text, mainTextFont, realX + -i, realY + -i, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + -i, realY + i, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + i, realY + -i, outlineColor, alignX, alignY);
			draw.SimpleText(text, mainTextFont, realX + i, realY + i, outlineColor, alignX, alignY);
		end;
	end;
	
	draw.SimpleText(text, mainTextFont, realX, realY, color, alignX, alignY);
	local width, height = self:GetCachedTextSize(mainTextFont, text);
	
	return realY + height + 2, width;
end;

-- A function to get the black fade alpha.
function Clockwork.kernel:GetBlackFadeAlpha()
	return Clockwork.BlackFadeIn or Clockwork.BlackFadeOut or 0;
end;

-- A function to get whether the screen is faded black.
function Clockwork.kernel:IsScreenFadedBlack()
	return (Clockwork.BlackFadeIn == 255);
end;

--[[ 
	A function to print colored text to the console.
	Sure, it's hacky, but Garry is being a douche.
--]]
function Clockwork.kernel:PrintColoredText(...)
	local currentColor = nil;
	local colorWhite = Clockwork.option:GetColor("white");
	local text = {};
	
	for k, v in pairs({...}) do
		if (type(v) == "Player") then
			text[#text + 1] = cwTeam.GetColor(v:Team());
			text[#text + 1] = v:Name();
		elseif (type(v) == "table") then
			currentColor = v;
		elseif (currentColor) then
			text[#text + 1] = currentColor;
			text[#text + 1] = v;
			currentColor = nil;
		else
			text[#text + 1] = colorWhite;
			text[#text + 1] = v;
		end;
	end;
	
	chat.ClockworkAddText(unpack(text));
end;

-- A function to get whether a custom crosshair is used.
function Clockwork.kernel:UsingCustomCrosshair()
	return Clockwork.CustomCrosshair;
end;

-- A function to get a cached text size.
function Clockwork.kernel:GetCachedTextSize(font, text)
	if (!Clockwork.CachedTextSizes) then
		Clockwork.CachedTextSizes = {};
	end;
	
	if (!Clockwork.CachedTextSizes[font]) then
		Clockwork.CachedTextSizes[font] = {};
	end;
	
	if (!Clockwork.CachedTextSizes[font][text]) then
		surface.SetFont(font);
		
		Clockwork.CachedTextSizes[font][text] = { surface.GetTextSize(text) };
	end;
	
	return Clockwork.CachedTextSizes[font][text][1], Clockwork.CachedTextSizes[font][text][2];
end;

-- A function to draw information at a position.
function Clockwork.kernel:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
	local mainTextFont = Clockwork.option:GetFont("main_text");
	local width, height = self:GetCachedTextSize(mainTextFont, text);
	
	if (width and height) then
		if (!bAlignLeft) then
			x = x - (width / 2);
		end;
		
		if (Callback) then
			x, y = Callback(x, y, width, height);
		end;
	
		return self:DrawSimpleText(text, x, y, Color(color.r, color.g, color.b, alpha or color.a), nil, nil, nil, shadowDepth);
	end;
end;

-- A function to get the player info box.
function Clockwork.kernel:GetPlayerInfoBox()
	return Clockwork.PlayerInfoBox;
end;

-- A function to draw the local player's information.
function Clockwork.kernel:DrawPlayerInfo(info)
	if (!Clockwork.plugin:Call("PlayerCanSeePlayerInfo")) then
		return;
	end;
	
	local foregroundColor = Clockwork.option:GetColor("foreground");
	local subInformation = Clockwork.PlayerInfoText.subText;
	local information = Clockwork.PlayerInfoText.text;
	local colorWhite = Clockwork.option:GetColor("white");
	local textWidth, textHeight = self:GetCachedTextSize(
		Clockwork.option:GetFont("player_info_text"), "U"
	);
	local width = Clockwork.PlayerInfoText.width;
	
	if (width < info.width) then
		width = info.width;
	elseif (width > width) then
		info.width = width;
	end;
	
	if (#information == 0 and #subInformation == 0) then
		return;
	end;
	
	local height = (textHeight * #information) + ((textHeight + 12) * #subInformation);
	local scrW = ScrW();
	local scrH = ScrH();
	
	if (#information > 0) then
		height = height + 8;
	end;
	
	local y = info.y + 8;
	local x = info.x - (width / 2);
	
	local boxInfo = {
		subInformation = subInformation,
		drawBackground = true,
		information = information,
		textHeight = textHeight,
		cornerSize = 2,
		textWidth = textWidth,
		height = height,
		width = width,
		x = x,
		y = y
	};
	
	if (!Clockwork.plugin:Call("PreDrawPlayerInfo", boxInfo, information, subInformation)) then
		self:OverrideMainFont(Clockwork.option:GetFont("player_info_text"));
		
		for k, v in pairs(subInformation) do
			x, y = self:DrawPlayerInfoSubBox(v.text, x, y, width, boxInfo);
		end;
		
		if (#information > 0 and boxInfo.drawBackground) then
			SLICED_PLAYER_INFO:Draw(x, y, width, height - ((textHeight + 12) * #subInformation), boxInfo.cornerSize);
		end;
		
		if (#information > 0) then
			x = x + 8
			y = y + 4;
		end;
			
		for k, v in pairs(information) do
			self:DrawInfo(v.text, x, y - 1, colorWhite, 255, true);
			y = y + textHeight;
		end;
		
		self:OverrideMainFont(false);
	end;
	
	Clockwork.plugin:Call("PostDrawPlayerInfo", boxInfo, information, subInformation);
	info.y = info.y + boxInfo.height + 12;
	
	return boxInfo;
end;

-- A function to get whether the info menu panel can be created.
function Clockwork.kernel:CanCreateInfoMenuPanel()
	return (table.Count(Clockwork.quickmenu.stored) > 0 or table.Count(Clockwork.quickmenu.categories) > 0);
end;
	
-- A function to create the info menu panel.
function Clockwork.kernel:CreateInfoMenuPanel(x, y, iMinimumWidth)
	if (IsValid(Clockwork.InfoMenuPanel)) then return; end;
	
	local options = {};
	
	for k, v in pairs(Clockwork.quickmenu.categories) do
		options[k] = {};
		
		for k2, v2 in pairs(v) do
			local info = v2.GetInfo();
			
			if (type(info) == "table") then
				options[k][k2] = info;
				options[k][k2].isArgTable = true;
			end;
		end;
	end;
	
	for k, v in pairs(Clockwork.quickmenu.stored) do
		local info = v.GetInfo();
		
		if (type(info) == "table") then
			options[k] = info;
			options[k].isArgTable = true;
		end;
	end;
	
	Clockwork.InfoMenuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
		if (arguments.name) then
			option = arguments.name;
		end;
		
		if (arguments.options) then
			local subMenu = menuPanel:AddSubMenu(option);
			
			for k, v in pairs(arguments.options) do
				local name = v;
				
				if (type(v) == "table") then
					name = v[1];
				end;
				
				subMenu:AddOption(name, function()
					if (arguments.Callback) then
						if (type(v) == "table") then
							arguments.Callback(v[2]);
						else
							arguments.Callback(v);
						end;
					end;
					
					self:RemoveActiveToolTip();
					self:CloseActiveDermaMenus();
				end);
			end;
			
			if (IsValid(subMenu)) then
				if (arguments.toolTip) then
					subMenu:SetToolTip(arguments.toolTip);
				end;
			end;
		else
			menuPanel:AddOption(option, function()
				if (arguments.Callback) then
					arguments.Callback();
				end;
				
				self:RemoveActiveToolTip();
				self:CloseActiveDermaMenus();
			end);
			
			menuPanel.Items = menuPanel:GetChildren();
			local panel = menuPanel.Items[#menuPanel.Items];
			
			if (IsValid(panel) and arguments.toolTip) then
				panel:SetToolTip(arguments.toolTip);
			end;
		end;
	end, iMinimumWidth);
	
	if (IsValid(Clockwork.InfoMenuPanel)) then
		Clockwork.InfoMenuPanel:SetVisible(false);
		Clockwork.InfoMenuPanel:SetSize(iMinimumWidth, Clockwork.InfoMenuPanel:GetTall());
		Clockwork.InfoMenuPanel:SetPos(x, y);
	end;
end;

-- A function to get the ragdoll eye angles.
function Clockwork.kernel:GetRagdollEyeAngles()
	if (!Clockwork.RagdollEyeAngles) then
		Clockwork.RagdollEyeAngles = Angle(0, 0, 0);
	end;
	
	return Clockwork.RagdollEyeAngles;
end;

-- A function to draw a gradient.
function Clockwork.kernel:DrawGradient(gradientType, x, y, width, height, color)
	if (!Clockwork.Gradients[gradientType]) then
		return;
	end;
	
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	surface.SetTexture(Clockwork.Gradients[gradientType]);
	surface.DrawTexturedRect(x, y, width, height);
end;

-- A function to draw a simple gradient box.
function Clockwork.kernel:DrawSimpleGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
	local gradientAlpha = math.min(color.a, maxAlpha or 100);
	
	draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75));
	
	if (x + cornerSize < x + width and y + cornerSize < y + height) then
		surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha);
		surface.SetMaterial(self:GetGradientTexture());
		surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2));
	end;
end;

-- A function to draw a textured gradient.
function Clockwork.kernel:DrawTexturedGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
	local gradientAlpha = math.min(color.a, maxAlpha or 100);

	draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75));

	if (x + cornerSize < x + width and y + cornerSize < y + height) then
		surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha);
		surface.SetMaterial(self:GetGradientTexture());
		surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2));
	end;
end;

-- A function to draw a player information sub box.
function Clockwork.kernel:DrawPlayerInfoSubBox(text, x, y, width, boxInfo)
	local foregroundColor = Clockwork.option:GetColor("foreground");
	local colorInfo = Clockwork.option:GetColor("information");
	local boxHeight = boxInfo.textHeight + 8;
	
	if (boxInfo.drawBackground) then
		SLICED_PLAYER_INFO:Draw(x, y, width, boxHeight, 4, foregroundColor, 50);
	end;
	
	self:DrawInfo(text, x + 8, y + (boxHeight / 2), colorInfo, 255, true,
		function(x, y, width, height)
			return x, y - (height / 2);
		end
	);
	
	return x, y + boxHeight + 4;
end;

-- A function to handle an item's spawn icon click.
function Clockwork.kernel:HandleItemSpawnIconClick(itemTable, spawnIcon, Callback)
	local customFunctions = itemTable("customFunctions");
	local itemFunctions = {};
	local destroyName = Clockwork.option:GetKey("name_destroy");
	local dropName = Clockwork.option:GetKey("name_drop");
	local useName = Clockwork.option:GetKey("name_use");
	
	if (itemTable.OnUse) then
		itemFunctions[#itemFunctions + 1] = itemTable("useText", useName);
	end;
	
	if (itemTable.OnDrop) then
		itemFunctions[#itemFunctions + 1] = itemTable("dropText", dropName);
	end;
	
	if (itemTable.OnDestroy) then
		itemFunctions[#itemFunctions + 1] = itemTable("destroyText", destroyName);
	end;
	
	if (customFunctions) then
		for k, v in pairs(customFunctions) do
			itemFunctions[#itemFunctions + 1] = v;
		end;
	end;

	if (itemTable.GetOptions) then
		local options = itemTable:GetOptions(nil, nil);
		for k, v in pairs(options) do
			itemFunctions[#itemFunctions + 1] = {title = k, name = v};
		end
	end
	
	if (itemTable.OnEditFunctions) then
		itemTable:OnEditFunctions(itemFunctions);
	end;
	
	Clockwork.plugin:Call("PlayerAdjustItemFunctions", itemTable, itemFunctions);
	self:ValidateTableKeys(itemFunctions);
	
	table.sort(itemFunctions, function(a, b) return ((type(a) == "table" and a.title) or a) < ((type(b) == "table" and b.title) or b); end);
	if (#itemFunctions == 0 and !Callback) then return; end;
	
	local options = {};
	
	if (itemTable.GetEntityMenuOptions) then
		itemTable:GetEntityMenuOptions(nil, options);
	end;

	local itemMenu = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
		menuPanel:AddOption(option, function()
			if (type(arguments) == "table" and arguments.isArgTable) then
				if (arguments.Callback) then
					arguments.Callback();
				end;
			elseif (arguments == "function") then
				arguments();
			end;
			
			timer.Simple(FrameTime(), function()
				self:RemoveActiveToolTip();
			end);
		end);
		
		menuPanel.Items = menuPanel:GetChildren();
		local panel = menuPanel.Items[#menuPanel.Items];
		
		if (IsValid(panel)) then
			if (type(arguments) == "table") then
				if (arguments.toolTip) then
					self:CreateMarkupToolTip(panel);
					panel:SetMarkupToolTip(arguments.toolTip);
				end;
			end;
		end;
	end, nil, true);
	
	if (Callback) then Callback(itemMenu); end;
	
	itemMenu:SetMinimumWidth(100);
	Clockwork.plugin:Call("PlayerAdjustItemMenu", itemTable, itemMenu, itemFunctions);
		
	for k, v in pairs(itemFunctions) do
		local useText = itemTable("useText", "Use");
		local dropText = itemTable("dropText", "Drop");
		local destroyText = itemTable("destroyText", "Destroy");
		
		if ((!useText and v == "Use") or (useText and v == useText)) then
			itemMenu:AddOption(v, function()
				if (itemTable) then
					if (itemTable.OnHandleUse) then
						itemTable:OnHandleUse(function()
							self:RunCommand(
								"InvAction", "use", itemTable("uniqueID"), itemTable("itemID")
							);
						end);
					else
						self:RunCommand(
							"InvAction", "use", itemTable("uniqueID"), itemTable("itemID")
						);
					end;
				end;
			end);
		elseif ((!dropText and v == "Drop") or (dropText and v == dropText)) then
			itemMenu:AddOption(v, function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", "drop", itemTable("uniqueID"), itemTable("itemID")
					);
				end;
			end);
		elseif ((!destroyText and v == "Destroy") or (destroyText and v == destroyText)) then
			local subMenu = itemMenu:AddSubMenu(v);
			
			subMenu:AddOption("Yes", function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", "destroy", itemTable("uniqueID"), itemTable("itemID")
					);
				end;
			end);
			
			subMenu:AddOption("No", function() end);
		elseif (type(v) == "table") then
			itemMenu:AddOption(v.title, function()
				if (itemTable.HandleOptions) then
					local transmit, data = itemTable:HandleOptions(v.name);
					if (transmit) then
						Clockwork.datastream:Start("MenuOption", {option = v.name, data = data, item = itemTable("itemID")});
					end;
				end;
			end);
		else
			if (itemTable.OnCustomFunction) then
				itemTable:OnCustomFunction(v);
			end;
			
			itemMenu:AddOption(v, function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", v, itemTable("uniqueID"), itemTable("itemID")
					);
				end;
			end);
		end;
	end;
	
	itemMenu:Open();
end;

-- A function to handle an item's spawn icon right click.
function Clockwork.kernel:HandleItemSpawnIconRightClick(itemTable, spawnIcon)
	if (itemTable.OnHandleRightClick) then
		local functionName = itemTable:OnHandleRightClick();
		
		if (functionName and functionName != "Use") then
			local customFunctions = itemTable("customFunctions");
			
			if (customFunctions and table.HasValue(customFunctions, functionName)) then
				if (itemTable.OnCustomFunction) then
					itemTable:OnCustomFunction(v);
				end;
			end;
			
			self:RunCommand(
				"InvAction", string.lower(functionName), itemTable("uniqueID"), itemTable("itemID")
			);
			return;
		end;
	end;
	
	if (itemTable.OnUse) then
		if (itemTable.OnHandleUse) then
			itemTable:OnHandleUse(function()
				self:RunCommand("InvAction", "use", itemTable("uniqueID"), itemTable("itemID"));
			end);
		else
			self:RunCommand("InvAction", "use", itemTable("uniqueID"), itemTable("itemID"));
		end;
	end;
end;

-- A function to set a panel's perform layout callback.
function Clockwork.kernel:SetOnLayoutCallback(target, Callback)
	if (target.PerformLayout) then
		target.OldPerformLayout = target.PerformLayout;
		
		-- Called when the panel's layout is performed.
		function target.PerformLayout()
			target:OldPerformLayout(); Callback(target);
		end;
	end;
end;

-- A function to set the active titled DMenu.
function Clockwork.kernel:SetTitledMenu(menuPanel, title)
	Clockwork.TitledMenu = {
		menuPanel = menuPanel,
		title = title
	};
end;

-- A function to add a markup line.
function Clockwork.kernel:AddMarkupLine(markupText, text, color)
	if (markupText != "") then
		markupText = markupText.."\n";
	end;
	
	return markupText..self:MarkupTextWithColor(text, color);
end;

-- A function to draw a markup tool tip.
function Clockwork.kernel:DrawMarkupToolTip(markupObject, x, y, alpha)
	local height = markupObject:GetHeight();
	local width = markupObject:GetWidth();
	
	if (x - (width / 2) > 0) then
		x = x - (width / 2);
	end;
	
	if (x + width > ScrW()) then
		x = x - width - 8;
	end;
	
	if (y + (height + 8) > ScrH()) then
		y = y - height - 8;
	end;
	
	self:DrawSimpleGradientBox(2, x - 8, y - 8, width + 16, height + 16, Color(50, 50, 50, alpha));
	markupObject:Draw(x, y, nil, nil, alpha);
end;
	
-- A function to override a markup object's draw function.
function Clockwork.kernel:OverrideMarkupDraw(markupObject, sCustomFont)
	function markupObject:Draw(xOffset, yOffset, hAlign, vAlign, alphaOverride)
		for k, v in pairs(self.blocks) do
			if (!v.colour) then
				debug.Trace();
				return;
			end;
		
			local alpha = v.colour.a or 255;
			local y = yOffset + (v.height - v.thisY) + v.offset.y;
			local x = xOffset;
			
			if (hAlign == TEXT_ALIGN_CENTER) then
				x = x - (self.totalWidth / 2);
			elseif (hAlign == TEXT_ALIGN_RIGHT) then
				x = x - self.totalWidth;
			end;
			
			x = x + v.offset.x;
			
			if (hAlign == TEXT_ALIGN_CENTER) then
				y = y - (self.totalHeight / 2);
			elseif (hAlign == TEXT_ALIGN_BOTTOM) then
				y = y - self.totalHeight;
			end;
			
			if (alphaOverride) then
				alpha = alphaOverride;
			end;
			
			Clockwork.kernel:OverrideMainFont(sCustomFont or v.font);
				Clockwork.kernel:DrawSimpleText(v.text, x, y, Color(v.colour.r, v.colour.g, v.colour.b, alpha));
			Clockwork.kernel:OverrideMainFont(false);
		end;
	end;
end;

-- A function to get the active markup tool tip.
function Clockwork.kernel:GetActiveMarkupToolTip()
	return Clockwork.MarkupToolTip;
end;

-- A function to get markup from a color.
function Clockwork.kernel:ColorToMarkup(color)
	return "<color="..math.ceil(color.r)..","..math.ceil(color.g)..","..math.ceil(color.b)..">";
end;

-- A function to markup text with a color.
function Clockwork.kernel:MarkupTextWithColor(text, color, scale)
	local fontName = Clockwork.fonts:GetMultiplied("cwTooltip", scale or 1);
	local finalText = text;
	
	if (color) then
		finalText = self:ColorToMarkup(color)..text.."</color>";
	end;
	
	finalText = "<font="..fontName..">"..finalText.."</font>";
	
	return finalText;
end;

-- A function to create a markup tool tip.
function Clockwork.kernel:CreateMarkupToolTip(panel)
	panel.OldCursorExited = panel.OnCursorExited;
	panel.OldCursorEntered = panel.OnCursorEntered;
	
	-- Called when the cursor enters the panel.
	function panel.OnCursorEntered(panel, ...)
		if (panel.OldCursorEntered) then
			panel:OldCursorEntered(...);
		end;
		
		Clockwork.MarkupToolTip = panel;
	end;

	-- Called when the cursor exits the panel.
	function panel.OnCursorExited(panel, ...)
		if (panel.OldCursorExited) then
			panel:OldCursorExited(...);
		end;
		
		if (Clockwork.MarkupToolTip == panel) then
			Clockwork.MarkupToolTip = nil;
		end;
	end;
	
	-- A function to set the panel's markup tool tip.
	function panel.SetMarkupToolTip(panel, text)
		if (!panel.MarkupToolTip or panel.MarkupToolTip.text != text) then
			panel.MarkupToolTip = {
				object = markup.Parse(text, ScrW() * 0.25),
				text = text
			};
			
			self:OverrideMarkupDraw(panel.MarkupToolTip.object);
		end;
	end;
	
	-- A function to get the panel's markup tool tip.
	function panel.GetMarkupToolTip(panel)
		return panel.MarkupToolTip;
	end;
	
	-- A function to set the panel's tool tip.
	function panel.SetToolTip(panel, toolTip)
		panel:SetMarkupToolTip(toolTip);
	end;
	
	return panel;
end;

-- A function to create a custom category panel.
function Clockwork.kernel:CreateCustomCategoryPanel(categoryName, parent)
	if (!parent.CategoryList) then
		parent.CategoryList = {};
	end;
	
	local collapsibleCategory = vgui.Create("DCollapsibleCategory", parent);
		collapsibleCategory:SetExpanded(true);
		collapsibleCategory:SetPadding(2);
		collapsibleCategory:SetLabel(categoryName);
	parent.CategoryList[#parent.CategoryList + 1] = collapsibleCategory;
	
	return collapsibleCategory;
end;

-- A function to draw the armor bar.
function Clockwork.kernel:DrawArmorBar()
	local armor = math.Clamp(Clockwork.Client:Armor(), 0, Clockwork.Client:GetMaxArmor());
	
	if (!self.armor) then
		self.armor = armor;
	else
		self.armor = math.Approach(self.armor, armor, 1);
	end;
		
	if (armor > 0) then
		Clockwork.bars:Add("ARMOR", Color(139, 174, 179, 255), "", self.armor, Clockwork.Client:GetMaxArmor(), self.health < 10, 1);
	end;
end;

-- A function to draw the health bar.
function Clockwork.kernel:DrawHealthBar()
	local health = math.Clamp(Clockwork.Client:Health(), 0, Clockwork.Client:GetMaxHealth());
	
	if (!self.armor) then
		self.health = health;
	else
		self.health = math.Approach(self.health, health, 1);
	end;
	
	if (health > 0) then
		Clockwork.bars:Add("HEALTH", Color(179, 46, 49, 255), "", self.health, Clockwork.Client:GetMaxHealth(), self.health < 10, 2);
	end;
end;

-- A function to remove the active tool tip.
function Clockwork.kernel:RemoveActiveToolTip()
	ChangeTooltip();
end;

-- A function to close active Derma menus.
function Clockwork.kernel:CloseActiveDermaMenus()
	CloseDermaMenus();
end;

-- A function to register a background blur.
function Clockwork.kernel:RegisterBackgroundBlur(panel, fCreateTime)
	Clockwork.BackgroundBlurs[panel] = fCreateTime or SysTime();
end;

-- A function to remove a background blur.
function Clockwork.kernel:RemoveBackgroundBlur(panel)
	Clockwork.BackgroundBlurs[panel] = nil;
end;

-- A function to draw the background blurs.
function Clockwork.kernel:DrawBackgroundBlurs()
	local scrH, scrW = ScrH(), ScrW();
	local sysTime = SysTime();
	
	for k, v in pairs(Clockwork.BackgroundBlurs) do
		if (type(k) == "string" or (IsValid(k) and k:IsVisible())) then
			local fraction = math.Clamp((sysTime - v) / 1, 0, 1);
			local x, y = 0, 0;
			
			surface.SetMaterial(Clockwork.ScreenBlur);
			surface.SetDrawColor(255, 255, 255, 255);
			
			for i = 0.33, 1, 0.33 do
				Clockwork.ScreenBlur:SetFloat("$blur", fraction * 5 * i);
				Clockwork.ScreenBlur:Recompute();
				
				if (render) then render.UpdateScreenEffectTexture();end;
				
				surface.DrawTexturedRect(x, y, scrW, scrH);
			end;
			
			surface.SetDrawColor(10, 10, 10, 200 * fraction);
			surface.DrawRect(x, y, scrW, scrH);
		end;
	end;
end;

-- A function to get the notice panel.
function Clockwork.kernel:GetNoticePanel()
	if (IsValid(Clockwork.NoticePanel) and Clockwork.NoticePanel:IsVisible()) then
		return Clockwork.NoticePanel;
	end;
end;

-- A function to set the notice panel.
function Clockwork.kernel:SetNoticePanel(noticePanel)
	Clockwork.NoticePanel = noticePanel;
end;

-- A function to add some cinematic text.
function Clockwork.kernel:AddCinematicText(text, color, barLength, hangTime, font, bThisOnly)
	local colorWhite = Clockwork.option:GetColor("white");
	local cinematicTable = {
		barLength = barLength or (ScrH() * 8),
		hangTime = hangTime or 3,
		color = color or colorWhite,
		font = font,
		text = text,
		add = 0
	};
	
	if (bThisOnly) then
		Clockwork.Cinematics[1] = cinematicTable;
	else
		Clockwork.Cinematics[#Clockwork.Cinematics + 1] = cinematicTable;
	end;
end;

-- A function to add a notice.
function Clockwork.kernel:AddNotify(text, class, length)
	if (class != NOTIFY_HINT or string.utf8sub(text, 1, 6) != "#Hint_") then
		if (Clockwork.BaseClass.AddNotify) then
			Clockwork.BaseClass:AddNotify(text, class, length);
		end;
	end;
end;

-- A function to get whether the local player is using the tool gun.
function Clockwork.kernel:IsUsingTool()
	if (IsValid(Clockwork.Client:GetActiveWeapon())
	and Clockwork.Client:GetActiveWeapon():GetClass() == "gmod_tool") then
		return true;
	else
		return false;
	end;
end;

-- A function to get whether the local player is using the camera.
function Clockwork.kernel:IsUsingCamera()
	if (IsValid(Clockwork.Client:GetActiveWeapon())
	and Clockwork.Client:GetActiveWeapon():GetClass() == "gmod_camera") then
		return true;
	else
		return false;
	end;
end;

-- A function to get the target ID data.
function Clockwork.kernel:GetTargetIDData()
	return Clockwork.TargetIDData;
end;

-- A function to calculate the screen fading.
function Clockwork.kernel:CalculateScreenFading()
	if (Clockwork.plugin:Call("ShouldPlayerScreenFadeBlack")) then
		if (!Clockwork.BlackFadeIn) then
			if (Clockwork.BlackFadeOut) then
				Clockwork.BlackFadeIn = Clockwork.BlackFadeOut;
			else
				Clockwork.BlackFadeIn = 0;
			end;
		end;
		
		Clockwork.BlackFadeIn = math.Clamp(Clockwork.BlackFadeIn + (FrameTime() * 20), 0, 255);
		Clockwork.BlackFadeOut = nil;
		self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, Clockwork.BlackFadeIn));
	else
		if (Clockwork.BlackFadeIn) then
			Clockwork.BlackFadeOut = Clockwork.BlackFadeIn;
		end;
		
		Clockwork.BlackFadeIn = nil;
		
		if (Clockwork.BlackFadeOut) then
			Clockwork.BlackFadeOut = math.Clamp(Clockwork.BlackFadeOut - (FrameTime() * 40), 0, 255);
			self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, Clockwork.BlackFadeOut));
			
			if (Clockwork.BlackFadeOut == 0) then
				Clockwork.BlackFadeOut = nil;
			end;
		end;
	end;
end;
	
-- A function to draw a cinematic.
function Clockwork.kernel:DrawCinematic(cinematicTable, curTime)
	local maxBarLength = cinematicTable.barLength or (ScrH() / 13);
	local font = cinematicTable.font or Clockwork.option:GetFont("cinematic_text");
	
	if (cinematicTable.goBack and curTime > cinematicTable.goBack) then
		cinematicTable.add = math.Clamp(cinematicTable.add - 2, 0, maxBarLength);
		
		if (cinematicTable.add == 0) then
			table.remove(Clockwork.Cinematics, 1);
			cinematicTable = nil;
		end;
	else
		cinematicTable.add = math.Clamp(cinematicTable.add + 1, 0, maxBarLength);
		
		if (cinematicTable.add == maxBarLength and !cinematicTable.goBack) then
			cinematicTable.goBack = curTime + cinematicTable.hangTime;
		end;
	end;
	
	if (cinematicTable) then
		draw.RoundedBox(0, 0, -maxBarLength + cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255));
		draw.RoundedBox(0, 0, ScrH() - cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255));
		draw.SimpleText(cinematicTable.text, font, ScrW() / 2, (ScrH() - cinematicTable.add) + (maxBarLength / 2), cinematicTable.color, 1, 1);
	end
end;

-- A function to draw the cinematic introduction.
function Clockwork.kernel:DrawCinematicIntro(curTime)
	local cinematicInfo = Clockwork.plugin:Call("GetCinematicIntroInfo");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (cinematicInfo) then
		if (Clockwork.CinematicScreenAlpha and Clockwork.CinematicScreenTarget) then
			Clockwork.CinematicScreenAlpha = math.Approach(Clockwork.CinematicScreenAlpha, Clockwork.CinematicScreenTarget, 1);
			
			if (Clockwork.CinematicScreenAlpha == Clockwork.CinematicScreenTarget) then
				if (Clockwork.CinematicScreenTarget == 255) then
					if (!Clockwork.CinematicScreenGoBack) then
						Clockwork.CinematicScreenGoBack = curTime + 2.5;
						Clockwork.option:PlaySound("rollover");
					end;
				else
					Clockwork.CinematicScreenDone = true;
				end;
			end;
			
			if (Clockwork.CinematicScreenGoBack and curTime >= Clockwork.CinematicScreenGoBack) then
				Clockwork.CinematicScreenGoBack = nil;
				Clockwork.CinematicScreenTarget = 0;
				Clockwork.option:PlaySound("rollover");
			end;
			
			if (!Clockwork.CinematicScreenDone and cinematicInfo.credits) then
				local alpha = math.Clamp(Clockwork.CinematicScreenAlpha, 0, 255);
				
				self:OverrideMainFont(Clockwork.option:GetFont("intro_text_tiny"));
					self:DrawSimpleText(cinematicInfo.credits, ScrW() / 8, ScrH() * 0.75, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha));
				self:OverrideMainFont(false);
			end;
		else
			Clockwork.CinematicScreenAlpha = 0;
			Clockwork.CinematicScreenTarget = 255;
			Clockwork.option:PlaySound("rollover");
		end;
	end;
end;

-- A function to draw the cinematic introduction bars.
function Clockwork.kernel:DrawCinematicIntroBars()
	if (Clockwork.config:Get("draw_intro_bars"):Get()) then
		local maxBarLength = ScrH() / 8;
		
		if (!Clockwork.CinematicBarsTarget and !Clockwork.CinematicBarsAlpha) then
			Clockwork.CinematicBarsAlpha = 0;
			Clockwork.CinematicBarsTarget = 255;
			Clockwork.option:PlaySound("rollover");
		end;
		
		Clockwork.CinematicBarsAlpha = math.Approach(Clockwork.CinematicBarsAlpha, Clockwork.CinematicBarsTarget, 1);
		
		if (Clockwork.CinematicScreenDone) then
			if (Clockwork.CinematicScreenBarLength != 0) then
				Clockwork.CinematicScreenBarLength = math.Clamp((maxBarLength / 255) * Clockwork.CinematicBarsAlpha, 0, maxBarLength);
			end;
			
			if (Clockwork.CinematicBarsTarget != 0) then
				Clockwork.CinematicBarsTarget = 0;
				Clockwork.option:PlaySound("rollover");
			end;
			
			if (Clockwork.CinematicBarsAlpha == 0) then
				Clockwork.CinematicBarsDrawn = true;
			end;
		elseif (Clockwork.CinematicScreenBarLength != maxBarLength) then
			if (!Clockwork.IntroBarsMultiplier) then
				Clockwork.IntroBarsMultiplier = 1;
			else
				Clockwork.IntroBarsMultiplier = math.Clamp(Clockwork.IntroBarsMultiplier + (FrameTime() * 8), 1, 12);
			end;
			
			Clockwork.CinematicScreenBarLength = math.Clamp((maxBarLength / 255) * math.Clamp(Clockwork.CinematicBarsAlpha * Clockwork.IntroBarsMultiplier, 0, 255), 0, maxBarLength);
		end;
		
		draw.RoundedBox(0, 0, 0, ScrW(), Clockwork.CinematicScreenBarLength, Color(0, 0, 0, 255));
		draw.RoundedBox(0, 0, ScrH() - Clockwork.CinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255));
	end;
end;
	
-- A function to draw the cinematic info.
function Clockwork.kernel:DrawCinematicInfo()
	if (!Clockwork.CinematicInfoAlpha and !Clockwork.CinematicInfoSlide) then
		Clockwork.CinematicInfoAlpha = 255;
		Clockwork.CinematicInfoSlide = 0;
	end;
	
	Clockwork.CinematicInfoSlide = math.Approach(Clockwork.CinematicInfoSlide, 255, 1);
	
	if (Clockwork.CinematicScreenAlpha and Clockwork.CinematicScreenTarget) then
		Clockwork.CinematicInfoAlpha = math.Approach(Clockwork.CinematicInfoAlpha, 0, 1);
		
		if (Clockwork.CinematicInfoAlpha == 0) then
			Clockwork.CinematicInfoDrawn = true;
		end;
	end;
	
	local cinematicInfo = Clockwork.plugin:Call("GetCinematicIntroInfo");
	local colorWhite = Clockwork.option:GetColor("white");
	local colorInfo = Clockwork.option:GetColor("information");
	
	if (cinematicInfo) then
		local screenHeight = ScrH();
		local screenWidth = ScrW();
		local textPosY = screenHeight * 0.3;
		local textPosX = screenWidth * 0.3;
		
		if (cinematicInfo.title) then
			local cinematicInfoTitle = string.upper(cinematicInfo.title);
			local cinematicIntroText = string.upper(cinematicInfo.text);
			local introTextSmallFont = Clockwork.option:GetFont("intro_text_small");
			local introTextBigFont = Clockwork.option:GetFont("intro_text_big");
			local textWidth, textHeight = self:GetCachedTextSize(introTextBigFont, cinematicInfoTitle);
			local boxAlpha = math.min(Clockwork.CinematicInfoAlpha, 150);
			
			if (cinematicInfo.text) then
				local smallTextWidth, smallTextHeight = self:GetCachedTextSize(introTextSmallFont, cinematicIntroText);
				self:DrawGradient(
					GRADIENT_RIGHT, 0, textPosY - 32, screenWidth, textHeight + smallTextHeight + 64, Color(100, 100, 100, boxAlpha)
				);
			else
				self:DrawGradient(
					GRADIENT_RIGHT, 0, textPosY - 32, screenWidth, textHeight + 64, Color(100, 100, 100, boxAlpha)
				);
			end;
			
			self:OverrideMainFont(introTextBigFont);
				self:DrawSimpleText(cinematicInfoTitle, textPosX, textPosY, Color(colorInfo.r, colorInfo.g, colorInfo.b, Clockwork.CinematicInfoAlpha));
			self:OverrideMainFont(false);
			
			if (cinematicInfo.text) then
				self:OverrideMainFont(introTextSmallFont);
					self:DrawSimpleText(cinematicIntroText, textPosX, textPosY + textHeight + 8, Color(colorWhite.r, colorWhite.g, colorWhite.b, Clockwork.CinematicInfoAlpha));
				self:OverrideMainFont(false);
			end;
		elseif (cinematicInfo.text) then
			self:OverrideMainFont(introTextSmallFont);
				self:DrawSimpleText(cinematicIntroText, textPosX, textPosY, Color(colorWhite.r, colorWhite.g, colorWhite.b, Clockwork.CinematicInfoAlpha));
			self:OverrideMainFont(false);
		end;
	end;
end;

-- A function to draw some door text.
function Clockwork.kernel:DrawDoorText(entity, eyePos, eyeAngles, font, nameColor, textColor)
	local entityColor = entity:GetColor();
	
	if (entityColor.a <= 0 or entity:IsEffectActive(EF_NODRAW)) then
		return;
	end;
	
	local doorData = Clockwork.entity:CalculateDoorTextPosition(entity);
	
	if (!doorData.hitWorld) then
		local frontY = -26;
		local backY = -26;
		local alpha = self:CalculateAlphaFromDistance(256, eyePos, entity:GetPos());
		
		if (alpha <= 0) then
			return;
		end;
		
		local owner = Clockwork.entity:GetOwner(entity);
		local name = Clockwork.plugin:Call("GetDoorInfo", entity, DOOR_INFO_NAME);
		local text = Clockwork.plugin:Call("GetDoorInfo", entity, DOOR_INFO_TEXT);
		
		if (name or text) then
			local nameWidth, nameHeight = self:GetCachedTextSize(font, name or "");
			local textWidth, textHeight = self:GetCachedTextSize(font, text or "");
			local longWidth = nameWidth;
			local boxAlpha = math.min(alpha, 150);
			
			if (textWidth > longWidth) then
				longWidth = textWidth;
			end;
			
			local scale = math.abs((doorData.width * 0.75) / longWidth);
			local nameScale = math.min(scale, 0.05);
			local textScale = math.min(scale, 0.03);
			local longHeight = nameHeight + textHeight + 8;
			
			cam.Start3D2D(doorData.position, doorData.angles, nameScale);
				self:DrawGradient(GRADIENT_CENTER, -(longWidth / 2) - 128, frontY - 8, longWidth + 256, longHeight, Color(100, 100, 100, boxAlpha));
			cam.End3D2D();
			
			cam.Start3D2D(doorData.positionBack, doorData.anglesBack, nameScale);
				self:DrawGradient(GRADIENT_CENTER, -(longWidth / 2) - 128, frontY - 8, longWidth + 256, longHeight, Color(100, 100, 100, boxAlpha));
			cam.End3D2D();
			
			if (name) then
				if (!text or text == "") then
					nameColor = textColor or nameColor; 
				end;
				
				cam.Start3D2D(doorData.position, doorData.angles, nameScale);
					self:OverrideMainFont(font);
						frontY = self:DrawInfo(name, 0, frontY, nameColor, alpha, nil, nil, 3);
					self:OverrideMainFont(false);
				cam.End3D2D();
				
				cam.Start3D2D(doorData.positionBack, doorData.anglesBack, nameScale);
					self:OverrideMainFont(font);
						backY = self:DrawInfo(name, 0, backY, nameColor, alpha, nil, nil, 3);
					self:OverrideMainFont(false);
				cam.End3D2D();
			end;
			
			if (text) then
				cam.Start3D2D(doorData.position, doorData.angles, textScale);
					self:OverrideMainFont(font);
						frontY = self:DrawInfo(text, 0, frontY, textColor, alpha, nil, nil, 3);
					self:OverrideMainFont(false);
				cam.End3D2D();
				
				cam.Start3D2D(doorData.positionBack, doorData.anglesBack, textScale);
					self:OverrideMainFont(font);
						backY = self:DrawInfo(text, 0, backY, textColor, alpha, nil, nil, 3);
					self:OverrideMainFont(false);
				cam.End3D2D();
			end;
		end;
	end;
end;
	
-- A function to get whether the local player's character screen is open.
function Clockwork.kernel:IsCharacterScreenOpen(isVisible)
	if (Clockwork.character:IsPanelOpen()) then
		local panel = Clockwork.character:GetPanel();
			
		if (isVisible) then
			if (panel) then
				return panel:IsVisible();
			end;
		else
			return panel != nil;
		end;
	end;
end;
	
-- A function to save schema data.
function Clockwork.kernel:SaveSchemaData(fileName, data)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
		return;
	end;	
	
	cwFile.Write("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", self:Serialize(data));
end;

-- A function to delete schema data.
function Clockwork.kernel:DeleteSchemaData(fileName)
	cwFile.Delete("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt");
end;

-- A function to check if schema data exists.
function Clockwork.kernel:SchemaDataExists(fileName)
	return cwFile.Exists("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA");
end;
	
-- A function to find schema data in a directory.
function Clockwork.kernel:FindSchemaDataInDir(directory)
	return cwFile.Find("clockwork/schemas/"..self:GetSchemaFolder().."/"..directory, "LUA", "namedesc");
end;

-- A function to restore schema data.
function Clockwork.kernel:RestoreSchemaData(fileName, failSafe)
	if (self:SchemaDataExists(fileName)) then
		local data = cwFile.Read("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA");
		
		if (data) then
			local bSuccess, value = pcall(util.JSONToTable, data);
			
			if (bSuccess and value != nil) then
				return value;
			else
				local bSuccess, value = pcall(self.Deserialize, self, data);
				
				if (bSuccess and value != nil) then
					return value;
				else
					MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] '"..fileName.."' schema data has failed to restore.\n"..value.."\n");
					
					self:DeleteSchemaData(fileName);
				end;
			end;
		end;
	end;
		
	if (failSafe != nil) then
		return failSafe;
	else
		return {};
	end;
end;

-- A function to restore Clockwork data.
function Clockwork.kernel:RestoreClockworkData(fileName, failSafe)
	if (self:ClockworkDataExists(fileName)) then
		local data = cwFile.Read("clockwork/"..fileName..".txt", "DATA");
			
		if (data) then
			local success, value = pcall(util.JSONToTable, data);
				
			if (success and value != nil) then
				return value;
			else
				local bSuccess, value = pcall(self.Deserialize, self, data);
					
				if (bSuccess and value != nil) then
					return value;
				else
					MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] '"..fileName.."' clockwork data has failed to restore.\n"..value.."\n");
					
					self:DeleteClockworkData(fileName);
				end;
			end;
		end;
	end;
		
	if (failSafe != nil) then
		return failSafe;
	else
		return {};
	end;
end;

-- A function to save Clockwork data.
function Clockwork.kernel:SaveClockworkData(fileName, data)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
		
		return;
	end;	

	cwFile.Write("clockwork/"..fileName..".txt", self:Serialize(data));
end;

-- A function to check if Clockwork data exists.
function Clockwork.kernel:ClockworkDataExists(fileName)
	return cwFile.Exists("clockwork/"..fileName..".txt", "DATA");
end;

-- A function to delete Clockwork data.
function Clockwork.kernel:DeleteClockworkData(fileName)
	cwFile.Delete("clockwork/"..fileName..".txt");
end;
	
-- A function to run a Clockwork command.
function Clockwork.kernel:RunCommand(command, ...)
	RunConsoleCommand("cwCmd", command, ...);
end;
	
-- A function to get whether the local player is choosing a character.
function Clockwork.kernel:IsChoosingCharacter()
	if (Clockwork.character:GetPanel()) then
		return Clockwork.character:IsPanelOpen();
	else
		return true;
	end;
end;
	
-- A function to include the schema.
function Clockwork.kernel:IncludeSchema()
	local schemaFolder = self:GetSchemaFolder();
		
	if (schemaFolder and type(schemaFolder) == "string") then
		Clockwork.plugin:Include(schemaFolder.."/schema", true);
	end;
end;

concommand.Add("cwSay", function(player, command, arguments)
	return Clockwork.datastream:Start("PlayerSay", table.concat(arguments, " "));
end);

concommand.Add("cwLua", function(player, command, arguments)
	if (player:IsSuperAdmin()) then
		RunString(table.concat(arguments, " "));
		return;
	end;
	
	print("You do not have access to this command, "..player:Name()..".");
end);

local entityMeta = FindMetaTable("Entity");
local weaponMeta = FindMetaTable("Weapon");
local playerMeta = FindMetaTable("Player");

entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets;
weaponMeta.OldGetPrintName = weaponMeta.OldGetPrintName or weaponMeta.GetPrintName;
playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		Clockwork.plugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	Clockwork.plugin:Call("EntityFireBullets", self, bulletInfo);
	return self:ClockworkFireBullets(bulletInfo);
end;

-- A function to get a weapon's print name.
function weaponMeta:GetPrintName()
	local itemTable = Clockwork.item:GetByWeapon(self);
	
	if (itemTable) then
		return itemTable("name");
	else
		return self:OldGetPrintName();
	end;
end;

-- A function to get a player's name.
function playerMeta:Name()
	local name = self:GetSharedVar("Name");
	
	if (!name or name == "") then
		return self:SteamName();
	else
		return name;
	end;
end;

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.cwPlaybackRate or 1;
end;

-- A function to get whether a player is noclipping.
function playerMeta:IsNoClipping()
	return Clockwork.player:IsNoClipping(self);
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning(bNoWalkSpeed)
	if (self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching()
	and self:GetSharedVar("IsRunMode")) then
		if (self:GetVelocity():Length() >= self:GetWalkSpeed()
		or bNoWalkSpeed) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to get whether a player is jogging.
function playerMeta:IsJogging(bTestSpeed)
	if (!self:IsRunning() and (self:GetSharedVar("IsJogMode") or bTestSpeed)) then
		if (self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching()) then
			if (self:GetVelocity():Length() > 0) then
				return true;
			end;
		end;
	end;
	
	return false;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	local forcedAnimation = self:GetSharedVar("ForceAnim");
	
	if (forcedAnimation != 0) then
		return {
			animation = forcedAnimation,
		};
	end;
end;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return Clockwork.player:IsRagdolled(self, exception, entityless);
end;

-- A function to set a shared variable for a player.
function playerMeta:SetSharedVar(key, value)
	Clockwork.player:SetSharedVar(self, key, value);
end;

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key, sharedTable)
	return Clockwork.player:GetSharedVar(self, key, sharedTable);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	if (IsValid(self)) then
		return self:GetSharedVar("Initialized");
	end;
end;

-- A function to get a player's gender.
function playerMeta:GetGender()
	if (self:GetSharedVar("Gender") == 1) then
		return GENDER_FEMALE;
	else
		return GENDER_MALE;
	end;
end;

-- A function to get a player's faction.
function playerMeta:GetFaction()
	local index = self:GetSharedVar("Faction");
	
	if (Clockwork.faction:FindByID(index)) then
		return Clockwork.faction:FindByID(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return Clockwork.player:GetWagesName(self);
end;

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	local playerData = Clockwork.player.playerData[key];
	
	if (playerData and (not playerData.playerOnly
	or self == Clockwork.Client)) then
		return self:GetSharedVar(key);
	end;
	
	return default;
end;

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	local characterData = Clockwork.player.characterData[key];
	
	if (characterData and (not characterData.playerOnly
	or self == Clockwork.Client)) then
		return self:GetSharedVar(key);
	end;
	
	return default;
end;

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetSharedVar("MaxAP");
	
	if (maxArmor > 0) then
		return maxArmor;
	else
		return 100;
	end;
end;

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetSharedVar("MaxHP");
	
	if (maxHealth > 0) then
		return maxHealth;
	else
		return 100;
	end;
end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState()
	return Clockwork.player:GetRagdollState(self);
end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return Clockwork.player:GetRagdollEntity(self);
end;

-- A function to get a player's rank within their faction.
function playerMeta:GetFactionRank()
	local rankName, rank = Clockwork.player:GetFactionRank(self);
	
	return rankName, rank;
end;

-- A function to get a player's chat icon.
function playerMeta:GetChatIcon()
	return Clockwork.player:GetChatIcon(self);
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;
