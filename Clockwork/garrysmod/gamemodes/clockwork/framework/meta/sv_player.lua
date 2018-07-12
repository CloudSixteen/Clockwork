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
local cwAttribute = Clockwork.attribute;
local cwAttributes = Clockwork.attributes;
local cwDatabase = Clockwork.database;
local cwDatastream = Clockwork.datastream;
local cwFaction = Clockwork.faction;
local cwInventory = Clockwork.inventory;
local cwHint = Clockwork.hint;
local cwCommand = Clockwork.command;
local cwClass = Clockwork.class;
local cwVoice = Clockwork.voice;

local playerMeta = FindMetaTable("Player");

playerMeta.ClockworkSetCrouchedWalkSpeed = playerMeta.ClockworkSetCrouchedWalkSpeed or playerMeta.SetCrouchedWalkSpeed;
playerMeta.ClockworkLastHitGroup = playerMeta.ClockworkLastHitGroup or playerMeta.LastHitGroup;
playerMeta.ClockworkSetJumpPower = playerMeta.ClockworkSetJumpPower or playerMeta.SetJumpPower;
playerMeta.ClockworkSetWalkSpeed = playerMeta.ClockworkSetWalkSpeed or playerMeta.SetWalkSpeed;
playerMeta.ClockworkStripWeapons = playerMeta.ClockworkStripWeapons or playerMeta.StripWeapons;
playerMeta.ClockworkSetRunSpeed = playerMeta.ClockworkSetRunSpeed or playerMeta.SetRunSpeed;
playerMeta.ClockworkStripWeapon = playerMeta.ClockworkStripWeapon or playerMeta.StripWeapon;
playerMeta.ClockworkGodDisable = playerMeta.ClockworkGodDisable or playerMeta.GodDisable;
playerMeta.ClockworkGodEnable = playerMeta.ClockworkGodEnable or playerMeta.GodEnable;
playerMeta.ClockworkUniqueID = playerMeta.ClockworkUniqueID or playerMeta.UniqueID;
playerMeta.ClockworkSetArmor = playerMeta.ClockworkSetArmor or playerMeta.SetArmor;
playerMeta.ClockworkGive = playerMeta.ClockworkGive or playerMeta.Give;
playerMeta.ClockworkKick = playerMeta.ClockworkKick or playerMeta.Kick;
playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name;

-- A function to get a player's name.
function playerMeta:Name()
	return self:QueryCharacter("Name", self:SteamName());
end;

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self.fakingDeath) then
		return self:ClockworkAlive();
	else
		return false;
	end;
end;

-- A function to set whether a player is faking death.
function playerMeta:SetFakingDeath(fakingDeath, killSilent)
	self.fakingDeath = fakingDeath;
	
	if (!fakingDeath and killSilent) then
		self:KillSilent();
	end;
end;

-- A function to save a player's character.
function playerMeta:SaveCharacter()
	cwPly:SaveCharacter(self);
end;

-- A function to give a player an item weapon.
function playerMeta:GiveItemWeapon(itemTable)
	cwPly:GiveItemWeapon(self, itemTable);
end;

-- A function to notify a player that they don't have enough cash.
function playerMeta:NotifyMissingCash(amountMissing)
	self:Notify({"YouNeedAnother", Clockwork.kernel:FormatCash(amountMissing, nil, true)});
end;

-- A function to get whether a player has a trait.
function playerMeta:HasTrait(uniqueID)
	local traits = self:GetCharacterData("Traits");
	
	if (traits and table.HasValue(traits, uniqueID)) then
		return true;
	end;
end;

