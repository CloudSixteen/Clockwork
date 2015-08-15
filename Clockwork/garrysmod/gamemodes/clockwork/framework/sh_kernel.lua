--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[ Micro-optimizations --]]
local Clockwork = Clockwork;
local von = von;
local HITGROUP_RIGHTARM = HITGROUP_RIGHTARM;
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG;
local HITGROUP_LEFTARM = HITGROUP_LEFTARM;
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG;
local HITGROUP_STOMACH = HITGROUP_STOMACH;
local HITGROUP_CHEST = HITGROUP_CHEST;
local HITGROUP_HEAD = HITGROUP_HEAD;
local UnPredictedCurTime = UnPredictedCurTime;
local RunConsoleCommand = RunConsoleCommand;
local FindMetaTable = FindMetaTable;
local getmetatable = getmetatable;
local setmetatable = setmetatable;
local GetGlobalVar = GetGlobalVar;
local SetGlobalVar = SetGlobalVar;
local ErrorNoHalt = ErrorNoHalt;
local EffectData = EffectData;
local VectorRand = VectorRand;
local DamageInfo = DamageInfo;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local IsValid = IsValid;
local SysTime = SysTime;
local unpack = unpack;
local Format = Format;
local Vector = Vector;
local Color = Color;
local pairs = pairs;
local pcall = pcall;
local type = type;
local resource = resource;
local string = string;
local table = table;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local util = util;

local stringFind = string.find;
local mathNormalize = math.NormalizeAngle;

Clockwork.kernel = Clockwork.kernel or {};
Clockwork.Timers = Clockwork.Timers or {};
Clockwork.Libraries = Clockwork.Libraries or {};
Clockwork.SharedTables = Clockwork.SharedTables or {};

--[[
	@codebase Shared
	@details A function to encode a URL.
	@param String The URL to encode.
	@returns String The encoded URL.
--]]
function Clockwork.kernel:URLEncode(url)
	local output = "";
	
	for i = 1, #url do
		local c = string.utf8sub(url, i, i);
		local a = string.byte(c);
		
		if (a < 128) then
			if (a == 32 or a >= 34 and a <= 38 or a == 43 or a == 44 or a == 47 or a >= 58
			and a <= 64 or a >= 91 and a <= 94 or a == 96 or a >= 123 and a <= 126) then
				output = output.."%"..string.format("%x", a);
			else
				output = output..c;
			end;
		end;
	end;
	
	return output;
end;

--[[
	@codebase Shared
	@details A function to get whether two tables are equal.
	@param Table The first unique table to compare.
	@param Table The second unique table to compare.
	@returns Bool Whether or not the tables are equal.
--]]
function Clockwork.kernel:AreTablesEqual(tableA, tableB)
	if (type(tableA) == "table" and type(tableB) == "table") then
		for k, v in pairs(tableA) do
			if (!self:AreTablesEqual(v, tableB[k])) then
				return false;
			end;
		end;

		return true;
	end;
	
	return (tableA == tableB);
end;

--[[
	@codebase Shared
	@details A function to get whether a weapon is a default weapon.
	@param Entity The weapon entity.
	@returns Bool Whether or not the weapon is a default weapon.
--]]
function Clockwork.kernel:IsDefaultWeapon(weapon)
	if (IsValid(weapon)) then
		local class = string.lower(weapon:GetClass());
		if (class == "weapon_physgun" or class == "gmod_physcannon"
		or class == "gmod_tool") then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to format cash.
function Clockwork.kernel:FormatCash(amount, singular, lowerName)
	local formatSingular = Clockwork.option:GetKey("format_singular_cash");
	local formatCash = Clockwork.option:GetKey("format_cash");
	local cashName = Clockwork.option:GetKey("name_cash", lowerName);
	local realAmount = tostring(math.Round(amount));
	
	if (singular) then
		return self:Replace(self:Replace(formatSingular, "%n", cashName), "%a", realAmount);
	else
		return self:Replace(self:Replace(formatCash, "%n", cashName), "%a", realAmount);
	end;
end;

--[[
	Define the default library class.
--]]

local LIBRARY = {};

-- A function to add a library function to a metatable.
function LIBRARY:AddToMetaTable(metaName, funcName, newName)
	local metaTable = FindMetaTable(metaName);
	
	metaTable[newName or funcName] = function(...)
		return self[funcName](self, ...)
	end;
end;

-- A function to create a new library.
function Clockwork.kernel:NewLibrary(libName)
	if (!Clockwork.Libraries[libName]) then
		Clockwork.Libraries[libName] = self:NewMetaTable(LIBRARY);
	end;
	
	return Clockwork.Libraries[libName];
end;

-- A function find a library by its name.
function Clockwork.kernel:FindLibrary(libName)
	return Clockwork.Libraries[libName];
