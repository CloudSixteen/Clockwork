--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
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

--[[ Math Library Localizations --]]
local mathNormalizeAngle = math.NormalizeAngle;
local mathApproach = math.Approach;
local mathRandom = math.random;
local mathRound = math.Round;
local mathClamp = math.Clamp;
local mathFloor = math.floor;
local mathCeil = math.ceil;
local mathSin = math.sin;
local mathMin = math.min;
local mathMax = math.max;
local mathAbs = math.abs;

--[[ String Library Localizations --]]
local stringExplode = string.Explode;
local stringFormat = string.format;
local stringGmatch = string.gmatch;
local stringSub = string.utf8sub;
local stringLen = string.utf8len;
local stringLower = string.lower;
local stringUpper = string.upper;
local stringMatch = string.match;
local stringFind = string.find;
local stringGsub = string.gsub;
local stringByte = string.byte;
local stringRep = string.rep;

--[[ Table Library Localizations --]]
local tableHasValue = table.HasValue;
local tableInsert = table.insert;
local tableRemove = table.remove;
local tableCount = table.Count;
local tableSort = table.sort;
local tableAdd = table.Add;

Clockwork.kernel = Clockwork.kernel or {};
Clockwork.Timers = Clockwork.Timers or {};
Clockwork.Libraries = Clockwork.Libraries or {};
Clockwork.SharedTables = Clockwork.SharedTables or {};

--[[
	@codebase Shared
	@details A function to split a string but keep the delimiter.
	@param {String} The string to split.
	@returns {String} The delimiter pattern.
--]]
function Clockwork.kernel:SplitKeepDelim(input, delim)
	local output = {};
	local a = string.match(input, delim);

	while (a) do
		local b = string.find(input, a);
		local upto = string.sub(input, 1, b - 1);
		
		table.insert(output, upto);
		table.insert(output, a);

		input = string.sub(input, b + string.len(a));
		
		a = string.match(input, delim);
	end;

	if (input ~= "") then
		table.insert(output, input);
	end;
	
	return output;
end;


--[[
	@codebase Shared
	@details A function to encode a URL.
	@param {String} The URL to encode.
	@returns {String} The encoded URL.
--]]
function Clockwork.kernel:URLEncode(url)
	local output = "";
	
	for i = 1, #url do
		local c = stringSub(url, i, i);
		local a = stringByte(c);
		
		if (a < 128) then
			if (a == 32 or a >= 34 and a <= 38 or a == 43 or a == 44 or a == 47 or a >= 58
			and a <= 64 or a >= 91 and a <= 94 or a == 96 or a >= 123 and a <= 126) then
				output = output.."%"..stringFormat("%x", a);
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
	@param {Table} The first unique table to compare.
	@param {Table} The second unique table to compare.
	@returns {Bool} Whether or not the tables are equal.
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
	@param {Entity} The weapon entity.
	@returns {Bool} Whether or not the weapon is a default weapon.
--]]
function Clockwork.kernel:IsDefaultWeapon(weapon)
	if (IsValid(weapon)) then
		local class = stringLower(weapon:GetClass());
		if (class == "weapon_physgun" or class == "gmod_physcannon"
		or class == "gmod_tool") then
			return true;
		end;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details A function to format cash.
	@param {Unknown} Missing description for amount.
	@param {Unknown} Missing description for singular.
	@param {Unknown} Missing description for lowerName.
	@returns {Unknown}
--]]
function Clockwork.kernel:FormatCash(amount, singular, lowerName)
	local output = {};
	local cashName = Clockwork.option:GetKey("name_cash");

	if (SERVER) then
		if (singular) then
			output = {"CashAmountSingular", amount};
		else
			output = {"CashAmount", amount, lowerName and string.lower(cashName) or cashName};
		end;
	else
		if (singular) then
			output = L("CashAmountSingular", amount);
		else
			output = L("CashAmount", amount, lowerName and string.lower(cashName) or cashName);
		end;
	end;

	return output;
end;

--[[ Define the default library class. --]]
local LIBRARY = {};

--[[
	@codebase Shared
	@details A function to add a library function to a metatable.
	@param {Unknown} Missing description for metaName.
	@param {Unknown} Missing description for funcName.
	@param {Unknown} Missing description for newName.
	@returns {Unknown}
--]]
function LIBRARY:AddToMetaTable(metaName, funcName, newName)
	local metaTable = FindMetaTable(metaName);
	
	metaTable[newName or funcName] = function(...)
		return self[funcName](self, ...)
	end;
end;

--[[
	@codebase Shared
	@details A function to create a new library.
	@param {Unknown} Missing description for libName.
	@returns {Unknown}
--]]
function Clockwork.kernel:NewLibrary(libName)
	if (!Clockwork.Libraries[libName]) then
		Clockwork.Libraries[libName] = self:NewMetaTable(LIBRARY);
	end;
	
	return Clockwork.Libraries[libName];
end;

--[[
	@codebase Shared
	@details A function find a library by its name.
	@param {Unknown} Missing description for libName.
	@returns {Unknown}
--]]
function Clockwork.kernel:FindLibrary(libName)
	return Clockwork.Libraries[libName];
end;

--[[
	@codebase Shared
	@details A function to create a library if it doesn't exist, and then return it.
	@param {Unknown} Missing description for libName.
	@returns {Unknown}
--]]
function cwLibrary(libName)
	if (!Clockwork[libName]) then
		Clockwork[libName] = Clockwork.kernel:NewLibrary(libName);
	end;

	return Clockwork[libName];
end;

--[[
	@codebase Shared
	@details An alias for the above function.
	@param {Unknown} Missing description for libName.
	@returns {Unknown}
--]]
function cwLib(libName)
	return library(libName);
end;

--[[
	@codebase Shared
	@details A function to create a library and class function.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function cwClass(name)
	local lib = cwLib(name);
	local CLASS = {__index = CLASS};

	function lib:New(...)
		local obj = Clockwork.kernel:NewMetaTable(CLASS);
			obj = lib[name](obj, ...);
		return obj, lib;
	end;
end;

--[[
	@codebase Shared
	@details A function to convert a string to a color.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.kernel:StringToColor(text)
	local explodedData = stringExplode(",", text);
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

--[[
	@codebase Shared
	@details A function to get a log type color.
	@param {Unknown} Missing description for logType.
	@returns {Unknown}
--]]
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
	@returns {String} The kernel version.
--]]
function Clockwork.kernel:GetVersion()
	return Clockwork.KernelVersion;
end;

--[[
	@codebase Shared
	@details A function to get the kernel build.
	@returns {String} The kernel build.
--]]
function Clockwork.kernel:GetBuild()
	return Clockwork.KernelBuild;
end;

--[[
	@codebase Shared
	@details A function to get the kernel version and build.
	@returns {String} The kernel version and build concatenated.
--]]
function Clockwork.kernel:GetVersionBuild()
	if (Clockwork.KernelBuild) then
		return Clockwork.KernelVersion.."-"..Clockwork.KernelBuild;
	else
		return Clockwork.KernelVersion;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the schema folder.
	@returns {String} The schema folder.
--]]
function Clockwork.kernel:GetSchemaFolder(sFolderName)
	if (sFolderName) then
		return (stringGsub(Clockwork.SchemaFolder, "gamemodes/", "").."/schema/"..sFolderName);
	else
		return (stringGsub(Clockwork.SchemaFolder, "gamemodes/", ""));
	end;
end;

--[[
	@codebase Shared
	@details A function to get the schema gamemode path.
	@returns {String} The schema gamemode path.
--]]
function Clockwork.kernel:GetSchemaGamemodePath()
	return (stringGsub(Clockwork.SchemaFolder, "gamemodes/", "").."/gamemode");
end;

--[[
	@codebase Shared
	@details A function to get the Clockwork folder.
	@returns {String} The Clockwork folder.
--]]
function Clockwork.kernel:GetClockworkFolder()
	return (stringGsub(Clockwork.ClockworkFolder, "gamemodes/", ""));
end;

--[[
	@codebase Shared
	@details A function to get the Clockwork path.
	@returns {String} The Clockwork path.
--]]
function Clockwork.kernel:GetClockworkPath()
	return (stringGsub(Clockwork.ClockworkFolder, "gamemodes/", "").."/framework");
end;

--[[
	@codebase Shared
	@details A function to get the path to GMod.
	@returns {Unknown}
--]]
function Clockwork.kernel:GetPathToGMod()
	return util.RelativePathToFull("."):sub(1, -2);
end;