-- A function to give a weapon to a player.
function playerMeta:Give(class, itemTable, bForceReturn)
	local iTeamIndex = self:Team();
	
	if (!cwPlugin:Call("PlayerCanBeGivenWeapon", self, class, itemTable)) then
		return;
	end;
	
	if (self:IsRagdolled() and !bForceReturn) then
		local ragdollWeapons = self:GetRagdollWeapons();
		local spawnWeapon = cwPly:GetSpawnWeapon(self, class);
		local bCanHolster = (itemTable and cwPlugin:Call("PlayerCanHolsterWeapon", self, itemTable, true, true));
		
		if (!spawnWeapon) then iTeamIndex = nil; end;
		
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == class
			and v.weaponData["itemTable"] == itemTable) then
				v.canHolster = bCanHolster;
				v.teamIndex = iTeamIndex;
				return;
			end;
		end;
		
		ragdollWeapons[#ragdollWeapons + 1] = {
			weaponData = {
				class = class,
				itemTable = itemTable
			},
			canHolster = bCanHolster,
			teamIndex = iTeamIndex,
		};
	elseif (!self:HasWeapon(class)) then
		self.cwForceGive = true;
			self:ClockworkGive(class);
		self.cwForceGive = nil;
		
		local weapon = self:GetWeapon(class);
		
		if (IsValid(weapon) and itemTable) then
			cwDatastream:Start(self, "WeaponItemData", {
				definition = cwItem:GetDefinition(itemTable, true),
				weapon = weapon:EntIndex()
			});
			
			weapon:SetNetworkedString(
				"ItemID", tostring(itemTable("itemID"))
			);
			weapon.cwItemTable = itemTable;
			
			if (itemTable.OnWeaponGiven) then
				itemTable:OnWeaponGiven(self, weapon);
			end;
		end;
	end;
	
	cwPlugin:Call("PlayerGivenWeapon", self, class, itemTable);
end;

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	if (self.cwData and self.cwData[key] != nil) then
		return self.cwData[key];
	else
		return default;
	end;
end;

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.cwPlaybackRate or 1;
end;


-- A function to get a player's information table.
function playerMeta:GetInfoTable()
	return self.cwInfoTable;
end;

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	local oldArmor = self:Armor();
		self:ClockworkSetArmor(armor);
	cwPlugin:Call("PlayerArmorSet", self, armor, oldArmor);
end;

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	local oldHealth = self:Health();
		self:ClockworkSetHealth(health);
	cwPlugin:Call("PlayerHealthSet", self, health, oldHealth);
end;

-- A function to get whether a player is noclipping.
function playerMeta:IsNoClipping()
	return cwPly:IsNoClipping(self);
end;

-- A function to get whether a player is running.
function playerMeta:IsRunning(bNoWalkSpeed)
	if (self:Alive() and !self:IsRagdolled() and !self:InVehicle()
	and !self:Crouching() and self:KeyDown(IN_SPEED)) then
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

-- A function to strip a weapon from a player.
function playerMeta:StripWeapon(weaponClass)
	if (self:IsRagdolled()) then
		local ragdollWeapons = self:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				weapons[k] = nil;
			end;
		end;
	else
		self:ClockworkStripWeapon(weaponClass);
	end;
end;

-- A function to get the player's target run speed.
function playerMeta:GetTargetRunSpeed()
	return self.cwTargetRunSpeed or self:GetRunSpeed();
end;

-- A function to handle a player's attribute progress.
function playerMeta:HandleAttributeProgress(curTime)
	if (self.cwAttrProgressTime and curTime >= self.cwAttrProgressTime) then
		self.cwAttrProgressTime = curTime + 30;
		
		for k, v in pairs(self.cwAttrProgress) do
			local attributeTable = cwAttribute:FindByID(k);
			
			if (attributeTable) then
				cwDatastream:Start(self, "AttributeProgress", {
					index = attributeTable.index, amount = v
				});
			end;
		end;
		
		if (self.cwAttrProgress) then
			self.cwAttrProgress = {};
		end;
	end;
end;

-- A function to handle a player's attribute boosts.
function playerMeta:HandleAttributeBoosts(curTime)
	for k, v in pairs(self.cwAttrBoosts) do
		for k2, v2 in pairs(v) do
			if (v2.duration and v2.endTime) then
				if (curTime > v2.endTime) then
					self:BoostAttribute(k2, k, false);
				else
					local timeLeft = v2.endTime - curTime;
					
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

-- A function to strip a player's weapons.
function playerMeta:StripWeapons(ragdollForce)
	if (self:IsRagdolled() and !ragdollForce) then
		self:GetRagdollTable().weapons = {};
	else
		self:ClockworkStripWeapons();
	end;
