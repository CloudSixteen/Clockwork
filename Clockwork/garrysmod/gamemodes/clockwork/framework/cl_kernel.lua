--[[ 
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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
local FindMetaTable = FindMetaTable;
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
local gui = gui;

--[[
	Derive from Sandbox, because we want the spawn menu and such!
	We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode("sandbox");

--[[
	This is a hack to allow us to call plugin hooks based
	on default GMod hooks that are called.
--]]

hook.ClockworkCall = hook.Call;
hook.Timings = {};

function hook.Call(name, gamemode, ...)
	if (!IsValid(Clockwork.Client)) then
		Clockwork.Client = LocalPlayer();
	end;
	
	local startTime = SysTime();
		local bStatus, value = pcall(Clockwork.plugin.RunHooks, Clockwork.plugin, name, nil, ...);
	local timeTook = SysTime() - startTime;
	
	hook.Timings[name] = timeTook;
	
	if (!bStatus) then
		ErrorNoHalt("[Clockwork] The '"..name.."' hook failed to run.\n"..value.."\n"..value.."\n");
	end;
	
	if (value == nil) then
		local startTime = SysTime();
			local bStatus, a, b, c = pcall(hook.ClockworkCall, name, gamemode or Clockwork, ...);
		local timeTook = SysTime() - startTime;
		
		hook.Timings[name] = timeTook;
		
		if (!bStatus) then
			ErrorNoHalt("[Clockwork] The '"..name.."' hook failed to run.\n"..a.."\n");
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
		local duration = 8;
		local curTime = UnPredictedCurTime();
		
		if (introImage != "") then
			duration = 16;
		end;
		
		Clockwork.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8);
		Clockwork.ClockworkIntroFadeOut = curTime + duration;
		Clockwork.ClockworkIntroSound = CreateSound(Clockwork.Client, "music/hl2_song7.mp3");
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
						k, string.rep("*", string.len(tostring(v.value)))
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

Clockwork.datastream:Hook("PhysDesc", function(data)
	Derma_StringRequest("Description", "What do you want to change your physical description to?", Clockwork.Client:GetSharedVar("PhysDesc"), function(text)
		Clockwork.kernel:RunCommand("CharPhysDesc", text);
	end);
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

-- Called when a weapon is picked up and added to the HUD.
function Clockwork:HUDWeaponPickedUp(...) end;

-- Called when an item is picked up and added to the HUD.
function Clockwork:HUDItemPickedUp(...) end;

-- Called when some ammo is picked up and added to the HUD.
function Clockwork:HUDAmmoPickedUp(...) end;

-- Called when the context menu is opened.
function Clockwork:OnContextMenuOpen()
	if (self.kernel:IsUsingTool()) then
		return self.BaseClass:OnContextMenuOpen(self);
	else
		gui.EnableScreenClicker(true);
	end;
end;

-- Called when the context menu is closed.
function Clockwork:OnContextMenuClose()
	if (self.kernel:IsUsingTool()) then
		return self.BaseClass:OnContextMenuClose(self);
	else
		gui.EnableScreenClicker(false);
	end;
end;

-- Called when a player attempts to use the property menu.
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

-- Called when a player attempts to use drive.
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

-- Called when the Clockwork directory is rebuilt.
function Clockwork:ClockworkDirectoryRebuilt(panel)
	for k, v in pairs(self.command.stored) do
		if (!self.player:HasFlags(self.Client, v.access)) then
			self.command:RemoveHelp(v);
		else
			self.command:AddHelp(v);
		end;
	end;
end;

-- Called when a Derma skin should be forced.
function Clockwork:ForceDermaSkin()
	--[[
		Disable the custom Derma skin as it needs updating to GWEN.
		return "Clockwork";
	--]]
	
	return nil;
end;

-- Called when the local player is given an item.
function Clockwork:PlayerItemGiven(itemTable)
	if (self.storage:IsStorageOpen()) then
		self.storage:GetPanel():Rebuild();
	end;
end;

-- Called when the local player has an item taken.
function Clockwork:PlayerItemTaken(itemTable)
	if (self.storage:IsStorageOpen()) then
		self.storage:GetPanel():Rebuild();
	end;
end;

-- Called when the local player's character has initialized.
function Clockwork:PlayerCharacterInitialized(iCharacterKey) end;

-- Called before the local player's storage is rebuilt.
function Clockwork:PlayerPreRebuildStorage(panel) end;

-- Called when the local player's storage is rebuilt.
function Clockwork:PlayerStorageRebuilt(panel, categories) end;

-- Called when the local player's business is rebuilt.
function Clockwork:PlayerBusinessRebuilt(panel, categories) end;

-- Called when the local player's inventory is rebuilt.
function Clockwork:PlayerInventoryRebuilt(panel, categories) end;

-- Called when an entity fires some bullets.
function Clockwork:EntityFireBullets(entity, bulletInfo) end;

-- Called when a player's bullet info should be adjusted.
function Clockwork:PlayerAdjustBulletInfo(player, bulletInfo) end;

-- Called when Clockwork config has initialized.
function Clockwork:ClockworkConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs(self.item:GetAll()) do
			v.cost = 0;
		end;
	end;
end;

-- Called when a Clockwork ConVar has changed.
function Clockwork:ClockworkConVarChanged(name, previousValue, newValue) end;

-- Called when Clockwork config has changed.
function Clockwork:ClockworkConfigChanged(key, data, previousValue, newValue) end;

-- Called when an entity's menu options are needed.
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
			
			local examineText = Clockwork.item:GetMarkupToolTip(itemTable);
			
			if (itemTable.GetEntityExamineText) then
				examineText = itemTable:GetEntityExamineText(entity);
			end;
			
			options["Take"] = "cwItemTake";
			options["Examine"] = {
				isArgTable = true,
				isOrdered = true,
				toolTip = examineText,
			};
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

-- Called when the GUI mouse is released.
function Clockwork:GUIMouseReleased(code)
	if (!self.config:Get("use_opens_entity_menus"):Get()
	and vgui.CursorVisible()) then
		local trace = self.Client:GetEyeTrace();
		
		if (IsValid(trace.Entity) and trace.HitPos:Distance(self.Client:GetShootPos()) <= 80) then
			self.EntityMenu = self.kernel:HandleEntityMenu(trace.Entity);
			
			if (IsValid(self.EntityMenu)) then
				self.EntityMenu:SetPos(gui.MouseX() - (self.EntityMenu:GetWide() / 2), gui.MouseY() - (self.EntityMenu:GetTall() / 2));
			end;
		end;
	end;
end;

-- Called when a key is released.
function Clockwork:KeyRelease(player, key)
	if (self.config:Get("use_opens_entity_menus"):Get()) then
		if (key == IN_USE) then
			local activeWeapon = player:GetActiveWeapon();
			local trace = self.Client:GetEyeTraceNoCursor();
			
			if (IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_physgun") then
				if (player:KeyDown(IN_ATTACK)) then
					return;
				end;
			end;
			
			if (IsValid(trace.Entity) and trace.HitPos:Distance(self.Client:GetShootPos()) <= 80) then
				self.EntityMenu = self.kernel:HandleEntityMenu(trace.Entity);
				
				if (IsValid(self.EntityMenu)) then
					self.EntityMenu:SetPos(
						(ScrW() / 2) - (self.EntityMenu:GetWide() / 2), (ScrH() / 2) - (self.EntityMenu:GetTall() / 2)
					);
				end;
			end;
		end;
	end;
end;

-- Called when the local player is created.
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

-- Called when the client initializes.
function Clockwork:Initialize()
	CW_CONVAR_TWELVEHOURCLOCK = self.kernel:CreateClientConVar("cwTwelveHourClock", 0, true, true);
	CW_CONVAR_SHOWTIMESTAMPS = self.kernel:CreateClientConVar("cwShowTimeStamps", 0, true, true);
	CW_CONVAR_MAXCHATLINES = self.kernel:CreateClientConVar("cwMaxChatLines", 10, true, true);
	CW_CONVAR_HEADBOBSCALE = self.kernel:CreateClientConVar("cwHeadbobScale", 1, true, true);
	CW_CONVAR_SHOWSERVER = self.kernel:CreateClientConVar("cwShowServer", 1, true, true);
	CW_CONVAR_SHOWAURA = self.kernel:CreateClientConVar("cwShowClockwork", 1, true, true);
	CW_CONVAR_SHOWHINTS = self.kernel:CreateClientConVar("cwShowHints", 1, true, true);
	CW_CONVAR_ADMINESP = self.kernel:CreateClientConVar("cwAdminESP", 0, true, true);
	CW_CONVAR_SHOWLOG = self.kernel:CreateClientConVar("cwShowLog", 1, true, true);
	CW_CONVAR_SHOWOOC = self.kernel:CreateClientConVar("cwShowOOC", 1, true, true);
	CW_CONVAR_SHOWIC = self.kernel:CreateClientConVar("cwShowIC", 1, true, true);
	
	if (!self.chatBox.panel) then
		self.chatBox:CreateDermaAll();
	end;
	
	self.item:Initialize();
	
	if (!self.option:GetKey("top_bars")) then
		CW_CONVAR_TOPBARS = self.kernel:CreateClientConVar("cwTopBars", 0, true, true);
	else
		self.setting:RemoveByConVar("cwTopBars");
	end;
	
	self.plugin:Call("ClockworkKernelLoaded");
	self.plugin:Call("ClockworkInitialized");
	
	self.theme:CreateFonts();
		-- self.theme:CopySkin();
	self.theme:Initialize();
	
	self.plugin:CheckMismatches();
end;

--[[
	@codebase Client
	@details Called when Clockwork has initialized.
--]]
function Clockwork:ClockworkInitialized()
	local newLogoFile = "clockwork/logo/001.png";
	local oldLogoFile = "clockwork/clockwork_logo.png";
	
	if (!file.Exists("materials/"..newLogoFile, "GAME")) then
		newLogoFile = oldLogoFile;
	end;
	
	self.SpawnIconMaterial = Material("vgui/spawnmenu/hover");
	self.DefaultGradient = surface.GetTextureID("gui/gradient_down");
	self.GradientTexture = Material(self.option:GetKey("gradient")..".png");
	self.ClockworkSplash = Material(newLogoFile);
	self.FishEyeTexture = Material("models/props_c17/fisheyelens");
	self.GradientCenter = surface.GetTextureID("gui/center_gradient");
	self.GradientRight = surface.GetTextureID("gui/gradient");
	self.GradientUp = surface.GetTextureID("gui/gradient_up");
	self.ScreenBlur = Material("pp/blurscreen");
	self.Gradients = {
		[GRADIENT_CENTER] = self.GradientCenter;
		[GRADIENT_RIGHT] = self.GradientRight;
		[GRADIENT_DOWN] = self.DefaultGradient;
		[GRADIENT_UP] = self.GradientUp;
	};
end;

--[[
	@codebase Client
	@details Called when an Clockwork item has initialized.
--]]
function Clockwork:ClockworkItemInitialized(itemTable) end;

--[[
	@codebase Client
	@details Called when a player's phys desc override is needed.
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
		if (!self.plugin:Call("PlayerCanZoom")) then
			return true;
		end;
	end;
	
	if (string.find(bind, "+attack") or string.find(bind, "+attack2")) then
		if (self.storage:IsStorageOpen()) then
			return true;
		end;
	end;
	
	if (self.config:Get("block_inv_binds"):Get()) then
		if (string.find(string.lower(bind), self.config:Get("command_prefix"):Get().."invaction")
		or string.find(string.lower(bind), "cwcmd invaction")) then
			return true;
		end;
	end;
	
	return self.plugin:Call("TopLevelPlayerBindPress", player, bind, bPress);
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
	local ragdollEyeAngles = self.kernel:GetRagdollEyeAngles();
	
	if (ragdollEyeAngles and IsValid(self.Client)) then
		local defaultSensitivity = 0.05;
		local sensitivity = defaultSensitivity * (self.plugin:Call("AdjustMouseSensitivity", defaultSensitivity) or defaultSensitivity);
		
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

-- Called when the view should be calculated.
function Clockwork:CalcView(player, origin, angles, fov)
	local scale = CW_CONVAR_HEADBOBSCALE:GetFloat() or 1;

	if (self.Client:IsRagdolled()) then
		local ragdollEntity = self.Client:GetRagdollEntity();
		local ragdollState = self.Client:GetRagdollState();
		
		if (self.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov};
		else
			local eyes = ragdollEntity:GetAttachment(ragdollEntity:LookupAttachment("eyes"));
			
			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + self.kernel:GetRagdollEyeAngles();
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
	elseif (self.config:Get("enable_headbob"):Get() and scale > 0) then
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
				
				self.plugin:Call("PlayerAdjustHeadbobInfo", info);
				
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
	local weapon = self.Client:GetActiveWeapon();
	local changedAngles = (view.vm_angles != nil);
	local changedOrigin = (view.vm_origin != nil);
	
	if (IsValid(weapon)) then
		local weaponRaised = self.player:GetWeaponRaised(self.Client);
		
		if (!self.Client:HasInitialized() or !self.config:HasInitialized()
		or self.Client:GetMoveType() == MOVETYPE_OBSERVER) then
			weaponRaised = nil;
		end;
		
		if (!weaponRaised) then
			local originalOrigin = Vector(origin.x, origin.y, origin.z);
			local originalAngles = Angle(angles.p, angles.y, angles.r);
			local itemTable = self.item:GetByWeapon(weapon);
			local originMod = Vector(-3.0451, -1.6419, -0.5771);
			local anglesMod = Angle(-12.9015, -47.2118, 5.1173);
			
			if (itemTable and itemTable("loweredAngles")) then
				anglesMod = itemTable("loweredAngles");
			elseif (weapon.LoweredAngles) then
				anglesMod = weapon.LoweredAngles;
			end;
			
			if (itemTable and itemTable("loweredOrigin")) then
				originMod = itemTable("loweredOrigin");
			elseif (weapon.LoweredOrigin) then
				originMod = weapon.LoweredOrigin;
			end;
			
			local viewInfo = {
				origin = originMod,
				angles = anglesMod
			};
			
			self.plugin:Call("GetWeaponLoweredViewInfo", itemTable, weapon, viewInfo);
			
			originalAngles:RotateAroundAxis(originalAngles:Right(), viewInfo.angles.p);
			originalAngles:RotateAroundAxis(originalAngles:Up(), viewInfo.angles.y);
			originalAngles:RotateAroundAxis(originalAngles:Forward(), viewInfo.angles.r);
			
			originalOrigin = originalOrigin + viewInfo.origin.x * originalAngles:Right();
			originalOrigin = originalOrigin + viewInfo.origin.y * originalAngles:Forward();
			originalOrigin = originalOrigin + viewInfo.origin.z * originalAngles:Up();
			
			view.vm_origin = originalOrigin;
			view.vm_angles = originalAngles;
		elseif (self.config:Get("use_free_aiming"):Get()) then
			if (!self.kernel:IsDefaultWeapon(weapon) and !changedAngles) then
				-- Thanks to BlackOps7799 for this open source example.
				
				if (!self.SmoothViewAngle) then
					self.SmoothViewAngle = angles;
				else
					self.SmoothViewAngle = LerpAngle(RealFrameTime() * 16, self.SmoothViewAngle, angles);
				end;
				
				self.SmoothViewAngle.r = 0;
				
				view.angles = self.SmoothViewAngle;
				view.vm_origin = origin;
				view.vm_angles = angles;
			end;
		end;
	end;
	
	self.plugin:Call("CalcViewAdjustTable", view);
	
	return view;
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
	
	if (!IsValid(self.Client) or !self.Client:HasInitialized() or self.kernel:IsChoosingCharacter()) then
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
	
	self.kernel:RemoveActiveToolTip();
	self.kernel:CloseActiveDermaMenus();
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
	local attributesName = self.option:GetKey("name_attributes");
	local systemName = self.option:GetKey("name_system");
	local scoreboardName = self.option:GetKey("name_scoreboard");
	local directoryName = self.option:GetKey("name_directory");
	local inventoryName = self.option:GetKey("name_inventory");
	local businessName = self.option:GetKey("name_business");
	
	menuItems:Add("Classes", "cwClasses", "Choose from a list of available classes.");
	menuItems:Add("Settings", "cwSettings", "Configure the way Clockwork works for you.");
	menuItems:Add("Donations", "cwDonations", "Check your donation subscriptions.");
	menuItems:Add(systemName, "cwSystem", self.option:GetKey("description_system"));
	menuItems:Add(scoreboardName, "cwScoreboard", self.option:GetKey("name_scoreboard"));
	menuItems:Add(businessName, "cwBusiness", self.option:GetKey("description_business"));
	menuItems:Add(inventoryName, "cwInventory", self.option:GetKey("description_inventory"));
	menuItems:Add(directoryName, "cwDirectory", self.option:GetKey("description_directory"));
	menuItems:Add(attributesName, "cwAttributes", self.option:GetKey("description_attributes"));
end;

-- Called when the menu's items should be destroyed.
function Clockwork:MenuItemsDestroy(menuItems) end;

-- Called each tick.
function Clockwork:Tick()
	local realCurTime = CurTime();
	local curTime = UnPredictedCurTime();
	local font = self.option:GetFont("player_info_text");
	
	if (self.character:IsPanelPolling()) then
		local panel = self.character:GetPanel();
		
		if (!panel and self.plugin:Call("ShouldCharacterMenuBeCreated")) then
			self.character:SetPanelPolling(false);
			self.character.isOpen = true;
			self.character.panel = vgui.Create("cwCharacterMenu");
			self.character.panel:MakePopup();
			self.character.panel:ReturnToMainMenu();

			self.plugin:Call("PlayerCharacterScreenCreated", self.character.panel);
		end;
	end;
	
	if (IsValid(self.Client) and !self.kernel:IsChoosingCharacter()) then
		self.bars.stored = {};
		self.PlayerInfoText.text = {};
		self.PlayerInfoText.width = ScrW() * 0.15;
		self.PlayerInfoText.subText = {};
		
		self.kernel:DrawHealthBar();
		self.kernel:DrawArmorBar();
		
		self.plugin:Call("GetBars", self.bars);
		self.plugin:Call("DestroyBars", self.bars);
		self.plugin:Call("GetPlayerInfoText", self.PlayerInfoText);
		self.plugin:Call("DestroyPlayerInfoText", self.PlayerInfoText);
		
		table.sort(self.bars.stored, function(a, b)
			if (a.text == "" and b.text == "") then
				return a.priority > b.priority;
			elseif (a.text == "") then
				return true;
			else
				return a.priority > b.priority;
			end;
		end);
		
		table.sort(self.PlayerInfoText.subText, function(a, b)
			return a.priority > b.priority;
		end);
		
		for k, v in pairs(self.PlayerInfoText.text) do
			self.PlayerInfoText.width = self.kernel:AdjustMaximumWidth(font, v.text, self.PlayerInfoText.width);
		end;
		
		for k, v in pairs(self.PlayerInfoText.subText) do
			self.PlayerInfoText.width = self.kernel:AdjustMaximumWidth(font, v.text, self.PlayerInfoText.width);
		end;
		
		self.PlayerInfoText.width = self.PlayerInfoText.width + 16;
		
		if (self.config:Get("fade_dead_npcs"):Get()) then
			for k, v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
				if (!self.entity:IsDecaying(v)) then
					self.entity:Decay(v, 300);
				end;
			end;
		end;
		
		local playedHeartbeatSound = false;
		
		if (self.Client:Alive() and self.config:Get("enable_heartbeat"):Get()) then
			local maxHealth = self.Client:GetMaxHealth();
			local health = self.Client:Health();
			
			if (health < maxHealth) then
				if (!self.HeartbeatSound) then
					self.HeartbeatSound = CreateSound(self.Client, "player/heartbeat1.wav");
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
		
		for k, v in pairs(self.attributes.boosts) do
			for k2, v2 in pairs(v) do
				if (v2.duration and v2.endTime) then
					if (realCurTime > v2.endTime) then
						self.attributes.boosts[k][k2] = nil;
					else
						local timeLeft = v2.endTime - realCurTime;
						
						if (timeLeft >= 0) then
							if (v2.default < 0) then
								v2.amount = math.min((v2.default / v2.duration) * timeLeft, 0);
							else
								v2.amount = math.max((v2.default / v2.duration) * timeLeft, 0);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	if (self.kernel:IsInfoMenuOpen() and !input.IsKeyDown(KEY_F1)) then
		Clockwork.kernel:RemoveBackgroundBlur("InfoMenu");
		Clockwork.kernel:CloseActiveDermaMenus();
		Clockwork.InfoMenuOpen = false;
		
		if (IsValid(Clockwork.InfoMenuPanel)) then
			Clockwork.InfoMenuPanel:Remove();
		end;
		
		timer.Simple(FrameTime() * 0.5, function()
			Clockwork.kernel:RemoveActiveToolTip();
		end);
	end;
	
	local menuMusic = self.option:GetKey("menu_music");
	
	if (menuMusic != "") then
		if (IsValid(self.Client) and self.character:IsPanelOpen()) then
			if (!self.MusicSound) then
				self.MusicSound = CreateSound(self.Client, menuMusic);
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
					value = self.kernel:GetSharedVar(k2);
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
function Clockwork:OnEntityCreated(entity)
	if (entity == LocalPlayer() and IsValid(entity)) then
		self.Client = entity;
	end;
end;

-- Called each frame.
function Clockwork:Think()
	if (!self.CreatedLocalPlayer) then
		if (IsValid(self.Client)) then
			self.plugin:Call("LocalPlayerCreated");
				self.datastream:Start("LocalPlayerCreated", true);
			self.CreatedLocalPlayer = true;
		end;
	end;
	
	self.kernel:CallTimerThink(CurTime());
	self.kernel:CalculateHints();
	
	if (self.kernel:IsCharacterScreenOpen()) then
		local panel = self.character:GetPanel();
		
		if (panel) then
			panel:SetVisible(self.plugin:Call("GetPlayerCharacterScreenVisible", panel));
			
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

local SCREEN_DAMAGE_OVERLAY = Material("clockwork/screendamage.png");
local VIGNETTE_OVERLAY = Material("clockwork/vignette.png");

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
	if (!self.cwVignetteAlpha) then
		self.cwVignetteAlpha = 100;
		self.cwVignetteAlphaDelta = self.cwVignetteAlpha;
	end;

	local data = {};
		data.start = self.Client:GetShootPos();
		data.endpos = data.start + (self.Client:GetUp() * 512);
		data.filder = self.Client;
	local trace = util.TraceLine(data);

	if (!trace.HitWorld and !trace.HitNonWorld) then
		self.cwVignetteAlpha = 100;
	else
		self.cwVignetteAlpha = 255;
	end;

	self.cwVignetteAlphaDelta = math.Approach(self.cwVignetteAlphaDelta, self.cwVignetteAlpha, FrameTime() * 70);

	local scrW, scrH = ScrW(), ScrH();

	surface.SetDrawColor(0, 0, 0, self.cwVignetteAlphaDelta);
	surface.SetMaterial(VIGNETTE_OVERLAY);
	surface.DrawTexturedRect(0, 0, scrW, scrH);
end;

-- Called when the foreground HUD should be painted.
function Clockwork:HUDPaintForeground()
	local backgroundColor = self.option:GetColor("background");
	local colorWhite = self.option:GetColor("white");
	local info = self.plugin:Call("GetProgressBarInfo");
	
	if (info) then
		local height = 32;
		local width = (ScrW() * 0.5);
		local x = ScrW() * 0.25;
		local y = ScrH() * 0.3;
		
		self.kernel:DrawGradient(
			GRADIENT_RIGHT, x - 16, y - 16, width + 32, height + 32, Color(100, 100, 100, 200)
		);
		
		self.kernel:DrawBar(
			x, y, width, height, info.color or Clockwork.option:GetColor("information"),
			info.text or "Progress Bar", info.percentage or 100, 100, info.flash
		);
	else
		info = self.plugin:Call("GetPostProgressBarInfo");
		
		if (info) then
			local height = 32;
			local width = (ScrW() / 2) - 64;
			local x = ScrW() * 0.25;
			local y = ScrH() * 0.3;
			
			self.kernel:DrawGradient(
				GRADIENT_RIGHT, x - 16, y - 16, width + 32, height + 32, Color(100, 100, 100, 200)
			);
			
			self.kernel:DrawBar(
				x, y, width, height, info.color or Clockwork.option:GetColor("information"),
				info.text or "Progress Bar", info.percentage or 100, 100, info.flash
			);
		end;
	end;
	
	if (self.player:IsAdmin(self.Client)) then
		if (self.plugin:Call("PlayerCanSeeAdminESP")) then
			self.kernel:DrawAdminESP();
		end;
	end;
	
	local screenTextInfo = self.plugin:Call("GetScreenTextInfo");
	
	if (screenTextInfo) then
		local alpha = screenTextInfo.alpha or 255;
		local y = (ScrH() / 2) - 128;
		local x = ScrW() / 2;
		
		if (screenTextInfo.title) then
			self.kernel:OverrideMainFont(self.option:GetFont("menu_text_small"));
				y = self.kernel:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha);
			self.kernel:OverrideMainFont(false);
		end;
		
		if (screenTextInfo.text) then
			self.kernel:OverrideMainFont(self.option:GetFont("menu_text_tiny"));
				y = self.kernel:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha);
			self.kernel:OverrideMainFont(false);
		end;
	end;
	
	self.chatBox:Paint();
	
	local info = {width = ScrW() * 0.3, x = 8, y = 8};
		self.kernel:DrawBars(info, "top");
	self.plugin:Call("HUDPaintTopScreen", info);
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
	local blackFadeAlpha = self.kernel:GetBlackFadeAlpha();
	
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
		self.kernel:DrawCinematic(cinematic, CurTime());
	end;

	local activeMarkupToolTip = Clockwork.kernel:GetActiveMarkupToolTip();

	if (activeMarkupToolTip and IsValid(activeMarkupToolTip) and activeMarkupToolTip:IsVisible()) then
		local markupToolTip = activeMarkupToolTip:GetMarkupToolTip();
		local alpha = activeMarkupToolTip:GetAlpha();
		local x, y = gui.MouseX(), gui.MouseY() + 24;
		
		if (markupToolTip) then
			self.kernel:DrawMarkupToolTip(markupToolTip.object, x, y, alpha);
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
			return (CW_CONVAR_TOPBARS:GetInt() == 0 and self.kernel:IsInfoMenuOpen());
		else
			return self.kernel:IsInfoMenuOpen();
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
	if (self.kernel:IsInfoMenuOpen() and self.config:Get("limb_damage_system"):Get()) then
		return true;
	else
		return false;
	end;
end;

-- Called when the local player attempts to see the date and time.
function Clockwork:PlayerCanSeeDateTime()
	return self.kernel:IsInfoMenuOpen();
end;

-- Called when the local player attempts to see a class.
function Clockwork:PlayerCanSeeClass(class)
	return true;
end;

-- Called when the local player attempts to see the player info.
function Clockwork:PlayerCanSeePlayerInfo()
	return self.kernel:IsInfoMenuOpen();
end;

--
function Clockwork:AddHint(name, delay)
	if (IsValid(self.Client) and self.Client:HasInitialized()) then
		self.kernel:AddTopHint(
			self.kernel:ParseData("#Hint_"..name), delay
		);
	end;
end;

--
function Clockwork:AddNotify(text, class, length)
	return self.kernel:AddNotify(text, class, length);
end;

-- Called when the target ID HUD should be drawn.
function Clockwork:HUDDrawTargetID()
	local targetIDTextFont = self.option:GetFont("target_id_text");
	local traceEntity = NULL;
	local colorWhite = self.option:GetColor("white");
	
	self.kernel:OverrideMainFont(targetIDTextFont);
	
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
					local entity = self.entity:GetPlayer(trace.Entity);
					
					if (entity) then
						fadeDistance = self.plugin:Call("GetTargetPlayerFadeDistance", entity);
					end;
					
					local alpha = math.Clamp(self.kernel:CalculateAlphaFromDistance(fadeDistance, self.Client, trace.HitPos) * 1.5, 0, 255);
					
					if (alpha > 0) then
						alpha = math.min(alpha, math.Clamp(1 - ((self.TargetIDData.fadeTime - curTime) / 3), 0, 1) * 255);
					end;
					
					self.TargetIDData.fadeDistance = fadeDistance;
					self.TargetIDData.player = entity;
					self.TargetIDData.alpha = alpha;
					self.TargetIDData.class = class;
					
					if (entity and self.Client != entity) then
						if (self.plugin:Call("ShouldDrawPlayerTargetID", entity)) then
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
										local text = string.Explode("\n", self.plugin:Call("GetTargetPlayerName", entity));
										local newY;
										
										for k, v in pairs(text) do
											newY = self.kernel:DrawInfo(v, x, y, cwTeam.GetColor(entity:Team()), alpha);
											
											if (flashAlpha) then
												self.kernel:DrawInfo(v, x, y, colorWhite, flashAlpha);
											end;
											
											if (newY) then
												y = newY;
											end;
										end;
									else
										local unrecognisedName, usedPhysDesc = self.player:GetUnrecognisedName(entity);
										local wrappedTable = {unrecognisedName};
										local teamColor = cwTeam.GetColor(entity:Team());
										local result = self.plugin:Call("PlayerCanShowUnrecognised", entity, x, y, unrecognisedName, teamColor, alpha, flashAlpha);
										local newY;
										
										if (type(result) == "string") then
											wrappedTable = {};
											self.kernel:WrapText(result, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										elseif (usedPhysDesc) then
											wrappedTable = {};
											self.kernel:WrapText(unrecognisedName, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable);
										end;
										
										if (result == true or type(result) == "string") then
											for k, v in pairs(wrappedTable) do
												newY = self.kernel:DrawInfo(v, x, y, teamColor, alpha);
													
												if (flashAlpha) then
													self.kernel:DrawInfo(v, x, y, colorWhite, flashAlpha);
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
									
									self.plugin:Call("GetTargetPlayerText", entity, self.TargetPlayerText);
									self.plugin:Call("DestroyTargetPlayerText", entity, self.TargetPlayerText);
									
									y = self.plugin:Call("DrawTargetPlayerStatus", entity, alpha, x, y) or y;
									
									for k, v in pairs(self.TargetPlayerText.stored) do
										y = self.kernel:DrawInfo(v.text, x, y, v.color or colorWhite, alpha);
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
							
							y = self.kernel:DrawInfo(name, x, y, Color(150, 150, 100, 255), alpha);
							y = self.kernel:DrawBar(
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
								
								y = self.kernel:DrawInfo("An unknown weapon", x, y, Color(200, 100, 50, 255), alpha);
								y = self.kernel:DrawInfo("Press use to equip.", x, y, colorWhite, alpha);
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
	
	self.kernel:OverrideMainFont(false);
	
	if (!IsValid(traceEntity)) then
		if (self.TargetIDData) then
			self.TargetIDData = nil;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function Clockwork:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = self.option:GetColor("information");
	local gender = "He";
	
	if (target:GetGender() == GENDER_FEMALE) then
		gender = "She";
	end;
	
	if (!target:Alive()) then
		return self.kernel:DrawInfo(gender.." is clearly deceased.", x, y, informationColor, alpha);
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

-- Called when the admin ESP info is needed.
function Clockwork:GetAdminESPInfo(info)
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			local physBone = v:LookupBone("ValveBiped.Bip01_Head1");
			
			if (physBone) then
				local bonePosition = v:GetBonePosition(physBone);
				local position = nil;
					
				if (string.find(v:GetModel(), "vortigaunt")) then
					bonePosition = v:GetBonePosition(v:LookupBone("ValveBiped.Head"));
				end;
					
				if (bonePosition) then
					position = bonePosition + Vector(0, 0, 16);
				else
					position = v:GetPos() + Vector(0, 0, 80);
				end;
				
				info[#info + 1] = {
					position = position,
					color = cwTeam.GetColor(v:Team()),
					text = v:Name().." ("..v:Health().."/"..v:GetMaxHealth()..")"
				};
			end;
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function Clockwork:GetPostProgressBarInfo() end;

-- Called when the custom character options are needed.
function Clockwork:GetCustomCharacterOptions(character, options, menu) end;

-- Called when the custom character buttons are needed.
function Clockwork:GetCustomCharacterButtons(character, buttons) end;

-- Called when the progress bar info is needed.
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
		
		if (fallenOver and self.plugin:Call("PlayerCanGetUp")) then
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

-- Called when the player info text is needed.
function Clockwork:GetPlayerInfoText(playerInfoText)
	local cash = self.player:GetCash();
	local wages = self.player:GetWages();
	
	if (self.config:Get("cash_enabled"):Get()) then
		if (cash > 0) then
			playerInfoText:Add("CASH", self.option:GetKey("name_cash")..": "..Clockwork.kernel:FormatCash(cash, true));
		end;
		
		if (wages > 0) then
			playerInfoText:Add("WAGES", self.Client:GetWagesName()..": "..Clockwork.kernel:FormatCash(wages));
		end;
	end;

	playerInfoText:AddSub("NAME", self.Client:Name(), 2);
	playerInfoText:AddSub("CLASS", cwTeam.GetName(self.Client:Team()), 1);
end;

-- Called when the target player's fade distance is needed.
function Clockwork:GetTargetPlayerFadeDistance(player)
	return 4096;
end;

-- Called when the player info text should be destroyed.
function Clockwork:DestroyPlayerInfoText(playerInfoText) end;

-- Called when the target player's text is needed.
function Clockwork:GetTargetPlayerText(player, targetPlayerText)
	local targetIDTextFont = self.option:GetFont("target_id_text");
	local physDescTable = {};
	local thirdPerson = "him";
	
	if (player:GetGender() == GENDER_FEMALE) then
		thirdPerson = "her";
	end;
	
	if (self.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		self.kernel:WrapText(self.player:GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable);
		
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
		
		if (string.len(physDesc) > 64) then
			return string.sub(physDesc, 1, 61).."...";
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
	local doorCost = self.config:Get("door_cost"):Get();
	local owner = self.entity:GetOwner(door);
	local text = self.entity:GetDoorText(door);
	local name = self.entity:GetDoorName(door);
	
	if (information == DOOR_INFO_NAME) then
		if (self.entity:IsDoorHidden(door)
		or self.entity:IsDoorFalse(door)) then
			return false;
		elseif (name == "") then
			return "Door";
		else
			return name;
		end;
	elseif (information == DOOR_INFO_TEXT) then
		if (self.entity:IsDoorUnownable(door)) then
			if (!self.entity:IsDoorHidden(door)
			and !self.entity:IsDoorFalse(door)) then
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
	
	local colorWhite = self.option:GetColor("white");
	local colorInfo = self.option:GetColor("information");
	local doorFont = self.option:GetFont("large_3d_2d");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	if (!self.kernel:IsChoosingCharacter()) then
		cam.Start3D(eyePos, eyeAngles);
			local entities = ents.FindInSphere(eyePos, 256);
			
			for k, v in pairs(entities) do
				if (IsValid(v) and self.entity:IsDoor(v)) then
					self.kernel:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorInfo, colorWhite);
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
		
		if (!self.kernel:IsChoosingCharacter()) then
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
			self.plugin:Call("PlayerSetDefaultColorModify", self.ColorModify);
		end;
		
		self.plugin:Call("PlayerAdjustColorModify", self.ColorModify);
		self.plugin:Call("PlayerAdjustMotionBlurs", motionBlurs);
		
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
	local scale = CW_CONVAR_HEADBOBSCALE:GetFloat() or 1;
	
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
		if (!self.plugin:Call("PlayerCanSeeUnconscious")) then
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
	local introTextSmallFont = self.option:GetFont("intro_text_small");
	local colorWhite = self.option:GetColor("white");
	local curTime = UnPredictedCurTime();
	local scrH = ScrH();
	local scrW = ScrW();
	
	if (self.kernel:IsChoosingCharacter()) then
		if (self.plugin:Call("ShouldDrawCharacterBackground")) then
			self.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
		end;
		
		self.plugin:Call("HUDPaintCharacterSelection");
	elseif (!hasClientInitialized) then
		if (!self.HasCharacterMenuBeenVisible
		and self.plugin:Call("ShouldDrawCharacterBackground")) then
			drawPendingScreenBlack = true;
		end;
	end;
	
	if (hasClientInitialized) then
		if (!self.CharacterLoadingFinishTime) then
			local loadingTime = self.plugin:Call("GetCharacterLoadingTime");
			self.CharacterLoadingDelay = loadingTime;
			self.CharacterLoadingFinishTime = curTime + loadingTime;
		end;
		
		if (!self.kernel:IsChoosingCharacter()) then
			self.kernel:CalculateScreenFading();
			
			if (!self.kernel:IsUsingCamera()) then
				self.plugin:Call("HUDPaintForeground");
			end;
			
			self.plugin:Call("HUDPaintImportant");
		end;
		
		if (self.CharacterLoadingFinishTime > curTime) then
			drawCharacterLoading = true;
		elseif (!self.CinematicScreenDone) then
			self.kernel:DrawCinematicIntro(curTime);
			self.kernel:DrawCinematicIntroBars();
		end;
	end;
	
	if (self.plugin:Call("ShouldDrawBackgroundBlurs")) then
		self.kernel:DrawBackgroundBlurs();
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
		local introImage = self.option:GetKey("intro_image");
		
		if (introImage != "") then
			duration = 16;
		end;
		
		local timeLeft = math.Clamp(self.ClockworkIntroFadeOut - curTime, 0, duration);
		local material = self.ClockworkIntroOverrideImage or self.ClockworkSplash;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512;
		local alpha = 255;
		
		if (!self.ClockworkIntroOverrideImage) then
			if (introImage != "" and timeLeft <= 8) then
				self.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8);
				self.ClockworkIntroOverrideImage = Material(introImage..".png");
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
			self.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha));
		else
			local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2);
			
			self.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha));
			self.kernel:DrawGradient(
				GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
			);
			
			material:SetFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect(x, y, width, height);
		end;
		
		drawPendingScreenBlack = nil;
	end;
	
	if (self.kernel:GetSharedVar("NoMySQL")) then
		self.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255));
		draw.SimpleText(self.kernel:GetSharedVar("NoMySQL"), introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1);
	elseif (self.DataStreamedAlpha and self.DataStreamedAlpha > 0) then
		local textString = "Please wait while Clockwork initializes.";
		
		if (!self.CreatedLocalPlayer) then
			textString = "Please wait while Source creates the local player.";
		elseif (!self.config:HasInitialized()) then
			textString = "Please wait while the server config is retrieved.";
		end;
		
		self.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, self.DataStreamedAlpha));
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH / 2, Color(colorWhite.r, colorWhite.g, colorWhite.b, self.DataStreamedAlpha), 1, 1);
		
		drawPendingScreenBlack = nil;
	end;
	
	if (drawCharacterLoading) then
		self.plugin:Call("HUDPaintCharacterLoading", math.Clamp((255 / self.CharacterLoadingDelay) * (self.CharacterLoadingFinishTime - curTime), 0, 255));
	elseif (drawPendingScreenBlack) then
		self.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
	end;
	
	if (self.CharacterLoadingFinishTime) then
		if (!self.CinematicInfoDrawn) then
			self.kernel:DrawCinematicInfo();
		end;
		
		if (!self.CinematicBarsDrawn) then
			self.kernel:DrawCinematicIntroBars();
		end;
	end;
	
	self.plugin:Call("PostDrawBackgroundBlurs");
