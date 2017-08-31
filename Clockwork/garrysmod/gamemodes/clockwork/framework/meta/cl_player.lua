--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local cwDatastream = Clockwork.datastream;
local cwCharacter = Clockwork.character;
local cwCommand = Clockwork.command;
local cwSetting = Clockwork.setting;
local cwFaction = Clockwork.faction;
local cwChatBox = Clockwork.chatBox;
local cwEntity = Clockwork.entity;
local cwOption = Clockwork.option;
local cwConfig = Clockwork.config;
local cwKernel = Clockwork.kernel;
local cwPlugin = Clockwork.plugin;
local cwTheme = Clockwork.theme;
local cwEvent = Clockwork.event;
local cwPly = Clockwork.player;
local cwMenu = Clockwork.menu;
local cwQuiz = Clockwork.quiz;
local cwItem = Clockwork.item;
local cwLimb = Clockwork.limb;

local playerMeta = FindMetaTable("Player");

playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name;

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
	return cwPly:IsNoClipping(self);
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
function playerMeta:IsJogging(testSpeed)
	if (!self:IsRunning() and (self:GetSharedVar("IsJogMode") or testSpeed)) then
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
	return cwPly:IsRagdolled(self, exception, entityless);
end;

-- A function to set a shared variable for a player.
function playerMeta:SetSharedVar(key, value)
	cwPly:SetSharedVar(self, key, value);
end;

-- A function to get whether a player has a trait.
function playerMeta:HasTrait(uniqueID)
	return (self.cwTraits and table.HasValue(self.cwTraits, uniqueID));
end;

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key, sharedTable)
	return cwPly:GetSharedVar(self, key, sharedTable);
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
	
	if (cwFaction:FindByID(index)) then
		return cwFaction:FindByID(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return cwPly:GetWagesName(self);
end;

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	local playerData = cwPly.playerData[key];
	
	if (playerData and (!playerData.playerOnly or self == Clockwork.Client)) then
		return self:GetSharedVar(key);
	end;
	
	return default;
end;

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	local characterData = cwPly.characterData[key];
	
	if (characterData and (!characterData.playerOnly or self == Clockwork.Client)) then
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
	return cwPly:GetRagdollState(self);
end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return cwPly:GetRagdollEntity(self);
end;

-- A function to get a player's rank within their faction.
function playerMeta:GetFactionRank(character)
	return cwPly:GetFactionRank(self, character);
end;

-- A function to get a player's chat icon.
function playerMeta:GetChatIcon()
	return cwPly:GetChatIcon(self);
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;