end;

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self.godMode = true; self:ClockworkGodEnable();
end;

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self.godMode = nil; self:ClockworkGodDisable();
end;

-- A function to get whether a player has God mode enabled.
function playerMeta:IsInGodMode()
	return self.godMode;
end;

-- A function to update whether a player's weapon is raised.
function playerMeta:UpdateWeaponRaised()
	cwPly:UpdateWeaponRaised(self);
end;

-- A function to update whether a player's weapon has fired.
function playerMeta:UpdateWeaponFired()
	local activeWeapon = self:GetActiveWeapon();
	
	if (IsValid(activeWeapon)) then
		if (self.cwClipOneInfo.weapon == activeWeapon) then
			local clipOne = activeWeapon:Clip1();
			
			if (clipOne < self.cwClipOneInfo.ammo) then
				self.cwClipOneInfo.ammo = clipOne;
				cwPlugin:Call("PlayerFireWeapon", self, activeWeapon, CLIP_ONE, activeWeapon:GetPrimaryAmmoType());
			end;
		else
			self.cwClipOneInfo.weapon = activeWeapon;
			self.cwClipOneInfo.ammo = activeWeapon:Clip1();
		end;
		
		if (self.cwClipTwoInfo.weapon == activeWeapon) then
			local clipTwo = activeWeapon:Clip2();
			
			if (clipTwo < self.cwClipTwoInfo.ammo) then
				self.cwClipTwoInfo.ammo = clipTwo;
				cwPlugin:Call("PlayerFireWeapon", self, activeWeapon, CLIP_TWO, activeWeapon:GetSecondaryAmmoType());
			end;
		else
			self.cwClipTwoInfo.weapon = activeWeapon;
			self.cwClipTwoInfo.ammo = activeWeapon:Clip2();
		end;
	end;
end;

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():WaterLevel();
	else
		return self:ClockworkWaterLevel();
	end;
end;

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():IsOnFire();
	else
		return self:ClockworkIsOnFire();
	end;
end;

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():Extinguish();
	else
		return self:ClockworkExtinguish();
	end;
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return cwPly:GetWeaponClass(self) == "cw_hands";
end;

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return cwPly:GetWeaponClass(self) == "cw_keys";
end;

-- A function to get a player's wages.
function playerMeta:GetWages()
	return cwPly:GetWages(self);
end;

-- A function to get a player's community ID.
playerMeta.CommunityID = playerMeta.SteamID64;

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return cwPly:IsRagdolled(self, exception, entityless);
end;

-- A function to get whether a player is kicked.
function playerMeta:IsKicked()
	return self.isKicked;
end;

-- A function to get whether a player has spawned.
function playerMeta:HasSpawned()
	return self.cwHasSpawned;
end;

-- A function to kick a player.
function playerMeta:Kick(reason)
	if (!self:IsKicked()) then
		timer.Simple(FrameTime() * 0.5, function()
			local isKicked = self:IsKicked();
			
			if (IsValid(self) and isKicked) then
				if (self:HasSpawned()) then
					game.ConsoleCommand("kickid "..self:UserID().." "..isKicked.."\n");
				else
					self.isKicked = nil;
					self:Kick(isKicked);
				end;
			end;
		end);
	end;
	
	if (!reason) then
		self.isKicked = "You have been kicked.";
	else
		self.isKicked = reason;
	end;
end;

-- A function to ban a player.
function playerMeta:Ban(duration, reason)
	cwBans:Add(self:SteamID(), duration * 60, reason);
end;

-- A function to get a player's cash.
function playerMeta:GetCash()
	if (cwConfig:Get("cash_enabled"):Get()) then
		return self:QueryCharacter("Cash");
	else
		return 0;
	end;
end;

-- A function to get a character's flags.
function playerMeta:GetFlags() return self:QueryCharacter("Flags"); end;

-- A function to get a player's faction.
function playerMeta:GetFaction() return self:QueryCharacter("Faction"); end;

-- A function to get a player's gender.
function playerMeta:GetGender() return self:QueryCharacter("Gender"); end;