end;

-- A function to convert a string to a color.
function Clockwork.kernel:StringToColor(text)
	local explodedData = string.Explode(",", text);
	local color = Color(255, 255, 255, 255);
	
	if (explodedData[1]) then
		color.r = tonumber(explodedData[1]:Trim()) or 255;
	end;
	
	if (explodedData[2]) then
		color.g = tonumber(explodedData[2]:Trim()) or 255;
	end;
	
	if (explodedData[3]) then
		color.b = tonumber(explodedData[3]:Trim()) or 255;
	end;
	
	if (explodedData[4]) then
		color.a = tonumber(explodedData[4]:Trim()) or 255;
	end;
	
	return color;
end;

-- A function to get a log type color.
function Clockwork.kernel:GetLogTypeColor(logType)
	local logTypes = {
		Color(255, 50, 50, 255),
		Color(255, 150, 0, 255),
		Color(255, 200, 0, 255),
		Color(0, 150, 255, 255),
		Color(0, 255, 125, 255)
	};
	
	return logTypes[logType] or logTypes[5];
end;

--[[
	@codebase Shared
	@details A function to get the kernel version.
	@returns String The kernel version.
--]]
function Clockwork.kernel:GetVersion()
	return Clockwork.KernelVersion;
end;

--[[
	@codebase Shared
	@details A function to get the schema folder.
	@returns String The schema folder.
--]]
function Clockwork.kernel:GetSchemaFolder(sFolderName)
	if (sFolderName) then
		return (string.gsub(Clockwork.SchemaFolder, "gamemodes/", "").."/schema/"..sFolderName);
	else
		return (string.gsub(Clockwork.SchemaFolder, "gamemodes/", ""));
	end;
end;

--[[
	@codebase Shared
	@details A function to get the schema gamemode path.
	@returns String The schema gamemode path.
--]]
function Clockwork.kernel:GetSchemaGamemodePath()
	return (string.gsub(Clockwork.SchemaFolder, "gamemodes/", "").."/gamemode");
end;

--[[
	@codebase Shared
	@details A function to get the Clockwork folder.
	@returns String The Clockwork folder.
--]]
function Clockwork.kernel:GetClockworkFolder()
	return (string.gsub(Clockwork.ClockworkFolder, "gamemodes/", ""));
end;

--[[
	@codebase Shared
	@details A function to get the Clockwork path.
	@returns String The Clockwork path.
--]]
function Clockwork.kernel:GetClockworkPath()
	return (string.gsub(Clockwork.ClockworkFolder, "gamemodes/", "").."/framework");
end;

-- A function to get the path to GMod.
function Clockwork.kernel:GetPathToGMod()
	return util.RelativePathToFull("."):sub(1, -2);
end;

-- A function to convert a string to a boolean.
function Clockwork.kernel:ToBool(text)
	if (text == "true" or text == "yes" or text == "1") then
		return true;
	else
		return false;
	end;
end;

-- A function to remove text from the end of a string.
function Clockwork.kernel:RemoveTextFromEnd(text, toRemove)
	local toRemoveLen = string.utf8len(toRemove);
	if (string.utf8sub(text, -toRemoveLen) == toRemove) then
		return (string.utf8sub(text, 0, -(toRemoveLen + 1)));
	else
		return text;
	end;
end;

-- A function to split a string.
function Clockwork.kernel:SplitString(text, interval)
	local length = string.utf8len(text);
	local baseTable = {};
	local i = 0;
	
	while (i * interval < length) do
		baseTable[i + 1] = string.utf8sub(text, i * interval + 1, (i + 1) * interval);
		i = i + 1;
	end;
	
	return baseTable;
end;

-- A function to get whether a letter is a vowel.
function Clockwork.kernel:IsVowel(letter)
	letter = string.lower(letter);
	return (letter == "a" or letter == "e" or letter == "i"
	or letter == "o" or letter == "u");
end;

-- A function to pluralize some text.
function Clockwork.kernel:Pluralize(text)
	if (string.utf8sub(text, -2) != "fe") then
		local lastLetter = string.utf8sub(text, -1);
		
		if (lastLetter == "y") then
			if (self:IsVowel(string.utf8sub(text, string.utf8len(text) - 1, 2))) then
				return string.utf8sub(text, 1, -2).."ies";
			else
				return text.."s";
			end;
		elseif (lastLetter == "h") then
			return text.."es";
		elseif (lastLetter != "s") then
			return text.."s";
		else
			return text;
		end;
	else
		return string.utf8sub(text, 1, -3).."ves";
	end;
end;

