--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local cwConfig = Clockwork.config;
local cwPly = Clockwork.player;
local cwPlugin = Clockwork.plugin;
local cwStorage = Clockwork.storage;
local cwEvent = Clockwork.event;
local cwLimb = Clockwork.limb;
local cwItem = Clockwork.item;
local cwEntity = Clockwork.entity;
local cwKernel = Clockwork.kernel;
local cwOption = Clockwork.option;
local cwBans = Clockwork.bans;
local cwDatabase = Clockwork.database;
local cwDatastream = Clockwork.datastream;
local cwFaction = Clockwork.faction;
local cwInventory = Clockwork.inventory;
local cwHint = Clockwork.hint;
local cwCommand = Clockwork.command;
local cwClass = Clockwork.class;
local cwVoice = Clockwork.voice;

local entityMeta = FindMetaTable("Entity");
local playerMeta = FindMetaTable("Player");

entityMeta.ClockworkSetMaterial = entityMeta.ClockworkSetMaterial or entityMeta.SetMaterial;
entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets;
entityMeta.ClockworkExtinguish = entityMeta.ClockworkExtinguish or entityMeta.Extinguish;
entityMeta.ClockworkWaterLevel = entityMeta.ClockworkWaterLevel or entityMeta.WaterLevel;
entityMeta.ClockworkSetHealth = entityMeta.ClockworkSetHealth or entityMeta.SetHealth;
entityMeta.ClockworkSetColor = entityMeta.ClockworkSetColor or entityMeta.SetColor;
entityMeta.ClockworkIsOnFire = entityMeta.ClockworkIsOnFire or entityMeta.IsOnFire;
entityMeta.ClockworkSetModel = entityMeta.ClockworkSetModel or entityMeta.SetModel;
entityMeta.ClockworkSetSkin = entityMeta.ClockworkSetSkin or entityMeta.SetSkin;
entityMeta.ClockworkAlive = entityMeta.ClockworkAlive or playerMeta.Alive;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		cwPlugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	cwPlugin:Call("EntityFireBullets", self, bulletInfo);
	return self:ClockworkFireBullets(bulletInfo);
end;

-- A function to set an entity's skin.
function entityMeta:SetSkin(skin)
	self:ClockworkSetSkin(skin);
	
	if (self:IsPlayer()) then
		cwPlugin:Call("PlayerSkinChanged", self, skin);
		
		if (self:IsRagdolled()) then
			self:GetRagdollTable().skin = skin;
		end;
	end;
end;

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	self:ClockworkSetModel(model);
	
	if (self:IsPlayer()) then
		cwPlugin:Call("PlayerModelChanged", self, model);
		
		if (self:IsRagdolled()) then
			self:GetRagdollTable().model = model;
		end;
	end;
end;

-- A function to get an entity's owner key.
function entityMeta:GetOwnerKey()
	return self.cwOwnerKey;
end;

-- A function to set an entity's owner key.
function entityMeta:SetOwnerKey(key)
	self.cwOwnerKey = key;
end;

-- A function to get whether an entity is a map entity.
function entityMeta:IsMapEntity()
	return cwEntity:IsMapEntity(self);
end;

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return cwEntity:GetStartPosition(self);
end;

-- A function to emit a hit sound for an entity.
function entityMeta:EmitHitSound(sound)
	self:EmitSound("weapons/crossbow/hitbod2.wav",
		math.random(100, 150), math.random(150, 170)
	);
	
	timer.Simple(FrameTime(), function()
		if (IsValid(self)) then
			self:EmitSound(sound);
		end;
	end);
end;

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if (self:IsPlayer() and self:IsRagdolled()) then
		self:GetRagdollEntity():SetMaterial(material);
	end;
	
	self:ClockworkSetMaterial(material);
end;

-- A function to set an entity's color.
function entityMeta:SetColor(color)
	if (self:IsPlayer() and self:IsRagdolled()) then
		self:GetRagdollEntity():SetColor(color);
	end;
	
	self:ClockworkSetColor(color);
end;

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	if (IsValid(self)) then
		return cwPlugin:Call("GetEntityBeingHeld", self);
	end;
end;