-- A function to get a player's traits.
function playerMeta:GetTraits()
	return self:GetCharacterData("Traits");
end;

-- A function to get a player's inventory.
function playerMeta:GetInventory() return self:QueryCharacter("Inventory"); end;

-- A function to get a player's attributes.
function playerMeta:GetAttributes() return self:QueryCharacter("Attributes"); end;

-- A function to get a player's saved ammo.
function playerMeta:GetSavedAmmo() return self:QueryCharacter("Ammo"); end;

-- A function to get a player's default model.
function playerMeta:GetDefaultModel() return self:QueryCharacter("Model"); end;

-- A function to get a player's character ID.
function playerMeta:GetCharacterID() return self:QueryCharacter("CharacterID"); end;

-- A function to get the time when a player's character was created.
function playerMeta:GetTimeCreated() return self:QueryCharacter("TimeCreated"); end;

-- A function to get a player's character key.
function playerMeta:GetCharacterKey() return self:QueryCharacter("Key"); end;

-- A function to get a player's recognised names.
function playerMeta:GetRecognisedNames()
	return self:QueryCharacter("RecognisedNames");
end;

-- A function to get a player's character table.
function playerMeta:GetCharacter() return cwPly:GetCharacter(self); end;

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return cwStorage:GetTable(self); end;
 
-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return cwPly:GetRagdollTable(self); end;

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return cwPly:GetRagdollState(self); end;

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return cwStorage:GetEntity(self); end;

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return cwPly:GetRagdollEntity(self); end;

-- A function to get a player's ragdoll weapons.
function playerMeta:GetRagdollWeapons()
	return self:GetRagdollTable().weapons or {};
end;

-- A function to get whether a player's ragdoll has a weapon.
function playerMeta:RagdollHasWeapon(weaponClass)
	local ragdollWeapons = self:GetRagdollWeapons();
	
	if (ragdollWeapons) then
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				return true;
			end;
		end;
	end;
end;

-- A function to set a player's maximum armor.
function playerMeta:SetMaxArmor(armor)
	self:SetSharedVar("MaxAP", armor);
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

-- A function to set a player's maximum health.
function playerMeta:SetMaxHealth(health)
	self:SetSharedVar("MaxHP", health);
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

-- A function to get whether a player is viewing the starter hints.
function playerMeta:IsViewingStarterHints()
	return self.cwViewStartHints;
end;

-- A function to get a player's last hit group.
function playerMeta:LastHitGroup()
	return self.cwLastHitGroup or self:ClockworkLastHitGroup();
end;


-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	cwDatastream:Start(self, "RunCommand", {...});
end;

-- A function to run a Clockwork command on a player.
function playerMeta:RunClockworkCmd(command, ...)
	cwPly:RunClockworkCommand(self, command, ...)
end;

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return cwPly:GetWagesName(self);
end;

-- A function to create a player'a animation stop delay.
function playerMeta:CreateAnimationStopDelay(delay)
	cwKernel:CreateTimer("ForcedAnim"..self:UniqueID(), delay, 1, function()
		if (IsValid(self)) then
			local forcedAnimation = self:GetForcedAnimation();
			
			if (forcedAnimation) then
				self:SetForcedAnimation(false);
			end;
		end;
	end);
end;

-- A function to set a player's forced animation.
function playerMeta:SetForcedAnimation(animation, delay, OnAnimate, OnFinish)
	local forcedAnimation = self:GetForcedAnimation();
	local sequence = nil;
	
	if (!animation) then
		self:SetSharedVar("ForceAnim", 0);
		self.cwForcedAnimation = nil;
		
		if (forcedAnimation and forcedAnimation.OnFinish) then
			forcedAnimation.OnFinish(self);
		end;
		
		return false;
	end;
	
	local bIsPermanent = (!delay or delay == 0);
	local bShouldPlay = (!forcedAnimation or forcedAnimation.delay != 0);
	
	if (bShouldPlay) then
		if (type(animation) == "string") then
			sequence = self:LookupSequence(animation);
		else
			sequence = self:SelectWeightedSequence(animation);
		end;
		
		self.cwForcedAnimation = {
			animation = animation,
			OnAnimate = OnAnimate,
			OnFinish = OnFinish,
			delay = delay
		};
		
		if (bIsPermanent) then
			cwKernel:DestroyTimer(
				"ForcedAnim"..self:UniqueID()
			);
		else
			self:CreateAnimationStopDelay(delay);
		end;
		
		self:SetSharedVar("ForceAnim", sequence);
		
		if (forcedAnimation and forcedAnimation.OnFinish) then
			forcedAnimation.OnFinish(self);
		end;
		
		return true;
	end;
