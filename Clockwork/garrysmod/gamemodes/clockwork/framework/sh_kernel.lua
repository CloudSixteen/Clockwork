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
		local c = string.sub(url, i, i);
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
	local toRemoveLen = string.len(toRemove);
	if (string.sub(text, -toRemoveLen) == toRemove) then
		return (string.sub(text, 0, -(toRemoveLen + 1)));
	else
		return text;
	end;
end;

-- A function to split a string.
function Clockwork.kernel:SplitString(text, interval)
	local length = string.len(text);
	local baseTable = {};
	local i = 0;
	
	while (i * interval < length) do
		baseTable[i + 1] = string.sub(text, i * interval + 1, (i + 1) * interval);
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
	if (string.sub(text, -2) != "fe") then
		local lastLetter = string.sub(text, -1);
		
		if (lastLetter == "y") then
			if (self:IsVowel(string.sub(text, string.len(text) - 1, 2))) then
				return string.sub(text, 1, -2).."ies";
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
		return string.sub(text, 1, -3).."ves";
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
	
	if (string.find(model, "/player/")) then
		return self.BaseClass:CalcMainActivity(player, velocity);
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
	local normalized = math.NormalizeAngle(yaw - eyeAngles.y);

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

if (SERVER) then
	local ServerLog = ServerLog;
	local cvars = cvars;

	Clockwork.Entities = {};
	Clockwork.TempPlayerData = {};
	Clockwork.HitGroupBonesCache = {
		{"ValveBiped.Bip01_R_UpperArm", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_R_Forearm", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_L_UpperArm", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_L_Forearm", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_R_Thigh", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Calf", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Foot", HITGROUP_RIGHTLEG},
		{"ValveBiped.Bip01_R_Hand", HITGROUP_RIGHTARM},
		{"ValveBiped.Bip01_L_Thigh", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Calf", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Foot", HITGROUP_LEFTLEG},
		{"ValveBiped.Bip01_L_Hand", HITGROUP_LEFTARM},
		{"ValveBiped.Bip01_Pelvis", HITGROUP_STOMACH},
		{"ValveBiped.Bip01_Spine2", HITGROUP_CHEST},
		{"ValveBiped.Bip01_Spine1", HITGROUP_CHEST},
		{"ValveBiped.Bip01_Head1", HITGROUP_HEAD},
		{"ValveBiped.Bip01_Neck1", HITGROUP_HEAD}
	};
	Clockwork.MeleeTranslation = {
		[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
		[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_MELEE2,
		[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_MELEE2,
		[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_MELEE2,
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1_MELEE2,
		[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_MELEE2,
		[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_MELEE2,
		[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_MELEE2,
		[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_MELEE2
	};
	
	-- A function to save schema data.
	function Clockwork.kernel:SaveSchemaData(fileName, data)
		if (type(data) != "table") then
			ErrorNoHalt("[Clockwork] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			return;
		end;
	
		return Clockwork.file:Write("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", self:Serialize(data));
	end;

	-- A function to delete schema data.
	function Clockwork.kernel:DeleteSchemaData(fileName)
		return Clockwork.file:Delete("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw");
	end;

	-- A function to check if schema data exists.
	function Clockwork.kernel:SchemaDataExists(fileName)
		return cwFile.Exists("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", "GAME");
	end;
	
	-- A function to get the schema data path.
	function Clockwork.kernel:GetSchemaDataPath()
		return "settings/clockwork/schemas/"..self:GetSchemaFolder();
	end;
	
	local SCHEMA_GAMEMODE_INFO = nil;
	
	-- A function to get the schema gamemode info.
	function Clockwork.kernel:GetSchemaGamemodeInfo()
		if (SCHEMA_GAMEMODE_INFO) then return SCHEMA_GAMEMODE_INFO; end;
		
		local schemaFolder = string.lower(self:GetSchemaFolder());
		local schemaData = util.KeyValuesToTable(
			Clockwork.file:Read("gamemodes/"..schemaFolder.."/"..schemaFolder..".txt")
		);
		
		if (not schemaData) then
			schemaData = {};
		end;
		
		if (schemaData["Gamemode"]) then
			schemaData = schemaData["Gamemode"];
		end;
		
		SCHEMA_GAMEMODE_INFO = {};
			SCHEMA_GAMEMODE_INFO["name"] = schemaData["title"] or "Undefined";
			SCHEMA_GAMEMODE_INFO["author"] = schemaData["author"] or "Undefined";
			SCHEMA_GAMEMODE_INFO["description"] = schemaData["description"] or "Undefined";
		return SCHEMA_GAMEMODE_INFO;
	end;
	
	-- A function to get the schema gamemode name.
	function Clockwork.kernel:GetSchemaGamemodeName()
		local schemaInfo = self:GetSchemaGamemodeInfo();
		return schemaInfo["name"];
	end;
	
	-- A function to find schema data in a directory.
	function Clockwork.kernel:FindSchemaDataInDir(directory)
		return cwFile.Find("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..directory, "GAME");
	end;

	-- A function to restore schema data.
	function Clockwork.kernel:RestoreSchemaData(fileName, failSafe)
		if (self:SchemaDataExists(fileName)) then
			local data = Clockwork.file:Read("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", "namedesc");
			
			if (data) then
				local bSuccess, value = pcall(util.JSONToTable, data);
				
				if (bSuccess and value != nil) then
					return value;
				else
					local bSuccess, value = pcall(self.Deserialize, self, data);
					
					if (bSuccess and value != nil) then
						return value;
					else
						ErrorNoHalt("[Clockwork] '"..fileName.."' schema data has failed to restore.\n"..value.."\n");
						
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
			local data = Clockwork.file:Read("settings/clockwork/"..fileName..".cw");
			
			if (data) then
				local bSuccess, value = pcall(util.JSONToTable, data);
				
				if (bSuccess and value != nil) then
					return value;
				else
					local bSuccess, value = pcall(self.Deserialize, self, data);
					
					if (bSuccess and value != nil) then
						return value;
					else
						ErrorNoHalt("[Clockwork] '"..fileName.."' clockwork data has failed to restore.\n"..value.."\n");
						
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
	
	-- A function to setup a full directory.
	function Clockwork.kernel:SetupFullDirectory(filePath)
		local directory = string.gsub(self:GetPathToGMod()..filePath, "\\", "/");
		local exploded = string.Explode("/", directory);
		local currentPath = "";
		
		for k, v in pairs(exploded) do
			if (k < #exploded) then
				currentPath = currentPath..v.."/";
				Clockwork.file:MakeDirectory(currentPath);
			end;
		end;
		
		return currentPath..exploded[#exploded];
	end;

	-- A function to save Clockwork data.
	function Clockwork.kernel:SaveClockworkData(fileName, data)
		if (type(data) != "table") then
			ErrorNoHalt("[Clockwork] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
			return;
		end;
	
		return Clockwork.file:Write("settings/clockwork/"..fileName..".cw", self:Serialize(data));
	end;

	-- A function to check if Clockwork data exists.
	function Clockwork.kernel:ClockworkDataExists(fileName)
		return cwFile.Exists("settings/clockwork/"..fileName..".cw", "GAME");
	end;

	-- A function to delete Clockwork data.
	function Clockwork.kernel:DeleteClockworkData(fileName)
		return Clockwork.file:Delete("settings/clockwork/"..fileName..".cw");
	end;

	-- A function to convert a force.
	function Clockwork.kernel:ConvertForce(force, limit)
		local forceLength = force:Length();
		
		if (forceLength == 0) then
			return Vector(0, 0, 0);
		end;
		
		if (!limit) then
			limit = 800;
		end;
		
		if (forceLength > limit) then
			return force / (forceLength / limit);
		else
			return force;
		end;
	end;
	
	-- A function to save a player's attribute boosts.
	function Clockwork.kernel:SavePlayerAttributeBoosts(player, data)
		local attributeBoosts = player:GetAttributeBoosts();
		local curTime = CurTime();
		
		if (data["AttrBoosts"]) then
			data["AttrBoosts"] = nil;
		end;
		
		if (table.Count(attributeBoosts) > 0) then
			data["AttrBoosts"] = {};
			
			for k, v in pairs(attributeBoosts) do
				data["AttrBoosts"][k] = {};
				
				for k2, v2 in pairs(v) do
					if (v2.duration) then
						if (curTime < v2.endTime) then
							data["AttrBoosts"][k][k2] = {
								duration = math.ceil(v2.endTime - curTime),
								amount = v2.amount
							};
						end;
					else
						data["AttrBoosts"][k][k2] = {
							amount = v2.amount
						};
					end;
				end;
			end;
		end;
	end;
	
	-- A function to calculate a player's spawn time.
	function Clockwork.kernel:CalculateSpawnTime(player, inflictor, attacker, damageInfo)
		local info = {
			attacker = attacker,
			inflictor = inflictor,
			spawnTime = Clockwork.config:Get("spawn_time"):Get(),
			damageInfo = damageInfo
		};

		Clockwork.plugin:Call("PlayerAdjustDeathInfo", player, info);

		if (info.spawnTime and info.spawnTime > 0) then
			Clockwork.player:SetAction(player, "spawn", info.spawnTime, 3);
		end;
	end;
	
	-- A function to create a decal.
	function Clockwork.kernel:CreateDecal(texture, position, temporary)
		local decal = ents.Create("infodecal");
		
		if (temporary) then
			decal:SetKeyValue("LowPriority", "true");
		end;
		
		decal:SetKeyValue("Texture", texture);
		decal:SetPos(position);
		decal:Spawn();
		decal:Fire("activate");
		
		return decal;
	end;
	
	-- A function to handle a player's weapon fire delay.
	function Clockwork.kernel:HandleWeaponFireDelay(player, bIsRaised, weapon, curTime)
		local delaySecondaryFire = nil;
		local delayPrimaryFire = nil;
		
		if (!Clockwork.plugin:Call("PlayerCanFireWeapon", player, bIsRaised, weapon, true)) then
			delaySecondaryFire = curTime + 60;
		end;
		
		if (!Clockwork.plugin:Call("PlayerCanFireWeapon", player, bIsRaised, weapon)) then
			delayPrimaryFire = curTime + 60;
		end;
		
		if (delaySecondaryFire == nil and weapon.secondaryFireDelayed) then
			weapon:SetNextSecondaryFire(weapon.secondaryFireDelayed);
			weapon.secondaryFireDelayed = nil;
		end;
		
		if (delayPrimaryFire == nil and weapon.primaryFireDelayed) then
			weapon:SetNextPrimaryFire(weapon.primaryFireDelayed);
			weapon.primaryFireDelayed = nil;
		end;
		
		if (delaySecondaryFire) then
			if (!weapon.secondaryFireDelayed) then
				weapon.secondaryFireDelayed = weapon:GetNextSecondaryFire();
			end;
			
			--[[
				This is a terrible hotfix for the SMG not being able 
				to fire after loading ammunition.
			--]]
			if (weapon:GetClass() != "weapon_smg1") then
				weapon:SetNextSecondaryFire(delaySecondaryFire);
			end;
		end;
		
		if (delayPrimaryFire) then
			if (!weapon.primaryFireDelayed) then
				weapon.primaryFireDelayed = weapon:GetNextPrimaryFire();
			end;
			
			weapon:SetNextPrimaryFire(delayPrimaryFire);
		end;
	end;
	
	-- A function to scale damage by hit group.
	function Clockwork:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
		if (!damageInfo:IsFallDamage() and !damageInfo:IsDamageType(DMG_CRUSH)) then
			if (hitGroup == HITGROUP_HEAD) then
				damageInfo:ScaleDamage(self.config:Get("scale_head_dmg"):Get());
			elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
				damageInfo:ScaleDamage(self.config:Get("scale_chest_dmg"):Get());
			elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
			or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR) then
				damageInfo:ScaleDamage(self.config:Get("scale_limb_dmg"):Get());
			end;
		end;
		
		self.plugin:Call("PlayerScaleDamageByHitGroup", player, attacker, hitGroup, damageInfo, baseDamage);
	end;
	
	-- A function to calculate player damage.
	function Clockwork.kernel:CalculatePlayerDamage(player, hitGroup, damageInfo)
		local bDamageIsValid = damageInfo:IsBulletDamage() or damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		local bHitGroupIsValid = true;
		
		if (Clockwork.config:Get("armor_chest_only"):Get()) then
			if (hitGroup != HITGROUP_CHEST and hitGroup != HITGROUP_GENERIC) then
				bHitGroupIsValid = nil;
			end;
		end;
		
		if (player:Armor() > 0 and bDamageIsValid and bHitGroupIsValid) then
			local armor = player:Armor() - damageInfo:GetDamage();
			
			if (armor < 0) then
				Clockwork.limb:TakeDamage(player, hitGroup, damageInfo:GetDamage() * 2);
				player:SetHealth(math.max(player:Health() - math.abs(armor), 1));
				player:SetArmor(math.max(armor, 0));
			else
				player:SetArmor(math.max(armor, 0));
			end;
		else
			Clockwork.limb:TakeDamage(player, hitGroup, damageInfo:GetDamage() * 2);
			player:SetHealth(math.max(player:Health() - damageInfo:GetDamage(), 1));
		end;
		
		if (damageInfo:IsFallDamage()) then
			Clockwork.limb:TakeDamage(player, HITGROUP_RIGHTLEG, damageInfo:GetDamage());
			Clockwork.limb:TakeDamage(player, HITGROUP_LEFTLEG, damageInfo:GetDamage());
		end;
	end;
	
	-- A function to get a ragdoll's hit bone.
	function Clockwork.kernel:GetRagdollHitBone(entity, position, failSafe, minimum)
		local closest = {};
		
		for k, v in pairs(Clockwork.HitGroupBonesCache) do
			local bone = entity:LookupBone(v[1]);
			
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				if (bonePosition) then
					local distance = bonePosition:Distance(position);
					
					if (!closest[1] or distance < closest[1]) then
						if (!minimum or distance <= minimum) then
							closest[1] = distance;
							closest[2] = bone;
						end;
					end;
				end;
			end;
		end;
		
		if (closest[2]) then
			return closest[2];
		else
			return failSafe;
		end;
	end;
	
	-- A function to get a ragdoll's hit group.
	function Clockwork.kernel:GetRagdollHitGroup(entity, position)
		local closest = {nil, HITGROUP_GENERIC};
		
		for k, v in pairs(Clockwork.HitGroupBonesCache) do
			local bone = entity:LookupBone(v[1]);
			
			if (bone) then
				local bonePosition = entity:GetBonePosition(bone);
				
				if (position) then
					local distance = bonePosition:Distance(position);
					
					if (!closest[1] or distance < closest[1]) then
						closest[1] = distance;
						closest[2] = v[2];
					end;
				end;
			end;
		end;
		
		return closest[2];
	end;

	-- A function to create blood effects at a position.
	function Clockwork.kernel:CreateBloodEffects(position, decals, entity, forceVec, fScale)
		if (!entity.cwNextBlood or CurTime() >= entity.cwNextBlood) then
			local effectData = EffectData();
				effectData:SetOrigin(position);
				effectData:SetNormal(forceVec or (VectorRand() * 80));
				effectData:SetScale(fScale or 0.5);
			util.Effect("cw_bloodsmoke", effectData, true, true);
			
			local effectData = EffectData();
				effectData:SetOrigin(position);
				effectData:SetEntity(entity);
				effectData:SetStart(position);
				effectData:SetScale(fScale or 0.5);
			util.Effect("BloodImpact", effectData, true, true);
			
			for i = 1, decals do
				local trace = {};
					trace.start = position;
					trace.endpos = trace.start;
					trace.filter = entity;
				trace = util.TraceLine(trace);
				
				util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			end;
			
			entity.cwNextBlood = CurTime() + 0.5;
		end;
	end;
	
	-- A function to do the entity take damage hook.
	function Clockwork.kernel:DoEntityTakeDamageHook(arguments)
		local entity = arguments[1];
		local damageInfo = arguments[2];
		
		if (!IsValid(entity)) then
			return;
		end;		
		
		local inflictor = damageInfo:GetInflictor();
		local attacker = damageInfo:GetAttacker();
		local amount = damageInfo:GetDamage();
	
		if (amount != damageInfo:GetDamage()) then
			amount = damageInfo:GetDamage();
		end;
		
		local player = Clockwork.entity:GetPlayer(entity);
		
		if (player) then
			local ragdoll = player:GetRagdollEntity();
			
			if (!hook.Call("PlayerShouldTakeDamage", Clockwork, player, attacker, inflictor, damageInfo)
			or player:IsInGodMode()) then
				damageInfo:SetDamage(0);
				
				return true;
			end;
			
			if (ragdoll and entity != ragdoll) then
				hook.Call("EntityTakeDamage", Clockwork, ragdoll, damageInfo);
				damageInfo:SetDamage(0);
				
				return true;
			end;
			
			if (entity == ragdoll) then
				local physicsObject = entity:GetPhysicsObject();
				
				if (IsValid(physicsObject)) then
					local velocity = physicsObject:GetVelocity():Length();
					local curTime = CurTime();
					
					if (damageInfo:IsDamageType(DMG_CRUSH)) then
						if (entity.cwNextFallDamage
						and curTime < entity.cwNextFallDamage) then
							damageInfo:SetDamage(0);
							return true;
						end;
						
						amount = hook.Call("GetFallDamage", Clockwork, player, velocity);
						entity.cwNextFallDamage = curTime + 1;
						damageInfo:SetDamage(amount)
					end;
				end;
			end;
		end;
	end;
	
	-- A function to perform the date and time think.
	function Clockwork.kernel:PerformDateTimeThink()
		local defaultDays = Clockwork.option:GetKey("default_days");
		local minute = Clockwork.time:GetMinute();
		local month = Clockwork.date:GetMonth();
		local year = Clockwork.date:GetYear();
		local hour = Clockwork.time:GetHour();
		local day = Clockwork.time:GetDay();
		
		Clockwork.time.minute = Clockwork.time:GetMinute() + 1;
		
		if (Clockwork.time:GetMinute() == 60) then
			Clockwork.time.minute = 0;
			Clockwork.time.hour = Clockwork.time:GetHour() + 1;
			
			if (Clockwork.time:GetHour() == 24) then
				Clockwork.time.hour = 0;
				Clockwork.time.day = Clockwork.time:GetDay() + 1;
				Clockwork.date.day = Clockwork.date:GetDay() + 1;
				
				if (Clockwork.time:GetDay() == #defaultDays + 1) then
					Clockwork.time.day = 1;
				end;
				
				if (Clockwork.date:GetDay() == 31) then
					Clockwork.date.day = 1;
					Clockwork.date.month = Clockwork.date:GetMonth() + 1;
					
					if (Clockwork.date:GetMonth() == 13) then
						Clockwork.date.month = 1;
						Clockwork.date.year = Clockwork.date:GetYear() + 1;
					end;
				end;
			end;
		end;
		
		if (Clockwork.time:GetMinute() != minute) then
			Clockwork.plugin:Call("TimePassed", TIME_MINUTE);
		end;
		
		if (Clockwork.time:GetHour() != hour) then
			Clockwork.plugin:Call("TimePassed", TIME_HOUR);
		end;
		
		if (Clockwork.time:GetDay() != day) then
			Clockwork.plugin:Call("TimePassed", TIME_DAY);
		end;
		
		if (Clockwork.date:GetMonth() != month) then
			Clockwork.plugin:Call("TimePassed", TIME_MONTH);
		end;
		
		if (Clockwork.date:GetYear() != year) then
			Clockwork.plugin:Call("TimePassed", TIME_YEAR);
		end;
		
		local month = self:ZeroNumberToDigits(Clockwork.date:GetMonth(), 2);
		local day = self:ZeroNumberToDigits(Clockwork.date:GetDay(), 2);
		
		self:SetSharedVar("Minute", Clockwork.time:GetMinute());
		self:SetSharedVar("Hour", Clockwork.time:GetHour());
		self:SetSharedVar("Date", day.."/"..month.."/"..Clockwork.date:GetYear());
		self:SetSharedVar("Day", Clockwork.time:GetDay());
	end;
	
	-- A function to create a ConVar.
	function Clockwork.kernel:CreateConVar(name, value, flags, Callback)
		local conVar = CreateConVar(name, value, flags or FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE);
		
		cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
			Clockwork.plugin:Call("ClockworkConVarChanged", conVar, previousValue, newValue);
			
			if (Callback) then
				Callback(conVar, previousValue, newValue);
			end;
		end);
		
		return conVar;
	end;
	
	-- A function to check if the server is shutting down.
	function Clockwork.kernel:IsShuttingDown()
		return Clockwork.ShuttingDown;
	end;
	
	-- A function to distribute wages cash.
	function Clockwork.kernel:DistributeWagesCash()
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v:HasInitialized() and v:Alive()) then
				local wages = v:GetWages();
				
				if (Clockwork.plugin:Call("PlayerCanEarnWagesCash", v, wages)) then
					if (wages > 0) then
						if (Clockwork.plugin:Call("PlayerGiveWagesCash", v, wages, v:GetWagesName())) then
							Clockwork.player:GiveCash(v, wages, v:GetWagesName());
						end;
					end;
					
					Clockwork.plugin:Call("PlayerEarnWagesCash", v, wages);
				end;
			end;
		end;
	end;
	
	-- A function to distribute generator cash.
	function Clockwork.kernel:DistributeGeneratorCash()
		local generatorEntities = {};
		
		for k, v in pairs(Clockwork.generator:GetAll()) do
			table.Add(generatorEntities, ents.FindByClass(k));
		end;
		
		for k, v in pairs(generatorEntities) do
			local generator = Clockwork.generator:FindByID(v:GetClass());
			local player = v:GetPlayer();
			
			if (IsValid(player) and v:GetPower() != 0) then
				local info = {
					generator = generator,
					entity = v,
					cash = generator.cash,
					name = "Generator"
				};
				
				v:SetDTInt(0, math.max(v:GetPower() - 1, 0));
				Clockwork.plugin:Call("PlayerAdjustEarnGeneratorInfo", player, info);
				
				if (Clockwork.plugin:Call("PlayerCanEarnGeneratorCash", player, info, info.cash)) then
					if (v.OnEarned) then
						local result = v:OnEarned(player, info.cash);
						
						if (type(result) == "number") then
							info.cash = result;
						end;
						
						if (result != false) then
							if (result != true) then
								Clockwork.player:GiveCash(k, info.cash, info.name);
							end;
							
							Clockwork.plugin:Call("PlayerEarnGeneratorCash", player, info, info.cash);
						end;
					else
						Clockwork.player:GiveCash(k, info.cash, info.name);
						Clockwork.plugin:Call("PlayerEarnGeneratorCash", player, info, info.cash);
					end;
				end;
			end;
		end;
	end;
	
	-- A function to include the schema.
	function Clockwork.kernel:IncludeSchema()
		return CloudAuthX.kernel:IncludeSchema();
	end;
	
	-- A function to print a log message.
	function Clockwork.kernel:PrintLog(logType, text)
		local listeners = {};
		
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v:HasInitialized() and v:GetInfoNum("cwShowLog", 0) == 1) then
				if (Clockwork.player:IsAdmin(v)) then
					listeners[#listeners + 1] = v;
				end;
			end;
		end;
		
		Clockwork.datastream:Start(listeners, "Log", {
			logType = (logType or 5), text = text
		});
		
		if (CW_CONVAR_LOG:GetInt() == 1 and game.IsDedicated()) then
			self:ServerLog(text);
		end;
	end;
	
	-- A function to log to the server.
	function Clockwork.kernel:ServerLog(text)
		local dateInfo = os.date("*t");
		local unixTime = os.time();
		
		if (dateInfo) then
			if (dateInfo.month < 10) then dateInfo.month = "0"..dateInfo.month; end;
			if (dateInfo.day < 10) then dateInfo.day = "0"..dateInfo.day; end;
			local fileName = dateInfo.year.."-"..dateInfo.month.."-"..dateInfo.day;
			
			if (dateInfo.hour < 10) then dateInfo.hour = "0"..dateInfo.hour; end;
			if (dateInfo.min < 10) then dateInfo.min = "0"..dateInfo.min; end;
			if (dateInfo.sec < 10) then dateInfo.sec = "0"..dateInfo.sec; end;
			local time = dateInfo.hour..":"..dateInfo.min..":"..dateInfo.sec;
			local logText = time..": "..string.gsub(text, "\n", "");

			Clockwork.file:Append("logs/clockwork/"..fileName..".log", logText.."\n");
		end;
	
		ServerLog(text.."\n"); Clockwork.plugin:Call("ClockworkLog", text, unixTime);
	end;
else
	local CreateClientConVar = CreateClientConVar;
	local CloseDermaMenus = CloseDermaMenus;
	local ChangeTooltip = ChangeTooltip;
	local ScreenScale = ScreenScale;
	local FrameTime = FrameTime;
	local DermaMenu = DermaMenu;
	local ScrW = ScrW;
	local ScrH = ScrH;
	local surface = surface;
	local render = render;
	local draw = draw;
	local vgui = vgui;
	local cam = cam;
	local gui = gui;

	Clockwork.BackgroundBlurs = Clockwork.BackgroundBlurs or {};
	Clockwork.RecognisedNames = Clockwork.RecognisedNames or {};
	Clockwork.NetworkProxies = Clockwork.NetworkProxies or {};
	Clockwork.AccessoryData = Clockwork.AccessoryData or {};
	Clockwork.InfoMenuOpen = false;
	Clockwork.ColorModify = Clockwork.ColorModify or {};
	Clockwork.ClothesData = Clockwork.ClothesData or {};
	Clockwork.Cinematics = Clockwork.Cinematics or {};
	Clockwork.kernel.ESPInfo = Clockwork.kernel.ESPInfo or {};
	Clockwork.kernel.Hints = Clockwork.kernel.Hints or {};

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
		--[[
			This will be the new method.
			return size * (ScrH() / 480.0);
		--]]
	
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
			local textWidth, textHeight = self:GetCachedTextSize(font, string.sub(text, currentCharacter, currentCharacter));

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
				local currentCharacter = string.sub(text, i, i);
				local currentSingleWidth = Clockwork.kernel:GetTextSize(font, currentCharacter);
				
				if ((currentWidth + currentSingleWidth) >= maximumWidth) then
					baseTable[#baseTable + 1] = string.sub(text, 0, (i - 1));
					text = string.sub(text, i);
					
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
			
			if (position) then
				if (type(v.text) == "string") then
					self:DrawSimpleText(v.text, position.x, position.y, v.color or colorWhite, 1, 1);
				else
					
					for k2, v2 in ipairs(v.text) do
						local text, color, width, height;
											
						if (type(v2) == "string") then
							text = v2;
							color = v.color;
							v2 = {text, color};
						else
							text = v2[1];
							color = v2[2];
						end;
									
						if (k2 > 1) then
							self:OverrideMainFont(Clockwork.option:GetFont("esp_text"));
							width, height = surface.GetTextSize(text);							
						else
							self:OverrideMainFont(false);
							width, height = surface.GetTextSize(text);
						end;
						
						self:DrawSimpleText(text, position.x, position.y, color or colorWhite, 1, 1);
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
		if (class != NOTIFY_HINT or string.sub(text, 1, 6) != "#Hint_") then
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
			ErrorNoHalt("[Clockwork] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
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
						ErrorNoHalt("[Clockwork] '"..fileName.."' schema data has failed to restore.\n"..value.."\n");
						
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
						ErrorNoHalt("[Clockwork] '"..fileName.."' clockwork data has failed to restore.\n"..value.."\n");
						
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
			ErrorNoHalt("[Clockwork] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
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
end;

-- A function to explode a string by tags.
function Clockwork.kernel:ExplodeByTags(text, seperator, open, close, hide)
	local results = {};
	local current = "";
	local tag = nil;
	
	for i = 1, #text do
		local character = string.sub(text, i, i);
		
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
	if (string.len(description) <= 128) then
		if (!string.find(string.sub(description, -2), "%p")) then
			return description..".";
		else
			return description;
		end;
	else
		return string.sub(description, 1, 125).."...";
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
	if (string.sub(directory, -1) == "/") then
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
		directory = "Clockwork/framework/"..directory;
	end;
	
	if (string.sub(directory, -1) != "/") then
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
	
	if (string.sub(directory, -1) != "/") then
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
					ErrorNoHalt("[Clockwork] The '"..tostring(k).."' timer has failed to run.\n"..value.."\n");
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
	return string.rep("0", math.Clamp(digits - string.len(tostring(number)), 0, digits))..tostring(number);
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

-- A function to get the default class value.
function Clockwork.kernel:GetDefaultClassValue(class)
	local convertTable = {
		["String"] = "",
		["Entity"] = NULL,
		["Vector"] = Vector(0, 0, 0),
		["Int"] = 0,
		["Angle"] = Angle(0, 0, 0),
		["Float"] = 0.0,
		["Bool"] = false
	};
	
	return convertTable[class];
end;

-- A function to set a shared variable.
function Clockwork.kernel:SetSharedVar(key, value, sharedTable)
	if (!sharedTable) then
		local sharedVars = self:GetSharedVars():Global();
	
		if (sharedVars and sharedVars[key]) then
			local class = self:ConvertNetworkedClass(sharedVars.class);
		
			if (class) then
				if (value == nil) then
					value = Clockwork:GetDefaultClassValue(class);
				end;
			
				_G["SetGlobal"..class](key, value);
				return;
			end;
		end;
	
		SetGlobalVar(key, value);
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
			local class = self:ConvertNetworkedClass(sharedVars.class);
		
			if (class) then
				return _G["GetGlobal"..class](key);
			end;
		end;
	
		return GetGlobalVar(key);
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
			
			if (string.sub(key, 1, 1) == "(" and string.sub(key, -1) == ")") then
				lower = true;
				amount = tonumber(string.sub(key, 2, -2));
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