-- A function to serialize a table.
function Clockwork.kernel:Serialize(tableToSerialize)
	local bSuccess, value = pcall(von.serialize, tableToSerialize);
  
	if (!bSuccess) then
		print(value);
		return "";  	
	end;
  
	return value;
end;

-- A function to deserialize a string.
function Clockwork.kernel:Deserialize(stringToDeserialize)
	local bSuccess, value = pcall(von.deserialize, stringToDeserialize);
  
	if (!bSuccess) then
		print(value);
		return {};  	
	end;
  
	return value;
end;

-- A function to get ammo information from a weapon.
function Clockwork.kernel:GetAmmoInformation(weapon)
	if (IsValid(weapon) and IsValid(weapon.Owner) and weapon.Primary and weapon.Secondary) then
		if (!weapon.AmmoInfo) then
			weapon.AmmoInfo = {
				primary = {
					ammoType = weapon:GetPrimaryAmmoType(),
					clipSize = weapon.Primary.ClipSize
				},
				secondary = {
					ammoType = weapon:GetSecondaryAmmoType(),
					clipSize = weapon.Secondary.ClipSize
				}
			};
		end;
		
		weapon.AmmoInfo.primary.ownerAmmo = weapon.Owner:GetAmmoCount(weapon.AmmoInfo.primary.ammoType);
		weapon.AmmoInfo.primary.clipBullets = weapon:Clip1();
		weapon.AmmoInfo.primary.doesNotShoot = (weapon.AmmoInfo.primary.clipBullets == -1);
		weapon.AmmoInfo.secondary.ownerAmmo = weapon.Owner:GetAmmoCount(weapon.AmmoInfo.secondary.ammoType);
		weapon.AmmoInfo.secondary.clipBullets = weapon:Clip2();
		weapon.AmmoInfo.secondary.doesNotShoot = (weapon.AmmoInfo.secondary.clipBullets == -1);
		
		if (!weapon.AmmoInfo.primary.doesNotShoot and weapon.AmmoInfo.primary.ownerAmmo > 0) then
			weapon.AmmoInfo.primary.ownerClips = math.ceil(weapon.AmmoInfo.primary.clipSize / weapon.AmmoInfo.primary.ownerAmmo);
		else
			weapon.AmmoInfo.primary.ownerClips = 0;
		end;
		
		if (!weapon.AmmoInfo.secondary.doesNotShoot and weapon.AmmoInfo.secondary.ownerAmmo > 0) then
			weapon.AmmoInfo.secondary.ownerClips = math.ceil(weapon.AmmoInfo.secondary.clipSize / weapon.AmmoInfo.secondary.ownerAmmo);
		else
			weapon.AmmoInfo.secondary.ownerClips = 0;
		end;
		
		return weapon.AmmoInfo;
	end;
end;

-- Called when the player's jumping animation should be handled.
function Clockwork:HandlePlayerJumping(player)
	if (!player.m_bJumping and !player:OnGround() and player:WaterLevel() <= 0) then
		player.m_bJumping = true;
		player.m_bFirstJumpFrame = false;
		player.m_flJumpStartTime = 0;
	end
	
	if (player.m_bJumping) then
		if (player.m_bFirstJumpFrame) then
			player.m_bFirstJumpFrame = false;
			player:AnimRestartMainSequence();
		end;
		
		if (player:WaterLevel() >= 2) then
			player.m_bJumping = false;
			player:AnimRestartMainSequence();
		elseif (CurTime() - player.m_flJumpStartTime > 0.2) then
			if (player:OnGround()) then
				player.m_bJumping = false;
				player:AnimRestartMainSequence();
			end
		end
		
		if (player.m_bJumping) then
			player.CalcIdeal = self.animation:GetForModel(player:GetModel(), "jump");
			
			return true;
		end;
	end;
	
	return false;
end;

-- Called when the player's ducking animation should be handled.
function Clockwork:HandlePlayerDucking(player, velocity)
	if (player:Crouching()) then
		local model = player:GetModel();
		local weapon = player:GetActiveWeapon();
		local bIsRaised = self.player:GetWeaponRaised(player, true);
		local velLength = velocity:Length2D();
		local animationAct = "crouch";
		local weaponHoldType = "pistol";
		
		if (IsValid(weapon)) then
			weaponHoldType = self.animation:GetWeaponHoldType(player, weapon);
		
			if (weaponHoldType) then
				animationAct = animationAct.."_"..weaponHoldType;
			end;
		end;
		
		if (bIsRaised) then
			animationAct = animationAct.."_aim";
		end;
		
		if (velLength > 0.5) then
			animationAct = animationAct.."_walk";
		else
			animationAct = animationAct.."_idle";
		end;

		player.CalcIdeal = self.animation:GetForModel(model, animationAct);
		
		return true;
	end;
	
	return false;
end;