end;

-- A function to set whether a player's config has initialized.
function playerMeta:SetConfigInitialized(initialized)
	self.cwConfigInitialized = initialized;
end;

-- A function to get whether a player's config has initialized.
function playerMeta:HasConfigInitialized()
	return self.cwConfigInitialized;
end;

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	return self.cwForcedAnimation;
end;

-- A function to get a player's item entity.
function playerMeta:GetItemEntity()
	if (IsValid(self.itemEntity)) then
		return self.itemEntity;
	end;
end;

-- A function to set a player's item entity.
function playerMeta:SetItemEntity(entity)
	self.itemEntity = entity;
end;

-- A function to create a player's temporary data.
function playerMeta:CreateTempData()
	local uniqueID = self:UniqueID();
	
	if (!Clockwork.TempPlayerData[uniqueID]) then
		Clockwork.TempPlayerData[uniqueID] = {};
	end;
	
	return Clockwork.TempPlayerData[uniqueID];
end;

-- A function to make a player fake pickup an entity.
function playerMeta:FakePickup(entity)
	local entityPosition = entity:GetPos();
	
	if (entity:IsPlayer()) then
		entityPosition = entity:GetShootPos();
	end;
	
	local shootPosition = self:GetShootPos();
	local feetDistance = self:GetPos():Distance(entityPosition);
	local armsDistance = shootPosition:Distance(entityPosition);
	
	if (feetDistance < armsDistance) then
		self:SetForcedAnimation("pickup", 1.2);
	else
		self:SetForcedAnimation("gunrack", 1.2);
	end;
end;

-- A function to set a player's temporary data.
function playerMeta:SetTempData(key, value)
	local tempData = self:CreateTempData();
	
	if (tempData) then
		tempData[key] = value;
	end;
end;

-- A function to set the player's Clockwork user group.
function playerMeta:SetClockworkUserGroup(userGroup)
	if (self:GetClockworkUserGroup() != userGroup) then
		self.cwUserGroup = userGroup;
		self:SetUserGroup(userGroup);
		self:SaveCharacter();

		cwPlugin:Call("OnPlayerUserGroupSet", self, userGroup);
	end;
end;

-- A function to get the player's Clockwork user group.
function playerMeta:GetClockworkUserGroup()
	return self.cwUserGroup;
end;

-- A function to get a player's temporary data.
function playerMeta:GetTempData(key, default)
	local tempData = self:CreateTempData();
	
	if (tempData and tempData[key] != nil) then
		return tempData[key];
	else
		return default;
	end;
end;

-- A function to get a player's items by ID.
function playerMeta:GetItemsByID(uniqueID)
	return cwInventory:GetItemsByID(
		self:GetInventory(), uniqueID
	);
end;

-- A function to find a player's items by name.
function playerMeta:FindItemsByName(uniqueID, name)
	return cwInventory:FindItemsByName(
		self:GetInventory(), uniqueID, name
	);
end;

-- A function to get the maximum weight a player can carry.
function playerMeta:GetMaxWeight()
	local itemsList = cwInventory:GetAsItemsList(self:GetInventory()); 
	local weight = self:GetSharedVar("InvWeight");
	
	for k, v in pairs(itemsList) do
		local addInvWeight = v("addInvSpace");
		if (addInvWeight) then
			weight = weight + addInvWeight;
		end;
	end;
	
	return weight;
end;