end;

-- Called when the background blurs should be drawn.
function Clockwork:ShouldDrawBackgroundBlurs()
	return true;
end;

-- Called just after the background blurs have been drawn.
function Clockwork:PostDrawBackgroundBlurs()
	local introTextSmallFont = self.option:GetFont("intro_text_small");
	local position = self.plugin:Call("GetChatBoxPosition");
	
	if (position) then
		self.chatBox:SetCustomPosition(position.x, position.y);
	end;
	
	local backgroundColor = self.option:GetColor("background");
	local colorWhite = self.option:GetColor("white");
	local panelInfo = self.CurrentFactionSelected;
	local menuPanel = self.kernel:GetRecogniseMenu();
	
	if (panelInfo and IsValid(panelInfo[1]) and panelInfo[1]:IsVisible()) then
		local factionTable = self.faction:FindByID(panelInfo[2]);
		
		if (factionTable and factionTable.material) then
			if (file.Exists("materials/"..factionTable.material..".png", "GAME")) then
				if (!panelInfo[3]) then
					panelInfo[3] = Material(factionTable.material..".png");
				end;
				
				if (self.kernel:IsCharacterScreenOpen(true)) then
					surface.SetDrawColor(255, 255, 255, panelInfo[1]:GetAlpha());
					surface.SetMaterial(panelInfo[3]);
					surface.DrawTexturedRect(panelInfo[1].x, panelInfo[1].y + panelInfo[1]:GetTall() + 16, 512, 256);
				end;
			end;
		end;
	end;
	
	if (self.TitledMenu and IsValid(self.TitledMenu.menuPanel)) then
		local menuTextTiny = self.option:GetFont("menu_text_tiny");
		local menuPanel = self.TitledMenu.menuPanel;
		local menuTitle = self.TitledMenu.title;
		
		self.kernel:DrawSimpleGradientBox(2, menuPanel.x - 4, menuPanel.y - 4, menuPanel:GetWide() + 8, menuPanel:GetTall() + 8, backgroundColor);
		self.kernel:OverrideMainFont(menuTextTiny);
			self.kernel:DrawInfo(menuTitle, menuPanel.x, menuPanel.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4;
			end);
		self.kernel:OverrideMainFont(false);
	end;
	
	self.kernel:DrawDateTime();
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
	if (!self.kernel:IsChoosingCharacter() and !self.kernel:IsUsingCamera()) then
		if (self.event:CanRun("view", "damage") and self.Client:Alive()) then
			local maxHealth = self.Client:GetMaxHealth();
			local health = self.Client:Health();
			
			if (health < maxHealth) then
				self.plugin:Call("DrawPlayerScreenDamage", 1 - ((1 / maxHealth) * health));
			end;
		end;
		
		if (self.event:CanRun("view", "vignette") and self.config:Get("enable_vignette"):Get()) then
			self.plugin:Call("DrawPlayerVignette");
		end;
		
		local weapon = self.Client:GetActiveWeapon();
		self.BaseClass:HUDPaint();
		
		if (!self.kernel:IsScreenFadedBlack()) then
			for k, v in pairs(cwPlayer.GetAll()) do
				if (v:HasInitialized() and v != self.Client) then
					self.plugin:Call("HUDPaintPlayer", v);
				end;
			end;
		end;
		
		if (!self.kernel:IsUsingTool()) then
			self.kernel:DrawHints();
		end;
		
		if ((self.config:Get("enable_crosshair"):Get() or self.kernel:IsDefaultWeapon(weapon))
		and (IsValid(weapon) and weapon.DrawCrosshair != false)) then
			local info = {
				color = Color(255, 255, 255, 255),
				x = ScrW() / 2,
				y = ScrH() / 2
			};
			
			self.plugin:Call("GetPlayerCrosshairInfo", info);
			self.CustomCrosshair = self.plugin:Call("DrawPlayerCrosshair", info.x, info.y, info.color);
		else
			self.CustomCrosshair = false;
		end;
	end;