-- Called when the player's swimming animation should be handled.
function Clockwork:HandlePlayerSwimming(player)
	if (player:WaterLevel() >= 2) then
		if (player.m_bFirstSwimFrame) then
			player:AnimRestartMainSequence();
			player.m_bFirstSwimFrame = false;
		end;
		
		player.m_bInSwim = true;
	else
		player.m_bInSwim = false;
		
		if (!player.m_bFirstSwimFrame) then
			player.m_bFirstSwimFrame = true;
		end;
	end;
	
	return false;
end;

-- Called when the player's driving animation should be handled.
function Clockwork:HandlePlayerDriving(player)
	if (player:InVehicle()) then
		player.CalcIdeal = self.animation:GetForModel(player:GetModel(), "sit");
		return true;
	end;
	
	return false;
end;

-- Called when a player's animation is updated.
function Clockwork:UpdateAnimation(player, velocity, maxSeqGroundSpeed)
	local velLength = velocity:Length2D();
	local rate = 1.0;
	
	if (velLength > 0.5) then
		rate = ((velLength * 0.8) / maxSeqGroundSpeed);
	end
	
	player.cwPlaybackRate = math.Clamp(rate, 0, 1.5);
	player:SetPlaybackRate(player.cwPlaybackRate);
	
	if (player:InVehicle() and CLIENT) then
		local vehicle = player:GetVehicle();
		
		if (IsValid(vehicle)) then
			local velocity = vehicle:GetVelocity();
			local steer = (vehicle:GetPoseParameter("vehicle_steer") * 2) - 1;
			
			player:SetPoseParameter("vertical_velocity", velocity.z * 0.01);
			player:SetPoseParameter("vehicle_steer", steer);
		end;
	end;
end;

-- Called when the main activity should be calculated.
function Clockwork:CalcMainActivity(player, velocity)
	local model = player:GetModel();
	
	if (stringFind(model, "/player/")) then
		return cwBaseClass:CalcMainActivity(player, velocity);
	end;
	
	ANIMATION_PLAYER = player;
	
	local weapon = player:GetActiveWeapon();
	local bIsRaised = self.player:GetWeaponRaised(player, true);
	local animationAct = "stand";
	local weaponHoldType = "pistol";
	local forcedAnimation = player:GetForcedAnimation();

	if (IsValid(weapon)) then
		weaponHoldType = self.animation:GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = animationAct.."_"..weaponHoldType;
		end;
	end;
	
	if (bIsRaised) then
		animationAct = animationAct.."_aim";
	end;
	
	player.CalcIdeal = self.animation:GetForModel(model, animationAct.."_idle");
	player.CalcSeqOverride = -1;
	
	if (!self:HandlePlayerDriving(player)
	and !self:HandlePlayerJumping(player)
	and !self:HandlePlayerDucking(player, velocity)
	and !self:HandlePlayerSwimming(player)
	and !self:HandlePlayerNoClipping(player, velocity)
	and !self:HandlePlayerVaulting(player, velocity)) then
		local velLength = velocity:Length2D();
				
		if (player:IsRunning() or player:IsJogging()) then
			player.CalcIdeal = self.animation:GetForModel(model, animationAct.."_run");
		elseif (velLength > 0.5) then
			player.CalcIdeal = self.animation:GetForModel(model, animationAct.."_walk");
		end;
		
		if (CLIENT) then
			player:SetIK(false);
		end;
	end;
	
	if (forcedAnimation) then
		player.CalcSeqOverride = forcedAnimation.animation;
		
		if (forcedAnimation.OnAnimate) then
			forcedAnimation.OnAnimate(player);
			forcedAnimation.OnAnimate = nil;
		end;
	end;
	
	if (type(player.CalcSeqOverride) == "string") then
		player.CalcSeqOverride = player:LookupSequence(player.CalcSeqOverride);
	end;
	
	if (type(player.CalcIdeal) == "string") then
		player.CalcSeqOverride = player:LookupSequence(player.CalcIdeal);
	end;
	
	ANIMATION_PLAYER = nil;

	local eyeAngles = player:EyeAngles();
	local yaw = velocity:Angle().yaw;
	local normalized = mathNormalize(yaw - eyeAngles.y);

	player:SetPoseParameter("move_yaw", normalized);
	
	return player.CalcIdeal, player.CalcSeqOverride;
end;