-- A function to get the maximum space a player can carry.
function playerMeta:GetMaxSpace()
	local itemsList = cwInventory:GetAsItemsList(self:GetInventory()); 
	local space = self:GetSharedVar("InvSpace");
	
	for k, v in pairs(itemsList) do
		local addInvSpace = v("addInvVolume");
		if (addInvSpace) then
			space = space + addInvSpace;
		end;
	end;
	
	return space;
end;

-- A function to get whether a player can hold a weight.
function playerMeta:CanHoldWeight(weight)
	local inventoryWeight = cwInventory:CalculateWeight(
		self:GetInventory()
	);
	
	if (inventoryWeight + weight > self:GetMaxWeight()) then
		return false;
	else
		return true;
	end;
end;

-- A function to get whether a player can hold a weight.
function playerMeta:CanHoldSpace(space)
	if (!cwInventory:UseSpaceSystem()) then
		return true;
	end;

	local inventorySpace = cwInventory:CalculateSpace(
		self:GetInventory()
	);
	
	if (inventorySpace + space > self:GetMaxSpace()) then
		return false;
	else
		return true;
	end;
end;

-- A function to get a player's inventory weight.
function playerMeta:GetInventoryWeight()
	return cwInventory:CalculateWeight(self:GetInventory());
end;

-- A function to get a player's inventory weight.
function playerMeta:GetInventorySpace()
	return cwInventory:CalculateSpace(self:GetInventory());
end;

-- A function to get whether a player has an item by ID.
function playerMeta:HasItemByID(uniqueID)
	return cwInventory:HasItemByID(
		self:GetInventory(), uniqueID
	);
end;

-- A function to count how many items a player has by ID.
function playerMeta:GetItemCountByID(uniqueID)
	return cwInventory:GetItemCountByID(
		self:GetInventory(), uniqueID
	);
end;

-- A function to get whether a player has a certain amount of items by ID.
function playerMeta:HasItemCountByID(uniqueID, amount)
	return cwInventory:HasItemCountByID(
		self:GetInventory(), uniqueID, amount
	);
end;

-- A function to find a player's item by ID.
function playerMeta:FindItemByID(uniqueID, itemID)
	return cwInventory:FindItemByID(
		self:GetInventory(), uniqueID, itemID
	);
end;

-- A function to get whether a player has an item as a weapon.
function playerMeta:HasItemAsWeapon(itemTable)
	for k, v in pairs(self:GetWeapons()) do
		local weaponItemTable = cwItem:GetByWeapon(v);
		if (itemTable:IsTheSameAs(weaponItemTable)) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to find a player's weapon item by ID.
function playerMeta:FindWeaponItemByID(uniqueID, itemID)
	for k, v in pairs(self:GetWeapons()) do
		local weaponItemTable = cwItem:GetByWeapon(v);
		if (weaponItemTable and weaponItemTable("uniqueID") == uniqueID
		and weaponItemTable("itemID") == itemID) then
			return weaponItemTable;
		end;
	end;
end;

-- A function to get whether a player has an item instance.
function playerMeta:HasItemInstance(itemTable)
	return cwInventory:HasItemInstance(
		self:GetInventory(), itemTable
	);
end;

-- A function to get a player's item instance.
function playerMeta:GetItemInstance(uniqueID, itemID)
	return cwInventory:FindItemByID(
		self:GetInventory(), uniqueID, itemID
	);
end;

-- A function to take a player's item by ID.
function playerMeta:TakeItemByID(uniqueID, itemID)
	local itemTable = self:GetItemInstance(uniqueID, itemID);
	
	if (itemTable) then
		return self:TakeItem(itemTable);
	else
		return false;
	end;
end;

-- A function to get a player's attribute boosts.
function playerMeta:GetAttributeBoosts()
	return self.cwAttrBoosts;
end;

-- A function to rebuild a player's inventory.
function playerMeta:RebuildInventory()
	cwInventory:Rebuild(self);
end;