--[[
	@codebase Shared
	@details A function to convert a string to a boolean.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.kernel:ToBool(text)
	if (text == "true" or text == "yes" or text == "1") then
		return true;
	else
		return false;
	end;
end;

--[[
	@codebase Shared
	@details A function to remove text from the end of a string.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for toRemove.
	@returns {Unknown}
--]]
function Clockwork.kernel:RemoveTextFromEnd(text, toRemove)
	local toRemoveLen = stringLen(toRemove);
	if (stringSub(text, -toRemoveLen) == toRemove) then
		return (stringSub(text, 0, -(toRemoveLen + 1)));
	else
		return text;
	end;
end;

--[[
	@codebase Shared
	@details A function to split a string.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for interval.
	@returns {Unknown}
--]]
function Clockwork.kernel:SplitString(text, interval)
	local length = stringLen(text);
	local baseTable = {};
	local i = 0;
	
	while (i * interval < length) do
		baseTable[i + 1] = stringSub(text, i * interval + 1, (i + 1) * interval);
		i = i + 1;
	end;
	
	return baseTable;
end;

--[[
	@codebase Shared
	@details A function to get whether a letter is a vowel.
	@param {Unknown} Missing description for letter.
	@returns {Unknown}
--]]
function Clockwork.kernel:IsVowel(letter)
	letter = stringLower(letter);
	return (letter == "a" or letter == "e" or letter == "i"
	or letter == "o" or letter == "u");
end;

--[[
	@codebase Shared
	@details A function to pluralize some text.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.kernel:Pluralize(text)
	if (stringSub(text, -2) != "fe") then
		local lastLetter = stringSub(text, -1);
		
		if (lastLetter == "y") then
			if (self:IsVowel(stringSub(text, stringLen(text) - 1, 2))) then
				return stringSub(text, 1, -2).."ies";
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
		return stringSub(text, 1, -3).."ves";
	end;
end;

--[[
	@codebase Shared
	@details A function to serialize a table.
	@param {Unknown} Missing description for tableToSerialize.
	@returns {Unknown}
--]]
function Clockwork.kernel:Serialize(tableToSerialize)
	local wasSuccess, value = pcall(von.serialize, tableToSerialize);
  
	if (!wasSuccess) then
		print(value);
		return "";  	
	end;
  
	return value;
end;

--[[
	@codebase Shared
	@details A function to deserialize a string.
	@param {Unknown} Missing description for stringToDeserialize.
	@returns {Unknown}
--]]
function Clockwork.kernel:Deserialize(stringToDeserialize)
	local wasSuccess, value = pcall(von.deserialize, stringToDeserialize);
  
	if (!wasSuccess) then
		print(value);
		return {};  	
	end;
  
	return value;
end;

--[[
	@codebase Shared
	@details A function to get ammo information from a weapon.
	@param {Unknown} Missing description for weapon.
	@returns {Unknown}
--]]
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
			weapon.AmmoInfo.primary.ownerClips = mathCeil(weapon.AmmoInfo.primary.clipSize / weapon.AmmoInfo.primary.ownerAmmo);
		else
			weapon.AmmoInfo.primary.ownerClips = 0;
		end;
		
		if (!weapon.AmmoInfo.secondary.doesNotShoot and weapon.AmmoInfo.secondary.ownerAmmo > 0) then
			weapon.AmmoInfo.secondary.ownerClips = mathCeil(weapon.AmmoInfo.secondary.clipSize / weapon.AmmoInfo.secondary.ownerAmmo);
		else
			weapon.AmmoInfo.secondary.ownerClips = 0;
		end;
		
		return weapon.AmmoInfo;
	end;
end;

--[[
	@codebase Shared
	@details Called when a player's footstep sound should be played.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for foot.
	@param {Unknown} Missing description for sound.
	@param {Unknown} Missing description for volume.
	@param {Unknown} Missing description for recipientFilter.
	@returns {Unknown}
--]]
function Clockwork:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	if (CLIENT) then return true; end;

	if (!self.plugin:Call("PrePlayerDefaultFootstep", player, position, foot, sound, volume, recipientFilter)) then
		local itemTable = player:GetClothesItem();
			
		if (itemTable) then
			if (player:IsRunning() or player:IsJogging()) then
				if (itemTable.runSound) then
					if (type(itemTable.runSound) == "table") then
						sound = itemTable.runSound[ mathRandom(1, #itemTable.runSound) ];
					else
						sound = itemTable.runSound;
					end;
				end;
			elseif (itemTable.walkSound) then
				if (type(itemTable.walkSound) == "table") then
					sound = itemTable.walkSound[ mathRandom(1, #itemTable.walkSound) ];
				else
					sound = itemTable.walkSound;
				end;
			end;
		end;

		player:EmitSound(sound);
		
		return true;
	end;
end;

--[[
	@codebase Shared
	@details Called when the player's jumping animation should be handled.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
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
			player.CalcIdeal = Clockwork.animation:GetForModel(player:GetModel(), "jump");
			
			return true;
		end;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details Called when the player's ducking animation should be handled.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for velocity.
	@returns {Unknown}
--]]
function Clockwork:HandlePlayerDucking(player, velocity)
	if (player:Crouching()) then
		local model = player:GetModel();
		local weapon = player:GetActiveWeapon();
		local bIsRaised = Clockwork.player:GetWeaponRaised(player, true);
		local velLength = velocity:Length2D();
		local animationAct = "crouch";
		local weaponHoldType = "pistol";
		
		if (IsValid(weapon)) then
			weaponHoldType = Clockwork.animation:GetWeaponHoldType(player, weapon);
		
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

		player.CalcIdeal = Clockwork.animation:GetForModel(model, animationAct);
		
		return true;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details Called when the player's swimming animation should be handled.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details Called when the player's driving animation should be handled.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork:HandlePlayerDriving(player)
	if (player:InVehicle()) then
		player.CalcIdeal = Clockwork.animation:GetForModel(player:GetModel(), "sit");
		return true;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details Called when a player's animation is updated.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for velocity.
	@param {Unknown} Missing description for maxSeqGroundSpeed.
	@returns {Unknown}
--]]
function Clockwork:UpdateAnimation(player, velocity, maxSeqGroundSpeed)
	local velLength = velocity:Length2D();
	local rate = 1.0;
	
	if (velLength > 0.5) then
		rate = ((velLength * 0.8) / maxSeqGroundSpeed);
	end
	
	player.cwPlaybackRate = mathClamp(rate, 0, 1.5);
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

local IdleActivity = ACT_HL2MP_IDLE;
local IdleActivityTranslate = {
	[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = IdleActivity + 5,
	[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = IdleActivity + 5,
	[ACT_MP_RELOAD_CROUCH] = IdleActivity + 6,
	[ACT_MP_RELOAD_STAND] = IdleActivity + 6,
	[ACT_MP_CROUCH_IDLE] = IdleActivity + 3,
	[ACT_MP_STAND_IDLE] = IdleActivity,
	[ACT_MP_CROUCHWALK] = IdleActivity + 4,
	[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM,
	[ACT_MP_WALK] = IdleActivity + 1,
	[ACT_MP_RUN] = IdleActivity + 2,
};
	
--[[
	@codebase Shared
	@details Called when a player's activity is supposed to be translated.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for act.
	@returns {Unknown}
--]]
function Clockwork:TranslateActivity(player, act)
	local model = player:GetModel();
	local bIsRaised = Clockwork.player:GetWeaponRaised(player, true);
	
	if (stringFind(model, "/player/")) then
		local newAct = player:TranslateWeaponActivity(act);
		
		if (!bIsRaised or act == newAct) then
			return IdleActivityTranslate[act];
		else
			return newAct;
		end;
	end;
	
	return act;
end;

--[[
	@codebase Shared
	@details Called when the main activity should be calculated.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for velocity.
	@returns {Unknown}
--]]
function Clockwork:CalcMainActivity(player, velocity)
	local model = player:GetModel();
	
	ANIMATION_PLAYER = player;
	
	local weapon = player:GetActiveWeapon();
	local bIsRaised = Clockwork.player:GetWeaponRaised(player, true);
	local animationAct = "stand";
	local weaponHoldType = "pistol";
	local forcedAnimation = player:GetForcedAnimation();

	if (IsValid(weapon)) then
		weaponHoldType = Clockwork.animation:GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = animationAct.."_"..weaponHoldType;
		end;
	end;
	
	if (bIsRaised) then
		animationAct = animationAct.."_aim";
	end;
	
	player.CalcIdeal = Clockwork.animation:GetForModel(model, animationAct.."_idle");
	player.CalcSeqOverride = -1;
	
	if (!self:HandlePlayerDriving(player)
	and !self:HandlePlayerJumping(player)
	and !self:HandlePlayerDucking(player, velocity)
	and !self:HandlePlayerSwimming(player)
	and !self:HandlePlayerNoClipping(player, velocity)
	and !self:HandlePlayerVaulting(player, velocity)) then
		local velLength = velocity:Length2D();
				
		if (player:IsRunning() or player:IsJogging()) then
			player.CalcIdeal = Clockwork.animation:GetForModel(model, animationAct.."_run");
		elseif (velLength > 0.5) then
			player.CalcIdeal = Clockwork.animation:GetForModel(model, animationAct.."_walk");
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
	local normalized = mathNormalizeAngle(yaw - eyeAngles.y);

	player:SetPoseParameter("move_yaw", normalized);

	return player.CalcIdeal, player.CalcSeqOverride;
end;

--[[
	@codebase Shared
	@details Called when the animation event is supposed to be done.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for event.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork:DoAnimationEvent(player, event, data)
	local model = player:GetModel();
	
	if (stringFind(model, "/player/")) then
		return self.BaseClass:DoAnimationEvent(player, event, data);
	end;
	
	local weapon = player:GetActiveWeapon();
	local animationAct = "pistol";
	
	if (IsValid(weapon)) then
		weaponHoldType = Clockwork.animation:GetWeaponHoldType(player, weapon);
	
		if (weaponHoldType) then
			animationAct = weaponHoldType;
		end;
	end;
	
	if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
		local gestureSequence = Clockwork.animation:GetForModel(model, animationAct.."_attack");
		
		if (gestureSequence) then
			if (player:Crouching()) then
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			else
				player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gestureSequence, true);
			end;
		end;
		
		return ACT_VM_PRIMARYATTACK;
	elseif (event == PLAYERANIMEVENT_RELOAD) then
		local gestureSequence = Clockwork.animation:GetForModel(model, animationAct.."_reload");

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
	
	--[[
		@codebase Shared
		@details A function to save schema data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SaveSchemaData(fileName, data)
		if (type(data) != "table") then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			return;
		end;
	
		return Clockwork.file:Write("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", self:Serialize(data));
	end;

	--[[
		@codebase Shared
		@details A function to delete schema data.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DeleteSchemaData(fileName)
		return Clockwork.file:Delete("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw");
	end;

	--[[
		@codebase Shared
		@details A function to check if schema data exists.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SchemaDataExists(fileName)
		return _file.Exists("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", "GAME");
	end;
	
	--[[
		@codebase Shared
		@details A function to get the schema data path.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetSchemaDataPath()
		return "settings/clockwork/schemas/"..self:GetSchemaFolder();
	end;
	
	local SCHEMA_GAMEMODE_INFO = nil;
	
	--[[
		@codebase Shared
		@details A function to get the schema gamemode info.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetSchemaGamemodeInfo()
		if (SCHEMA_GAMEMODE_INFO) then
			return SCHEMA_GAMEMODE_INFO;
		end;
		
		local schemaFolder = stringLower(self:GetSchemaFolder());
		local schemaData = util.KeyValuesToTable(Clockwork.file:Read("gamemodes/"..schemaFolder.."/"..schemaFolder..".txt"));
		
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
		SCHEMA_GAMEMODE_INFO["version"] = schemaData["version"] and math.Round(schemaData["version"], 6) or "Undefined";
		
		return SCHEMA_GAMEMODE_INFO;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the schema gamemode name.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetSchemaGamemodeName()
		local schemaInfo = self:GetSchemaGamemodeInfo();
		
		return schemaInfo["name"];

	end;

	--[[
		@codebase Shared
		@details A function to get the schema version.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetSchemaGamemodeVersion()
		local schemaInfo = self:GetSchemaGamemodeInfo();
		
		return schemaInfo["version"];
	end;
	
	--[[
		@codebase Shared
		@details A function to find schema data in a directory.
		@param {Unknown} Missing description for directory.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:FindSchemaDataInDir(directory)
		return _file.Find("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..directory, "GAME");
	end;

	--[[
		@codebase Shared
		@details A function to restore schema data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for failSafe.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RestoreSchemaData(fileName, failSafe)
		if (self:SchemaDataExists(fileName)) then
			local data = Clockwork.file:Read("settings/clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".cw", "namedesc");
			
			if (data) then
				local wasSuccess, value = pcall(self.Deserialize, self, data);

				if (wasSuccess and value != nil) then
					return value;
				else
					MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] '"..fileName.."' schema data has failed to restore.\n"..value.."\n");
					
					self:DeleteSchemaData(fileName);
				end;
			end;
		end;
		
		if (failSafe != nil) then
			return failSafe;
		else
			return {};
		end;
	end;

	--[[
		@codebase Shared
		@details A function to restore Clockwork data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for failSafe.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RestoreClockworkData(fileName, failSafe)
		if (self:ClockworkDataExists(fileName)) then
			local data = Clockwork.file:Read("settings/clockwork/"..fileName..".cw");
			
			if (data) then
				local wasSuccess, value = pcall(util.JSONToTable, data);
				
				if (wasSuccess and value != nil) then
					return value;
				else
					local wasSuccess, value = pcall(self.Deserialize, self, data);
					
					if (wasSuccess and value != nil) then
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
	
	--[[
		@codebase Shared
		@details A function to setup a full directory.
		@param {Unknown} Missing description for filePath.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SetupFullDirectory(filePath)
		local directory = stringGsub(self:GetPathToGMod()..filePath, "\\", "/");
		local exploded = stringExplode("/", directory);
		local currentPath = "";
		
		for k, v in pairs(exploded) do
			if (k < #exploded) then
				currentPath = currentPath..v.."/";
				Clockwork.file:MakeDirectory(currentPath);
			end;
		end;
		
		return currentPath..exploded[#exploded];
	end;

	--[[
		@codebase Shared
		@details A function to save Clockwork data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SaveClockworkData(fileName, data)
		if (type(data) != "table") then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
			return;
		end;
	
		return Clockwork.file:Write("settings/clockwork/"..fileName..".cw", self:Serialize(data));
	end;

	--[[
		@codebase Shared
		@details A function to check if Clockwork data exists.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:ClockworkDataExists(fileName)
		return _file.Exists("settings/clockwork/"..fileName..".cw", "GAME");
	end;

	--[[
		@codebase Shared
		@details A function to delete Clockwork data.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DeleteClockworkData(fileName)
		return Clockwork.file:Delete("settings/clockwork/"..fileName..".cw");
	end;

	--[[
		@codebase Shared
		@details A function to convert a force.
		@param {Unknown} Missing description for force.
		@param {Unknown} Missing description for limit.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to save a player's attribute boosts.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SavePlayerAttributeBoosts(player, data)
		local attributeBoosts = player:GetAttributeBoosts();
		local curTime = CurTime();
		
		if (data["AttrBoosts"]) then
			data["AttrBoosts"] = nil;
		end;
		
		if (tableCount(attributeBoosts) > 0) then
			data["AttrBoosts"] = {};
			
			for k, v in pairs(attributeBoosts) do
				data["AttrBoosts"][k] = {};
				
				for k2, v2 in pairs(v) do
					if (v2.duration) then
						if (curTime < v2.endTime) then
							data["AttrBoosts"][k][k2] = {
								duration = mathCeil(v2.endTime - curTime),
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
	
	--[[
		@codebase Shared
		@details A function to calculate a player's spawn time.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for inflictor.
		@param {Unknown} Missing description for attacker.
		@param {Unknown} Missing description for damageInfo.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to create a decal.
		@param {Unknown} Missing description for texture.
		@param {Unknown} Missing description for position.
		@param {Unknown} Missing description for temporary.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to handle a player's weapon fire delay.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for bIsRaised.
		@param {Unknown} Missing description for weapon.
		@param {Unknown} Missing description for curTime.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to scale damage by hit group.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for attacker.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for damageInfo.
		@param {Unknown} Missing description for baseDamage.
		@returns {Unknown}
	--]]
	function Clockwork:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
		if (!damageInfo:IsFallDamage() and !damageInfo:IsDamageType(DMG_CRUSH)) then
			if (hitGroup == HITGROUP_HEAD) then
				damageInfo:ScaleDamage(Clockwork.config:Get("scale_head_dmg"):Get());
			elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
				damageInfo:ScaleDamage(Clockwork.config:Get("scale_chest_dmg"):Get());
			elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
			or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR) then
				damageInfo:ScaleDamage(Clockwork.config:Get("scale_limb_dmg"):Get());
			end;
		end;
		
		self.plugin:Call("PlayerScaleDamageByHitGroup", player, attacker, hitGroup, damageInfo, baseDamage);
	end;
	
	--[[
		@codebase Shared
		@details A function to calculate player damage.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for damageInfo.
		@returns {Unknown}
	--]]
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
				player:SetHealth(mathMax(player:Health() - mathAbs(armor), 1));
				player:SetArmor(mathMax(armor, 0));
			else
				player:SetArmor(mathMax(armor, 0));
			end;
		else
			Clockwork.limb:TakeDamage(player, hitGroup, damageInfo:GetDamage() * 2);
			player:SetHealth(mathMax(player:Health() - damageInfo:GetDamage(), 1));
		end;
		
		if (damageInfo:IsFallDamage()) then
			Clockwork.limb:TakeDamage(player, HITGROUP_RIGHTLEG, damageInfo:GetDamage());
			Clockwork.limb:TakeDamage(player, HITGROUP_LEFTLEG, damageInfo:GetDamage());
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get a ragdoll's hit bone.
		@param {Unknown} Missing description for entity.
		@param {Unknown} Missing description for position.
		@param {Unknown} Missing description for failSafe.
		@param {Unknown} Missing description for minimum.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to get a ragdoll's hit group.
		@param {Unknown} Missing description for entity.
		@param {Unknown} Missing description for position.
		@returns {Unknown}
	--]]
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

	--[[
		@codebase Shared
		@details A function to create blood effects at a position.
		@param {Unknown} Missing description for position.
		@param {Unknown} Missing description for decals.
		@param {Unknown} Missing description for entity.
		@param {Unknown} Missing description for forceVec.
		@param {Unknown} Missing description for fScale.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to do the entity take damage hook.
		@param {Unknown} Missing description for ....
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DoEntityTakeDamageHook(entity, damageInfo)
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
			
			hook.Call("PrePlayerTakeDamage", Clockwork, player, attacker, inflictor, damageInfo);
			
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
						if (entity.cwNextFallDamage and curTime < entity.cwNextFallDamage) then
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
	
	--[[
		@codebase Shared
		@details A function to perform the date and time think.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to create a ConVar.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for value.
		@param {Unknown} Missing description for flags.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to check if the server is shutting down.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IsShuttingDown()
		return Clockwork.ShuttingDown;
	end;
	
	--[[
		@codebase Shared
		@details A function to distribute wages cash.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DistributeWagesCash()
		local plyTable = cwPlayer.GetAll();

		for k, v in pairs(plyTable) do
			if (v:HasInitialized() and v:Alive()) then
				local info = {
					wages = v:GetWages();
				};
				
				Clockwork.plugin:Call("PlayerModifyWagesInfo", v, info);
				
				if (Clockwork.plugin:Call("PlayerCanEarnWagesCash", v, info.wages)) then
					if (info.wages > 0) then
						if (Clockwork.plugin:Call("PlayerGiveWagesCash", v, info.wages, v:GetWagesName())) then
							Clockwork.player:GiveCash(v, info.wages, v:GetWagesName());
						end;
					end;
					
					Clockwork.plugin:Call("PlayerEarnWagesCash", v, info.wages);
				end;
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to distribute generator cash.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DistributeGeneratorCash()
		local generatorEntities = {};
		
		for k, v in pairs(Clockwork.generator:GetAll()) do
			tableAdd(generatorEntities, ents.FindByClass(k));
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
				
				v:SetDTInt(0, mathMax(v:GetPower() - 1, 0));
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
	
	--[[
		@codebase Shared
		@details A function to include the schema.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IncludeSchema()
		return CloudAuthX.kernel:IncludeSchema();
	end;
	
	--[[
		@codebase Shared
		@details A function to print a log message.
		@param {Unknown} Missing description for logType.
		@param {Unknown} Missing description for text.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:PrintLog(logType, text)
		local listeners = {};
		local plyTable = cwPlayer.GetAll();

		for k, v in pairs(plyTable) do
			if (v:HasInitialized() and v:GetInfoNum("cwShowLog", 0) == 1) then
				if (Clockwork.player:IsAdmin(v)) then
					listeners[#listeners + 1] = v;
				end;
			end;
		end;
		
		Clockwork.datastream:Start(listeners, "Log", {
			logType = (logType or 5),
			text = text
		});
		
		if (CW_CONVAR_LOG:GetInt() == 1 and game.IsDedicated()) then
			self:ServerLog(T(text));
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to log to the server.
		@param {Unknown} Missing description for text.
		@returns {Unknown}
	--]]
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
			local logText = time..": "..stringGsub(text, "\n", "");

			Clockwork.file:Append("logs/clockwork/"..fileName..".log", logText.."\n");
		end;
	
		ServerLog(text.."\n");
		
		Clockwork.plugin:Call("ClockworkLog", text, unixTime);
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
	
	Clockwork.kernel.CenterHints = Clockwork.kernel.CenterHints or {};
	Clockwork.kernel.ESPInfo = Clockwork.kernel.ESPInfo or {};
	Clockwork.kernel.Hints = Clockwork.kernel.Hints or {};

	--[[
		@codebase Shared
		@details A function to register a network proxy.
		@param {Unknown} Missing description for entity.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RegisterNetworkProxy(entity, name, Callback)
		if (!Clockwork.NetworkProxies[entity]) then
			Clockwork.NetworkProxies[entity] = {};
		end;
		
		Clockwork.NetworkProxies[entity][name] = {
			Callback = Callback,
			oldValue = nil
		};
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the info menu is open.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IsInfoMenuOpen()
		return Clockwork.InfoMenuOpen;
	end;
	
	--[[
		@codebase Shared
		@details A function to create a client ConVar.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for value.
		@param {Unknown} Missing description for save.
		@param {Unknown} Missing description for userData.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to scale a font size to the screen.
		@param {Unknown} Missing description for size.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:FontScreenScale(size)
		--[[
			This will be the new method.
			return size * (ScrH() / 480.0);
		--]]
	
		return ScreenScale(size);
	end;
	
	--[[
		@codebase Shared
		@details A function to get a material.
		@param {Unknown} Missing description for materialPath.
		@param {Unknown} Missing description for pngParameters.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetMaterial(materialPath, pngParameters)
		self.CachedMaterial = self.CachedMaterial or {};

		if (!self.CachedMaterial[materialPath]) then
			self.CachedMaterial[materialPath] = Material(materialPath, pngParameters);
		end;

		return self.CachedMaterial[materialPath];
	end;

	--[[
		@codebase Shared
		@details A function to get the 3D font size.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetFontSize3D()
		return self:FontScreenScale(32);
	end;
	
	--[[
		@codebase Shared
		@details A function to get the size of text.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for text.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetTextSize(font, text)
		local defaultWidth, defaultHeight = self:GetCachedTextSize(font, "U");
		local height = defaultHeight;
		local width = 0;
		local textLength = 0;
		
		for i in stringGmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
			local currentCharacter = textLength + 1;
			local textWidth, textHeight = self:GetCachedTextSize(font, stringSub(text, currentCharacter, currentCharacter));

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
	
	--[[
		@codebase Shared
		@details A function to calculate alpha from a distance.
		@param {Unknown} Missing description for maximum.
		@param {Unknown} Missing description for start.
		@param {Unknown} Missing description for finish.
		@returns {Unknown}
	--]]
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
		
		return mathClamp(255 - ((255 / maximum) * (start:Distance(finish))), 0, 255);
	end;
	
	--[[
		@codebase Shared
		@details A function to wrap text into a table.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for maximumWidth.
		@param {Unknown} Missing description for baseTable.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:WrapText(text, font, maximumWidth, baseTable)
		if (maximumWidth <= 0 or !text or text == "") then
			return;
		end;
		
		if (self:GetTextSize(font, text) > maximumWidth) then
			local currentWidth = 0;
			local firstText = nil;
			local secondText = nil;
			
			for i = 0, #text do
				local currentCharacter = stringSub(text, i, i);
				local currentSingleWidth = Clockwork.kernel:GetTextSize(font, currentCharacter);
				
				if ((currentWidth + currentSingleWidth) >= maximumWidth) then
					baseTable[#baseTable + 1] = stringSub(text, 0, (i - 1));
					text = stringSub(text, i);
					
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
	
	--[[
		@codebase Shared
		@details A function to handle an entity's menu.
		@param {Unknown} Missing description for entity.
		@returns {Unknown}
	--]]
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

		if (tableCount(options) == 0) then return; end;
		
		local menuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
			if (itemTable and type(arguments) == "table" and arguments.isOptionTable) then
				menuPanel:AddOption(T(arguments.title), function()
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
				menuPanel:AddOption(T(option), function()
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
						tableInsert(menuPanel.Items, 1, panel);
					end;
						
					if (arguments.toolTip) then
						self:CreateMarkupToolTip(panel);
						panel:SetMarkupToolTip(arguments.toolTip);
					end;
				end;
			end;
		end);
			
		self:RegisterBackgroundBlur(menuPanel, SysTime());
		self:SetTitledMenu(menuPanel, L("InteractWithThisEntity"));
		menuPanel.entity = entity;
			
		return menuPanel;
	end;

	--[[
		@codebase Shared
		@details A function to get the gradient texture.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetGradientTexture()
		return Clockwork.GradientTexture;
	end;
	
	--[[
		@codebase Shared
		@details A function to add a menu from data.
		@param {Unknown} Missing description for menuPanel.
		@param {Unknown} Missing description for data.
		@param {Unknown} Missing description for Callback.
		@param {Unknown} Missing description for minimumWidth.
		@param {Unknown} Missing description for manualOpen.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:AddMenuFromData(menuPanel, data, Callback, minimumWidth, manualOpen)
		local isCreated = false;
		local options = {};
		
		if (!menuPanel) then
			isCreated = true; menuPanel = DermaMenu();
			
			if (minimumWidth) then
				menuPanel:SetMinimumWidth(minimumWidth);
			end;
		end;
		
		for k, v in pairs(data) do
			options[#options + 1] = {k, v};
		end;
		
		tableSort(options, function(a, b)
			return a[1] < b[1];
		end);
		
		for k, v in pairs(options) do
			if (type(v[2]) == "table" and !v[2].isArgTable) then
				if (tableCount(v[2]) > 0) then
					self:AddMenuFromData(menuPanel:AddSubMenu(T(v[1])), v[2], Callback);
				end;
			elseif (type(v[2]) == "function") then
				menuPanel:AddOption(T(v[1]), v[2]);
			elseif (Callback) then
				Callback(menuPanel, v[1], v[2]);
			end;
		end;
		
		if (!isCreated) then return; end;
		
		if (!manualOpen) then
			if (#options > 0) then
				menuPanel:Open();
			else
				menuPanel:Remove();
			end;
		end;
		
		return menuPanel;
	end;
	
	--[[
		@codebase Shared
		@details A function to adjust the width of text.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for addition.
		@param {Unknown} Missing description for extra.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:AdjustMaximumWidth(font, text, width, addition, extra)
		local textString = tostring(self:Replace(text, "&", "U"));
		local textWidth = self:GetCachedTextSize(font, textString) + (extra or 0);
		
		if (textWidth > width) then
			width = textWidth + (addition or 0);
		end;
		
		return width;
	end;
	
	--[[
		A function to add a center hint. If noSound is false then no
		sound will play, otherwise if it is a string then it will
		play that sound.
	--]]
	function Clockwork.kernel:AddCenterHint(text, delay, color, noSound, showDuplicated)
		local colorWhite = Clockwork.option:GetColor("white");
		local localized = T(text);
		
		if (color) then
			if (type(color) == "string") then
				color = Clockwork.option:GetColor(color);
			end;
		else
			color = colorWhite;
		end;
		
		if (!showDuplicated) then
			for k, v in pairs(self.CenterHints) do
				if (v.text == localized) then
					return;
				end;
			end;
		end;
		
		if (tableCount(self.CenterHints) == 10) then
			tableRemove(self.CenterHints, 10);
		end;
		
		if (type(noSound) == "string") then
			surface.PlaySound(noSound);
		elseif (noSound == nil) then
			surface.PlaySound("hl1/fvox/blip.wav");
		end;
		
		self.CenterHints[#self.CenterHints + 1] = {
			startTime = SysTime(),
			velocityX = -5,
			velocityY = 0,
			targetAlpha = 255,
			alphaSpeed = 64,
			color = color,
			delay = delay,
			alpha = 0,
			text = localized,
			y = ScrH() * 0.6,
			x = ScrW() * 0.5
		};
	end;
	
	local function UpdateCenterHint(index, hintInfo, iCount)
		local hintsFont = Clockwork.option:GetFont("hints_text");
		local fontWidth, fontHeight = Clockwork.kernel:GetCachedTextSize(
			hintsFont, hintInfo.text
		);
		local height = fontHeight;
		local width = fontWidth;
		local alpha = 255;
		local x = hintInfo.x;
		local y = hintInfo.y;
		
		local idealY = (ScrH() * 0.4) + (height * (index - 1));
		local idealX = (ScrW() * 0.5) - (width * 0.5);
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
		
		if (mathAbs(distanceY) < 2 and mathAbs(hintInfo.velocityY) < 0.1) then
			hintInfo.velocityY = 0;
		end;
		
		if (mathAbs(distanceX) < 2 and mathAbs(hintInfo.velocityX) < 0.1) then
			hintInfo.velocityX = 0;
		end;
		
		hintInfo.velocityX = hintInfo.velocityX * (0.95 - FrameTime() * 8);
		hintInfo.velocityY = hintInfo.velocityY * (0.95 - FrameTime() * 8);
		hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1;
		hintInfo.x = x;
		hintInfo.y = y;
		
		return (timeLeft < 0.1);
	end;
	
	--[[
		A function to add a top hint. If noSound is false then no
		sound will play, otherwise if it is a string then it will
		play that sound.
	--]]
	function Clockwork.kernel:AddTopHint(text, delay, color, noSound, showDuplicated)
		local colorWhite = Clockwork.option:GetColor("white");
		local localized = T(text);
		
		if (color) then
			if (type(color) == "string") then
				color = Clockwork.option:GetColor(color);
			end;
		else
			color = colorWhite;
		end;
		
		if (!showDuplicated) then
			for k, v in pairs(self.Hints) do
				if (v.text == localized) then
					return;
				end;
			end;
		end;
		
		if (tableCount(self.Hints) == 10) then
			tableRemove(self.Hints, 10);
		end;
		
		if (type(noSound) == "string") then
			surface.PlaySound(noSound);
		elseif (noSound == nil) then
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
			text = localized,
			y = ScrH() * 0.2,
			x = ScrW()
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
		
		local idealY = 24 + (height * (index - 1));
		local idealX = ScrW() - width - 48;
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
		
		if (mathAbs(distanceY) < 2 and mathAbs(hintInfo.velocityY) < 0.1) then
			hintInfo.velocityY = 0;
		end;
		
		if (mathAbs(distanceX) < 2 and mathAbs(hintInfo.velocityX) < 0.1) then
			hintInfo.velocityX = 0;
		end;
		
		hintInfo.velocityX = hintInfo.velocityX * (0.95 - FrameTime() * 8);
		hintInfo.velocityY = hintInfo.velocityY * (0.95 - FrameTime() * 8);
		hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1;
		hintInfo.x = x;
		hintInfo.y = y;
		
		return (timeLeft < 0.1);
	end;
	
	--[[
		@codebase Shared
		@details A function to calculate the hints.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CalculateHints()
		for k, v in pairs(self.Hints) do
			if (UpdateHint(k, v, #self.Hints)) then
				tableRemove(self.Hints, k);
			end;
		end;
		
		for k, v in pairs(self.CenterHints) do
			if (UpdateCenterHint(k, v, #self.CenterHints)) then
				tableRemove(self.CenterHints, k);
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
	
	--[[
		@codebase Shared
		@details A function to draw the date and time.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawDateTime()
		local backgroundColor = Clockwork.option:GetColor("background");
		local mainTextFont = Clockwork.option:GetFont("main_text");
		local colorWhite = Clockwork.option:GetColor("white");
		local colorInfo = Clockwork.option:GetColor("information");
		local scrW = ScrW();
		local scrH = ScrH();
		local info = {
			DrawText = Util_DrawText,
			width = mathMin(scrW * 0.5, 512),
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
			self:DrawInfo(L("CharacterRoleplayInfo"), x, y + 4, colorInfo, nil, true, function(x, y, width, height)
				return x, y - height;
			end);
			
			SLICED_INFO_MENU_BG:Draw(x, y + 8, width, height, 8, backgroundColor);
			y = y + height + 16;
			
			if (self:CanCreateInfoMenuPanel() and self:IsInfoMenuOpen()) then
				local menuPanelX = x;
				local menuPanelY = y;
				
				self:DrawInfo(L("SelectQuickMenuOption"), x, y, colorInfo, nil, true, function(x, y, width, height)
					menuPanelY = menuPanelY + height + 8;
					return x, y;
				end);
				
				self:CreateInfoMenuPanel(menuPanelX, menuPanelY, width);
				
				SLICED_INFO_MENU_INSIDE:Draw(Clockwork.InfoMenuPanel.x - 4, Clockwork.InfoMenuPanel.y - 4, Clockwork.InfoMenuPanel:GetWide() + 8, Clockwork.InfoMenuPanel:GetTall() + 8, 8, backgroundColor);
				
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
				local text = stringUpper(dateString..". "..dayName..", "..timeString..".");
				
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
					text = L("LimbStatus", L(texInfo.names[k]), limbHealth)
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

	--[[
		@codebase Shared
		@details A function to draw the top hints.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawHints()
		if (Clockwork.plugin:Call("PlayerCanSeeHints") and #self.Hints > 0) then
			local hintsFont = Clockwork.option:GetFont("hints_text");
			
			for k, v in pairs(self.Hints) do
				self:OverrideMainFont(hintsFont);
					self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true);
				self:OverrideMainFont(false);
			end;
		end;
		
		if (Clockwork.plugin:Call("PlayerCanSeeCenterHints") and #self.CenterHints > 0) then
			for k, v in pairs(self.CenterHints) do
				self:OverrideMainFont(hintsFont);
					self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true);
				self:OverrideMainFont(false);
			end;
		end;
	end;

	--[[
		@codebase Shared
		@details A function to draw the top bars.
		@param {Unknown} Missing description for info.
		@param {Unknown} Missing description for class.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawBars(info, class)
		if (Clockwork.plugin:Call("PlayerCanSeeBars", class)) then
			local barTextFont = Clockwork.option:GetFont("bar_text");
			
			Clockwork.bars.width = info.width;
			Clockwork.bars.height = Clockwork.bars.height or 12;
			Clockwork.bars.padding = Clockwork.bars.padding or 14;
			Clockwork.bars.y = info.y;
			
			if (class == "tab") then
				Clockwork.bars.x = info.x - (info.width / 2);
			else
				Clockwork.bars.x = info.x;
			end;
			
			Clockwork.option:SetFont("bar_text", Clockwork.option:GetFont("auto_bar_text"));
				for k, v in pairs(Clockwork.bars.stored) do
					Clockwork.bars.y = self:DrawBar(Clockwork.bars.x, Clockwork.bars.y, Clockwork.bars.width, Clockwork.bars.height, v.color, v.text, v.value, v.maximum, v.flash, {uniqueID = v.uniqueID}) + (Clockwork.bars.padding + 2);
				end;
			Clockwork.option:SetFont("bar_text", barTextFont);
			
			info.y = Clockwork.bars.y;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the ESP info.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetESPInfo()
		return self.ESPInfo;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw the admin ESP.
		@returns {Unknown}
	--]]
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
							text = v2.text;
							color = v2.color;

							local barNumbers = v2.bar;

							if (type(barNumbers) == "table") then
								barValue = barNumbers.value;
								maximum = barNumbers.max;
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

						if (v2.icon) then
							local icon = "icon16/exclamation.png";
							local width = surface.GetTextSize(text);

							if (type(v2.icon == "string") and v2.icon != "") then
								icon = v2.icon;
							end;

							surface.SetDrawColor(255, 255, 255, 255);
							surface.SetMaterial(Clockwork.kernel:GetMaterial(icon));
							surface.DrawTexturedRect(position.x - (width * 0.40) - height, position.y - height * 0.5, height, height);
						end;

						if (barValue and CW_CONVAR_ESPBARS:GetInt() == 1) then
							local barHeight = height * 0.80;
							local barColor = v2.barColor or Clockwork:GetValueColor(barValue);
							local grayColor = Color(150, 150, 150, 170);
							local progress = 100 * (barValue / maximum);

							if progress < 0 then
								progress = 0;
							end;

							draw.RoundedBox(6, position.x - 50, position.y - (barHeight * 0.45), 100, barHeight, grayColor);
							draw.RoundedBox(6, position.x - 50, position.y - (barHeight * 0.45), mathFloor(progress), barHeight, barColor);
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

	--[[
		@codebase Shared
		@details A function to draw a bar with a value and a maximum.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for height.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for value.
		@param {Unknown} Missing description for maximum.
		@param {Unknown} Missing description for flash.
		@param {Unknown} Missing description for barInfo.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawBar(x, y, width, height, color, text, value, maximum, flash, barInfo)
		local backgroundColor = Clockwork.option:GetColor("background");
		local foregroundColor = Clockwork.option:GetColor("foreground");
		local progressWidth = mathClamp(((width - 4) / maximum) * value, 0, width - 4);
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
				local alpha = mathClamp(mathAbs(mathSin(UnPredictedCurTime()) * 50), 0, 50);
				
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
	
	--[[
		@codebase Shared
		@details A function to set the recognise menu.
		@param {Unknown} Missing description for menuPanel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SetRecogniseMenu(menuPanel)
		Clockwork.RecogniseMenu = menuPanel;
		self:SetTitledMenu(menuPanel, L("SelectWhoCanRecognize"));
	end;
	
	--[[
		@codebase Shared
		@details A function to get the recognise menu.
		@param {Unknown} Missing description for menuPanel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetRecogniseMenu(menuPanel)
		return Clockwork.RecogniseMenu;
	end;
	
	--[[
		@codebase Shared
		@details A function to override the main font.
		@param {Unknown} Missing description for font.
		@returns {Unknown}
	--]]
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

	--[[
		@codebase Shared
		@details A function to get the screen's center.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetScreenCenter()
		return ScrW() / 2, (ScrH() / 2) + 32;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw some simple text.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for alignX.
		@param {Unknown} Missing description for alignY.
		@param {Unknown} Missing description for shadowless.
		@param {Unknown} Missing description for shadowDepth.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless, shadowDepth)
		local mainTextFont = Clockwork.option:GetFont("main_text");
		local realX = mathRound(x);
		local realY = mathRound(y);
		
		if (!shadowless) then
			local outlineColor = Color(25, 25, 25, mathMin(225, color.a));
			
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
	
	--[[
		@codebase Shared
		@details A function to get the black fade alpha.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetBlackFadeAlpha()
		return Clockwork.BlackFadeIn or Clockwork.BlackFadeOut or 0;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the screen is faded black.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to get whether a custom crosshair is used.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:UsingCustomCrosshair()
		return Clockwork.CustomCrosshair;
	end;
	
	--[[
		@codebase Shared
		@details A function to get a cached text size.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for text.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to draw scaled information at a position.
		@param {Unknown} Missing description for scale.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for alpha.
		@param {Unknown} Missing description for bAlignLeft.
		@param {Unknown} Missing description for Callback.
		@param {Unknown} Missing description for shadowDepth.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawInfoScaled(scale, text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
		local newFont = Clockwork.fonts:GetMultiplied("cwMainText", scale);
		local returnY = 0;
		
		self:OverrideMainFont(newFont);
		
		returnY = self:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth);
		
		self:OverrideMainFont(false);
		
		return returnY;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw information at a position.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for alpha.
		@param {Unknown} Missing description for bAlignLeft.
		@param {Unknown} Missing description for Callback.
		@param {Unknown} Missing description for shadowDepth.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to get the player info box.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetPlayerInfoBox()
		return Clockwork.PlayerInfoBox;
	end;

	--[[
		@codebase Shared
		@details A function to draw the local player's information.
		@param {Unknown} Missing description for info.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to get whether the info menu panel can be created.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CanCreateInfoMenuPanel()
		return (tableCount(Clockwork.quickmenu.stored) > 0 or tableCount(Clockwork.quickmenu.categories) > 0);
	end;
	
	--[[
		@codebase Shared
		@details A function to create the info menu panel.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for minimumWidth.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CreateInfoMenuPanel(x, y, minimumWidth)
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
				local subMenu = menuPanel:AddSubMenu(L(option));
				
				for k, v in pairs(arguments.options) do
					local name = v;
					
					if (type(v) == "table") then
						name = v[1];
					end;
					
					subMenu:AddOption(T(name), function()
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
						subMenu:SetToolTip(T(arguments.toolTip));
					end;
				end;
			else
				menuPanel:AddOption(T(option), function()
					if (arguments.Callback) then
						arguments.Callback();
					end;
					
					self:RemoveActiveToolTip();
					self:CloseActiveDermaMenus();
				end);
				
				menuPanel.Items = menuPanel:GetChildren();
				
				local panel = menuPanel.Items[#menuPanel.Items];
				
				if (IsValid(panel) and arguments.toolTip) then
					panel:SetToolTip(T(arguments.toolTip));
				end;
			end;
		end, minimumWidth);
		
		if (IsValid(Clockwork.InfoMenuPanel)) then
			Clockwork.InfoMenuPanel:SetVisible(false);
			Clockwork.InfoMenuPanel:SetSize(minimumWidth, Clockwork.InfoMenuPanel:GetTall());
			Clockwork.InfoMenuPanel:SetPos(x, y);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the ragdoll eye angles.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetRagdollEyeAngles()
		if (!Clockwork.RagdollEyeAngles) then
			Clockwork.RagdollEyeAngles = Angle(0, 0, 0);
		end;
		
		return Clockwork.RagdollEyeAngles;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a gradient.
		@param {Unknown} Missing description for gradientType.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for height.
		@param {Unknown} Missing description for color.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawGradient(gradientType, x, y, width, height, color)
		if (!Clockwork.Gradients[gradientType]) then
			return;
		end;
		
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.SetTexture(Clockwork.Gradients[gradientType]);
		surface.DrawTexturedRect(x, y, width, height);
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a simple gradient box.
		@param {Unknown} Missing description for cornerSize.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for height.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for maxAlpha.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawSimpleGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
		local gradientAlpha = mathMin(color.a, maxAlpha or 100);
		
		draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75));
		
		if (x + cornerSize < x + width and y + cornerSize < y + height) then
			surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha);
			surface.SetMaterial(self:GetGradientTexture());
			surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2));
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a textured gradient.
		@param {Unknown} Missing description for cornerSize.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for height.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for maxAlpha.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawTexturedGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
		local gradientAlpha = mathMin(color.a, maxAlpha or 100);
		
		draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75));

		if (x + cornerSize < x + width and y + cornerSize < y + height) then
			surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha);
			surface.SetMaterial(self:GetGradientTexture());
			surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2));
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a player information sub box.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for width.
		@param {Unknown} Missing description for boxInfo.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to handle an item's spawn icon click.
		@param {Unknown} Missing description for itemTable.
		@param {Unknown} Missing description for spawnIcon.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:HandleItemSpawnIconClick(itemTable, spawnIcon, Callback)
		local customFunctions = itemTable("customFunctions");
		local itemFunctions = {};
		
		if (itemTable.OnUse) then
			itemFunctions[#itemFunctions + 1] = itemTable("useText", "Use");
		end;
		
		if (itemTable.OnDrop) then
			itemFunctions[#itemFunctions + 1] = itemTable("dropText", "Drop");
		end;
		
		if (itemTable.OnDestroy) then
			itemFunctions[#itemFunctions + 1] = itemTable("destroyText", "Destroy");
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
		
		tableSort(itemFunctions, function(a, b)
			return ((type(a) == "table" and a.title) or a) < ((type(b) == "table" and b.title) or b);
		end);
		
		if (#itemFunctions == 0 and !Callback) then
			return;
		end;
		
		local options = {};
		
		if (itemTable.GetEntityMenuOptions) then
			itemTable:GetEntityMenuOptions(nil, options);
		end;
	
		local itemMenu = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
			menuPanel:AddOption(T(option), function()
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
		
		if (Callback) then
			Callback(itemMenu);
		end;
		
		itemMenu:SetMinimumWidth(100);
		
		Clockwork.plugin:Call("PlayerAdjustItemMenu", itemTable, itemMenu, itemFunctions);
			
		for k, v in pairs(itemFunctions) do
			local useText = itemTable("useText", "Use");
			local dropText = itemTable("dropText", "Drop");
			local destroyText = itemTable("destroyText", "Destroy");
			
			if (v == useText) then
				itemMenu:AddOption(T(v), function()
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
			elseif (v == dropText) then
				itemMenu:AddOption(T(v), function()
					if (itemTable) then
						self:RunCommand(
							"InvAction", "drop", itemTable("uniqueID"), itemTable("itemID")
						);
					end;
				end);
			elseif (v == destroyText) then
				local subMenu = itemMenu:AddSubMenu(T(v));
				
				subMenu:AddOption("Yes", function()
					if (itemTable) then
						self:RunCommand(
							"InvAction", "destroy", itemTable("uniqueID"), itemTable("itemID")
						);
					end;
				end);
				
				subMenu:AddOption("No", function() end);
			elseif (type(v) == "table") then
				itemMenu:AddOption(T(v.title), function()
					local defaultAction = true;
					
					if (itemTable.HandleOptions) then
						local transmit, data = itemTable:HandleOptions(v.name);
						
						if (transmit) then
							Clockwork.datastream:Start("MenuOption", {option = v.name, data = data, item = itemTable("itemID")});
							defaultAction = false;
						end;
					end;
					
					if (defaultAction) then
						self:RunCommand(
							"InvAction", v.name, itemTable("uniqueID"), itemTable("itemID")
						);
					end;
				end);
			else
				if (itemTable.OnCustomFunction) then
					itemTable:OnCustomFunction(v);
				end;
				
				itemMenu:AddOption(T(v), function()
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
	
	--[[
		@codebase Shared
		@details A function to handle an item's spawn icon right click.
		@param {Unknown} Missing description for itemTable.
		@param {Unknown} Missing description for spawnIcon.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:HandleItemSpawnIconRightClick(itemTable, spawnIcon)
		if (itemTable.OnHandleRightClick) then
			local functionName = itemTable:OnHandleRightClick();
			
			if (functionName and functionName != "Use") then
				local customFunctions = itemTable("customFunctions");
				
				if (customFunctions and tableHasValue(customFunctions, functionName)) then
					if (itemTable.OnCustomFunction) then
						itemTable:OnCustomFunction(v);
					end;
				end;
				
				self:RunCommand(
					"InvAction", stringLower(functionName), itemTable("uniqueID"), itemTable("itemID")
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
	
	--[[
		@codebase Shared
		@details A function to set a panel's perform layout callback.
		@param {Unknown} Missing description for target.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SetOnLayoutCallback(target, Callback)
		if (target.PerformLayout) then
			target.OldPerformLayout = target.PerformLayout;
			
			--[[
				@codebase Shared
				@details Called when the panel's layout is performed.
				@returns {Unknown}
			--]]
			function target.PerformLayout()
				target:OldPerformLayout(); Callback(target);
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to set the active titled DMenu.
		@param {Unknown} Missing description for menuPanel.
		@param {Unknown} Missing description for title.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SetTitledMenu(menuPanel, title)
		Clockwork.TitledMenu = {
			menuPanel = menuPanel,
			title = title
		};
	end;
	
	--[[
		@codebase Shared
		@details A function to add a markup line.
		@param {Unknown} Missing description for markupText.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for color.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:AddMarkupLine(markupText, text, color)
		if (markupText != "") then
			markupText = markupText.."\n";
		end;
		
		return markupText..self:MarkupTextWithColor(text, color);
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a markup tool tip.
		@param {Unknown} Missing description for markupObject.
		@param {Unknown} Missing description for x.
		@param {Unknown} Missing description for y.
		@param {Unknown} Missing description for alpha.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to override a markup object's draw function.
		@param {Unknown} Missing description for markupObject.
		@param {Unknown} Missing description for customFont.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:OverrideMarkupDraw(markupObject, customFont)
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
				
				-- TODO: May need to revert back to using v.font for the backup font.
				Clockwork.kernel:OverrideMainFont(customFont or v.font);
					Clockwork.kernel:DrawSimpleText(v.text, x, y, Color(v.colour.r, v.colour.g, v.colour.b, alpha));
				Clockwork.kernel:OverrideMainFont(false);
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the active markup tool tip.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetActiveMarkupToolTip()
		return Clockwork.MarkupToolTip;
	end;
	
	--[[
		@codebase Shared
		@details A function to get markup from a color.
		@param {Unknown} Missing description for color.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:ColorToMarkup(color)
		return "<color="..mathCeil(color.r)..","..mathCeil(color.g)..","..mathCeil(color.b)..">";
	end;
	
	--[[
		@codebase Shared
		@details A function to markup text with a color.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for scale.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:MarkupTextWithColor(text, color, scale)
		local fontName = Clockwork.fonts:GetMultiplied("cwTooltip", scale or 1);
		local finalText = text;
		
		if (color) then
			finalText = self:ColorToMarkup(color)..text.."</color>";
		end;
		
		finalText = "<font="..fontName..">"..finalText.."</font>";
		
		return finalText;
	end;
	
	--[[
		@codebase Shared
		@details A function to create a markup tool tip.
		@param {Unknown} Missing description for panel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CreateMarkupToolTip(panel)
		panel.OldCursorExited = panel.OnCursorExited;
		panel.OldCursorEntered = panel.OnCursorEntered;
		
		function panel.OnCursorEntered(panel, ...)
			if (panel.OldCursorEntered) then
				panel:OldCursorEntered(...);
			end;
			
			Clockwork.MarkupToolTip = panel;
		end;

		function panel.OnCursorExited(panel, ...)
			if (panel.OldCursorExited) then
				panel:OldCursorExited(...);
			end;
			
			if (Clockwork.MarkupToolTip == panel) then
				Clockwork.MarkupToolTip = nil;
			end;
		end;
		
		function panel.SetMarkupToolTip(panel, text)
			if (!string.find(text, "</font>")) then
				text = Clockwork.kernel:MarkupTextWithColor(text);
			end;
		
			if (!panel.MarkupToolTip or panel.MarkupToolTip.text != text) then
				panel.MarkupToolTip = {
					object = markup.Parse(text, ScrW() * 0.25),
					text = text
				};
				
				self:OverrideMarkupDraw(panel.MarkupToolTip.object);
			end;
		end;
		
		function panel.GetMarkupToolTip(panel)
			return panel.MarkupToolTip;
		end;
		
		function panel.SetToolTip(panel, toolTip)
			panel:SetMarkupToolTip(toolTip);
		end;
		
		return panel;
	end;
	
	--[[
		@codebase Shared
		@details A function to create a custom category panel.
		@param {Unknown} Missing description for categoryName.
		@param {Unknown} Missing description for parent.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CreateCustomCategoryPanel(categoryName, parent)
		if (!parent.CategoryList) then
			parent.CategoryList = {};
		end;
		
		local collapsibleCategory = vgui.Create("DCollapsibleCategory", parent);
			collapsibleCategory:SetExpanded(true);
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetLabel(categoryName);
		parent.CategoryList[#parent.CategoryList + 1] = collapsibleCategory;
		
		return collapsibleCategory;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw the armor bar.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawArmorBar()
		local armor = mathClamp(Clockwork.Client:Armor(), 0, Clockwork.Client:GetMaxArmor());
		
		if (!self.armor) then
			self.armor = armor;
		else
			self.armor = mathApproach(self.armor, armor, 1);
		end;
		
		if (armor > 0) then
			Clockwork.bars:Add("ARMOR", Color(139, 174, 179, 255), "", self.armor, Clockwork.Client:GetMaxArmor(), self.health < 10, 1);
		end;
	end;

	--[[
		@codebase Shared
		@details A function to draw the health bar.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawHealthBar()
		local health = mathClamp(Clockwork.Client:Health(), 0, Clockwork.Client:GetMaxHealth());
		
		if (!self.armor) then
			self.health = health;
		else
			self.health = mathApproach(self.health, health, 1);
		end;
		
		if (health > 0) then
			Clockwork.bars:Add("HEALTH", Color(179, 46, 49, 255), "", self.health, Clockwork.Client:GetMaxHealth(), self.health < 10, 2);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to remove the active tool tip.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RemoveActiveToolTip()
		ChangeTooltip();
	end;
	
	--[[
		@codebase Shared
		@details A function to close active Derma menus.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CloseActiveDermaMenus()
		CloseDermaMenus();
	end;
	
	--[[
		@codebase Shared
		@details A function to register a background blur.
		@param {Unknown} Missing description for panel.
		@param {Unknown} Missing description for fCreateTime.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RegisterBackgroundBlur(panel, fCreateTime)
		Clockwork.BackgroundBlurs[panel] = fCreateTime or SysTime();
	end;
	
	--[[
		@codebase Shared
		@details A function to remove a background blur.
		@param {Unknown} Missing description for panel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RemoveBackgroundBlur(panel)
		Clockwork.BackgroundBlurs[panel] = nil;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw the background blurs.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawBackgroundBlurs()
		local scrH, scrW = ScrH(), ScrW();
		local sysTime = SysTime();
		
		for k, v in pairs(Clockwork.BackgroundBlurs) do
			if (type(k) == "string" or (IsValid(k) and k:IsVisible())) then
				local fraction = mathClamp((sysTime - v) / 1, 0, 1);
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
	
	--[[
		@codebase Shared
		@details A function to get the notice panel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetNoticePanel()
		if (IsValid(Clockwork.NoticePanel) and Clockwork.NoticePanel:IsVisible()) then
			return Clockwork.NoticePanel;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to set the notice panel.
		@param {Unknown} Missing description for noticePanel.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SetNoticePanel(noticePanel)
		Clockwork.NoticePanel = noticePanel;
	end;
	
	--[[
		@codebase Shared
		@details A function to add some cinematic text.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for color.
		@param {Unknown} Missing description for barLength.
		@param {Unknown} Missing description for hangTime.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for bThisOnly.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:AddCinematicText(text, color, barLength, hangTime, font, bThisOnly)
		local colorWhite = Clockwork.option:GetColor("white");
		local cinematicTable = {
			barLength = barLength or (ScrH() * 8),
			hangTime = hangTime or 3,
			color = color or colorWhite,
			font = font,
			text = T(text),
			add = 0
		};
		
		if (bThisOnly) then
			Clockwork.Cinematics[1] = cinematicTable;
		else
			Clockwork.Cinematics[#Clockwork.Cinematics + 1] = cinematicTable;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to add a notice.
		@param {Unknown} Missing description for text.
		@param {Unknown} Missing description for class.
		@param {Unknown} Missing description for length.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:AddNotify(text, class, length)
		if (class != NOTIFY_HINT or stringSub(text, 1, 6) != "#Hint_") then
			if (Clockwork.BaseClass.AddNotify) then
				Clockwork.BaseClass:AddNotify(text, class, length);
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the local player is using the tool gun.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IsUsingTool()
		if (IsValid(Clockwork.Client:GetActiveWeapon())
		and Clockwork.Client:GetActiveWeapon():GetClass() == "gmod_tool") then
			return true;
		else
			return false;
		end;
	end;

	--[[
		@codebase Shared
		@details A function to get whether the local player is using the camera.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IsUsingCamera()
		if (IsValid(Clockwork.Client:GetActiveWeapon())
		and Clockwork.Client:GetActiveWeapon():GetClass() == "gmod_camera") then
			return true;
		else
			return false;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the target ID data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:GetTargetIDData()
		return Clockwork.TargetIDData;
	end;
	
	--[[
		@codebase Shared
		@details A function to calculate the screen fading.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:CalculateScreenFading()
		if (Clockwork.plugin:Call("ShouldPlayerScreenFadeBlack")) then
			if (!Clockwork.BlackFadeIn) then
				if (Clockwork.BlackFadeOut) then
					Clockwork.BlackFadeIn = Clockwork.BlackFadeOut;
				else
					Clockwork.BlackFadeIn = 0;
				end;
			end;
			
			Clockwork.BlackFadeIn = mathClamp(Clockwork.BlackFadeIn + (FrameTime() * 20), 0, 255);
			Clockwork.BlackFadeOut = nil;
			self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, Clockwork.BlackFadeIn));
		else
			if (Clockwork.BlackFadeIn) then
				Clockwork.BlackFadeOut = Clockwork.BlackFadeIn;
			end;
			
			Clockwork.BlackFadeIn = nil;
			
			if (Clockwork.BlackFadeOut) then
				Clockwork.BlackFadeOut = mathClamp(Clockwork.BlackFadeOut - (FrameTime() * 40), 0, 255);
				self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, Clockwork.BlackFadeOut));
				
				if (Clockwork.BlackFadeOut == 0) then
					Clockwork.BlackFadeOut = nil;
				end;
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw a cinematic.
		@param {Unknown} Missing description for cinematicTable.
		@param {Unknown} Missing description for curTime.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawCinematic(cinematicTable, curTime)
		local maxBarLength = cinematicTable.barLength or (ScrH() / 13);
		local font = cinematicTable.font or Clockwork.option:GetFont("cinematic_text");
		
		if (cinematicTable.goBack and curTime > cinematicTable.goBack) then
			cinematicTable.add = mathClamp(cinematicTable.add - 2, 0, maxBarLength);
			
			if (cinematicTable.add == 0) then
				tableRemove(Clockwork.Cinematics, 1);
				cinematicTable = nil;
			end;
		else
			cinematicTable.add = mathClamp(cinematicTable.add + 1, 0, maxBarLength);
			
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
	
	--[[
		@codebase Shared
		@details A function to draw the cinematic introduction.
		@param {Unknown} Missing description for curTime.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawCinematicIntro(curTime)
		local cinematicInfo = Clockwork.plugin:Call("GetCinematicIntroInfo");
		local colorWhite = Clockwork.option:GetColor("white");
		
		if (cinematicInfo) then
			if (Clockwork.CinematicScreenAlpha and Clockwork.CinematicScreenTarget) then
				Clockwork.CinematicScreenAlpha = mathApproach(Clockwork.CinematicScreenAlpha, Clockwork.CinematicScreenTarget, 1);
				
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
					local alpha = mathClamp(Clockwork.CinematicScreenAlpha, 0, 255);
					
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
	
	--[[
		@codebase Shared
		@details A function to draw the cinematic introduction bars.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawCinematicIntroBars()
		if (Clockwork.config:Get("draw_intro_bars"):Get()) then
			local maxBarLength = ScrH() / 8;
			
			if (!Clockwork.CinematicBarsTarget and !Clockwork.CinematicBarsAlpha) then
				Clockwork.CinematicBarsAlpha = 0;
				Clockwork.CinematicBarsTarget = 255;
				Clockwork.option:PlaySound("rollover");
			end;
			
			Clockwork.CinematicBarsAlpha = mathApproach(Clockwork.CinematicBarsAlpha, Clockwork.CinematicBarsTarget, 1);
			
			if (Clockwork.CinematicScreenDone) then
				if (Clockwork.CinematicScreenBarLength != 0) then
					Clockwork.CinematicScreenBarLength = mathClamp((maxBarLength / 255) * Clockwork.CinematicBarsAlpha, 0, maxBarLength);
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
					Clockwork.IntroBarsMultiplier = mathClamp(Clockwork.IntroBarsMultiplier + (FrameTime() * 8), 1, 12);
				end;
				
				Clockwork.CinematicScreenBarLength = mathClamp((maxBarLength / 255) * mathClamp(Clockwork.CinematicBarsAlpha * Clockwork.IntroBarsMultiplier, 0, 255), 0, maxBarLength);
			end;
			
			draw.RoundedBox(0, 0, 0, ScrW(), Clockwork.CinematicScreenBarLength, Color(0, 0, 0, 255));
			draw.RoundedBox(0, 0, ScrH() - Clockwork.CinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255));
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw the cinematic info.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DrawCinematicInfo()
		if (!Clockwork.CinematicInfoAlpha and !Clockwork.CinematicInfoSlide) then
			Clockwork.CinematicInfoAlpha = 255;
			Clockwork.CinematicInfoSlide = 0;
		end;
		
		Clockwork.CinematicInfoSlide = mathApproach(Clockwork.CinematicInfoSlide, 255, 1);
		
		if (Clockwork.CinematicScreenAlpha and Clockwork.CinematicScreenTarget) then
			Clockwork.CinematicInfoAlpha = mathApproach(Clockwork.CinematicInfoAlpha, 0, 1);
			
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
			local textPosScale = 1 - (Clockwork.CinematicInfoAlpha / 255);
			local textPosY = (screenHeight * 0.35) - ((screenHeight * 0.15) * textPosScale);
			local textPosX = screenWidth * 0.3;
			
			if (cinematicInfo.title) then
				local cinematicInfoTitle = stringUpper(cinematicInfo.title);
				local cinematicIntroText = stringUpper(cinematicInfo.text);
				local introTextSmallFont = Clockwork.option:GetFont("intro_text_small");
				local introTextBigFont = Clockwork.option:GetFont("intro_text_big");
				local textWidth, textHeight = self:GetCachedTextSize(introTextBigFont, cinematicInfoTitle);
				local boxAlpha = mathMin(Clockwork.CinematicInfoAlpha, 150);
				
				if (cinematicInfo.text) then
					local smallTextWidth, smallTextHeight = self:GetCachedTextSize(introTextSmallFont, cinematicIntroText);
					
					self:DrawGradient(
						GRADIENT_RIGHT, 0, textPosY - 80, screenWidth, textHeight + smallTextHeight + 160, Color(100, 100, 100, boxAlpha)
					);
				else
					self:DrawGradient(
						GRADIENT_RIGHT, 0, textPosY - 80, screenWidth, textHeight + 160, Color(100, 100, 100, boxAlpha)
					);
				end;
				
				self:OverrideMainFont(introTextBigFont);
					self:DrawSimpleText(cinematicInfoTitle, textPosX, textPosY, Color(colorInfo.r, colorInfo.g, colorInfo.b, Clockwork.CinematicInfoAlpha), nil, nil, true);
				self:OverrideMainFont(false);
				
				if (cinematicInfo.text) then
					self:OverrideMainFont(introTextSmallFont);
						self:DrawSimpleText(cinematicIntroText, textPosX, textPosY + textHeight + 8, Color(colorWhite.r, colorWhite.g, colorWhite.b, Clockwork.CinematicInfoAlpha), nil, nil, true);
					self:OverrideMainFont(false);
				end;
			elseif (cinematicInfo.text) then
				self:OverrideMainFont(introTextSmallFont);
					self:DrawSimpleText(cinematicIntroText, textPosX, textPosY, Color(colorWhite.r, colorWhite.g, colorWhite.b, Clockwork.CinematicInfoAlpha), nil, nil, true);
				self:OverrideMainFont(false);
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to draw some door text.
		@param {Unknown} Missing description for entity.
		@param {Unknown} Missing description for eyePos.
		@param {Unknown} Missing description for eyeAngles.
		@param {Unknown} Missing description for font.
		@param {Unknown} Missing description for nameColor.
		@param {Unknown} Missing description for textColor.
		@returns {Unknown}
	--]]
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
			
			if (name) then name = L(name); end;
			if (text) then text = L(text); end;
			
			if (name or text) then
				local nameWidth, nameHeight = self:GetCachedTextSize(font, name or "");
				local textWidth, textHeight = self:GetCachedTextSize(font, text or "");
				local longWidth = nameWidth;
				local boxAlpha = mathMin(alpha, 150);
				
				if (textWidth > longWidth) then
					longWidth = textWidth;
				end;
				
				local scale = mathAbs((doorData.width * 0.75) / longWidth);
				local nameScale = mathMin(scale, 0.05);
				local textScale = mathMin(scale, 0.03);
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
	
	--[[
		@codebase Shared
		@details A function to get whether the local player's character screen is open.
		@param {Unknown} Missing description for isVisible.
		@returns {Unknown}
	--]]
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
	
	--[[
		@codebase Shared
		@details A function to save schema data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SaveSchemaData(fileName, data)
		if (type(data) != "table") then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
			return;
		end;	
	
		_file.Write("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", self:Serialize(data));
	end;

	--[[
		@codebase Shared
		@details A function to delete schema data.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DeleteSchemaData(fileName)
		_file.Delete("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt");
	end;

	--[[
		@codebase Shared
		@details A function to check if schema data exists.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SchemaDataExists(fileName)
		return _file.Exists("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA");
	end;
	
	--[[
		@codebase Shared
		@details A function to find schema data in a directory.
		@param {Unknown} Missing description for directory.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:FindSchemaDataInDir(directory)
		return _file.Find("clockwork/schemas/"..self:GetSchemaFolder().."/"..directory, "LUA", "namedesc");
	end;

	--[[
		@codebase Shared
		@details A function to restore schema data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for failSafe.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RestoreSchemaData(fileName, failSafe)
		if (self:SchemaDataExists(fileName)) then
			local data = _file.Read("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA");
			
			if (data) then
				local wasSuccess, value = pcall(util.JSONToTable, data);
				
				if (wasSuccess and value != nil) then
					return value;
				else
					local wasSuccess, value = pcall(self.Deserialize, self, data);
					
					if (wasSuccess and value != nil) then
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

	--[[
		@codebase Shared
		@details A function to restore Clockwork data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for failSafe.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RestoreClockworkData(fileName, failSafe)
		if (self:ClockworkDataExists(fileName)) then
			local data = _file.Read("clockwork/"..fileName..".txt", "DATA");
			
			if (data) then
				local success, value = pcall(util.JSONToTable, data);
				
				if (success and value != nil) then
					return value;
				else
					local wasSuccess, value = pcall(self.Deserialize, self, data);
					
					if (wasSuccess and value != nil) then
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

	--[[
		@codebase Shared
		@details A function to save Clockwork data.
		@param {Unknown} Missing description for fileName.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:SaveClockworkData(fileName, data)
		if (type(data) != "table") then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n");
			
			return;
		end;	
	
		_file.Write("clockwork/"..fileName..".txt", self:Serialize(data));
	end;

	--[[
		@codebase Shared
		@details A function to check if Clockwork data exists.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:ClockworkDataExists(fileName)
		return _file.Exists("clockwork/"..fileName..".txt", "DATA");
	end;

	--[[
		@codebase Shared
		@details A function to delete Clockwork data.
		@param {Unknown} Missing description for fileName.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:DeleteClockworkData(fileName)
		_file.Delete("clockwork/"..fileName..".txt");
	end;
	
	--[[
		@codebase Shared
		@details A function to run a Clockwork command.
		@param {Unknown} Missing description for command.
		@param {Unknown} Missing description for ....
		@returns {Unknown}
	--]]
	function Clockwork.kernel:RunCommand(command, ...)
		RunConsoleCommand("cwCmd", command, ...);
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the local player is choosing a character.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IsChoosingCharacter()
		if (Clockwork.character:GetPanel()) then
			return Clockwork.character:IsPanelOpen();
		else
			return true;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to include the schema.
		@returns {Unknown}
	--]]
	function Clockwork.kernel:IncludeSchema()
		local schemaFolder = self:GetSchemaFolder();
		
		if (schemaFolder and type(schemaFolder) == "string") then
			Clockwork.plugin:Include(schemaFolder.."/schema", true);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to explode a string by tags.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for seperator.
	@param {Unknown} Missing description for open.
	@param {Unknown} Missing description for close.
	@param {Unknown} Missing description for hide.
	@returns {Unknown}
--]]
function Clockwork.kernel:ExplodeByTags(text, seperator, open, close, hide)
	local results = {};
	local current = "";
	local tag = nil;
	
	for i = 1, #text do
		local character = stringSub(text, i, i);
		
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

--[[
	@codebase Shared
	@details A function to modify a physical description.
	@param {Unknown} Missing description for description.
	@returns {Unknown}
--]]
function Clockwork.kernel:ModifyPhysDesc(description)
	if (stringLen(description) <= 128) then
		if (!stringFind(stringSub(description, -2), "%p")) then
			return description..".";
		else
			return description;
		end;
	else
		return stringSub(description, 1, 125).."...";
	end;
end;

local MAGIC_CHARACTERS = "([%(%)%.%%%+%-%*%?%[%^%$])";

--[[
	@codebase Shared
	@details A function to replace something in text without pattern matching.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for find.
	@param {Unknown} Missing description for replace.
	@returns {Unknown}
--]]
function Clockwork.kernel:Replace(text, find, replace)
	return (text:gsub(find:gsub(MAGIC_CHARACTERS, "%%%1"), replace));
end;

--[[
	@codebase Shared
	@details A function to create a new meta table.
	@param {Unknown} Missing description for baseTable.
	@returns {Unknown}
--]]
function Clockwork.kernel:NewMetaTable(baseTable)
	local object = {};
		setmetatable(object, baseTable);
		baseTable.__index = baseTable;
	return object;
end;

--[[
	@codebase Shared
	@details A function to make a proxy meta table.
	@param {Unknown} Missing description for baseTable.
	@param {Unknown} Missing description for baseClass.
	@param {Unknown} Missing description for proxy.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to set whether a string should be in camel case.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for bCamelCase.
	@returns {Unknown}
--]]
function Clockwork.kernel:SetCamelCase(text, bCamelCase)
	if (bCamelCase) then
		return stringGsub(text, "^.", stringLower);
	else
		return stringGsub(text, "^.", stringUpper);
	end;
end;

--[[
	@codebase Shared
	@details A function to add files to the content download.
	@param {Unknown} Missing description for directory.
	@param {Unknown} Missing description for bRecursive.
	@returns {Unknown}
--]]
function Clockwork.kernel:AddDirectory(directory, bRecursive)
	if (stringSub(directory, -1) == "/") then
		directory = directory.."*.*";
	end;
	
	local files, folders = _file.Find(directory, "GAME", "namedesc");
	local rawDirectory = stringMatch(directory, "(.*)/").."/";
	
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

--[[
	@codebase Shared
	@details A function to add a file to the content download.
	@param {Unknown} Missing description for fileName.
	@returns {Unknown}
--]]
function Clockwork.kernel:AddFile(fileName)
	if (_file.Exists(fileName, "GAME")) then
		resource.AddFile(fileName);
	else
		-- print(Format("[Clockwork] File does not exist: %s.", fileName));
	end;
end;

--[[
	@codebase Shared
	@details A function to include files in a directory.
	@param {Unknown} Missing description for directory.
	@param {Unknown} Missing description for bFromBase.
	@returns {Unknown}
--]]
function Clockwork.kernel:IncludeDirectory(directory, bFromBase)
	if (bFromBase) then
		directory = "clockwork/framework/"..directory;
	end;
	
	if (stringSub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	for k, v in pairs(_file.Find(directory.."*.lua", "LUA", "namedesc")) do
		self:IncludePrefixed(directory..v);
	end;
end;

--[[
	@codebase Shared
	@details A function to include a prefixed cwFile.
	@param {Unknown} Missing description for fileName.
	@returns {Unknown}
--]]
function Clockwork.kernel:IncludePrefixed(fileName)
	local isShared = (stringFind(fileName, "sh_") or stringFind(fileName, "shared.lua"));
	local isClient = (stringFind(fileName, "cl_") or stringFind(fileName, "cl_init.lua"));
	local isServer = (stringFind(fileName, "sv_"));
	
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

--[[
	@codebase Shared
	@details A function to include plugins in a directory.
	@param {Unknown} Missing description for directory.
	@param {Unknown} Missing description for bFromBase.
	@returns {Unknown}
--]]
function Clockwork.kernel:IncludePlugins(directory, bFromBase)
	if (bFromBase) then
		directory = "Clockwork/"..directory;
	end;
	
	if (stringSub(directory, -1) != "/") then
		directory = directory.."/";
	end;
	
	local files, pluginFolders = _file.Find(directory.."*", "LUA", "namedesc");
	
	for k, v in pairs(pluginFolders) do
		if (v != ".." and v != ".") then
			Clockwork.plugin:Include(directory..v.."/plugin");
		end;
	end;	
	
	return true;
end;

--[[
	@codebase Shared
	@details A function to perform the timer think.
	@param {Unknown} Missing description for curTime.
	@returns {Unknown}
--]]
function Clockwork.kernel:CallTimerThink(curTime)
	for k, v in pairs(Clockwork.Timers) do
		if (!v.paused) then
			if (curTime >= v.nextCall) then
				local wasSuccess, value = pcall(v.Callback, unpack(v.arguments));
				
				if (!wasSuccess) then
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

--[[
	@codebase Shared
	@details A function to get whether a timer exists.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.kernel:TimerExists(name)
	return Clockwork.Timers[name];
end;

--[[
	@codebase Shared
	@details A function to start a timer.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.kernel:StartTimer(name)
	if (Clockwork.Timers[name] and Clockwork.Timers[name].paused) then
		Clockwork.Timers[name].nextCall = CurTime() + Clockwork.Timers[name].timeLeft;
		Clockwork.Timers[name].paused = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to pause a timer.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.kernel:PauseTimer(name)
	if (Clockwork.Timers[name] and !Clockwork.Timers[name].paused) then
		Clockwork.Timers[name].timeLeft = Clockwork.Timers[name].nextCall - CurTime();
		Clockwork.Timers[name].paused = true;
	end;
end;

--[[
	@codebase Shared
	@details A function to destroy a timer.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.kernel:DestroyTimer(name)
	Clockwork.Timers[name] = nil;
end;

--[[
	@codebase Shared
	@details A function to create a timer.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for delay.
	@param {Unknown} Missing description for repetitions.
	@param {Unknown} Missing description for Callback.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to run a function on the next frame.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.kernel:OnNextFrame(name, Callback)
	self:CreateTimer(name, FrameTime(), 1, Callback);
end;

--[[
	@codebase Shared
	@details A function to get whether a player has access to an object.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for object.
	@returns {Unknown}
--]]
function Clockwork.kernel:HasObjectAccess(player, object)
	local hasAccess = false;
	local faction = player:GetFaction();
	
	if (object.access) then
		if (Clockwork.player:HasAnyFlags(player, object.access)) then
			hasAccess = true;
		end;
	end;
	
	if (object.factions) then
		if (tableHasValue(object.factions, faction)) then
			hasAccess = true;
		end;
	end;
	
	if (object.classes) then
		local team = player:Team();
		local class = Clockwork.class:FindByID(team);
		
		if (class) then
			if (tableHasValue(object.classes, team)
			or tableHasValue(object.classes, class.name)) then
				hasAccess = true;
			end;
		end;
	end;
	
	if (object.traits) then
		for k, v in ipairs(object.traits) do
			if (player:HasTrait(v)) then
				hasAccess = true;
				break;
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
		
		if (tableHasValue(object.blacklist, faction)) then
			hasAccess = false;
		elseif (class) then
			if (tableHasValue(object.blacklist, team)
			or tableHasValue(object.blacklist, class.name)) then
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

--[[
	@codebase Shared
	@details A function to get the sorted commands.
	@returns {Unknown}
--]]
function Clockwork.kernel:GetSortedCommands()
	local commands = {};
	local source = Clockwork.command.stored;
	
	for k, v in pairs(source) do
		commands[#commands + 1] = k;
	end;
	
	tableSort(commands, function(a, b)
		return a < b;
	end);
	
	return commands;
end;

--[[
	@codebase Shared
	@details A function to zero a number to an amount of digits.
	@param {Unknown} Missing description for number.
	@param {Unknown} Missing description for digits.
	@returns {Unknown}
--]]
function Clockwork.kernel:ZeroNumberToDigits(number, digits)
	return stringRep("0", mathClamp(digits - stringLen(tostring(number)), 0, digits))..tostring(number);
end;

--[[
	@codebase Shared
	@details A function to get a short CRC from a value.
	@param {Unknown} Missing description for value.
	@returns {Unknown}
--]]
function Clockwork.kernel:GetShortCRC(value)
	return mathCeil(util.CRC(value) / 100000);
end;

--[[
	@codebase Shared
	@details A function to validate a table's keys.
	@param {Unknown} Missing description for baseTable.
	@returns {Unknown}
--]]
function Clockwork.kernel:ValidateTableKeys(baseTable)
	local invalidKeys = {};

	for i = 1, #baseTable do
		if (!baseTable[i]) then
			tableInsert(invalidKeys, i);
		end;
	end;

	for i = #invalidKeys, 1, -1 do
		tableRemove(baseTable, invalidKeys[i]);
	end;
end;

--[[
	@codebase Shared
	@details A function to get the map's physics entities.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to create a multicall table (by Deco Da Man).
	@param {Unknown} Missing description for baseTable.
	@param {Unknown} Missing description for object.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to get a default networked value.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to convert a networked class.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to get the default class value.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
function Clockwork.kernel:GetDefaultClassValue(class)
	return DEFAULT_NETWORK_CLASS_VALUE[class];
end;

--[[
	@codebase Shared
	@details A function to set a shared variable.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for value.
	@param {Unknown} Missing description for sharedTable.
	@returns {Unknown}
--]]
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
					MsgC(Color(255, 100, 0, 255), "[Clockwork:GlobalSharedVars] Attempted to set SharedVar '"..key.."' of type '"..class.."' with value of type '"..type(value).."'.\n"..err.."\n");
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

--[[
	@codebase Shared
	@details A function to get the shared vars.
	@returns {Unknown}
--]]
function Clockwork.kernel:GetSharedVars()
	return Clockwork.SharedVars, Clockwork.SharedTables;
end;

--[[
	@codebase Shared
	@details A function to get a shared variable.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for sharedTable.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to create fake damage info.
	@param {Unknown} Missing description for damage.
	@param {Unknown} Missing description for inflictor.
	@param {Unknown} Missing description for attacker.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for damageType.
	@param {Unknown} Missing description for damageForce.
	@returns {Unknown}
--]]
function Clockwork.kernel:FakeDamageInfo(damage, inflictor, attacker, position, damageType, damageForce)
	local damageInfo = DamageInfo();
	local realDamage = mathCeil(mathMax(damage, 0));
	
	damageInfo:SetDamagePosition(position);
	damageInfo:SetDamageForce(Vector() * damageForce);
	damageInfo:SetDamageType(damageType);
	damageInfo:SetInflictor(inflictor);
	damageInfo:SetAttacker(attacker);
	damageInfo:SetDamage(realDamage);
	
	return damageInfo;
end;

--[[
	@codebase Shared
	@details A function to unpack a color.
	@param {Unknown} Missing description for color.
	@returns {Unknown}
--]]
function Clockwork.kernel:UnpackColor(color)
	return color.r, color.g, color.b, color.a;
end;

--[[
	@codebase Shared
	@details A function to parse data in text.
	@param {Unknown} Missing description for text.
	@returns {Unknown}
--]]
function Clockwork.kernel:ParseData(text)
	local classes = {"%^", "%!"};
	
	for k, v in pairs(classes) do
		for key in stringGmatch(text, v.."(.-)"..v) do
			local lower = false;
			local amount;
			
			if (stringSub(key, 1, 1) == "(" and stringSub(key, -1) == ")") then
				lower = true;
				amount = tonumber(stringSub(key, 2, -2));
			else
				amount = tonumber(key);
			end;
			
			if (amount) then
				text = stringGsub(text, v..stringGsub(key, "([%(%)])", "%%%1")..v, tostring(self:FormatCash(amount, k == 2, lower)));
			end;
		end;
	end;
	
	for k in stringGmatch(text, "%*(.-)%*") do
		k = stringGsub(k, "[%(%)]", "");
		
		if (k != "") then
			text = stringGsub(text, "%*%("..k.."%)%*", tostring(Clockwork.option:Translate(k, true)));
			text = stringGsub(text, "%*"..k.."%*", tostring(Clockwork.option:Translate(k)));
		end;
	end;
	
	if (CLIENT) then
		for k in stringGmatch(text, ":(.-):") do
			if (k != "" and input.LookupBinding(k)) then
				text = self:Replace(text, ":"..k..":", "<"..stringUpper(tostring(input.LookupBinding(k)))..">");
			end;
		end;
	end;
	
	return Clockwork.config:Parse(text);
end;