local IdleActivity = ACT_HL2MP_IDLE;
local IdleActivityTranslate = {
	ACT_MP_ATTACK_CROUCH_PRIMARYFIRE = IdleActivity + 5,
	ACT_MP_ATTACK_STAND_PRIMARYFIRE = IdleActivity + 5,
	ACT_MP_RELOAD_CROUCH = IdleActivity + 6,
	ACT_MP_RELOAD_STAND = IdleActivity + 6,
	ACT_MP_CROUCH_IDLE = IdleActivity + 3,
	ACT_MP_STAND_IDLE = IdleActivity,
	ACT_MP_CROUCHWALK = IdleActivity + 4,
	ACT_MP_JUMP = ACT_HL2MP_JUMP_SLAM,
	ACT_MP_WALK = IdleActivity + 1,
	ACT_MP_RUN = IdleActivity + 2,
};
	
-- Called when a player's activity is supposed to be translated.
function Clockwork:TranslateActivity(player, act)
	local model = player:GetModel();
	local bIsRaised = self.player:GetWeaponRaised(player, true);
	
	if (string.find(model, "/player/")) then
		local newAct = player:TranslateWeaponActivity(act);
		
		if (!bIsRaised or act == newAct) then
			return IdleActivityTranslate[act];
		else
			return newAct;
		end;
	end;
	
	return act;
end;

-- Called when the animation event is supposed to be done.
function Clockwork:DoAnimationEvent(player, event, data)
	local model = player:GetModel();
	
	if (string.find(model, "/player/")) then
		return self.BaseClass:DoAnimationEvent(player, event, data);
	end;
	
	local weapon = player:GetActiveWeapon();
	local animationAct = "pistol";
	
	if (IsValid(weapon)) then
		weaponHoldType = self.animation:GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = weaponHoldType;
		end;
	end;
	
	if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
		local gestureSequence = self.animation:GetForModel(model, animationAct.."_attack");
		
		if (gestureSequence) then
			if (player:Crouching()) then
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			else
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			end;
		end;
		
		return ACT_VM_PRIMARYATTACK;
	elseif (event == PLAYERANIMEVENT_RELOAD) then
		local gestureSequence = self.animation:GetForModel(model, animationAct.."_reload");

		if (gestureSequence) then
			if (player:Crouching()) then
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			else
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			end;
		end;
		
		return ACT_INVALID;
	elseif (event == PLAYERANIMEVENT_JUMP) then
		player.m_bJumping = true;
		player.m_bFirstJumpFrame = true;
		player.m_flJumpStartTime = CurTime();
		
		player:AnimRestartMainSequence();
		
		return ACT_INVALID;
	elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
		player:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD);
		
		return ACT_INVALID;
	end;

	return nil;
end;