-- A function to give an item to a player.
function playerMeta:GiveItem(itemTable, isForced)
	if (type(itemTable) == "string") then
		itemTable = cwItem:CreateInstance(itemTable);
	end;
	
	if (!itemTable or !itemTable:IsInstance()) then
		debug.Trace();
		
		return false, {"ErrorGiveNonInstance"};
	end;
	
	local inventory = self:GetInventory();
	
	if ((self:CanHoldWeight(itemTable("weight"))
	and self:CanHoldSpace(itemTable("space"))) or isForced) then
		if (itemTable.OnGiveToPlayer) then
			itemTable:OnGiveToPlayer(self);
		end;
		
		cwKernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerGainedItem", self:Name(), {itemTable("name")}, itemTable("itemID")});
		
		cwInventory:AddInstance(inventory, itemTable);
		
		cwDatastream:Start(self, "InvGive", cwItem:GetDefinition(itemTable, true));
		
		cwPlugin:Call("PlayerItemGiven", self, itemTable, isForced);
		
		return itemTable;
	else
		return false, {"YourInventoryFull"};
	end;
end;

-- A function to take an item from a player.
function playerMeta:TakeItem(itemTable)
	if (!itemTable or !itemTable:IsInstance()) then
		debug.Trace();
		return false;
	end;
	
	local inventory = self:GetInventory();
	
	if (itemTable.OnTakeFromPlayer) then
		itemTable:OnTakeFromPlayer(self);
	end;
	
	cwKernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerLostItem", self:Name(), {itemTable("name")}, itemTable("itemID")});
	
	cwPlugin:Call("PlayerItemTaken", self, itemTable);
	
	cwInventory:RemoveInstance(inventory, itemTable);
	
	cwDatastream:Start(self, "InvTake", {itemTable("index"), itemTable("itemID")});
	
	return true;
end;

-- An easy function to give a table of items to a player.
function playerMeta:GiveItems(itemTables)
	for _, itemTable in pairs(itemTables) do
		self:GiveItem(itemTable)
	end
end

-- An easy function to take a table of items from a player.
function playerMeta:TakeItems(itemTables)
	for _, itemTable in pairs(itemTables) do
		self:TakeItem(itemTable)
	end
end

-- A function to update a player's attribute.
function playerMeta:UpdateAttribute(attribute, amount)
	return cwAttributes:Update(self, attribute, amount);
end;

-- A function to progress a player's attribute.
function playerMeta:ProgressAttribute(attribute, amount, gradual)
	return cwAttributes:Progress(self, attribute, amount, gradual);
end;

-- A function to boost a player's attribute.
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
	return cwAttributes:Boost(self, identifier, attribute, amount, duration);
end;

-- A function to get whether a boost is active for a player.
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
	return cwAttributes:IsBoostActive(self, identifier, attribute, amount, duration);
end;

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self.cwCharacterList;
end;

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, setClockworkVar)
	if (!setClockworkVar) then
		self.cwRunSpeed = speed;
	end;
	self:ClockworkSetRunSpeed(speed);
end;

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, setClockworkVar)
	if (!setClockworkVar) then
		self.cWalkSpeed = speed;
	end;
	
	self:ClockworkSetWalkSpeed(speed);
end;

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, setClockworkVar)
	if (!setClockworkVar) then
		self.cwJumpPower = power;
	end;
	
	self:ClockworkSetJumpPower(power);
end;

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, setClockworkVar)
	if (!setClockworkVar) then
		self.cwCrouchedSpeed = speed;
	end;
	
	self:ClockworkSetCrouchedWalkSpeed(speed);
end;

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self.cwInitialized;
end;

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if (self:GetCharacter()) then
		return cwPly:Query(self, key, default);
	else
		return default;
	end;
end;

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key)
	return cwPly:GetSharedVar(self, key);
end;

-- A function to set a shared variable for a player.
function playerMeta:SetSharedVar(key, value, sharedTable)
	cwPly:SetSharedVar(self, key, value, sharedTable);
end;

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	if (self:GetCharacter()) then
		local data = self:QueryCharacter("Data");
		
		if (data[key] != nil) then
			return data[key];
		end;
	end;
	
	return default;
end;

-- A function to get a player's time joined.
function playerMeta:TimeJoined()
	return self.cwTimeJoined or os.time();
end;