end;

-- Called when the local player's crosshair info is needed.
function Clockwork:GetPlayerCrosshairInfo(info)
	if (self.config:Get("use_free_aiming"):Get()) then
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
	if (self.config:Get("use_free_aiming"):Get()) then
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(x, y, 2, 2);
		surface.DrawRect(x, y + 9, 2, 2);
		surface.DrawRect(x, y - 9, 2, 2);
		surface.DrawRect(x + 9, y, 2, 2);
		surface.DrawRect(x - 9, y, 2, 2);
		
		return true;
	else
		return false;
	end;
end;

-- Called when a player starts using voice.
function Clockwork:PlayerStartVoice(player)
	if (self.config:Get("local_voice"):Get()) then
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
	if (string.find(self.config:Get("default_flags"):Get(), flag)) then
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
		self.menu:Create();
		self.menu:SetOpen(true);
		self.menu.holdTime = UnPredictedCurTime() + 0.5;
	end;
end;

-- Called when the scoreboard should be hidden.
function Clockwork:ScoreboardHide()
	if (self.Client:HasInitialized() and self.menu.holdTime) then
		if (UnPredictedCurTime() >= self.menu.holdTime) then
			self.menu:SetOpen(false);
		end;
	end;
end;

-- Overriding Garry's "grab ear" animation.
function Clockwork:GrabEarAnimation(player) end;

local entityMeta = FindMetaTable("Entity");
local weaponMeta = FindMetaTable("Weapon");
local playerMeta = FindMetaTable("Player");

entityMeta.ClockworkFireBullets = entityMeta.FireBullets;
weaponMeta.OldGetPrintName = weaponMeta.GetPrintName;
playerMeta.SteamName = playerMeta.Name;

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
function playerMeta:GetSharedVar(key)
	return Clockwork.player:GetSharedVar(self, key);
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

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;

concommand.Add("cwLua", function(player, command, arguments)
	if (player:IsSuperAdmin()) then
		RunString(table.concat(arguments, " "));
		return;
	end;
	
	print("You do not have access to this command, "..player:Name()..".");
end);