-- A function to explode a string by tags.
function Clockwork.kernel:ExplodeByTags(text, seperator, open, close, hide)
	local results = {};
	local current = "";
	local tag = nil;
	
	for i = 1, #text do
		local character = string.utf8sub(text, i, i);
		
		if (!tag) then
			if (character == open) then
				if (!hide) then
					current = current..character;
				end;
				
				tag = true;
			elseif (character == seperator) then
				results[#results + 1] = current; current = "";
			else
				current = current..character;
			end;
		else
			if (character == close) then
				if (!hide) then
					current = current..character;
				end;
				
				tag = nil;
			else
				current = current..character;
			end;
		end;
	end;
	
	if (current != "") then
		results[#results + 1] = current;
	end;
	
	return results;
end;

-- A function to modify a physical description.
function Clockwork.kernel:ModifyPhysDesc(description)
	if (string.utf8len(description) <= 128) then
		if (!string.find(string.utf8sub(description, -2), "%p")) then
			return description..".";
		else
			return description;
		end;
	else
		return string.utf8sub(description, 1, 125).."...";
	end;
end;

local MAGIC_CHARACTERS = "([%(%)%.%%%+%-%*%?%[%^%$])";

-- A function to replace something in text without pattern matching.
function Clockwork.kernel:Replace(text, find, replace)
	return (text:gsub(find:gsub(MAGIC_CHARACTERS, "%%%1"), replace));
end;

-- A function to create a new meta table.
function Clockwork.kernel:NewMetaTable(baseTable)
	local object = {};
		setmetatable(object, baseTable);
		baseTable.__index = baseTable;
	return object;
end;

-- A function to make a proxy meta table.
function Clockwork.kernel:MakeProxyTable(baseTable, baseClass, proxy)
	baseTable[proxy] = {};
	
	baseTable.__index = function(object, key)
		local value = rawget(object, key);
		
		if (type(value) == "function") then
			return value;
		elseif (object.__proxy) then
			return object:__proxy(key);
		else
			return object[proxy][key];
		end;
	end;
	
	baseTable.__newindex = function(object, key, value)
		if (type(value) ~= "function") then
			object[proxy][key] = value;
			return;
		end;
		
		rawset(object, key, value);
	end;
	
	for k, v in pairs(baseTable) do
		if (type(v) ~= "function" and k ~= proxy) then
			baseTable[proxy][k] = v;
			baseTable[k] = nil;
		end;
	end;
	
	setmetatable(baseTable, baseClass);
end;

-- A function to set whether a string should be in camel case.
function Clockwork.kernel:SetCamelCase(text, bCamelCase)
	if (bCamelCase) then
		return string.gsub(text, "^.", string.lower);
	else
		return string.gsub(text, "^.", string.upper);
	end;
end;

-- A function to add files to the content download.
function Clockwork.kernel:AddDirectory(directory, bRecursive)
	if (string.utf8sub(directory, -1) == "/") then
		directory = directory.."*.*";
	end;
	
	local files, folders = cwFile.Find(directory, "GAME", "namedesc");
	local rawDirectory = string.match(directory, "(.*)/").."/";
	
	for k, v in pairs(files) do
		self:AddFile(rawDirectory..v);
	end;
	
	if (bRecursive) then
		for k, v in pairs(folders) do
			if (v != ".." and v != ".") then
				self:AddDirectory(rawDirectory..v, true);
			end;
		end;
	end;
end;

-- A function to add a file to the content download.
function Clockwork.kernel:AddFile(fileName)
	if (cwFile.Exists(fileName, "GAME")) then
		resource.AddFile(fileName);
	else
		-- print(Format("[Clockwork] File does not exist: %s.", fileName));
	end;
end;

-- A function to include files in a directory.
function Clockwork.kernel:IncludeDirectory(directory, bFromBase)
	if (bFromBase) then
		directory = "clockwork/framework/"..directory;
	end;
	
	if (string.utf8sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	for k, v in pairs(cwFile.Find(directory.."*.lua", "LUA", "namedesc")) do
		self:IncludePrefixed(directory..v);
	end;
end;

-- A function to include a prefixed cwFile.
function Clockwork.kernel:IncludePrefixed(fileName)
	local isShared = (string.find(fileName, "sh_") or string.find(fileName, "shared.lua"));
	local isClient = (string.find(fileName, "cl_") or string.find(fileName, "cl_init.lua"));
	local isServer = (string.find(fileName, "sv_"));
	
	if (isServer and !SERVER) then
		return;
	end;
	
	if (isShared and SERVER) then
		AddCSLuaFile(fileName);
	elseif (isClient and SERVER) then
		AddCSLuaFile(fileName);
		return;
	end;
	
	local success, err = pcall(include, fileName);
	
	if (!success) then
		MsgN("[Clockwork] File System -> "..err);
	end;
end;

-- A function to include plugins in a directory.
function Clockwork.kernel:IncludePlugins(directory, bFromBase)
	if (bFromBase) then
		directory = "Clockwork/"..directory;
	end;
	
	if (string.utf8sub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	local files, pluginFolders = cwFile.Find(directory.."*", "LUA", "namedesc");
	
	for k, v in pairs(pluginFolders) do
		if (v != ".." and v != ".") then
			Clockwork.plugin:Include(directory..v.."/plugin");
		end;
	end;	
	
	return true;
end;

-- A function to perform the timer think.
function Clockwork.kernel:CallTimerThink(curTime)
	for k, v in pairs(Clockwork.Timers) do
		if (!v.paused) then
			if (curTime >= v.nextCall) then
				local bSuccess, value = pcall(v.Callback, unpack(v.arguments));
				
				if (!bSuccess) then
					MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..tostring(k).."' timer has failed to run.\n"..value.."\n");
				end;
				
				v.nextCall = curTime + v.delay;
				v.calls = v.calls + 1;
				
				if (v.calls == v.repetitions) then
					Clockwork.Timers[k] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to get whether a timer exists.
function Clockwork.kernel:TimerExists(name)
	return Clockwork.Timers[name];
end;

-- A function to start a timer.
function Clockwork.kernel:StartTimer(name)
	if (Clockwork.Timers[name] and Clockwork.Timers[name].paused) then
		Clockwork.Timers[name].nextCall = CurTime() + Clockwork.Timers[name].timeLeft;
		Clockwork.Timers[name].paused = nil;
	end;
end;

-- A function to pause a timer.
function Clockwork.kernel:PauseTimer(name)
	if (Clockwork.Timers[name] and !Clockwork.Timers[name].paused) then
		Clockwork.Timers[name].timeLeft = Clockwork.Timers[name].nextCall - CurTime();
		Clockwork.Timers[name].paused = true;
	end;
end;

-- A function to destroy a timer.
function Clockwork.kernel:DestroyTimer(name)
	Clockwork.Timers[name] = nil;
end;

-- A function to create a timer.
function Clockwork.kernel:CreateTimer(name, delay, repetitions, Callback, ...)
	Clockwork.Timers[name] = {
		calls = 0,
		delay = delay,
		nextCall = CurTime() + delay,
		Callback = Callback,
		arguments = {...},
		repetitions = repetitions
	};
end;

-- A function to run a function on the next frame.
function Clockwork.kernel:OnNextFrame(name, Callback)
	self:CreateTimer(name, FrameTime(), 1, Callback);
end;

-- A function to get whether a player has access to an object.
function Clockwork.kernel:HasObjectAccess(player, object)
	local hasAccess = false;
	local faction = player:GetFaction();
	
	if (object.access) then
		if (Clockwork.player:HasAnyFlags(player, object.access)) then
			hasAccess = true;
		end;
	end;
	
	if (object.factions) then
		if (table.HasValue(object.factions, faction)) then
			hasAccess = true;
		end;
	end;
	
	if (object.classes) then
		local team = player:Team();
		local class = Clockwork.class:FindByID(team);
		
		if (class) then
			if (table.HasValue(object.classes, team)
			or table.HasValue(object.classes, class.name)) then
				hasAccess = true;
			end;
		end;
	end;
	
	if (!object.access and !object.factions
	and !object.classes) then
		hasAccess = true;
	end;
	
	if (object.blacklist) then
		local team = player:Team();
		local class = Clockwork.class:FindByID(team);
		
		if (table.HasValue(object.blacklist, faction)) then
			hasAccess = false;
		elseif (class) then
			if (table.HasValue(object.blacklist, team)
			or table.HasValue(object.blacklist, class.name)) then
				hasAccess = false;
			end;
		else
			for k, v in pairs(object.blacklist) do
				if (type(v) == "string") then
					if (Clockwork.player:HasAnyFlags(player, v)) then
						hasAccess = false;
						
						break;
					end;
				end;
			end;
		end;
	end;
	
	if (object.HasObjectAccess) then
		return object:HasObjectAccess(player, hasAccess);
	end;
	
	return hasAccess;
end;

-- A function to get the sorted commands.
function Clockwork.kernel:GetSortedCommands()
	local commands = {};
	local source = Clockwork.command.stored;
	
	for k, v in pairs(source) do
		commands[#commands + 1] = k;
	end;
	
	table.sort(commands, function(a, b)
		return a < b;
	end);
	
	return commands;
end;

-- A function to zero a number to an amount of digits.
function Clockwork.kernel:ZeroNumberToDigits(number, digits)
	return string.rep("0", math.Clamp(digits - string.utf8len(tostring(number)), 0, digits))..tostring(number);
end;

-- A function to get a short CRC from a value.
function Clockwork.kernel:GetShortCRC(value)
	return math.ceil(util.CRC(value) / 100000);
end;

-- A function to validate a table's keys.
function Clockwork.kernel:ValidateTableKeys(baseTable)
	for i = 1, #baseTable do
		if (!baseTable[i]) then
			table.remove(baseTable, i);
		end;
	end;
end;

-- A function to get the map's physics entities.
function Clockwork.kernel:GetPhysicsEntities()
	local entities = {};
	
	for k, v in pairs(ents.FindByClass("prop_physicsmultiplayer")) do
		if (IsValid(v)) then
			entities[#entities + 1] = v;
		end;
	end;
	
	for k, v in pairs(ents.FindByClass("prop_physics")) do
		if (IsValid(v)) then
			entities[#entities + 1] = v;
		end;
	end;
	
	return entities;
end;

-- A function to create a multicall table (by Deco Da Man).
function Clockwork.kernel:CreateMulticallTable(baseTable, object)
	local metaTable = getmetatable(baseTable) or {};
		function metaTable.__index(baseTable, key)
			return function(baseTable, ...)
				for k, v in pairs(baseTable) do
					object[key](v, ...);
				end;
			end
		end
	setmetatable(baseTable, metaTable);
	
	return baseTable;
end;

local NETWORKED_VALUE_TABLE = {
	[NWTYPE_STRING] = "",
	[NWTYPE_ENTITY] = NULL,
	[NWTYPE_VECTOR] = Vector(0, 0, 0),
	[NWTYPE_NUMBER] = 0,
	[NWTYPE_ANGLE] = Angle(0, 0, 0),
	[NWTYPE_FLOAT] = 0.0,
	[NWTYPE_BOOL] = false
};

-- A function to get a default networked value.
function Clockwork.kernel:GetDefaultNetworkedValue(class)
	return NETWORKED_VALUE_TABLE[class];
end;

local NETWORKED_CLASS_TABLE = {
	[NWTYPE_STRING] = "String",
	[NWTYPE_ENTITY] = "Entity",
	[NWTYPE_VECTOR] = "Vector",
	[NWTYPE_NUMBER] = "Int",
	[NWTYPE_ANGLE] = "Angle",
	[NWTYPE_FLOAT] = "Float",
	[NWTYPE_BOOL] = "Bool"
};

-- A function to convert a networked class.
function Clockwork.kernel:ConvertNetworkedClass(class)
	return NETWORKED_CLASS_TABLE[class];
end;

local DEFAULT_NETWORK_CLASS_VALUE = {
	["String"] = "",
	["Entity"] = NULL,
	["Vector"] = Vector(0, 0, 0),
	["Int"] = 0,
	["Angle"] = Angle(0, 0, 0),
	["Float"] = 0.0,
	["Bool"] = false
};

-- A function to get the default class value.
function Clockwork.kernel:GetDefaultClassValue(class)
	return DEFAULT_NETWORK_CLASS_VALUE[class];
end;

-- A function to set a shared variable.
function Clockwork.kernel:SetSharedVar(key, value, sharedTable)
	if (!sharedTable) then
		local sharedVars = self:GetSharedVars():Global();
	
		if (sharedVars and sharedVars[key]) then
			local class = self:ConvertNetworkedClass(sharedVars[key].class);
			if (class) then
				if (value == nil) then
					value = self:GetDefaultClassValue(class);
				end;
				local success, err = pcall(_G["SetGlobal"..class], key, value);
				if (!success) then
					MsgC(Color(255, 100, 0, 255), "[Clockwork:GlobalSharedVars] Attempted to set SharedVar '"..key.."'' of type '"..class.."'' with value of type '"..type(value).."'.\n"..err.."\n");
				end;
				return;
			end;
		end;
	else
		Clockwork.SharedTables[sharedTable] = Clockwork.SharedTables[sharedTable] or {};
		Clockwork.SharedTables[sharedTable][key] = value;

		if (SERVER) then
			Clockwork.datastream:Start(nil, "SetSharedTableVar", {sharedTable = sharedTable, key = key, value = value});
		end;
	end;
end;

-- A function to get the shared vars.
function Clockwork.kernel:GetSharedVars()
	return Clockwork.SharedVars, Clockwork.SharedTables;
end;

-- A function to get a shared variable.
function Clockwork.kernel:GetSharedVar(key, sharedTable)
	if (!sharedTable) then
		local sharedVars = self:GetSharedVars():Global();
		if (sharedVars and sharedVars[key]) then
			local class = self:ConvertNetworkedClass(sharedVars[key].class);
		
			if (class) then
				return _G["GetGlobal"..class](key);
			end;
		end;
	else
		sharedTable = Clockwork.SharedTables[sharedTable];
		
		if (sharedTable) then
			return sharedTable[key];
		end;
	end;
end;

-- A function to create fake damage info.
function Clockwork.kernel:FakeDamageInfo(damage, inflictor, attacker, position, damageType, damageForce)
	local damageInfo = DamageInfo();
	local realDamage = math.ceil(math.max(damage, 0));
	
	damageInfo:SetDamagePosition(position);
	damageInfo:SetDamageForce(Vector() * damageForce);
	damageInfo:SetDamageType(damageType);
	damageInfo:SetInflictor(inflictor);
	damageInfo:SetAttacker(attacker);
	damageInfo:SetDamage(realDamage);
	
	return damageInfo;
end;

-- A function to unpack a color.
function Clockwork.kernel:UnpackColor(color)
	return color.r, color.g, color.b, color.a;
end;

-- A function to parse data in text.
function Clockwork.kernel:ParseData(text)
	local classes = {"%^", "%!"};
	
	for k, v in pairs(classes) do
		for key in string.gmatch(text, v.."(.-)"..v) do
			local lower = false;
			local amount;
			
			if (string.utf8sub(key, 1, 1) == "(" and string.utf8sub(key, -1) == ")") then
				lower = true;
				amount = tonumber(string.utf8sub(key, 2, -2));
			else
				amount = tonumber(key);
			end;
			
			if (amount) then
				text = string.gsub(text, v..string.gsub(key, "([%(%)])", "%%%1")..v, tostring(self:FormatCash(amount, k == 2, lower)));
			end;
		end;
	end;
	
	for k in string.gmatch(text, "%*(.-)%*") do
		k = string.gsub(k, "[%(%)]", "");
		
		if (k != "") then
			text = string.gsub(text, "%*%("..k.."%)%*", tostring(Clockwork.option:GetKey(k, true)));
			text = string.gsub(text, "%*"..k.."%*", tostring(Clockwork.option:GetKey(k)));
		end;
	end;
	
	if (CLIENT) then
		for k in string.gmatch(text, ":(.-):") do
			if (k != "" and input.LookupBinding(k)) then
				text = self:Replace(text, ":"..k..":", "<"..string.upper(tostring(input.LookupBinding(k)))..">");
			end;
		end;
	end;
	
	return Clockwork.config:Parse(text);
end;