-- A function to get when a player last played.
function playerMeta:LastPlayed()
	return self.cwLastPlayed or os.time();
end;

-- A function to get a player's clothes data.
function playerMeta:GetClothesData()
	local clothesData = self:GetCharacterData("Clothes");

	if (type(clothesData) != "table") then
		clothesData = {};
	end;
	
	return clothesData;
end;

-- A function to get a player's accessory data.
function playerMeta:GetAccessoryData()
	local accessoryData = self:GetCharacterData("Accessories");

	if (type(accessoryData) != "table") then
		accessoryData = {};
	end;
	
	return accessoryData;
end;

-- A function to remove a player's clothes.
function playerMeta:RemoveClothes(shouldRemoveItem)
	self:SetClothesData(nil);
	
	if (shouldRemoveItem) then
		local clothesItem = self:GetClothesItem();
		
		if (clothesItem) then
			self:TakeItem(clothesItem);
			
			return clothesItem;
		end;
	end;
end;

-- A function to get the player's clothes item.
function playerMeta:GetClothesItem()
	local clothesData = self:GetClothesData();
	
	if (type(clothesData) == "table") then
		if (clothesData.itemID != nil and clothesData.uniqueID != nil) then
			return self:FindItemByID(clothesData.uniqueID, clothesData.itemID);
		end;
	end;
end;

-- A function to get whether a player is wearing clothes.
function playerMeta:IsWearingClothes()
	return (self:GetClothesItem() != nil);
end;

-- A function to get whether a player is wearing an item.
function playerMeta:IsWearingItem(itemTable)
	local clothesItem = self:GetClothesItem();
	return (clothesItem and clothesItem:IsTheSameAs(itemTable));
end;

-- A function to network the player's clothes data.
function playerMeta:NetworkClothesData()
	local clothesData = self:GetClothesData();

	if (clothesData.uniqueID and clothesData.itemID) then
		self:SetSharedVar("Clothes", clothesData.uniqueID.." "..clothesData.itemID);
	else
		self:SetSharedVar("Clothes", "");
	end;
end;

-- A function to set a player's clothes data.
function playerMeta:SetClothesData(itemTable)
	local clothesItem = self:GetClothesItem();
	
	if (itemTable) then
		local model = cwClass:GetAppropriateModel(self:Team(), self, true);
		
		if (!model) then
			if (clothesItem and itemTable != clothesItem) then
				clothesItem:OnChangeClothes(self, false);
			end;
			
			itemTable:OnChangeClothes(self, true);
			
			local clothesData = self:GetClothesData();
				clothesData.itemID = itemTable("itemID");
				clothesData.uniqueID = itemTable("uniqueID");
			self:NetworkClothesData();
		end;
	else
		local clothesData = self:GetClothesData();
			clothesData.itemID = nil;
			clothesData.uniqueID = nil;
		self:NetworkClothesData();
		
		if (clothesItem) then
			clothesItem:OnChangeClothes(self, false);
		end;
	end;
end;

-- A function to get the entity a player is holding.
function playerMeta:GetHoldingEntity()
	return cwPlugin:Call("PlayerGetHoldingEntity", self) or self.cwIsHoldingEnt;
end;

-- A function to get whether a player's character menu is reset.
function playerMeta:IsCharacterMenuReset()
	return self.cwCharMenuReset;
end;

-- A function to get the player's active voice channel.
function playerMeta:GetActiveChannel()
	return cwVoice:GetActiveChannel(self);
end;

-- A function to check if a player can afford an amount.
function playerMeta:CanAfford(amount)
	return cwPly:CanAfford(self, amount);
end;

-- A function to get a player's rank within their faction.
function playerMeta:GetFactionRank(character)
	return cwPly:GetFactionRank(self, character);
end;

-- A function to set a player's rank within their faction.
function playerMeta:SetFactionRank(rank)
	return cwPly:SetFactionRank(self, rank);
end;

-- A function to get a player's global flags.
function playerMeta:GetPlayerFlags()
	return cwPly:GetPlayerFlags(self);
end;

playerMeta.GetName = playerMeta.Name;
playerMeta.Nick = playerMeta.Name;
