--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Json = Json;
local tostring = tostring;
local tonumber = tonumber;
local IsValid = IsValid;
local CurTime = CurTime;
local Vector = Vector;
local Angle = Angle;
local Color = Color;
local pairs = pairs;
local type = type;
local player = player;
local string = string;
local table = table;
local ents = ents;
local math = math;
local util = util;

if (!Clockwork.datastream) then include("sh_datastream.lua"); end;
if (!Clockwork.plugin) then include("sh_plugin.lua"); end;
if (!Clockwork.config) then include("sh_config.lua"); end;
if (!Clockwork.attribute) then include("sh_attribute.lua"); end;
if (!Clockwork.faction) then include("sh_faction.lua"); end;
if (!Clockwork.class) then include("sh_class.lua"); end;
if (!Clockwork.trait) then include("sh_trait.lua"); end;
if (!Clockwork.command) then include("sh_command.lua"); end;
if (!Clockwork.attribute) then include("sh_attribute.lua"); end;
if (!Clockwork.option) then include("sh_option.lua"); end;
if (!Clockwork.entity) then include("sh_entity.lua"); end;
if (!Clockwork.item) then include("sh_item.lua"); end;
if (!Clockwork.json) then include("sh_json.lua"); end;
if (!Clockwork.generator) then include("sh_generator.lua"); end;
if (!Clockwork.inventory) then include("sh_inventory.lua"); end;

local cwCfg = Clockwork.config;
local cwAttribute = Clockwork.attribute;
local cwTrait = Clockwork.trait;
local cwFaction = Clockwork.faction;
local cwClass = Clockwork.class;
local cwCommand = Clockwork.command;
local cwKernel = Clockwork.kernel;
local cwDatastream = Clockwork.datastream;
local cwOption = Clockwork.option;
local cwPlugin = Clockwork.plugin;
local cwEntity = Clockwork.entity;
local cwItem = Clockwork.item;
local cwJson = Clockwork.json;
local cwGenerator = Clockwork.generator;
local cwInventory = Clockwork.inventory;

Clockwork.player = cwKernel:NewLibrary("Player");

if (CLIENT) then
--[[
	@codebase Shared
	@details A function to get whether the local player can hold a weight.
	@param {Unknown} Missing description for weight.
	@returns {Unknown}
--]]
function Clockwork.player:CanHoldWeight(weight)
	local inventoryWeight = Clockwork.inventory:CalculateWeight(
		Clockwork.inventory:GetClient()
	);
	
	if (inventoryWeight + weight > Clockwork.player:GetMaxWeight()) then
		return false;
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player can fit a space.
	@param {Unknown} Missing description for space.
	@returns {Unknown}
--]]
function Clockwork.player:CanHoldSpace(space)
	local inventorySpace = Clockwork.inventory:CalculateSpace(
		Clockwork.inventory:GetClient()
	);
	
	if (inventorySpace + space > Clockwork.player:GetMaxSpace()) then
		return false;
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the maximum amount of weight the local player can carry.
	@returns {Unknown}
--]]
function Clockwork.player:GetMaxWeight()
	local itemsList = Clockwork.inventory:GetAsItemsList(
		Clockwork.inventory:GetClient()
	);
	
	local weight = Clockwork.Client:GetSharedVar("InvWeight") or Clockwork.config:Get("default_inv_weight"):Get();
	
	for k, v in pairs(itemsList) do
		local addInvWeight = v("addInvSpace");
		
		if (addInvWeight) then
			weight = weight + addInvWeight;
		end;
	end;
	
	return weight;
end;

--[[
	@codebase Shared
	@details A function to get the maximum amount of space the local player can carry.
	@returns {Unknown}
--]]
function Clockwork.player:GetMaxSpace()
	local itemsList = Clockwork.inventory:GetAsItemsList(
		Clockwork.inventory:GetClient()
	);
	local space = Clockwork.Client:GetSharedVar("InvSpace") or Clockwork.config:Get("default_inv_space"):Get();
	
	for k, v in pairs(itemsList) do
		local addInvSpace = v("addInvVolume");
		
		if (addInvSpace) then
			space = space + addInvSpace;
		end;
	end;
	
	return space;
end;

--[[
	@codebase Shared
	@details A function to find a player by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.player:FindByID(identifier)
	for k, v in pairs(player.GetAll()) do
		if (v:HasInitialized() and (v:SteamID() == identifier
		or string.find(string.lower(v:Name()), string.lower(identifier), 1, true))) then
			return v;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the local player's clothes data.
	@returns {Unknown}
--]]
function Clockwork.player:GetClothesData()
	return Clockwork.ClothesData;
end;

--[[
	@codebase Shared
	@details A function to get the local player's accessory data.
	@returns {Unknown}
--]]
function Clockwork.player:GetAccessoryData()
	return Clockwork.AccessoryData;
end;

--[[
	@codebase Shared
	@details A function to get the local player's clothes item.
	@returns {Unknown}
--]]
function Clockwork.player:GetClothesItem()
	local clothesData = self:GetClothesData();

	if (clothesData.itemID != nil and clothesData.uniqueID != nil) then
		return Clockwork.inventory:FindItemByID(
			Clockwork.inventory:GetClient(),
			clothesData.uniqueID, clothesData.itemID
		);
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player is wearing clothes.
	@returns {Unknown}
--]]
function Clockwork.player:IsWearingClothes()
	return (self:GetClothesItem() != nil);
end;

--[[
	@codebase Shared
	@details A function to get whether the local player has an accessory.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.player:HasAccessory(uniqueID)
	local accessoryData = self:GetAccessoryData();
	
	for k, v in pairs(accessoryData) do
		if (string.lower(v) == string.lower(uniqueID)) then
			return true;
		end;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player is wearing an accessory.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.player:IsWearingAccessory(itemTable)
	local accessoryData = self:GetAccessoryData();
	local itemID = itemTable("itemID");
	
	if (accessoryData[itemID]) then
		return true;
	else
		return false;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player is wearing an item.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.player:IsWearingItem(itemTable)
	local clothesItem = self:GetClothesItem();
	return (clothesItem and clothesItem:IsTheSameAs(itemTable));
end;

--[[
	@codebase Shared
	@details A function to get whether a player is noclipping.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:IsNoClipping(player)
	if (player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle()) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player is an admin.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:IsAdmin(player)
	if (self:HasFlags(player, "o")) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player's data has streamed.
	@returns {Unknown}
--]]
function Clockwork.player:HasDataStreamed()
	return Clockwork.DataHasStreamed;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can hear another player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for allowance.
	@returns {Unknown}
--]]
function Clockwork.player:CanHearPlayer(player, target, allowance)
	if (Clockwork.config:Get("messages_must_see_player"):Get()) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;
	
--[[
	@codebase Shared
	@details A function to get whether the target recognises the local player.
	@returns {Unknown}
--]]
function Clockwork.player:DoesTargetRecognise()
	if (Clockwork.config:Get("recognise_system"):Get()) then
		return Clockwork.Client:GetSharedVar("TargetKnows");
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's real trace.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for useFilterTrace.
	@returns {Unknown}
--]]
function Clockwork.player:GetRealTrace(player, useFilterTrace)
	if (!IsValid(player)) then
		return;
	end;

	local angles = player:GetAimVector() * 4096;
	local eyePos = EyePos();
	
	if (player != Clockwork.Client) then
		eyePos = player:EyePos();
	end;
	
	local trace = util.TraceLine({
		endpos = eyePos + angles,
		start = eyePos,
		filter = player
	});
	
	local newTrace = util.TraceLine({
		endpos = eyePos + angles,
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	});
	
	if ((IsValid(newTrace.Entity) and !newTrace.HitWorld and (!IsValid(trace.Entity)
	or string.find(trace.Entity:GetClass(), "vehicle"))) or useFilterTrace) then
		trace = newTrace;
	end;
	
	return trace;
end;

--[[
	@codebase Shared
	@details A function to get the local player's action.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for percentage.
	@returns {Unknown}
--]]
function Clockwork.player:GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("StartActTime");
	local actionDuration = player:GetSharedVar("ActDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("ActName");
	
	if (curTime < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime));
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the local player's maximum characters.
	@returns {Unknown}
--]]
function Clockwork.player:GetMaximumCharacters()
	local whitelisted = Clockwork.character:GetWhitelisted();
	local maximum = Clockwork.config:Get("additional_characters"):Get(2);
	
	for k, v in pairs(Clockwork.faction.stored) do
		if (!v.whitelist or table.HasValue(whitelisted, v.name)) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

--[[
	@codebase Shared
	@details A function to get whether a player's weapon is raised.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetWeaponRaised(player)
	return player:GetSharedVar("IsWepRaised");
end;

--[[
	@codebase Shared
	@details A function to get a player's unrecognised name.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = Clockwork.config:Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc) then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can see an NPC.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for allowance.
	@param {Unknown} Missing description for ignoreEnts.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeeNPC(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can see a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for allowance.
	@param {Unknown} Missing description for ignoreEnts.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeePlayer(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	elseif (target:GetEyeTraceNoCursor().Entity == player) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can see an entity.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for allowance.
	@param {Unknown} Missing description for ignoreEnts.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:LocalToWorld(target:OBBCenter());
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can see a position.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for allowance.
	@param {Unknown} Missing description for ignoreEnts.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = player;
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add(trace.filter, ents.GetAll());
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if (trace.Fraction >= (allowance or 0.75)) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's wages name.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetWagesName(player)
	return Clockwork.class:Query(player:Team(), "wagesName", Clockwork.config:Get("wages_name"):Get());
end;

--[[
	@codebase Shared
	@details A function to check whether a player is ragdolled
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for exception.
	@param {Unknown} Missing description for entityless.
	@returns {Unknown}
--]]
function Clockwork.player:IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		if (player:GetSharedVar("IsRagdoll") == 0) then
			return false;
		elseif (player:GetSharedVar("IsRagdoll") == exception) then
			return false;
		else
			return (player:GetSharedVar("IsRagdoll") != RAGDOLL_NONE);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player recognises another player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for status.
	@param {Unknown} Missing description for isAccurate.
	@returns {Unknown}
--]]
function Clockwork.player:DoesRecognise(player, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, RECOGNISE_PARTIAL);
	elseif (Clockwork.config:Get("recognise_system"):Get()) then
		local key = self:GetCharacterKey(player);
		local realValue = false;
		
		if (self:GetCharacterKey(Clockwork.Client) == key) then
			return true;
		elseif (Clockwork.RecognisedNames[key]) then
			if (isAccurate) then
				realValue = (Clockwork.RecognisedNames[key] == status);
			else
				realValue = (Clockwork.RecognisedNames[key] >= status);
			end;
		end;
		
		return Clockwork.plugin:Call("PlayerDoesRecognisePlayer", player, status, isAccurate, realValue);
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's character key.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterKey(player)
	if (IsValid(player)) then
		return player:GetSharedVar("Key");
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's ragdoll state.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetRagdollState(player)
	if (player:GetSharedVar("IsRagdoll") == 0) then
		return false;
	else
		return player:GetSharedVar("IsRagdoll");
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's physical description.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetPhysDesc(player)
	if (!player) then
		player = Clockwork.Client;
	end;
	
	local physDesc = player:GetSharedVar("PhysDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = Clockwork.class:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = Clockwork.config:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = Clockwork.kernel:ModifyPhysDesc(physDesc);
	end;
	
	local override = Clockwork.plugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

--[[
	@codebase Shared
	@details A function to get the local player's wages.
	@returns {Unknown}
--]]
function Clockwork.player:GetWages()
	return Clockwork.Client:GetSharedVar("Wages");
end;

--[[
	@codebase Shared
	@details A function to get the local player's cash.
	@returns {Unknown}
--]]
function Clockwork.player:GetCash()
	return Clockwork.Client:GetSharedVar("Cash");
end;

--[[
	@codebase Shared
	@details A function to get a player's ragdoll entity.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("Ragdoll");
	
	if (IsValid(ragdollEntity)) then
		return ragdollEntity;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's default skin.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDefaultSkin(player)
	local model, skin = Clockwork.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

--[[
	@codebase Shared
	@details A function to get a player's default model.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDefaultModel(player)
	local model, skin = Clockwork.class:GetAppropriateModel(player:Team(), player);
	return model;
end;

--[[
	@codebase Shared
	@details A function to check if a player has any flags.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@param {Unknown} Missing description for byDefault.
	@returns {Unknown}
--]]
function Clockwork.player:HasAnyFlags(player, flags, byDefault)
	local playerFlags = player:GetSharedVar("Flags")
	
	if (playerFlags != "") then
		if (Clockwork.class:HasAnyFlags(player:Team(), flags) and !byDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i);
			local wasSuccess = true;
			
			if (!byDefault) then
				local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						return true;
					end;
				else
					wasSuccess = nil;
				end;
			end;
			
			if (wasSuccess) then
				if (flag == "s") then
					if (player:IsSuperAdmin()) then
						return true;
					end;
				elseif (flag == "a") then
					if (player:IsAdmin()) then
						return true;
					end;
				elseif (flag == "o") then
					if (player:IsSuperAdmin() or player:IsAdmin()) then
						return true;
					elseif (player:IsUserGroup("operator")) then
						return true;
					end;
				elseif (string.find(playerFlags, flag)) then
					return true;
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player has access.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@param {Unknown} Missing description for byDefault.
	@returns {Unknown}
--]]
function Clockwork.player:HasFlags(player, flags, byDefault)
	local playerFlags = player:GetSharedVar("Flags")
	
	if (playerFlags != "") then
		if (Clockwork.class:HasFlags(player:Team(), flags) and !byDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i);
			local wasSuccess;
			
			if (!byDefault) then
				local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						wasSuccess = true;
					end;
				else
					return;
				end;
			end;
			
			if (!wasSuccess) then
				if (flag == "s") then
					if (!player:IsSuperAdmin()) then
						return;
					end;
				elseif (flag == "a") then
					if (!player:IsAdmin()) then
						return;
					end;
				elseif (flag == "o") then
					if (!player:IsSuperAdmin() and !player:IsAdmin()) then
						if (!player:IsUserGroup("operator")) then
							return;
						end;
					end;
				elseif (!string.find(playerFlags, flag)) then
					return false;
				end;
			end;
		end;
		
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to set a shared variable for a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for value.
	@returns {Unknown}
--]]
function Clockwork.player:SetSharedVar(player, key, value)
	if (IsValid(player)) then
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		
		if (!sharedVars) then
			return;
		elseif (not sharedVars[key]) then
			return;
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData.bPlayerOnly) then
			if (value == nil) then
				sharedVarData.value = Clockwork.kernel:GetDefaultNetworkedValue(sharedVarData.class);
			else
				sharedVarData.value = value;
			end;
		else
			local class = Clockwork.kernel:ConvertNetworkedClass(sharedVarData.class);
			
			if (class) then
				player["SetNetworked"..class](player, key, value);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's shared variable.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for sharedTable.
	@returns {Unknown}
--]]
function Clockwork.player:GetSharedVar(player, key, sharedTable)
	if (IsValid(player)) then
		if (!sharedTable) then
			local sharedVars = Clockwork.kernel:GetSharedVars():Player();
			
			if (!sharedVars) then
				return;
			elseif (not sharedVars[key]) then
				return;
			end;
			
			local sharedVarData = sharedVars[key];
			
			if (sharedVarData.bPlayerOnly) then
				if (!sharedVarData.value) then
					return Clockwork.kernel:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return sharedVarData.value;
				end;
			else
				local class = Clockwork.kernel:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					return player["GetNetworked"..class](player, key);
				end;
			end;
		else
			sharedTable = Clockwork.SharedTables[sharedTable];
		
			if (sharedTable) then
				return sharedTable[key];
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether the local player is drunk.
	@returns {Unknown}
--]]
function Clockwork.player:GetDrunk()
	local isDrunk = Clockwork.Client:GetSharedVar("IsDrunk");
	
	if (isDrunk and isDrunk > 0) then
		return isDrunk;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's chat icon.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetChatIcon(player)
	local icon;
	
	for k, v in pairs(Clockwork.icon:GetAll()) do
		if (v.callback(player)) then
			if (!icon) then
				icon = v.path;
			end;
			
			if (v.isPlayer) then
				icon = v.path;
				break;
			end;
		end;
	end;
	
	if (!icon) then
		local faction = player:GetFaction();
		
		icon = "icon16/user.png";
		
		if (faction and Clockwork.faction.stored[faction]) then
			if (Clockwork.faction.stored[faction].whitelist) then
				icon = "icon16/add.png";
			end;
		end;
	end;
	
	return icon;
end;

else -- if (SERVER) then

if (!Clockwork.database) then include("server/sv_database.lua"); end;
if (!Clockwork.chatBox) then include("server/sv_chatbox.lua"); end;
if (!Clockwork.hint) then include("sv_hint.lua"); end;

local cwHint = Clockwork.hint;
local cwChatbox = Clockwork.chatBox;
local cwDatabase = Clockwork.database;

Clockwork.player.property = Clockwork.player.property or {};
Clockwork.player.stored = Clockwork.player.stored or {};

--[[
	@codebase Shared
	@details A function to run an inventory action for a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for itemTable.
	@param {Unknown} Missing description for action.
	@returns {Unknown}
--]]
function Clockwork.player:InventoryAction(player, itemTable, action)
	return self:RunClockworkCommand(player, "InvAction", action, itemTable("uniqueID"), tostring(itemTable("itemID")));
end;

--[[
	@codebase Shared
	@details A function to get a player's gear.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for gearClass.
	@returns {Unknown}
--]]
function Clockwork.player:GetGear(player, gearClass)
	if (player.cwGearTab and IsValid(player.cwGearTab[gearClass])) then
		return player.cwGearTab[gearClass];
	end;
end;

--[[
	@codebase Shared
	@details A function to create a character from data.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork.player:CreateCharacterFromData(player, data)
	if (player.cwIsCreatingChar) then
		return;
	end;

	local minimumPhysDesc = cwCfg:Get("minimum_physdesc"):Get();
	local attributesTable = cwAttribute:GetAll();
	local factionTable = cwFaction:FindByID(data.faction);
	local traitsTable = cwTrait:GetAll();
	local hasAttributes = nil;
	local hasTraits = nil;
	local info = {};
	
	if (table.Count(attributesTable) > 0) then
		for k, v in pairs(attributesTable) do
			if (v.isOnCharScreen) then
				hasAttributes = true;
				break;
			end;
		end;
	end;
	
	if (table.Count(traitsTable) > 0) then
		for k, v in pairs(traitsTable) do
			hasTraits = true;
			break;
		end;
	end;
	
	if (!factionTable) then
		return self:SetCreateFault(player, {"FaultDidNotChooseFaction"});
	end;
	
	info.attributes = {};
	info.faction = factionTable.name;
	info.gender = data.gender;
	info.model = data.model;
	info.data = {};
	
	if (data.plugin) then
		for k, v in pairs(data.plugin) do
			info.data[k] = v;
		end;
	end;
	
	local classes = false;
	
	for k, v in pairs(cwClass:GetAll()) do
		if (v.isOnCharScreen and (v.factions
		and table.HasValue(v.factions, factionTable.name))) then
			classes = true;
		end;
	end;
	
	if (classes) then
		local classTable = cwClass:FindByID(data.class);
		
		if (!classTable) then
			return self:SetCreateFault(player, {"FaultNeedClass"});
		else
			info.data["Class"] = classTable.name;
		end;
	end;
	
	if (hasTraits and type(data.traits) == "table") then
		local maximumPoints = cwCfg:Get("max_trait_points"):Get();
		local pointsSpent = 0;
		
		info.data["Traits"] = {};
	
		for k, v in pairs(data.traits) do
			local traitTable = cwTrait:FindByID(v);
			
			if (traitTable) then
				table.insert(info.data["Traits"], traitTable.uniqueID);
				pointsSpent = pointsSpent + traitTable.points;
			end;
		end;
		
		if (pointsSpent > maximumPoints) then
			return self:SetCreateFault(player, {"FaultMorePointsThanCanSpend", cwOption:Translate("name_trait", true)});
		end;
	elseif (hasTraits) then
		return self:SetCreateFault(player, {"FaultDidNotChooseTraits", cwOption:Translate("name_traits", true)});
	end;
	
	if (hasAttributes and type(data.attributes) == "table") then
		local maximumPoints = cwCfg:Get("default_attribute_points"):Get();
		local pointsSpent = 0;
		
		if (factionTable.attributePointsScale) then
			maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
		end;
		
		if (factionTable.maximumAttributePoints) then
			maximumPoints = factionTable.maximumAttributePoints;
		end;
		
		for k, v in pairs(data.attributes) do
			local attributeTable = cwAttribute:FindByID(k);
			
			if (attributeTable and attributeTable.isOnCharScreen) then
				local uniqueID = attributeTable.uniqueID;
				local amount = math.Clamp(v, 0, attributeTable.maximum);
				
				info.attributes[uniqueID] = {
					amount = amount,
					progress = 0
				};
				
				pointsSpent = pointsSpent + amount;
			end;
		end;
		
		if (pointsSpent > maximumPoints) then
			return self:SetCreateFault(player, {"FaultMorePointsThanCanSpend", cwOption:GetKey("name_attribute", true)});
		end;
	elseif (hasAttributes) then
		return self:SetCreateFault(player, {"FaultDidNotChooseAttributes", cwOption:GetKey("name_attributes", true)});
	end;
	
	if (!factionTable.GetName) then
		if (!factionTable.useFullName) then
			if (data.forename and data.surname) then
				data.forename = string.gsub(data.forename, "^.", string.upper);
				data.surname = string.gsub(data.surname, "^.", string.upper);
				
				if (string.find(data.forename, "[%p%s%d]") or string.find(data.surname, "[%p%s%d]")) then
					return self:SetCreateFault(player, {"FaultNameNoSpecialChars"});
				end;
				
				if (!string.find(data.forename, "[aeiou]") or !string.find(data.surname, "[aeiou]")) then
					return self:SetCreateFault(player, {"FaultNameHaveVowel"});
				end;
				
				if (string.utf8len(data.forename) < 2 or string.utf8len(data.surname) < 2) then
					return self:SetCreateFault(player, {"FaultNameMinLength"});
				end;
				
				if (string.utf8len(data.forename) > 16 or string.utf8len(data.surname) > 16) then
					return self:SetCreateFault(player, {"FaultNameTooLong"});
				end;
			else
				return self:SetCreateFault(player, {"FaultNameInvalid"});
			end;
		elseif (!data.fullName or data.fullName == "") then
			return self:SetCreateFault(player, {"FaultNameInvalid"});
		end;
	end;
	
	if (cwCommand:FindByID("CharPhysDesc") != nil) then
		if (type(data.physDesc) != "string") then
			return self:SetCreateFault(player, {"FaultPhysDescNeeded"});
		elseif (string.utf8len(data.physDesc) < minimumPhysDesc) then
			return self:SetCreateFault(player, {"PhysDescMinimumLength", minimumPhysDesc});
		end;
		
		info.data["PhysDesc"] = cwKernel:ModifyPhysDesc(data.physDesc);
	end;
	
	if (!factionTable.GetModel and !info.model) then
		return self:SetCreateFault(player, {"FaultNeedModel"});
	end;
	
	if (!cwFaction:IsGenderValid(info.faction, info.gender)) then
		return self:SetCreateFault(player, {"FaultNeedGender"});
	end;
	
	if (factionTable.whitelist and !self:IsWhitelisted(player, info.faction)) then
		return self:SetCreateFault(player, {"FaultNotOnWhitelist", info.faction});
	elseif (cwFaction:IsModelValid(factionTable.name, info.gender, info.model)
	or (factionTable.GetModel and !info.model)) then
		local charactersTable = cwCfg:Get("mysql_characters_table"):Get();
		local schemaFolder = cwKernel:GetSchemaFolder();
		local characterID = nil;
		local characters = player:GetCharacters();
		
		if (cwFaction:HasReachedMaximum(player, factionTable.name)) then
			return self:SetCreateFault(player, {"FaultTooManyInFaction"});
		end;
		
		for i = 1, self:GetMaximumCharacters(player) do
			if (!characters[i]) then
				characterID = i;
				break;
			end;
		end;
		
		if (characterID) then
			if (factionTable.GetName) then
				info.name = factionTable:GetName(player, info, data);
			elseif (!factionTable.useFullName) then
				info.name = data.forename.." "..data.surname;
			else
				info.name = data.fullName;
			end;
			
			if (factionTable.GetModel) then
				info.model = factionTable:GetModel(player, info, data);
			else
				info.model = data.model;
			end;
			
			if (factionTable.OnCreation) then
				local fault = factionTable:OnCreation(player, info);
				
				if (fault == false or type(fault) == "string") then
					return self:SetCreateFault(player, fault or {"FaultGenericError"});
				end;
			end;
			
			for k, v in pairs(characters) do
				if (v.name == info.name) then
					return self:SetCreateFault(player, {"YouAlreadyHaveCharName", info.name});
				end;
			end;
			
			local fault = cwPlugin:Call("PlayerAdjustCharacterCreationInfo", player, info, data);
			
			if (fault == false or type(fault) == "string") then
				return self:SetCreateFault(player, fault or {"FaultGenericError"});
			end;
			
			local queryObj = cwDatabase:Select(charactersTable);
				queryObj:AddWhere("_Schema = ?", schemaFolder);
				queryObj:AddWhere("_Name = ?", info.name);
				queryObj:SetCallback(function(result)
					if (!IsValid(player)) then
						return;
					end;
					
					if (cwDatabase:IsResult(result)) then
						self:SetCreateFault(player, {"FaultCharNameExists", info.name});
						player.cwIsCreatingChar = nil;
					else
						self:LoadCharacter(player, characterID,
							{
								attributes = info.attributes,
								faction = info.faction,
								gender = info.gender,
								model = info.model,
								name = info.name,
								data = info.data
							},
							function()
								cwKernel:PrintLog(LOGTYPE_MINOR, {"LogPlayerCreateChar", player:SteamName(), info.faction, info.name});
								
								cwDatastream:Start(player, "CharacterFinish", {wasSuccess = true});
								
								player.cwIsCreatingChar = nil;
								
								local characters = player:GetCharacters();
								
								if (table.Count(characters) == 1) then
									self:UseCharacter(player, characterID);
								end;
							end
						);
					end;
				end);
			queryObj:Pull();
		else
			return self:SetCreateFault(player, {"FaultTooManyCharacters"});
		end;
	else
		return self:SetCreateFault(player, {"FaultNeedModel"});
	end;
end;

--[[
	@codebase Shared
	@details A function to open the character menu.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for shouldReset.
	@returns {Unknown}
--]]
function Clockwork.player:SetCharacterMenuOpen(player, shouldReset)
	if (player:HasInitialized()) then
		cwDatastream:Start(player, "CharacterOpen", (shouldReset == true));
		
		if (shouldReset) then
			player.cwCharMenuReset = true;
			player:KillSilent();
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to start a sound for a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for sound.
	@param {Unknown} Missing description for fVolume.
	@returns {Unknown}
--]]
function Clockwork.player:StartSound(player, uniqueID, sound, fVolume)
	if (!player.cwSoundsPlaying) then
		player.cwSoundsPlaying = {};
	end;
	
	if (!player.cwSoundsPlaying[uniqueID]
	or player.cwSoundsPlaying[uniqueID] != sound) then
		player.cwSoundsPlaying[uniqueID] = sound;
		
		cwDatastream:Start(player, "StartSound", {
			uniqueID = uniqueID, sound = sound, volume = (fVolume or 0.75)
		});
	end;
end;

--[[
	@codebase Shared
	@details A function to stop a sound for a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for iFadeOut.
	@returns {Unknown}
--]]
function Clockwork.player:StopSound(player, uniqueID, iFadeOut)
	if (!player.cwSoundsPlaying) then
		player.cwSoundsPlaying = {};
	end;
	
	if (player.cwSoundsPlaying[uniqueID]) then
		player.cwSoundsPlaying[uniqueID] = nil;
		
		cwDatastream:Start(player, "StopSound", {
			uniqueID = uniqueID, fadeOut = (iFadeOut or 0)
		});
	end;
end;

--[[
	@codebase Shared
	@details A function to remove a player's gear.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for gearClass.
	@returns {Unknown}
--]]
function Clockwork.player:RemoveGear(player, gearClass)
	if (player.cwGearTab and IsValid(player.cwGearTab[gearClass])) then
		player.cwGearTab[gearClass]:Remove();
		player.cwGearTab[gearClass] = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to strip all of a player's gear.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:StripGear(player)
	if (!player.cwGearTab) then return; end;
	
	for k, v in pairs(player.cwGearTab) do
		if (IsValid(v)) then v:Remove(); end;
	end;
	
	player.cwGearTab = {};
end;

--[[
	@codebase Shared
	@details A function to create a player's gear.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for gearClass.
	@param {Unknown} Missing description for itemTable.
	@param {Unknown} Missing description for mustHave.
	@returns {Unknown}
--]]
function Clockwork.player:CreateGear(player, gearClass, itemTable, mustHave)
	if (!player.cwGearTab) then
		player.cwGearTab = {};
	end;
	
	if (IsValid(player.cwGearTab[gearClass])) then
		player.cwGearTab[gearClass]:Remove();
	end;
	
	if (itemTable("isAttachment")) then
		local position = player:GetPos();
		local angles = player:GetAngles();
		local model = itemTable("attachmentModel", itemTable("model"));
		
		player.cwGearTab[gearClass] = ents.Create("cw_gear");
		player.cwGearTab[gearClass]:SetParent(player);
		player.cwGearTab[gearClass]:SetAngles(angles);
		player.cwGearTab[gearClass]:SetModel(model);
		player.cwGearTab[gearClass]:SetPos(position);
		player.cwGearTab[gearClass]:Spawn();
		
		if (itemTable("attachmentMaterial")) then
			player.cwGearTab[gearClass]:SetMaterial(itemTable("attachmentMaterial"));
		end;
		
		if (itemTable("attachmentColor")) then
			player.cwGearTab[gearClass]:SetColor(
				cwKernel:UnpackColor(itemTable("attachmentColor"))
			);
		else
			player.cwGearTab[gearClass]:SetColor(Color(255, 255, 255, 255));
		end;
		
		if (IsValid(player.cwGearTab[gearClass])) then
			player.cwGearTab[gearClass]:SetOwner(player);
			player.cwGearTab[gearClass]:SetMustHave(mustHave);
			player.cwGearTab[gearClass]:SetItemTable(gearClass, itemTable);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player is noclipping.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:IsNoClipping(player)
	if (player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle()) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player is an admin.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:IsAdmin(player)
	if (self:HasFlags(player, "o")) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player can hear another player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for iAllowance.
	@returns {Unknown}
--]]
function Clockwork.player:CanHearPlayer(player, target, iAllowance)
	if (cwCfg:Get("messages_must_see_player"):Get()) then
		return self:CanSeePlayer(player, target, (iAllowance or 0.5), true);
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A functon to get all property.
	@returns {Unknown}
--]]
function Clockwork.player:GetAllProperty()
	for k, v in pairs(self.property) do
		if (!IsValid(v)) then
			self.property[k] = nil;
		end;
	end;
	
	return self.property;
end;

--[[
	@codebase Shared
	@details A function to set a player's action.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for action.
	@param {Unknown} Missing description for duration.
	@param {Unknown} Missing description for priority.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:SetAction(player, action, duration, priority, Callback)
	local currentAction = self:GetAction(player);
	
	if (type(action) != "string" or action == "") then
		cwKernel:DestroyTimer("Action"..player:UniqueID());
		
		player:SetSharedVar("StartActTime", 0);
		player:SetSharedVar("ActDuration", 0);
		player:SetSharedVar("ActName", "");
		
		return;
	elseif (duration == false or duration == 0) then
		if (currentAction == action) then
			return self:SetAction(player, false);
		else
			return false;
		end;
	end;
	
	if (player.cwAction) then
		if ((priority and priority > player.cwAction[2])
		or currentAction == "" or action == player.cwAction[1]) then
			player.cwAction = nil;
		end;
	end;

	if (!player.cwAction) then
		local curTime = CurTime();
		
		player:SetSharedVar("StartActTime", curTime);
		player:SetSharedVar("ActDuration", duration);
		player:SetSharedVar("ActName", action);
		
		if (priority) then
			player.cwAction = {action, priority};
		else
			player.cwAction = nil;
		end;
		
		cwKernel:CreateTimer("Action"..player:UniqueID(), duration, 1, function()
			if (Callback) then
				Callback();
			end;
		end);
	end;
end;

--[[
	@codebase Shared
	@details A function to set the player's character menu state.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for state.
	@returns {Unknown}
--]]
function Clockwork.player:SetCharacterMenuState(player, state)
	cwDatastream:Start(player, "CharacterMenu", state);
end;

--[[
	@codebase Shared
	@details A function to get a player's action.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for percentage.
	@returns {Unknown}
--]]
function Clockwork.player:GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("StartActTime");
	local actionDuration = player:GetSharedVar("ActDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("ActName");
	
	if (startActionTime and CurTime() < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime));
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

--[[
	@codebase Shared
	@details A function to run a Clockwork command on a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for command.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.player:RunClockworkCommand(player, command, ...)
	return cwCommand:ConsoleCommand(player, "cwCmd", {command, ...});
end;

--[[
	@codebase Shared
	@details A function to get a player's wages name.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetWagesName(player)
	return cwClass:Query(player:Team(), "wagesName", cwCfg:Get("wages_name"):Get());
end;

--[[
	@codebase Shared
	@details A function to get whether a player can see an entity.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for iAllowance.
	@param {Unknown} Missing description for tIgnoreEnts.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeeEntity(player, target, iAllowance, tIgnoreEnts)
	if (player:GetEyeTraceNoCursor().Entity != target) then
		return self:CanSeePosition(player, target:LocalToWorld(target:OBBCenter()), iAllowance, tIgnoreEnts, target);
	else
		return true;
	end;
end;

--[[
	Duplicate functions, keeping them like this for backward compatiblity.
--]]
Clockwork.player.CanSeePlayer = Clockwork.player.CanSeeEntity;
Clockwork.player.CanSeeNPC = Clockwork.player.CanSeeEntity;

--[[
	@codebase Shared
	@details A function to get whether a player can see a position.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for iAllowance.
	@param {Unknown} Missing description for tIgnoreEnts.
	@param {Unknown} Missing description for targetEnt.
	@returns {Unknown}
--]]
function Clockwork.player:CanSeePosition(player, position, iAllowance, tIgnoreEnts, targetEnt)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = {player, targetEnt};
	
	if (tIgnoreEnts) then
		if (type(tIgnoreEnts) == "table") then
			table.Add(trace.filter, tIgnoreEnts);
		else
			table.Add(trace.filter, ents.GetAll());
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if (trace.Fraction >= (iAllowance or 0.75)) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to update whether a player's weapon is raised.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:UpdateWeaponRaised(player)
	local isRaised = self:GetWeaponRaised(player);
	local weapon = player:GetActiveWeapon();
	
	player:SetSharedVar("IsWepRaised", isRaised);
	
	if (IsValid(weapon)) then
		cwKernel:HandleWeaponFireDelay(player, isRaised, weapon, CurTime());
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player's weapon is raised.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for bIsCached.
	@returns {Unknown}
--]]
function Clockwork.player:GetWeaponRaised(player, bIsCached)
	if (bIsCached) then
		return player:GetSharedVar("IsWepRaised");
	end;
	
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon) and !weapon.NeverRaised) then
		if (weapon.GetRaised) then
			local isRaised = weapon:GetRaised();
			
			if (isRaised != nil) then
				return isRaised;
			end;
		end;
		
		return cwPlugin:Call("GetPlayerWeaponRaised", player, weapon:GetClass(), weapon);
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details A function to toggle whether a player's weapon is raised.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:ToggleWeaponRaised(player)
	self:SetWeaponRaised(player, !player.cwWeaponRaiseClass);
end;

--[[
	@codebase Shared
	@details A function to set whether a player's weapon is raised.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for isRaised.
	@returns {Unknown}
--]]
function Clockwork.player:SetWeaponRaised(player, isRaised)
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon)) then
		if (type(isRaised) == "number") then
			player.cwAutoWepRaised = weapon:GetClass();
			player:UpdateWeaponRaised();
			
			cwKernel:CreateTimer("WeaponRaised"..player:UniqueID(), isRaised, 1, function()
				if (IsValid(player)) then
					player.cwAutoWepRaised = nil;
					player:UpdateWeaponRaised();
				end;
			end);
		elseif (isRaised) then
			if (!player.cwWeaponRaiseClass) then
				if (weapon.OnRaised) then
					weapon:OnRaised();
				end;
			end;
			
			player.cwWeaponRaiseClass = weapon:GetClass();
			player.cwAutoWepRaised = nil;
			player:UpdateWeaponRaised();
		else
			if (player.cwWeaponRaiseClass) then
				if (weapon.OnLowered) then
					weapon:OnLowered();
				end;
			end;
			
			player.cwWeaponRaiseClass = nil;
			player.cwAutoWepRaised = nil;
			player:UpdateWeaponRaised();
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to setup a player's remove property delays.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for doAllCharacters.
	@returns {Unknown}
--]]
function Clockwork.player:SetupRemovePropertyDelays(player, doAllCharacters)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		local removeDelay = cwEntity:QueryProperty(v, "removeDelay");
		
		if (IsValid(v) and removeDelay) then
			if (uniqueID == cwEntity:QueryProperty(v, "uniqueID")
			and (doAllCharacters or key == cwEntity:QueryProperty(v, "key"))) then
				cwKernel:CreateTimer("RemoveDelay"..v:EntIndex(), removeDelay, 1, function(entity)
					if (IsValid(entity)) then
						entity:Remove();
					end;
				end, v);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to disable a player's property.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for characterOnly.
	@returns {Unknown}
--]]
function Clockwork.player:DisableProperty(player, characterOnly)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (IsValid(v) and uniqueID == cwEntity:QueryProperty(v, "uniqueID")
		and (!characterOnly or key == cwEntity:QueryProperty(v, "key"))) then
			cwEntity:SetPropertyVar(v, "owner", NULL);
			
			if (cwEntity:QueryProperty(v, "networked")) then
				v:SetNetworkedEntity("Owner", NULL);
			end;
			
			v:SetOwnerKey(nil);
			v:SetNetworkedBool("Owned", false);
			v:SetNetworkedInt("Key", 0);
			
			if (v.SetPlayer) then
				v:SetVar("Founder", NULL);
				v:SetVar("FounderIndex", 0);
				v:SetNetworkedString("FounderName", "");
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to give property to a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for networked.
	@param {Unknown} Missing description for removeDelay.
	@returns {Unknown}
--]]
function Clockwork.player:GiveProperty(player, entity, networked, removeDelay)
	cwKernel:DestroyTimer("RemoveDelay"..entity:EntIndex());
	cwEntity:ClearProperty(entity);
	
	entity.cwPropertyTab = {
		key = player:GetCharacterKey(),
		owner = player,
		owned = true,
		uniqueID = player:UniqueID(),
		networked = networked,
		removeDelay = removeDelay
	};
	
	if (entity.SetPlayer) then
		entity:SetPlayer(player);
	end;
	
	if (networked) then
		entity:SetNetworkedEntity("Owner", player);
	end;
	
	entity:SetOwnerKey(player:GetCharacterKey());
	entity:SetNetworkedBool("Owned", true);
	
	if (tonumber(entity.cwPropertyTab.key)) then
		entity:SetNetworkedInt("Key", entity.cwPropertyTab.key);
	end;
	
	self.property[entity:EntIndex()] = entity;
	cwPlugin:Call("PlayerPropertyGiven", player, entity, networked, removeDelay);
end;

--[[
	@codebase Shared
	@details A function to give property to an offline player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for networked.
	@param {Unknown} Missing description for removeDelay.
	@returns {Unknown}
--]]
function Clockwork.player:GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
	cwEntity:ClearProperty(entity);
	
	if (key and uniqueID) then
		local propertyUniqueID = cwEntity:QueryProperty(entity, "uniqueID");
		local owner = player.GetByUniqueID(uniqueID);
		
		if (IsValid(owner) and owner:GetCharacterKey() == key) then
			self:GiveProperty(owner, entity, networked, removeDelay);
			return;
		else
			owner = nil;
		end;
		
		if (propertyUniqueID) then
			cwKernel:DestroyTimer("RemoveDelay"..entity:EntIndex().." "..cwPropertyTabUniqueID);
		end;
		
		entity.cwPropertyTab = {
			key = key,
			owner = owner,
			owned = true,
			uniqueID = uniqueID,
			networked = networked,
			removeDelay = removeDelay
		};
		
		if (IsValid(entity.cwPropertyTab.owner)) then
			if (entity.SetPlayer) then
				entity:SetPlayer(entity.cwPropertyTab.owner);
			end;
			
			if (networked) then
				entity:SetNetworkedEntity("Owner", entity.cwPropertyTab.owner);
			end;
		end;
		
		entity:SetNetworkedBool("Owned", true);
		entity:SetNetworkedInt("Key", key);
		entity:SetOwnerKey(key);
		
		self.property[entity:EntIndex()] = entity;
		cwPlugin:Call("PlayerPropertyGivenOffline", key, uniqueID, entity, networked, removeDelay);
	end;
end;

--[[
	@codebase Shared
	@details A function to take property from an offline player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for anyCharacter.
	@returns {Unknown}
--]]
function Clockwork.player:TakePropertyOffline(key, uniqueID, entity, anyCharacter)
	if (key and uniqueID) then
		local owner = player.GetByUniqueID(uniqueID);
		
		if (IsValid(owner) and owner:GetCharacterKey() == key) then
			self:TakeProperty(owner, entity);
			return;
		end;
		
		if (cwEntity:QueryProperty(entity, "uniqueID") == uniqueID
		and cwEntity:QueryProperty(entity, "key") == key) then
			entity.cwPropertyTab = nil;
			entity:SetNetworkedEntity("Owner", NULL);
			entity:SetNetworkedBool("Owned", false);
			entity:SetNetworkedInt("Key", 0);
			entity:SetOwnerKey(nil);
			
			if (entity.SetPlayer) then
				entity:SetVar("Founder", nil);
				entity:SetVar("FounderIndex", nil);
				entity:SetNetworkedString("FounderName", "");
			end;
			
			self.property[entity:EntIndex()] = nil;
			cwPlugin:Call("PlayerPropertyTakenOffline", key, uniqueID, entity);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to take property from a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for entity.
	@returns {Unknown}
--]]
function Clockwork.player:TakeProperty(player, entity)
	if (cwEntity:GetOwner(entity) == player) then
		entity.cwPropertyTab = nil;
		
		entity:SetNetworkedEntity("Owner", NULL);
		entity:SetNetworkedBool("Owned", false);
		entity:SetNetworkedInt("Key", 0);
		entity:SetOwnerKey(nil);
		
		if (entity.SetPlayer) then
			entity:SetVar("Founder", nil);
			entity:SetVar("FounderIndex", nil);
			entity:SetNetworkedString("FounderName", "");
		end;
		
		self.property[entity:EntIndex()] = nil;
		cwPlugin:Call("PlayerPropertyTaken", player, entity);
	end;
end;

--[[
	@codebase Shared
	@details A function to set a player to their default skin.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:SetDefaultSkin(player)
	player:SetSkin(self:GetDefaultSkin(player));
end;

--[[
	@codebase Shared
	@details A function to get a player's default skin.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDefaultSkin(player)
	return cwPlugin:Call("GetPlayerDefaultSkin", player);
end;

--[[
	@codebase Shared
	@details A function to set a player to their default model.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:SetDefaultModel(player)
	player:SetModel(self:GetDefaultModel(player));
end;

--[[
	@codebase Shared
	@details A function to get a player's default model.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDefaultModel(player)
	return cwPlugin:Call("GetPlayerDefaultModel", player);
end;

--[[
	@codebase Shared
	@details A function to get whether a player is drunk.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDrunk(player)
	if (player.cwDrunkTab) then return #player.cwDrunkTab; end;
end;

--[[
	@codebase Shared
	@details A function to set whether a player is drunk.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for expire.
	@returns {Unknown}
--]]
function Clockwork.player:SetDrunk(player, expire)
	local curTime = CurTime();
	
	if (expire == false) then
		player.cwDrunkTab = nil;
	elseif (!player.cwDrunkTab) then
		player.cwDrunkTab = {curTime + expire};
	else
		player.cwDrunkTab[#player.cwDrunkTab + 1] = curTime + expire;
	end;
	
	player:SetSharedVar("IsDrunk", self:GetDrunk(player) or 0);
end;

--[[
	@codebase Shared
	@details A function to strip a player's default ammo.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for weapon.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.player:StripDefaultAmmo(player, weapon, itemTable)
	if (!itemTable) then
		itemTable = cwItem:GetByWeapon(weapon);
	end;
	
	if (itemTable) then
		local secondaryDefaultAmmo = itemTable("secondaryDefaultAmmo");
		local primaryDefaultAmmo = itemTable("primaryDefaultAmmo");
		
		if (primaryDefaultAmmo) then
			local ammoClass = weapon:GetPrimaryAmmoType();
			
			if (weapon:Clip1() != -1) then
				weapon:SetClip1(0);
			end;
			
			if (type(primaryDefaultAmmo) == "number") then
				player:SetAmmo(
					math.max(player:GetAmmoCount(ammoClass) - primaryDefaultAmmo, 0), ammoClass
				);
			end;
		end;
		
		if (secondaryDefaultAmmo) then
			local ammoClass = weapon:GetSecondaryAmmoType();
			
			if (weapon:Clip2() != -1) then
				weapon:SetClip2(0);
			end;
			
			if (type(secondaryDefaultAmmo) == "number") then
				player:SetAmmo(
					math.max(player:GetAmmoCount(ammoClass) - secondaryDefaultAmmo, 0), ammoClass
				);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player is whitelisted for a faction.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
function Clockwork.player:IsWhitelisted(player, faction)
	return table.HasValue(player:GetData("Whitelisted"), faction);
end;

--[[
	@codebase Shared
	@details A function to set whether a player is whitelisted for a faction.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for faction.
	@param {Unknown} Missing description for isWhitelisted.
	@returns {Unknown}
--]]
function Clockwork.player:SetWhitelisted(player, faction, isWhitelisted)
	local whitelisted = player:GetData("Whitelisted");
	
	if (isWhitelisted) then
		if (!self:IsWhitelisted(player, faction)) then
			whitelisted[table.Count(whitelisted) + 1] = faction;
		end;
	else
		for k, v in pairs(whitelisted) do
			if (v == faction) then
				table.remove(whitelisted, k);
				break;
			end;
		end;
	end;
	
	cwDatastream:Start(
		player, "SetWhitelisted", {faction, isWhitelisted}
	);
end;

--[[
	@codebase Shared
	@details A function to create a Condition timer.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for delay.
	@param {Unknown} Missing description for Condition.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:ConditionTimer(player, delay, Condition, Callback)
	local realDelay = CurTime() + delay;
	local uniqueID = player:UniqueID();
	
	if (player.cwConditionTimer) then
		player.cwConditionTimer.Callback(false);
		player.cwConditionTimer = nil;
	end;
	
	player.cwConditionTimer = {
		delay = realDelay,
		Callback = Callback,
		Condition = Condition
	};
	
	cwKernel:CreateTimer("CondTimer"..uniqueID, 0, 0, function()
		if (!IsValid(player)) then
			cwKernel:DestroyTimer("CondTimer"..uniqueID);
			Callback(false);
			return;
		end;
		
		if (Condition()) then
			if (CurTime() >= realDelay) then
				Callback(true); player.cwConditionTimer = nil;
				cwKernel:DestroyTimer("CondTimer"..uniqueID);
			end;
		else
			Callback(false); player.cwConditionTimer = nil;
			cwKernel:DestroyTimer("CondTimer"..uniqueID);
		end;
	end);
end;

--[[
	@codebase Shared
	@details A function to create an entity Condition timer.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for delay.
	@param {Unknown} Missing description for distance.
	@param {Unknown} Missing description for Condition.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:EntityConditionTimer(player, target, entity, delay, distance, Condition, Callback)
	local realEntity = entity or target;
	local realDelay = CurTime() + delay;
	local uniqueID = player:UniqueID();
	
	if (player.cwConditionEntTimer) then
		player.cwConditionEntTimer.Callback(false);
		player.cwConditionEntTimer = nil;
	end;
	
	player.cwConditionEntTimer = {
		delay = realDelay, target = target,
		entity = realEntity, distance = distance,
		Callback = Callback, Condition = Condition
	};
	
	cwKernel:CreateTimer("EntityCondTimer"..uniqueID, 0, 0, function()
		if (!IsValid(player)) then
			cwKernel:DestroyTimer("EntityCondTimer"..uniqueID);
			Callback(false);
			return;
		end;
		
		local traceLine = player:GetEyeTraceNoCursor();
		
		if (IsValid(target) and IsValid(realEntity) and traceLine.Entity == realEntity
		and traceLine.Entity:GetPos():Distance(player:GetShootPos()) <= distance
		and Condition()) then
			if (CurTime() >= realDelay) then
				Callback(true); player.cwConditionEntTimer = nil;
				cwKernel:DestroyTimer("EntityCondTimer"..uniqueID);
			end;
		else
			Callback(false); player.cwConditionEntTimer = nil;
			cwKernel:DestroyTimer("EntityCondTimer"..uniqueID);
		end;
	end);
end;

--[[
	@codebase Shared
	@details A function to get a player's spawn ammo.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ammo.
	@returns {Unknown}
--]]
function Clockwork.player:GetSpawnAmmo(player, ammo)
	if (ammo) then
		return player.cwSpawnAmmo[ammo];
	else
		return player.cwSpawnAmmo;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's spawn weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for weapon.
	@returns {Unknown}
--]]
function Clockwork.player:GetSpawnWeapon(player, weapon)
	if (weapon) then
		return player.cwSpawnWeps[weapon];
	else
		return player.cwSpawnWeps;
	end;
end;

--[[
	@codebase Shared
	@details A function to take spawn ammo from a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ammo.
	@param {Unknown} Missing description for amount.
	@returns {Unknown}
--]]
function Clockwork.player:TakeSpawnAmmo(player, ammo, amount)
	if (player.cwSpawnAmmo[ammo]) then
		if (player.cwSpawnAmmo[ammo] < amount) then
			amount = player.cwSpawnAmmo[ammo];
			
			player.cwSpawnAmmo[ammo] = nil;
		else
			player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] - amount;
		end;
		
		player:RemoveAmmo(amount, ammo);
	end;
end;

--[[
	@codebase Shared
	@details A function to give the player spawn ammo.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ammo.
	@param {Unknown} Missing description for amount.
	@returns {Unknown}
--]]
function Clockwork.player:GiveSpawnAmmo(player, ammo, amount)
	if (player.cwSpawnAmmo[ammo]) then
		player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] + amount;
	else
		player.cwSpawnAmmo[ammo] = amount;
	end;
	
	player:GiveAmmo(amount, ammo);
end;

--[[
	@codebase Shared
	@details A function to take a player's spawn weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
function Clockwork.player:TakeSpawnWeapon(player, class)
	player.cwSpawnWeps[class] = nil;
	player:StripWeapon(class);
end;

--[[
	@codebase Shared
	@details A function to give a player a spawn weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
function Clockwork.player:GiveSpawnWeapon(player, class)
	player.cwSpawnWeps[class] = true;
	player:Give(class);
end;

--[[
	@codebase Shared
	@details A function to give a player an item weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.player:GiveItemWeapon(player, itemTable)
	if (cwItem:IsWeapon(itemTable)) then
		player:Give(itemTable("weaponClass"), itemTable);
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to give a player a spawn item weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.player:GiveSpawnItemWeapon(player, itemTable)
	if (cwItem:IsWeapon(itemTable)) then
		player.cwSpawnWeps[itemTable("weaponClass")] = true;
		player:Give(itemTable("weaponClass"), itemTable);
		
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to give flags to a character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:GiveFlags(player, flags)
	for i = 1, #flags do
		local flag = string.utf8sub(flags, i, i);
		
		if (!string.find(player:GetFlags(), flag)) then
			player:SetCharacterData("Flags", player:GetFlags()..flag, true);
			
			cwPlugin:Call("PlayerFlagsGiven", player, flag);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to give flags to a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:GivePlayerFlags(player, flags)
	for i = 1, #flags do
		local flag = string.utf8sub(flags, i, i);
		
		if (!string.find(player:GetPlayerFlags(), flag)) then
			player:SetData("Flags", player:GetPlayerFlags()..flag, true);

			cwPlugin:Call("PlayerFlagsGiven", player, flag);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to play a sound to a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for sound.
	@returns {Unknown}
--]]
function Clockwork.player:PlaySound(player, sound)
	cwDatastream:Start(player, "PlaySound",sound);
end;

--[[
	@codebase Shared
	@details A function to get a player's maximum characters.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetMaximumCharacters(player)
	local maximum = cwCfg:Get("additional_characters"):Get();
	
	for k, v in pairs(cwFaction:GetAll()) do
		if (!v.whitelist or self:IsWhitelisted(player, v.name)) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

--[[
	@codebase Shared
	@details A function to query a player's character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for default.
	@returns {Unknown}
--]]
function Clockwork.player:Query(player, key, default)
	local character = player:GetCharacter();
	
	if (character) then
		key = cwKernel:SetCamelCase(key, true);
		
		if (character[key] != nil) then
			return character[key];
		end;
	end;
	
	return default;
end;

--[[
	@codebase Shared
	@details A function to set a player to a safe position.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for filter.
	@returns {Unknown}
--]]
function Clockwork.player:SetSafePosition(player, position, filter)
	position = self:GetSafePosition(player, position, filter);
	
	if (position) then
		player:SetMoveType(MOVETYPE_NOCLIP);
		player:SetPos(position);
		
		if (player:IsInWorld()) then
			player:SetMoveType(MOVETYPE_WALK);
		else
			player:Spawn();
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the safest position near a position.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for filter.
	@returns {Unknown}
--]]
function Clockwork.player:GetSafePosition(player, position, filter)
	local closestPosition = nil;
	local distanceAmount = 8;
	local directions = {};
	local yawForward = player:EyeAngles().yaw;
	local angles = {
		math.NormalizeAngle(yawForward - 180),
		math.NormalizeAngle(yawForward - 135),
		math.NormalizeAngle(yawForward + 135),
		math.NormalizeAngle(yawForward + 45),
		math.NormalizeAngle(yawForward + 90),
		math.NormalizeAngle(yawForward - 45),
		math.NormalizeAngle(yawForward - 90),
		math.NormalizeAngle(yawForward)
	};
	
	position = position + Vector(0, 0, 32);
	
	if (!filter) then
		filter = {player};
	elseif (type(filter) != "table") then
		filter = {filter};
	end;
	
	if (!table.HasValue(filter, player)) then
		filter[#filter + 1] = player;
	end;
	
	for i = 1, 8 do
		for k, v in pairs(angles) do
			directions[#directions + 1] = {v, distanceAmount};
		end;
		
		distanceAmount = distanceAmount * 2;
	end;
	
	-- A function to get a lower position.
	local function GetLowerPosition(testPosition, ignoreHeight)
		local trace = {
			filter = filter,
			endpos = testPosition - Vector(0, 0, 256),
			start = testPosition
		};
		
		return util.TraceLine(trace).HitPos + Vector(0, 0, 32);
	end;
	
	local trace = {
		filter = filter,
		endpos = position + Vector(0, 0, 256),
		start = position
	};
	
	local safePosition = GetLowerPosition(util.TraceLine(trace).HitPos);
	
	if (safePosition) then
		position = safePosition;
	end;
	
    for k, v in pairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + (angleVector * v[2]);
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (traceLine.Hit) then
			trace = {
				filter = filter,
				endpos = traceLine.HitPos - (angleVector * v[2]),
				start = traceLine.HitPos
			};
			
			traceLine = util.TraceEntity(trace, player);
			
			if (!traceLine.Hit) then
				position = traceLine.HitPos;
			end;
		end;
		
		if (!traceLine.Hit) then
			break;
		end;
    end;
	
    for k, v in pairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + (angleVector * v[2]);
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (!traceLine.Hit) then
			return traceLine.HitPos;
		end;
    end;
	
	return position;
end;

--[[
	@codebase Shared
	@details Called to convert a player's data to a string.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork.player:ConvertDataString(player, data)
	local wasSuccess, value = pcall(cwJson.Decode, cwJson, data);
	
	if (wasSuccess and value != nil) then
		return value;
	else
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to return a player's property.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:ReturnProperty(player)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (IsValid(v)) then
			if (uniqueID == cwEntity:QueryProperty(v, "uniqueID")) then
				if (key == cwEntity:QueryProperty(v, "key")) then
					self:GiveProperty(player, v, cwEntity:QueryProperty(v, "networked"));
				end;
			end;
		end;
	end;
	
	cwPlugin:Call("PlayerReturnProperty", player);
end;

--[[
	@codebase Shared
	@details A function to take flags from a character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:TakeFlags(player, flags)
	for i = 1, #flags do
		local flag = string.utf8sub(flags, i, i);
		
		if (string.find(player:GetFlags(), flag)) then
			player:SetCharacterData("Flags", string.gsub(player:GetFlags(), flag, ""), true);
			
			cwPlugin:Call("PlayerFlagsTaken", player, flag);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to take flags from a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:TakePlayerFlags(player, flags)
	for i = 1, #flags do
		local flag = string.utf8sub(flags, i, i);
		
		if (string.find(player:GetPlayerFlags(), flag)) then
			player:SetData("Flags", string.gsub(player:GetFlags(), flag, ""), true);

			cwPlugin:Call("PlayerFlagsTaken", player, flag);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to set whether a player's menu is open.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for isOpen.
	@returns {Unknown}
--]]
function Clockwork.player:SetMenuOpen(player, isOpen)
	cwDatastream:Start(player, "MenuOpen", isOpen);
end;

--[[
	@codebase Shared
	@details A function to set whether a player has intialized.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for initialized.
	@returns {Unknown}
--]]
function Clockwork.player:SetInitialized(player, initialized)
	player:SetSharedVar("Initialized", initialized);
end;

--[[
	@codebase Shared
	@details A function to check if a player has any flags.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@param {Unknown} Missing description for byDefault.
	@returns {Unknown}
--]]
function Clockwork.player:HasAnyFlags(player, flags, byDefault)
	if (player:GetCharacter()) then
		local playerFlags = player:GetFlags();
		
		if (cwClass:HasAnyFlags(player:Team(), flags) and !byDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i);
			local wasSuccess = true;
			
			if (!byDefault) then
				local hasFlag = cwPlugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						return true;
					end;
				else
					wasSuccess = nil;
				end;
			end;
			
			if (wasSuccess) then
				if (flag == "s") then
					if (player:IsSuperAdmin()) then
						return true;
					end;
				elseif (flag == "a") then
					if (player:IsAdmin()) then
						return true;
					end;
				elseif (flag == "o") then
					if (player:IsSuperAdmin() or player:IsAdmin()) then
						return true;
					elseif (player:IsUserGroup("operator")) then
						return true;
					end;
				elseif (string.find(playerFlags, flag)) then
					return true;
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player has flags.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@param {Unknown} Missing description for byDefault.
	@returns {Unknown}
--]]
function Clockwork.player:HasFlags(player, flags, byDefault)
	if (player:GetCharacter()) then
		local playerFlags = player:GetFlags();
		
		if (cwClass:HasFlags(player:Team(), flags) and !byDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i);
			local wasSuccess;
			
			if (!byDefault) then
				local hasFlag = cwPlugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						wasSuccess = true;
					end;
				else
					return;
				end;
			end;
			
			if (!wasSuccess) then
				if (flag == "s") then
					if (!player:IsSuperAdmin()) then
						return;
					end;
				elseif (flag == "a") then
					if (!player:IsAdmin()) then
						return;
					end;
				elseif (flag == "o") then
					if (!player:IsSuperAdmin() and !player:IsAdmin()) then
						if (!player:IsUserGroup("operator")) then
							return;
						end;
					end;
				elseif (!string.find(playerFlags, flag)) then
					return;
				end;
			end;
		end;
		
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to use a player's death code.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for commandTable.
	@param {Unknown} Missing description for arguments.
	@returns {Unknown}
--]]
function Clockwork.player:UseDeathCode(player, commandTable, arguments)
	cwPlugin:Call("PlayerDeathCodeUsed", player, commandTable, arguments);
	
	self:TakeDeathCode(player);
end;

--[[
	@codebase Shared
	@details A function to get whether a player has a death code.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for authenticated.
	@returns {Unknown}
--]]
function Clockwork.player:GetDeathCode(player, authenticated)
	if (player.cwDeathCodeIdx and (!authenticated or player.cwDeathCodeAuth)) then
		return player.cwDeathCodeIdx;
	end;
end;

--[[
	@codebase Shared
	@details A function to take a player's death code.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:TakeDeathCode(player)
	player.cwDeathCodeAuth = nil;
	player.cwDeathCodeIdx = nil;
end;

--[[
	@codebase Shared
	@details A function to give a player their death code.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GiveDeathCode(player)
	player.cwDeathCodeIdx = math.random(0, 99999);
	player.cwDeathCodeAuth = nil;
	
	cwDatastream:Start(player, "ChatBoxDeathCode", player.cwDeathCodeIdx);
end;

--[[
	@codebase Shared
	@details A function to take a door from a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for door.
	@param {Unknown} Missing description for shouldForce.
	@param {Unknown} Missing description for thisDoorOnly.
	@param {Unknown} Missing description for childrenOnly.
	@returns {Unknown}
--]]
function Clockwork.player:TakeDoor(player, door, shouldForce, thisDoorOnly, childrenOnly)
	local doorCost = cwCfg:Get("door_cost"):Get();
	
	if (!thisDoorOnly) then
		local doorParent = cwEntity:GetDoorParent(door);
		
		if (!doorParent or childrenOnly) then
			for k, v in pairs(cwEntity:GetDoorChildren(door)) do
				if (IsValid(v)) then
					self:TakeDoor(player, v, true, true);
				end;
			end;
		else
			return self:TakeDoor(player, doorParent, shouldForce);
		end;
	end;
	
	if (cwPlugin:Call("PlayerCanUnlockEntity", player, door)) then
		door:Fire("Unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
	
	cwEntity:SetDoorText(door, false);
	self:TakeProperty(player, door);
	
	cwPlugin:Call("PlayerDoorTaken", player, door)
	
	if (door:GetClass() == "prop_dynamic") then
		if (!door:IsMapEntity()) then
			door:Remove();
		end;
	end;
	
	if (!force and doorCost > 0) then
		self:GiveCash(player, doorCost / 2, {"CashSellDoor"});
	end;
end;

--[[
	@codebase Shared
	@details A function to make a player say text as a radio broadcast.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for check.
	@param {Unknown} Missing description for noEavesdrop.
	@returns {Unknown}
--]]
function Clockwork.player:SayRadio(player, text, check, noEavesdrop)
	local eavesdroppers = {};
	local listeners = {};
	local canRadio = true;
	local info = {listeners = {}, noEavesdrop = noEavesdrop, text = text};
	
	cwPlugin:Call("PlayerAdjustRadioInfo", player, info);
	
	for k, v in pairs(info.listeners) do
		if (type(k) == "Player") then
			listeners[k] = k;
		elseif (type(v) == "Player") then
			listeners[v] = v;
		end;
	end;
	
	if (!info.noEavesdrop) then
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v:HasInitialized() and !listeners[v]) then
				if (v:GetShootPos():Distance(player:GetShootPos()) <= cwCfg:Get("talk_radius"):Get()) then
					eavesdroppers[v] = v;
				end;
			end;
		end;
	end;
	
	if (check) then
		canRadio = cwPlugin:Call("PlayerCanRadio", player, info.text, listeners, eavesdroppers);
	end;
	
	if (canRadio) then
		info = cwChatbox:Add(listeners, player, "radio", info.text);
		
		if (info and IsValid(info.speaker)) then
			cwChatbox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			
			cwPlugin:Call("PlayerRadioUsed", player, info.text, listeners, eavesdroppers);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's faction table.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetFactionTable(player)
	return cwFaction:GetAll()[player:GetFaction()];
end;

--[[
	@codebase Shared
	@details A function to give a door to a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for door.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for unsellable.
	@param {Unknown} Missing description for override.
	@returns {Unknown}
--]]
function Clockwork.player:GiveDoor(player, door, name, unsellable, override)
	if (cwEntity:IsDoor(door)) then
		local doorParent = cwEntity:GetDoorParent(door);
		
		if (doorParent and !override) then
			self:GiveDoor(player, doorParent, name, unsellable);
		else
			for k, v in pairs(cwEntity:GetDoorChildren(door)) do
				if (IsValid(v)) then
					self:GiveDoor(player, v, name, unsellable, true);
				end;
			end;
			
			door.unsellable = unsellable;
			door.accessList = {};
			
			cwEntity:SetDoorText(door, name or "PurchasedDoorText");
			self:GiveProperty(player, door, true);
			
			cwPlugin:Call("PlayerDoorGiven", player, door)
			
			if (cwPlugin:Call("PlayerCanUnlockEntity", player, door)) then
				door:EmitSound("doors/door_latch3.wav");
				door:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's real trace.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for useFilterTrace.
	@returns {Unknown}
--]]
function Clockwork.player:GetRealTrace(player, useFilterTrace)
	local eyePos = player:EyePos();
	local trace = player:GetEyeTraceNoCursor();
	
	local newTrace = util.TraceLine({
		endpos = eyePos + (player:GetAimVector() * 4096),
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	});
	
	if ((IsValid(newTrace.Entity) and (!IsValid(trace.Entity)
	or trace.Entity:IsVehicle()) and !newTrace.HitWorld) or useFilterTrace) then
		trace = newTrace;
	end;
	
	return trace;
end;

--[[
	@codebase Shared
	@details A function to check if a player recognises another player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for status.
	@param {Unknown} Missing description for isAccurate.
	@returns {Unknown}
--]]
function Clockwork.player:DoesRecognise(player, target, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, target, RECOGNISE_PARTIAL);
	elseif (cwCfg:Get("recognise_system"):Get()) then
		local recognisedNames = player:GetRecognisedNames();
		local realValue = false;
		local key = target:GetCharacterKey();
		
		if (recognisedNames and recognisedNames[key]) then
			if (isAccurate) then
				realValue = (recognisedNames[key] == status);
			else
				realValue = (recognisedNames[key] >= status);
			end;
		end;
		
		return cwPlugin:Call("PlayerDoesRecognisePlayer", player, target, status, isAccurate, realValue);
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to send a player a creation fault.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for fault.
	@returns {Unknown}
--]]
function Clockwork.player:SetCreateFault(player, fault)
	if (!fault) then
		fault = "There has been an unknown error, please contact the administrator!";
	end;
	
	cwDatastream:Start(player, "CharacterFinish", {wasSuccess = false, fault = fault});
end;

--[[
	@codebase Shared
	@details A function to force a player to delete a character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for characterID.
	@returns {Unknown}
--]]
function Clockwork.player:ForceDeleteCharacter(player, characterID)
	local charactersTable = cwCfg:Get("mysql_characters_table"):Get();
	local schemaFolder = cwKernel:GetSchemaFolder();
	local character = player.cwCharacterList[characterID];
	
	if (character) then
		local queryObj = cwDatabase:Delete(charactersTable);
			queryObj:AddWhere("_Schema = ?", schemaFolder);
			queryObj:AddWhere("_SteamID = ?", player:SteamID());
			queryObj:AddWhere("_CharacterID = ?", characterID);
		queryObj:Push();
		
		if (!cwPlugin:Call("PlayerDeleteCharacter", player, character)) then
			cwKernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerDeletedChar", player:SteamName(), character.name});
		end;
		
		player.cwCharacterList[characterID] = nil;
		
		cwDatastream:Start(player, "CharacterRemove", characterID);
	end;
end;

--[[
	@codebase Shared
	@details A function to delete a player's character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for characterID.
	@returns {Unknown}
--]]
function Clockwork.player:DeleteCharacter(player, characterID)
	local character = player.cwCharacterList[characterID];
	
	if (character) then
		if (player:GetCharacter() != character) then
			local fault = cwPlugin:Call("PlayerCanDeleteCharacter", player, character);
			
			if (fault == nil or fault == true) then
				self:ForceDeleteCharacter(player, characterID);
				
				return true;
			elseif (type(fault) != "string") then
				return false, {"YouCannotDeleteThisCharacter"};
			else
				return false, fault;
			end;
		else
			return false, {"CannotDeleteCharacterUsing"};
		end;
	else
		return false, {"CharacterDoesNotExist"};
	end;
end;

--[[
	@codebase Shared
	@details A function to use a player's character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for characterID.
	@returns {Unknown}
--]]
function Clockwork.player:UseCharacter(player, characterID)
	local isCharacterMenuReset = player:IsCharacterMenuReset();
	local currentCharacter = player:GetCharacter();
	local character = player.cwCharacterList[characterID];
	
	if (!character) then
		return false, {"CharacterDoesNotExist"};
	end;
	
	if (currentCharacter != character or isCharacterMenuReset) then
		local factionTable = cwFaction:FindByID(character.faction);
		local fault = cwPlugin:Call("PlayerCanUseCharacter", player, character);
		
		if (fault == nil or fault == true) then
			local players = #cwFaction:GetPlayers(character.faction);
			local limit = cwFaction:GetLimit(factionTable.name);
			
			if (isCharacterMenuReset and character.faction == currentCharacter.faction) then
				players = players - 1;
			end;
				
			if (cwPlugin:Call("PlayerCanBypassFactionLimit", player, character)) then
				limit = nil;
			end;
			
			if (limit and players == limit) then
				return false, {"CannotSwitchFactionFull", character.faction, limit, limit};
			else
				if (currentCharacter) then
					local fault = cwPlugin:Call("PlayerCanSwitchCharacter", player, character);
					
					if (fault != nil and fault != true) then
						return false, fault or {"YouCannotSwitchToCharacter"};
					end;
				end;
				
				cwKernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerLoadedChar", player:SteamName(), character.name});
				
				if (isCharacterMenuReset) then
					player.cwCharMenuReset = false;
					player:Spawn();
				else
					self:LoadCharacter(player, characterID);
				end;
				
				return true;
			end;
		else
			return false, fault or {"YouCannotUseThisCharacter"};
		end;
	else
		return false, {"AlreadyUsingThisCharacter"};
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's character.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacter(player)
	return player.cwCharacter;
end;

--[[
	@codebase Shared
	@details A function to get a player's unrecognised name.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for bFormatted.
	@returns {Unknown}
--]]
function Clockwork.player:GetUnrecognisedName(player, bFormatted)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = cwCfg:Get("unrecognised_name"):Get();
	local usedPhysDesc = false;
	
	if (unrecognisedPhysDesc != "") then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	if (bFormatted) then
		if (string.utf8len(unrecognisedName) > 24) then
			unrecognisedName = string.utf8sub(unrecognisedName, 1, 21).."...";
		end;
		
		unrecognisedName = "["..unrecognisedName.."]";
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

--[[
	@codebase Shared
	@details A function to format text based on a relationship.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.player:FormatRecognisedText(player, text, ...)
	local arguments = {...};

	for i = 1, #arguments do
		if (string.find(text, "%%s") and IsValid(arguments[i])) then
			local unrecognisedName = "["..self:GetUnrecognisedName(arguments[i]).."]";
			
			if (self:DoesRecognise(player, arguments[i])) then
				unrecognisedName = arguments[i]:Name();
			end;
			
			text = string.gsub(text, "%%s", unrecognisedName, 1);
		end;
	end;
	
	return text;
end;

--[[
	@codebase Shared
	@details A function to restore a recognised name.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@returns {Unknown}
--]]
function Clockwork.player:RestoreRecognisedName(player, target)
	local recognisedNames = player:GetRecognisedNames();
	local key = target:GetCharacterKey();
	
	if (recognisedNames[key]) then
		if (cwPlugin:Call("PlayerCanRestoreRecognisedName", player, target)) then
			self:SetRecognises(player, target, recognisedNames[key], true);
		else
			recognisedNames[key] = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to restore a player's recognised names.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:RestoreRecognisedNames(player)
	cwDatastream:Start(player, "ClearRecognisedNames", true);
	
	if (cwCfg:Get("save_recognised_names"):Get()) then
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v:HasInitialized()) then
				self:RestoreRecognisedName(player, v);
				self:RestoreRecognisedName(v, player);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to set whether a player recognises a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for target.
	@param {Unknown} Missing description for status.
	@param {Unknown} Missing description for shouldForce.
	@returns {Unknown}
--]]
function Clockwork.player:SetRecognises(player, target, status, shouldForce)
	local recognisedNames = player:GetRecognisedNames();
	local name = target:Name();
	local key = target:GetCharacterKey();
	
	--[[ I have no idea why this would happen. --]]
	if (key == nil) then return end;
	
	if (status == RECOGNISE_SAVE) then
		if (cwCfg:Get("save_recognised_names"):Get()) then
			if (!cwPlugin:Call("PlayerCanSaveRecognisedName", player, target)) then
				status = RECOGNISE_TOTAL;
			end;
		else
			status = RECOGNISE_TOTAL;
		end;
	end;
	
	if (!status or shouldForce or !self:DoesRecognise(player, target, status)) then
		recognisedNames[key] = status or nil;
		
		cwDatastream:Start(player, "RecognisedName", {
			key = key, status = (status or 0)
		});
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's physical description.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetPhysDesc(player)
	local physDesc = player:GetCharacterData("PhysDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = cwClass:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = cwCfg:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = cwKernel:ModifyPhysDesc(physDesc);
	end;
	
	local override = cwPlugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

--[[
	@codebase Shared
	@details A function to clear a player's recognised names list.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for status.
	@param {Unknown} Missing description for isAccurate.
	@returns {Unknown}
--]]
function Clockwork.player:ClearRecognisedNames(player, status, isAccurate)
	if (!status) then
		local character = player:GetCharacter();
		
		if (character) then
			character.recognisedNames = {};
			
			cwDatastream:Start(player, "ClearRecognisedNames", true);
		end;
	else
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v:HasInitialized()) then
				if (self:DoesRecognise(player, v, status, isAccurate)) then
					self:SetRecognises(player, v, false);
				end;
			end;
		end;
	end;
	
	cwPlugin:Call("PlayerRecognisedNamesCleared", player, status, isAccurate);
end;

--[[
	@codebase Shared
	@details A function to clear a player's name from being recognised.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for status.
	@param {Unknown} Missing description for isAccurate.
	@returns {Unknown}
--]]
function Clockwork.player:ClearName(player, status, isAccurate)
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (!status or self:DoesRecognise(v, player, status, isAccurate)) then
				self:SetRecognises(v, player, false);
			end;
		end;
	end;
	
	cwPlugin:Call("PlayerNameCleared", player, status, isAccurate);
end;

--[[
	@codebase Shared
	@details A function to holsters all of a player's weapons.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:HolsterAll(player)
	for k, v in pairs(player:GetWeapons()) do
		local class = v:GetClass();
		local itemTable = cwItem:GetByWeapon(v);
		
		if (itemTable and cwPlugin:Call("PlayerCanHolsterWeapon", player, itemTable, v, true, true)) then
			cwPlugin:Call("PlayerHolsterWeapon", player, itemTable, v, true);
			player:StripWeapon(class);
			player:GiveItem(itemTable, true);
		end;
	end;
	
	player:SelectWeapon("cw_hands");
end;

--[[
	@codebase Shared
	@details A function to set a shared variable for a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for key.
	@param {Unknown} Missing description for value.
	@param {Unknown} Missing description for sharedTable.
	@returns {Unknown}
--]]
function Clockwork.player:SetSharedVar(player, key, value, sharedTable)
	if (IsValid(player)) then
		if (!sharedTable) then
			local sharedVars = cwKernel:GetSharedVars():Player();
			
			if (!sharedVars) then
				MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't get the sharedVars table.\n");
				return;
			elseif (not sharedVars[key]) then
				MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't find key '"..key.."' in sharedVars table. Is it registered?\n");
				return;
			end;
			
			local sharedVarData = sharedVars[key];
			
			if (sharedVarData.bPlayerOnly) then
				local realValue = value;
				
				if (value == nil) then
					realValue = cwKernel:GetDefaultNetworkedValue(sharedVarData.class);
				end;
				
				if (player.cwSharedVars[key] != realValue) then
					player.cwSharedVars[key] = realValue;
					
					cwDatastream:Start(player, "SharedVar", {key = key, value = realValue});
				end;
			else
				local class = cwKernel:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					if (value == nil) then
						value = cwKernel:GetDefaultClassValue(class);
					end;
					
					player["SetNetworked"..class](player, key, value);
				else
					MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't find network class for key '"..key.."'.");
				end;
			end;
		else
			cwDatastream:Start(player, "SetSharedTableVar", {sharedTable = sharedTable, key = key, value = value})
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's shared variable.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for key.
	@returns {Unknown}
--]]
function Clockwork.player:GetSharedVar(player, key)
	if (IsValid(player)) then
		local sharedVars = cwKernel:GetSharedVars():Player();
		
		if (!sharedVars) then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't get the sharedVars table.\n");
			return;
		elseif (not sharedVars[key]) then
			MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't find key '"..key.."' in sharedVars table. Is it registered?\n");
			return;
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData.bPlayerOnly) then
			if (!player.cwSharedVars[key]) then
				return cwKernel:GetDefaultNetworkedValue(sharedVarData.class);
			else
				return player.cwSharedVars[key];
			end;
		else
			local class = cwKernel:ConvertNetworkedClass(sharedVarData.class);
			
			if (class) then
				return player["GetNetworked"..class](player, key);
			else
				MsgC(Color(255, 100, 0, 255), "[Clockwork:PlayerSharedVars] Couldn't find network class for key '"..key.."'.");
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to set whether a player's character is banned.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for banned.
	@returns {Unknown}
--]]
function Clockwork.player:SetBanned(player, banned)
	player:SetCharacterData("CharBanned", banned);
	player:SaveCharacter();
	player:SetSharedVar("CharBanned", banned);
end;

--[[
	@codebase Shared
	@details A function to set a player's name.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for saveless.
	@returns {Unknown}
--]]
function Clockwork.player:SetName(player, name, saveless)
	local previousName = player:Name();
	local newName = name;
	
	player:SetCharacterData("Name", newName, true);
	player:SetSharedVar("Name", newName);
	
	if (!player.cwFirstSpawn) then
		cwPlugin:Call("PlayerNameChanged", player, previousName, newName);
	end;
	
	if (!saveless) then
		player:SaveCharacter();
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's generator count.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetGeneratorCount(player)
	local generators = cwGenerator:GetAll();
	local count = 0;
	
	for k, v in pairs(generators) do
		count = count + self:GetPropertyCount(player, k);
	end;
	
	return count;
end;

--[[
	@codebase Shared
	@details A function to get a player's property entities.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
function Clockwork.player:GetPropertyEntities(player, class)
	local uniqueID = player:UniqueID();
	local entities = {};
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (uniqueID == cwEntity:QueryProperty(v, "uniqueID")) then
			if (key == cwEntity:QueryProperty(v, "key")) then
				if (!class or v:GetClass() == class) then
					entities[#entities + 1] = v;
				end;
			end;
		end;
	end;
	
	return entities;
end;

--[[
	@codebase Shared
	@details A function to get a player's property count.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for class.
	@returns {Unknown}
--]]
function Clockwork.player:GetPropertyCount(player, class)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (uniqueID == cwEntity:QueryProperty(v, "uniqueID")) then
			if (key == cwEntity:QueryProperty(v, "key")) then
				if (!class or v:GetClass() == class) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

--[[
	@codebase Shared
	@details A function to get a player's door count.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDoorCount(player)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (cwEntity:IsDoor(v) and !cwEntity:GetDoorParent(v)) then
			if (uniqueID == cwEntity:QueryProperty(v, "uniqueID")) then
				if (player:GetCharacterKey() == cwEntity:QueryProperty(v, "key")) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

--[[
	@codebase Shared
	@details A function to take a player's door access.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for door.
	@returns {Unknown}
--]]
function Clockwork.player:TakeDoorAccess(player, door)
	if (door.accessList) then
		door.accessList[player:GetCharacterKey()] = false;
	end;
end;

--[[
	@codebase Shared
	@details A function to give a player door access.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for door.
	@param {Unknown} Missing description for access.
	@returns {Unknown}
--]]
function Clockwork.player:GiveDoorAccess(player, door, access)
	local key = player:GetCharacterKey();
	
	if (!door.accessList) then
		door.accessList = {
			[key] = access
		};
	else
		door.accessList[key] = access;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player has door access.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for door.
	@param {Unknown} Missing description for access.
	@param {Unknown} Missing description for isAccurate.
	@returns {Unknown}
--]]
function Clockwork.player:HasDoorAccess(player, door, access, isAccurate)
	if (!access) then
		return self:HasDoorAccess(player, door, DOOR_ACCESS_BASIC, isAccurate);
	else
		local doorParent = cwEntity:GetDoorParent(door);
		local key = player:GetCharacterKey();
		
		if (doorParent and cwEntity:DoorHasSharedAccess(doorParent)
		and (!door.accessList or door.accessList[key] == nil)) then
			return cwPlugin:Call("PlayerDoesHaveDoorAccess", player, doorParent, access, isAccurate);
		else
			return cwPlugin:Call("PlayerDoesHaveDoorAccess", player, door, access, isAccurate);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player can afford an amount.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for amount.
	@returns {Unknown}
--]]
function Clockwork.player:CanAfford(player, amount)
	if (cwCfg:Get("cash_enabled"):Get()) then
		return (player:GetCash() >= amount);
	else
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to give a player an amount of cash.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for amount.
	@param {Unknown} Missing description for reason.
	@param {Unknown} Missing description for noMsg.
	@returns {Unknown}
--]]
function Clockwork.player:GiveCash(player, amount, reason, noMsg)
	if (cwCfg:Get("cash_enabled"):Get()) then
		local positiveHintColor = "positive_hint";
		local negativeHintColor = "negative_hint";
		local roundedAmount = math.Round(amount);
		local cash = math.Round(math.max(player:GetCash() + roundedAmount, 0));
		
		player:SetCharacterData("Cash", cash, true);
		player:SetSharedVar("Cash", cash);
		
		if (roundedAmount < 0) then
			roundedAmount = math.abs(roundedAmount);
			
			if (!noMsg) then
				if (reason) then
					cwHint:Send(player, {"YourCharLostCashReason", cwKernel:FormatCash(roundedAmount), reason}, 4, negativeHintColor);
				else
					cwHint:Send(player, {"YourCharLostCash", cwKernel:FormatCash(roundedAmount)}, 4, negativeHintColor);
				end;
			end;
		elseif (roundedAmount > 0) then
			if (!noMsg) then
				if (reason) then
					cwHint:Send(player, {"YourCharGainedCashReason", cwKernel:FormatCash(roundedAmount), reason}, 4, positiveHintColor);
				else
					cwHint:Send(player, {"YourCharGainedCash", cwKernel:FormatCash(roundedAmount)}, 4, positiveHintColor);
				end;
			end;
		end;
		
		cwPlugin:Call("PlayerCashUpdated", player, roundedAmount, reason, noMsg);
	end;
end;

Clockwork.player:AddToMetaTable("Player", "GiveCash");

--[[
	@codebase Shared
	@details A function to show cinematic text to a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for color.
	@param {Unknown} Missing description for barLength.
	@param {Unknown} Missing description for hangTime.
	@returns {Unknown}
--]]
function Clockwork.player:CinematicText(player, text, color, barLength, hangTime)
	cwDatastream:Start(player, "CinematicText", {
		text = text,
		color = color,
		barLength = barLength,
		hangTime = hangTime
	});
end;

--[[
	@codebase Shared
	@details A function to show cinematic text to each player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for color.
	@param {Unknown} Missing description for hangTime.
	@returns {Unknown}
--]]
function Clockwork.player:CinematicTextAll(text, color, hangTime)
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			self:CinematicText(v, text, color, hangTime);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to find a player by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.player:FindByID(identifier)
	for k, v in pairs(player.GetAll()) do
		if (v:HasInitialized() and (v:SteamID() == identifier or v:UniqueID() == identifier
		or string.find(string.lower(v:Name()), string.lower(identifier), 1, true))) then
			return v;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get if a player is protected.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.player:IsProtected(identifier)
	local steamID = nil;
	local ownerSteamID = cwCfg:Get("owner_steamid"):Get();
	local wasSuccess, value = pcall(IsValid, identifier);
		
	if (!wasSuccess or value == false) then
		local playerObj = self:FindByID(identifier);

		if (IsValid(playerObj)) then
			steamID = playerObj:SteamID();
		end;
	else
		steamID = identifier:SteamID();
	end;
	
	if (string.find(ownerSteamID, ",")) then
		ownerSteamID = string.gsub(ownerSteamID, " ", "");
		ownerSteamID = string.Split(ownerSteamID, ",");

		for k, v in pairs(ownerSteamID) do
			if (steamID and steamID == v) then
				return true;
			end;
		end;
	else
		if (steamID and steamID == ownerSteamID) then
			return true;
		end;
	end;
	
	return false;
end;

--[[
	@codebase Shared
	@details A function to notify each player in a radius.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for class.
	@param {Unknown} Missing description for position.
	@param {Unknown} Missing description for radius.
	@returns {Unknown}
--]]
function Clockwork.player:NotifyInRadius(text, class, position, radius)
	local listeners = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (position:Distance(v:GetPos()) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	self:Notify(listeners, text, class);
end;

--[[
	@codebase Shared
	@details A function to notify each player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for icon.
	@returns {Unknown}
--]]
function Clockwork.player:NotifyAll(text, icon)
	self:Notify(nil, text, true, icon);
end;

--[[
	@codebase Server
	@details A function to notify admins by rank.
	@param {String} The rank and up that will be notified.
	@param {String} The text that will be sent to each admin.
	@param {String} The name of the icon that will be used in the message, can be nil.
--]]
function Clockwork.player:NotifyAdmins(adminLevel, text, icon)
	for k, v in pairs(player.GetAll()) do
		if (adminLevel == "operator" or adminLevel == "o") then
			if (v:IsAdmin()) then
				self:Notify(v, text, true, icon);
			end;
		elseif (adminLevel == "admin" or adminLevel == "a") then
			if (v:IsAdmin() and !v:IsUserGroup("operator")) then
				self:Notify(v, text, true, icon);
			end;
		elseif (adminLevel == "superadmin" or adminLevel == "s") then
			if (v:IsSuperAdmin()) then
				self:Notify(v, text, true, icon);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to notify a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for class.
	@param {Unknown} Missing description for icon.
	@returns {Unknown}
--]]
function Clockwork.player:Notify(player, text, class, icon)
	if (type(player) == "table") then
		for k, v in pairs(player) do
			self:Notify(v, text, class);
		end;
	elseif (class == true) then
		if (icon) then
			local data = {icon = icon};
			
			cwChatbox:Add(player, nil, "notify_all", text, data);
		else
			cwChatbox:Add(player, nil, "notify_all", text);
		end;
	elseif (!class) then
		if (icon) then
			cwChatbox:Add(player, nil, "notify", text, {icon = icon});
		else
			cwChatbox:Add(player, nil, "notify", text);
		end;
	else
		cwDatastream:Start(player, "Notification", {
			text = text,
			class = class
		});
	end;
end;

Clockwork.player:AddToMetaTable("Player", "Notify");

--[[
	@codebase Shared
	@details A function to set a player's weapons list from a table.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for weapons.
	@param {Unknown} Missing description for forceReturn.
	@returns {Unknown}
--]]
function Clockwork.player:SetWeapons(player, weapons, forceReturn)
	for k, v in pairs(weapons) do
		if (!player:HasWeapon(v.weaponData["class"])) then
			if (!v.teamIndex or player:Team() == v.teamIndex) then
				player:Give(v.weaponData["class"], v.weaponData["itemTable"], forceReturn);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to give ammo to a player from a table.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ammo.
	@returns {Unknown}
--]]
function Clockwork.player:GiveAmmo(player, ammo)
	for k, v in pairs(ammo) do
		player:GiveAmmo(v, k);
	end;
end;

--[[
	@codebase Shared
	@details A function to set a player's ammo list from a table.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ammo.
	@returns {Unknown}
--]]
function Clockwork.player:SetAmmo(player, ammo)
	for k, v in pairs(ammo) do
		player:SetAmmo(v, k);
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's ammo list as a table.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for doStrip.
	@returns {Unknown}
--]]
function Clockwork.player:GetAmmo(player, doStrip)
	local spawnAmmo = self:GetSpawnAmmo(player);
	local ammoTypes = {};
	local ammo = {};

	for k, v in pairs(cwItem:GetAll()) do
		if (v.ammoClass) then
			ammoTypes[v.ammoClass] = true;
		end;
	end;

	cwPlugin:Call("AdjustAmmoTypes", ammoTypes);

	if (ammoTypes) then
		for k, v in pairs(ammoTypes) do
			if (v) then
				ammo[k] = player:GetAmmoCount(k);
			end;
		end;
	end;
	
	if (spawnAmmo) then
		for k, v in pairs(spawnAmmo) do
			if (ammo[k]) then
				ammo[k] = math.max(ammo[k] - v, 0);
			end;
		end;
	end;
	
	if (doStrip) then
		player:RemoveAllAmmo();
	end;

	return ammo;
end;

--[[
	@codebase Shared
	@details A function to get a player's weapons list as a table.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for shouldKeep.
	@returns {Unknown}
--]]
function Clockwork.player:GetWeapons(player, shouldKeep)
	local weapons = {};
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = cwItem:GetByWeapon(v);
		local teamIndex = player:Team();
		local class = v:GetClass();
		
		if (!self:GetSpawnWeapon(player, class)) then
			teamIndex = nil;
		end;
		
		weapons[#weapons + 1] = {
			weaponData = {
				itemTable = itemTable,
				class = class
			},
			teamIndex = teamIndex
		};
		
		if (!shouldKeep) then
			player:StripWeapon(class);
		end;
	end;
	
	return weapons;
end;

--[[
	@codebase Shared
	@details A function to get the total weight of a player's equipped weapons.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetEquippedWeight(player)
	local weight = 0;
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = cwItem:GetByWeapon(v);
		
		if (itemTable) then
			weight = weight + itemTable("weight");
		end;
	end;
	
	return weight;
end;

--[[
	@codebase Shared
	@details A function to get the total space of a player's equipped weapons.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetEquippedSpace(player)
	local space = 0;
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = cwItem:GetByWeapon(v);
		
		if (itemTable) then
			space = space + itemTable("space");
		end;
	end;
	
	return space;
end;

--[[
	@codebase Shared
	@details A function to get a player's holstered weapon.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetHolsteredWeapon(player)
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = cwItem:GetByWeapon(v);
		local class = v:GetClass();
		
		if (itemTable) then
			if (self:GetWeaponClass(player) != class) then
				return class;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check whether a player is ragdolled.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for exception.
	@param {Unknown} Missing description for bNoEntity.
	@returns {Unknown}
--]]
function Clockwork.player:IsRagdolled(player, exception, bNoEntity)
	if (player:GetRagdollEntity() or bNoEntity) then
		local ragdolled = player:GetSharedVar("IsRagdoll");
		
		if (ragdolled == exception) then
			return false;
		else
			return (ragdolled != RAGDOLL_NONE);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to set a player's unragdoll time.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for delay.
	@returns {Unknown}
--]]
function Clockwork.player:SetUnragdollTime(player, delay)
	player.cwRagdollPaused = nil;
	
	if (delay) then
		self:SetAction(player, "unragdoll", delay, 2, function()
			if (IsValid(player) and player:Alive()) then
				self:SetRagdollState(player, RAGDOLL_NONE);
			end;
		end);
	else
		self:SetAction(player, "unragdoll", false);
	end;
end;

--[[
	@codebase Shared
	@details A function to pause a player's unragdoll time.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:PauseUnragdollTime(player)
	if (!player.cwRagdollPaused) then
		local unragdollTime = self:GetUnragdollTime(player);
		local curTime = CurTime();
		
		if (player:IsRagdolled()) then
			if (unragdollTime > 0) then
				player.cwRagdollPaused = unragdollTime - curTime;
				self:SetAction(player, "unragdoll", false);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to start a player's unragdoll time.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:StartUnragdollTime(player)
	if (player.cwRagdollPaused) then
		if (player:IsRagdolled()) then
			self:SetUnragdollTime(player, player.cwRagdollPaused);
			
			player.cwRagdollPaused = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's unragdoll time.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetUnragdollTime(player)
	local action, actionDuration, startActionTime = self:GetAction(player);
	
	if (action == "unragdoll") then
		return startActionTime + actionDuration;
	else
		return 0;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's ragdoll state.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetRagdollState(player)
	return player:GetSharedVar("IsRagdoll");
end;

--[[
	@codebase Shared
	@details A function to get a player's ragdoll entity.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetRagdollEntity(player)
	if (player.cwRagdollTab) then
		if (IsValid(player.cwRagdollTab.entity)) then
			return player.cwRagdollTab.entity;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's ragdoll table.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetRagdollTable(player)
	return player.cwRagdollTab;
end;

--[[
	@codebase Shared
	@details A function to do a player's ragdoll decay check.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for ragdoll.
	@returns {Unknown}
--]]
function Clockwork.player:DoRagdollDecayCheck(player, ragdoll)
	local index = ragdoll:EntIndex();
	
	cwKernel:CreateTimer("DecayCheck"..index, 60, 0, function()
		local ragdollIsValid = IsValid(ragdoll);
		local playerIsValid = IsValid(player);
		
		if (!playerIsValid and ragdollIsValid) then
			if (!cwEntity:IsDecaying(ragdoll)) then
				local decayTime = cwCfg:Get("body_decay_time"):Get();
				
				if (decayTime > 0 and cwPlugin:Call("PlayerCanRagdollDecay", player, ragdoll, decayTime)) then
					cwEntity:Decay(ragdoll, decayTime);
				end;
			else
				cwKernel:DestroyTimer("DecayCheck"..index);
			end;
		elseif (!ragdollIsValid) then
			cwKernel:DestroyTimer("DecayCheck"..index);
		end;
	end);
end;

--[[
	@codebase Shared
	@details A function to set a player's ragdoll immunity.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for delay.
	@returns {Unknown}
--]]
function Clockwork.player:SetRagdollImmunity(player, delay)
	if (delay) then
		player:GetRagdollTable().immunity = CurTime() + delay;
	else
		player:GetRagdollTable().immunity = 0;
	end;
end;

--[[
	@codebase Shared
	@details A function to set a player's ragdoll state.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for state.
	@param {Unknown} Missing description for delay.
	@param {Unknown} Missing description for decay.
	@param {Unknown} Missing description for force.
	@param {Unknown} Missing description for multiplier.
	@param {Unknown} Missing description for velocityCallback.
	@returns {Unknown}
--]]
function Clockwork.player:SetRagdollState(player, state, delay, decay, force, multiplier, velocityCallback)
	if (state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER) then
		if (player:IsRagdolled()) then
			if (cwPlugin:Call("PlayerCanRagdoll", player, state, delay, decay, player.cwRagdollTab)) then
				self:SetUnragdollTime(player, delay);
					player:SetSharedVar("IsRagdoll", state);
					player.cwRagdollTab.delay = delay;
					player.cwRagdollTab.decay = decay;
				cwPlugin:Call("PlayerRagdolled", player, state, player.cwRagdollTab);
			end;
		elseif (cwPlugin:Call("PlayerCanRagdoll", player, state, delay, decay)) then
			local velocity = player:GetVelocity() + (player:GetAimVector() * 128);
			local ragdoll = ents.Create("prop_ragdoll");
			
			ragdoll:SetMaterial(player:GetMaterial());
			ragdoll:SetAngles(player:GetAngles());
			ragdoll:SetColor(player:GetColor());
			ragdoll:SetModel(player:GetModel());
			ragdoll:SetSkin(player:GetSkin());
			ragdoll:SetPos(player:GetPos());
			ragdoll:Spawn();
			
			player.cwRagdollTab = {};
			player.cwRagdollTab.eyeAngles = player:EyeAngles();
			player.cwRagdollTab.immunity = CurTime() + cwCfg:Get("ragdoll_immunity_time"):Get();
			player.cwRagdollTab.moveType = MOVETYPE_WALK;
			player.cwRagdollTab.entity = ragdoll;
			player.cwRagdollTab.health = player:Health();
			player.cwRagdollTab.armor = player:Armor();
			player.cwRagdollTab.delay = delay;
			player.cwRagdollTab.decay = decay;
			
			if (!player:IsOnGround()) then
				player.cwRagdollTab.immunity = 0;
			end;
			
			if (IsValid(ragdoll)) then
				local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
				
				ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local physicsObject = ragdoll:GetPhysicsObjectNum(i);
					local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
					local position, angle = player:GetBonePosition(boneIndex);
					
					if (IsValid(physicsObject)) then
						physicsObject:SetPos(position);
						physicsObject:SetAngles(angle);
						
						if (!velocityCallback) then
							if (boneIndex == headIndex) then
								physicsObject:SetVelocity(velocity * 1.5);
							else
								physicsObject:SetVelocity(velocity);
							end;
							
							if (force) then
								if (boneIndex == headIndex) then
									physicsObject:ApplyForceCenter(force * 1.5);
								else
									physicsObject:ApplyForceCenter(force);
								end;
							end;
						else
							velocityCallback(physicsObject, boneIndex, ragdoll, velocity, force);
						end;
					end;
				end;
			end;
			
			if (player:Alive()) then
				if (IsValid(player:GetActiveWeapon())) then
					player.cwRagdollTab.weapon = self:GetWeaponClass(player);
				end;
				
				player.cwRagdollTab.weapons = self:GetWeapons(player, true);
				
				if (delay) then
					self:SetUnragdollTime(player, delay);
				end;
			end;
			
			if (player:InVehicle()) then
				player:ExitVehicle();
				player.cwRagdollTab.eyeAngles = Angle(0, 0, 0);
			end;
			
			if (player:IsOnFire()) then
				ragdoll:Ignite(8, 0);
			end;
			
			player:Spectate(OBS_MODE_CHASE);
			player:RunCommand("-duck");
			player:RunCommand("-voicerecord");
			player:SetMoveType(MOVETYPE_OBSERVER);
			player:StripWeapons(true);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			if (player:FlashlightIsOn()) then
				player:Flashlight(false);
			end;
			
			player.cwRagdollPaused = nil;
			
			player:SetSharedVar("IsRagdoll", state);
			player:SetSharedVar("Ragdoll", ragdoll);
			
			if (state != RAGDOLL_FALLENOVER) then
				self:GiveDeathCode(player);
			end;
			
			cwEntity:SetPlayer(ragdoll, player);
			self:DoRagdollDecayCheck(player, ragdoll);
			
			cwPlugin:Call("PlayerRagdolled", player, state, player.cwRagdollTab);
		end;
	elseif (state == RAGDOLL_NONE or state == RAGDOLL_RESET) then
		if (player:IsRagdolled(nil, true)) then
			local ragdollTable = player:GetRagdollTable();
			
			if (cwPlugin:Call("PlayerCanUnragdoll", player, state, ragdollTable)) then
				player:UnSpectate();
				player:CrosshairEnable();
				
				if (state != RAGDOLL_RESET) then
					self:LightSpawn(player, nil, nil, true);
				end;
				
				if (state != RAGDOLL_RESET) then
					if (IsValid(ragdollTable.entity)) then
						local velocity = ragdollTable.entity:GetVelocity();
						local position = cwEntity:GetPelvisPosition(ragdollTable.entity);
						
						if (position) then
							self:SetSafePosition(player, position, ragdollTable.entity);
						end;
						
						player:SetSkin(ragdollTable.entity:GetSkin());
						player:SetColor(ragdollTable.entity:GetColor());
						player:SetMaterial(ragdollTable.entity:GetMaterial());
						
						if (!ragdollTable.model) then
							player:SetModel(ragdollTable.entity:GetModel());
						else
							player:SetModel(ragdollTable.model);
						end;
						
						if (!ragdollTable.skin) then
							player:SetSkin(ragdollTable.entity:GetSkin());
						else
							player:SetSkin(ragdollTable.skin);
						end;
						
						player:SetVelocity(velocity);
					end;
					
					player:SetArmor(ragdollTable.armor);
					player:SetHealth(ragdollTable.health);
					player:SetMoveType(ragdollTable.moveType);
					player:SetEyeAngles(ragdollTable.eyeAngles);
				end;
				
				if (IsValid(ragdollTable.entity)) then
					cwKernel:DestroyTimer("DecayCheck"..ragdollTable.entity:EntIndex());
					
					if (ragdollTable.decay) then
						if (cwPlugin:Call("PlayerCanRagdollDecay", player, ragdollTable.entity, ragdollTable.decay)) then
							cwEntity:Decay(ragdollTable.entity, ragdollTable.decay);
						end;
					else
						ragdollTable.entity:Remove();
					end;
				end;
				
				if (state != RAGDOLL_RESET) then
					self:SetWeapons(player, ragdollTable.weapons, true);
					
					if (ragdollTable.weapon) then
						player:SelectWeapon(ragdollTable.weapon);
					end;
				end;
				
				self:SetUnragdollTime(player, false);
					player:SetSharedVar("IsRagdoll", RAGDOLL_NONE);
					player:SetSharedVar("Ragdoll", NULL);
				cwPlugin:Call("PlayerUnragdolled", player, state, ragdollTable);
				
				player.cwRagdollPaused = nil;
				player.cwRagdollTab = {};
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to make a player drop their weapons.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:DropWeapons(player)
	local ragdollEntity = player:GetRagdollEntity();
	
	if (player:IsRagdolled()) then
		local ragdollWeapons = player:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			local itemTable = v.weaponData["itemTable"];
			
			if (itemTable and cwPlugin:Call("PlayerCanDropWeapon", player, itemTable, NULL, true)) then
				local info = {
					itemTable = itemTable,
					position = ragdollEntity:GetPos() + Vector(0, 0, math.random(1, 48)),
					angles = Angle(0, 0, 0)
				};
				
				player:TakeItem(info.itemTable, true);
				ragdollWeapons[k] = nil;
				
				if (cwPlugin:Call("PlayerAdjustDropWeaponInfo", player, info)) then
					local entity = cwEntity:CreateItem(player, info.itemTable, info.position, info.angles);
					
					if (IsValid(entity)) then
						cwPlugin:Call("PlayerDropWeapon", player, info.itemTable, entity, NULL);
					end;
				end;
			end;
		end;
	else
		for k, v in pairs(player:GetWeapons()) do
			local itemTable = cwItem:GetByWeapon(v);
			
			if (itemTable and cwPlugin:Call("PlayerCanDropWeapon", player, itemTable, v, true)) then
				local info = {
					itemTable = itemTable,
					position = player:GetPos() + Vector(0, 0, math.random(1, 48)),
					angles = Angle(0, 0, 0)
				};
				
				if (cwPlugin:Call("PlayerAdjustDropWeaponInfo", player, info)) then
					local entity = cwEntity:CreateItem(
						player, info.itemTable, info.position, info.angles
					);
					
					if (IsValid(entity)) then
						cwPlugin:Call("PlayerDropWeapon", player, info.itemTable, entity, v);
						player:StripWeapon(v:GetClass());
						player:TakeItem(info.itemTable, true);
					end;
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to lightly spawn a player.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for weapons.
	@param {Unknown} Missing description for ammo.
	@param {Unknown} Missing description for forceReturn.
	@returns {Unknown}
--]]
function Clockwork.player:LightSpawn(player, weapons, ammo, forceReturn)
	if (player:IsRagdolled() and !forceReturn) then
		self:SetRagdollState(player, RAGDOLL_NONE);
	end;
	
	player.cwLightSpawn = true;
	
	local moveType = player:GetMoveType();
	local material = player:GetMaterial();
	local position = player:GetPos();
	local angles = player:EyeAngles();
	local weapon = player:GetActiveWeapon();
	local health = player:Health();
	local armor = player:Armor();
	local model = player:GetModel();
	local color = player:GetColor();	
	local skin = player:GetSkin();
	
	if (ammo) then
		if (type(ammo) != "table") then
			ammo = self:GetAmmo(player, true);
		end;
	end;
	
	if (weapons) then
		if (type(weapons) != "table") then
			weapons = self:GetWeapons(player);
		end;
		
		if (IsValid(weapon)) then
			weapon = weapon:GetClass();
		end;
	end;
	
	player.cwSpawnCallback = function(player, gamemodeHook)
		if (weapons) then
			Clockwork:PlayerLoadout(player);
			
			self:SetWeapons(player, weapons, forceReturn);
			
			if (type(weapon) == "string") then
				player:SelectWeapon(weapon);
			end;
		end;
		
		if (ammo) then
			self:GiveAmmo(player, ammo);
		end;
		
		player:SetPos(position);
		player:SetSkin(skin);
		player:SetModel(model);
		player:SetColor(color);
		player:SetArmor(armor);
		player:SetHealth(health);
		player:SetMaterial(material);
		player:SetMoveType(moveType);
		player:SetEyeAngles(angles);
		
		if (gamemodeHook) then
			special = special or false;
			
			cwPlugin:Call("PostPlayerLightSpawn", player, weapons, ammo, special);
		end;
		
		player:ResetSequence(
			player:GetSequence()
		);
	end;
	
	player:Spawn();
end;

--[[
	@codebase Shared
	@details A function to convert a table to camel case.
	@param {Unknown} Missing description for baseTable.
	@returns {Unknown}
--]]
function Clockwork.player:ConvertToCamelCase(baseTable)
	local newTable = {};
	
	for k, v in pairs(baseTable) do
		local key = cwKernel:SetCamelCase(string.gsub(k, "_", ""), true);
		
		if (key and key != "") then
			newTable[key] = v;
		end;
	end;
	
	return newTable;
end;

--[[
	@codebase Shared
	@details A function to get a player's characters.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacters(player, Callback)
	if (!IsValid(player)) then return; end;
	
	local charactersTable = cwCfg:Get("mysql_characters_table"):Get();
	local schemaFolder = cwKernel:GetSchemaFolder();
	local queryObj = cwDatabase:Select(charactersTable);
		queryObj:AddWhere("_Schema = ?", schemaFolder);
		queryObj:AddWhere("_SteamID = ?", player:SteamID());
		queryObj:SetCallback(function(result)
			if (!IsValid(player)) then return; end;
			
			if (cwDatabase:IsResult(result)) then
				local characters = {};
				
				for k, v in pairs(result) do
					characters[k] = self:ConvertToCamelCase(v);
				end;
				
				Callback(characters);
			else
				Callback();
			end;
		end);
	queryObj:Pull();
end;

--[[
	@codebase Shared
	@details A function to add a character to the character screen.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for character.
	@returns {Unknown}
--]]
function Clockwork.player:CharacterScreenAdd(player, character)
	local info = {
		name = character.name,
		model = character.model,
		banned = character.data["CharBanned"],
		faction = character.faction,
		characterID = character.characterID
	};
	
	if (character.data["PhysDesc"]) then
		if (string.utf8len(character.data["PhysDesc"]) > 64) then
			info.details = string.utf8sub(character.data["PhysDesc"], 1, 64).."...";
		else
			info.details = character.data["PhysDesc"];
		end;
	end;
	
	if (character.data["CharBanned"]) then
		info.details = "This character is banned.";
	end;
	
	cwPlugin:Call("PlayerAdjustCharacterScreenInfo", player, character, info);
	cwDatastream:Start(player, "CharacterAdd", info);
end;

--[[
	@codebase Shared
	@details A function to convert a character's MySQL variables to Lua variables.
	@param {Unknown} Missing description for baseTable.
	@returns {Unknown}
--]]
function Clockwork.player:ConvertCharacterMySQL(baseTable)
	baseTable.recognisedNames = self:ConvertCharacterRecognisedNamesString(baseTable.recognisedNames);
	baseTable.characterID = tonumber(baseTable.characterID);
	baseTable.attributes = self:ConvertCharacterDataString(baseTable.attributes);
	baseTable.inventory = cwInventory:ToLoadable(self:ConvertCharacterDataString(baseTable.inventory));
	baseTable.cash = tonumber(baseTable.cash);
	baseTable.ammo = self:ConvertCharacterDataString(baseTable.ammo);
	baseTable.data = self:ConvertCharacterDataString(baseTable.data);
	baseTable.key = tonumber(baseTable.key);
end;

--[[
	@codebase Shared
	@details A function to get a player's character ID.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterID(player)
	local character = player:GetCharacter();
	
	if (character) then
		for k, v in pairs(player:GetCharacters()) do
			if (v == character) then
				return k;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to load a player's character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for characterID.
	@param {Unknown} Missing description for mergeCreate.
	@param {Unknown} Missing description for Callback.
	@param {Unknown} Missing description for shouldForce.
	@returns {Unknown}
--]]
function Clockwork.player:LoadCharacter(player, characterID, mergeCreate, Callback, shouldForce)
	local character = {};
	local unixTime = os.time();
	
	if (mergeCreate) then
		character = {};
		character.name = name;
		character.data = {};
		character.ammo = {};
		character.cash = cwCfg:Get("default_cash"):Get();
		character.model = "models/police.mdl";
		character.flags = "b";
		character.schema = cwKernel:GetSchemaFolder();
		character.gender = GENDER_MALE;
		character.faction = FACTION_CITIZEN;
		character.steamID = player:SteamID();
		character.steamName = player:SteamName();
		character.inventory = {};
		character.attributes = {};
		character.onNextLoad = "";
		character.lastPlayed = unixTime;
		character.timeCreated = unixTime;
		character.characterID = characterID;
		character.recognisedNames = {};
		
		if (!player.cwCharacterList[characterID]) then
			table.Merge(character, mergeCreate);
			
			if (character and type(character) == "table") then
				character.inventory = {};
				
				cwPlugin:Call("GetPlayerDefaultInventory", player, character, character.inventory);
				
				if (!shouldForce) then
					local fault = cwPlugin:Call("PlayerCanCreateCharacter", player, character, characterID);
					
					if (fault == false or type(fault) == "string") then
						return self:SetCreateFault(player, fault or {"YouCannotCreateThisChar"});
					end;
				end;
				
				self:SaveCharacter(player, true, character, function(key)
					player.cwCharacterList[characterID] = character;
					player.cwCharacterList[characterID].key = key;
					
					cwPlugin:Call("PlayerCharacterCreated", player, character);
					
					self:CharacterScreenAdd(player, character);
					
					if (Callback) then
						Callback();
					end;
				end);
			end;
		end;
	else
		character = player.cwCharacterList[characterID];
		
		if (character) then
			if (player:GetCharacter()) then
				self:SaveCharacter(player);
				self:UpdateCharacter(player);
				
				cwPlugin:Call("PlayerCharacterUnloaded", player);
			end;
			
			player.cwCharacter = character;
			
			if (player:Alive()) then
				player:KillSilent();
			end;
			
			if (self:SetBasicSharedVars(player)) then
				cwPlugin:Call("PlayerCharacterLoaded", player);
				
				player:SaveCharacter();
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to set a player's basic shared variables.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:SetBasicSharedVars(player)
	local gender = player:GetGender();
	local faction = player:GetFaction();
	local factionList = cwFaction:GetAll();
	
	if (factionList[faction]) then
		player:SetSharedVar("Faction", factionList[faction].index);
	end;
	
	if (gender == GENDER_MALE) then
		player:SetSharedVar("Gender", 2);
	else
		player:SetSharedVar("Gender", 1);
	end;
	
	return true;
end;

--[[
	@codebase Shared
	@details A function to get the character's ammo as a string.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for character.
	@param {Unknown} Missing description for rawTable.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterAmmoString(player, character, rawTable)
	local ammo = table.Copy(character.ammo);
	
	for k, v in pairs(self:GetAmmo(player)) do
		if (v > 0) then
			ammo[k] = v;
		end;
	end;
	
	if (!rawTable) then
		return cwJson:Encode(ammo);
	else
		return ammo;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the character's data as a string.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for character.
	@param {Unknown} Missing description for rawTable.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterDataString(player, character, rawTable)
	local data = table.Copy(character.data);
	cwPlugin:Call("PlayerSaveCharacterData", player, data);
	
	if (!rawTable) then
		return cwJson:Encode(data);
	else
		return data;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the character's recognised names as a string.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for character.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterRecognisedNamesString(player, character)
	local recognisedNames = {};
	
	for k, v in pairs(character.recognisedNames) do
		if (v == RECOGNISE_SAVE) then
			recognisedNames[#recognisedNames + 1] = k;
		end;
	end;
	
	return cwJson:Encode(recognisedNames);
end;

--[[
	@codebase Shared
	@details A function to get the character's inventory as a string.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for character.
	@param {Unknown} Missing description for rawTable.
	@returns {Unknown}
--]]
function Clockwork.player:GetCharacterInventoryString(player, character, rawTable)
	local inventory = cwInventory:CreateDuplicate(character.inventory);
	cwPlugin:Call("PlayerAddToSavedInventory", player, character, function(itemTable)
		cwInventory:AddInstance(inventory, itemTable);
	end);
	
	if (!rawTable) then
		return cwJson:Encode(cwInventory:ToSaveable(inventory));
	else
		return inventory;
	end;
end;

--[[
	@codebase Shared
	@details A function to convert a character's recognised names string to a table.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork.player:ConvertCharacterRecognisedNamesString(data)
	local wasSuccess, value = pcall(cwJson.Decode, cwJson, data);
	
	if (wasSuccess and value != nil) then
		local recognisedNames = {};
		
		for k, v in pairs(value) do
			recognisedNames[v] = RECOGNISE_SAVE;
		end;
		
		return recognisedNames;
	else
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to convert a character's data string to a table.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork.player:ConvertCharacterDataString(data)
	local wasSuccess, value = pcall(cwJson.Decode, cwJson, data);
	
	if (wasSuccess and value != nil) then
		return value;
	else
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to load a player's data.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:LoadData(player, Callback)
	local playersTable = cwCfg:Get("mysql_players_table"):Get();
	local schemaFolder = cwKernel:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	
	local queryObj = cwDatabase:Select(playersTable);
		queryObj:AddWhere("_Schema = ?", schemaFolder);
		queryObj:AddWhere("_SteamID = ?", steamID);
		queryObj:SetCallback(function(result)
			if (!IsValid(player) or player.cwData) then
				return;
			end;
			
			local onNextPlay = "";
			
			if (cwDatabase:IsResult(result)) then
				player.cwTimeJoined = tonumber(result[1]._TimeJoined);
				player.cwLastPlayed = tonumber(result[1]._LastPlayed);
				player.cwUserGroup = result[1]._UserGroup;
				player.cwData = self:ConvertDataString(player, result[1]._Data);
				
				local wasSuccess, value = pcall(cwJson.Decode, cwJson, result[1]._Donations);
				
				if (wasSuccess and value != nil) then
					player.cwDonations = value;
				else
					player.cwDonations = {};
				end;
				
				onNextPlay = result[1]._OnNextPlay;
			else
				player.cwTimeJoined = unixTime;
				player.cwLastPlayed = unixTime;
				player.cwDonations = {};
				player.cwUserGroup = "user";
				player.cwData = self:SaveData(player, true);
			end;
			
			if (self:IsProtected(player)) then
				player.cwUserGroup = "superadmin";
			end;
			
			if (!player.cwUserGroup or player.cwUserGroup == "") then
				player.cwUserGroup = "user";
			end;
			
			if (!cwCfg:Get("use_own_group_system"):Get()
			and player.cwUserGroup != "user") then
				player:SetUserGroup(player.cwUserGroup);
			end;
			
			cwPlugin:Call("PlayerRestoreData", player, player.cwData);
			
			if (Callback and IsValid(player)) then
				Callback(player);
			end;
			
			if (onNextPlay != "") then
				local updateObj = cwDatabase:Update(playersTable);
					updateObj:SetValue("_OnNextPlay", "");
					updateObj:SetValue("_SteamID", steamID);
					updateObj:SetValue("_Schema", schemaFolder);
				updateObj:Push();
				
				PLAYER = player;
					RunString(onNextPlay);
				PLAYER = nil;
			end;
		end);
	queryObj:Pull();
	
	timer.Simple(2, function()
		if (IsValid(player) and !player.cwData) then
			self:LoadData(player, Callback);
		end;
	end);
end;

--[[
	@codebase Shared
	@details A function to save a players's data.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for shouldCreate.
	@returns {Unknown}
--]]
function Clockwork.player:SaveData(player, shouldCreate)
	if (!shouldCreate) then
		local schemaFolder = cwKernel:GetSchemaFolder();
		local steamName = cwDatabase:Escape(player:SteamName());
		local ipAddress = player:IPAddress();
		local userGroup = player:GetClockworkUserGroup();
		local steamID = player:SteamID();
		local data = table.Copy(player.cwData);
		
		cwPlugin:Call("PlayerSaveData", player, data);
		
		local playersTable = cwCfg:Get("mysql_players_table"):Get();
		local queryObj = cwDatabase:Update(playersTable);
			queryObj:AddWhere("_Schema = ?", schemaFolder);
			queryObj:AddWhere("_SteamID = ?", steamID);
			queryObj:SetValue("_LastPlayed", os.time());
			queryObj:SetValue("_SteamName", steamName);
			queryObj:SetValue("_IPAddress", ipAddress);
			queryObj:SetValue("_UserGroup", userGroup);
			queryObj:SetValue("_SteamID", steamID);
			queryObj:SetValue("_Schema", schemaFolder);
			queryObj:SetValue("_Data", cwJson:Encode(data));
		queryObj:Push();
	else
		local playersTable = cwCfg:Get("mysql_players_table"):Get();
		local queryObj = cwDatabase:Insert(playersTable);
			queryObj:SetValue("_Data", "");
			queryObj:SetValue("_Schema", cwKernel:GetSchemaFolder());
			queryObj:SetValue("_SteamID", player:SteamID());
			queryObj:SetValue("_Donations", "");
			queryObj:SetValue("_UserGroup", "user");
			queryObj:SetValue("_IPAddress", player:IPAddress());
			queryObj:SetValue("_SteamName", player:SteamName());
			queryObj:SetValue("_OnNextPlay", "");
			queryObj:SetValue("_LastPlayed", os.time());
			queryObj:SetValue("_TimeJoined", os.time());
		queryObj:Push();
		
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to update a player's character.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:UpdateCharacter(player)
	player.cwCharacter.inventory = self:GetCharacterInventoryString(player, player.cwCharacter, true);
	player.cwCharacter.ammo = self:GetCharacterAmmoString(player, player.cwCharacter, true);
	player.cwCharacter.data = self:GetCharacterDataString(player, player.cwCharacter, true);
end;

--[[
	@codebase Shared
	@details A function to save a player's character.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for shouldCreate.
	@param {Unknown} Missing description for character.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function Clockwork.player:SaveCharacter(player, shouldCreate, character, Callback)
	if (shouldCreate) then
		local charactersTable = cwCfg:Get("mysql_characters_table"):Get();
		local values = "";
		local amount = 1;
		local keys = "";
		
		if (!character or type(character) != "table") then
			character = player:GetCharacter();
		end;
		
		local queryObj = cwDatabase:Insert(charactersTable);
			for k, v in pairs(character) do
				local tableKey = "_"..cwKernel:SetCamelCase(k, false);
				
				if (k == "recognisedNames") then
					queryObj:SetValue(tableKey, cwJson:Encode(character.recognisedNames));
				elseif (k == "attributes") then
					queryObj:SetValue(tableKey, cwJson:Encode(character.attributes));
				elseif (k == "inventory") then
					queryObj:SetValue(tableKey, cwJson:Encode(cwInventory:ToSaveable(character.inventory)));
				elseif (k == "ammo") then
					queryObj:SetValue(tableKey, cwJson:Encode(character.ammo));
				elseif (k == "data") then
					queryObj:SetValue(tableKey, cwJson:Encode(v));
				else
					queryObj:SetValue(tableKey, v);
				end;
			end;
			if (system.IsWindows()) then
				queryObj:SetCallback(function(result, status, lastID)
					if (Callback and tonumber(lastID)) then
						Callback(tonumber(lastID));
					end;
				end);
			elseif (system.IsLinux()) then
				queryObj:SetCallback(function(result, status, lastID)
					if (Callback) then
						Callback(tonumber(lastID));
					end;
				end);
			end;
			queryObj:SetFlag(2);
		queryObj:Push();
	elseif (player:HasInitialized()) then
		local currentCharacter = player:GetCharacter();
		local charactersTable = cwCfg:Get("mysql_characters_table"):Get();
		local schemaFolder = cwKernel:GetSchemaFolder();
		local unixTime = os.time();
		local steamID = player:SteamID();
		
		if (!character) then
			character = player:GetCharacter();
		end;
		
		local queryObj = cwDatabase:Update(charactersTable);
			queryObj:AddWhere("_Schema = ?", schemaFolder);
			queryObj:AddWhere("_SteamID = ?", steamID);
			queryObj:AddWhere("_CharacterID = ?", character.characterID);
			queryObj:SetValue("_RecognisedNames", self:GetCharacterRecognisedNamesString(player, character));
			queryObj:SetValue("_Attributes", cwJson:Encode(character.attributes));
			queryObj:SetValue("_LastPlayed", unixTime);
			queryObj:SetValue("_SteamName", player:SteamName());
			queryObj:SetValue("_Faction", character.faction);
			queryObj:SetValue("_Gender", character.gender);
			queryObj:SetValue("_Schema", character.schema);
			queryObj:SetValue("_Model", character.model);
			queryObj:SetValue("_Flags", character.flags);
			queryObj:SetValue("_Cash", character.cash);
			queryObj:SetValue("_Name", character.name);
		
			if (currentCharacter == character) then
				queryObj:SetValue("_Inventory", self:GetCharacterInventoryString(player, character));
				queryObj:SetValue("_Ammo", self:GetCharacterAmmoString(player, character));
				queryObj:SetValue("_Data", self:GetCharacterDataString(player, character));
			else
				queryObj:SetValue("_Inventory", cwJson:Encode(cwInventory:ToSaveable(character.inventory)));
				queryObj:SetValue("_Ammo", cwJson:Encode(character.ammo));
				queryObj:SetValue("_Data", cwJson:Encode(character.data));
			end;
		queryObj:Push();
		
		--[[ Save the player's data after pushing the update. --]]
		Clockwork.player:SaveData(player);
	end;
end;

--[[
	@codebase Shared
	@details A function to get the class of a player's active weapon.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for safe.
	@returns {Unknown}
--]]
function Clockwork.player:GetWeaponClass(player, safe)
	if (IsValid(player:GetActiveWeapon())) then
		return player:GetActiveWeapon():GetClass();
	else
		return safe;
	end;
end;

--[[
	@codebase Shared
	@details A function to call a player's think hook.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for setSharedVars.
	@param {Unknown} Missing description for curTime.
	@returns {Unknown}
--]]
function Clockwork.player:CallThinkHook(player, setSharedVars, curTime)
	local infoTable = player.cwInfoTable;

	infoTable.inventoryWeight = cwCfg:Get("default_inv_weight"):Get();
	infoTable.inventorySpace = cwCfg:Get("default_inv_space"):Get();
	infoTable.crouchedSpeed = player.cwCrouchedSpeed;
	infoTable.jumpPower = player.cwJumpPower;
	infoTable.walkSpeed = player.cwWalkSpeed;
	infoTable.isRunning = player:IsRunning();
	infoTable.isJogging = player:IsJogging();
	infoTable.runSpeed = player.cwRunSpeed;
	infoTable.wages = cwClass:Query(player:Team(), "wages", 0);
	
	if (!player:IsJogging(true)) then
		infoTable.isJogging = nil;
		player:SetSharedVar("IsJogMode", false);
	end;
	
	if (setSharedVars) then
		cwPlugin:Call("PlayerSetSharedVars", player, curTime);
		player.cwNextSetSharedVars = nil;
	end;
	
	cwPlugin:Call("PlayerThink", player, curTime, infoTable);
	player.cwNextThink = nil;
end;

--[[
	@codebase Shared
	@details A function to get a player's wages.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetWages(player)
	return player:GetSharedVar("Wages");
end;

--[[
	@codebase Shared
	@details A function to set a character's flags.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:SetFlags(player, flags)
	self:TakeFlags(player, player:GetFlags());
	self:GiveFlags(player, flags);
end;

--[[
	@codebase Shared
	@details A function to set a player's flags.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for flags.
	@returns {Unknown}
--]]
function Clockwork.player:SetPlayerFlags(player, flags)
	self:TakePlayerFlags(player, player:GetPlayerFlags());
	self:GivePlayerFlags(player, flags);
end;

--[[
	@codebase Shared
	@details A function to set a player's rank within their faction.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for rank.
	@returns {Unknown}
--]]
function Clockwork.player:SetFactionRank(player, rank)
	if (rank) then
		local faction = cwFaction:FindByID(player:GetFaction());

		if (faction and istable(faction.ranks)) then
			for k, v in pairs(faction.ranks) do
				if (k == rank) then
					player:SetCharacterData("FactionRank", k);

					if (v.class and cwClass:GetAll()[v.class]) then
						cwClass:Set(player, v.class);
					end;

					if (v.model) then
						player:SetModel(v.model);
					end;

					if (istable(v.weapons)) then
						for k, v in pairs(v.weapons) do
							self:GiveSpawnWeapon(player, v);
						end;
					end;

					break;
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function which returns the unique ID of any diseases a player has.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetDiseases(player)
	local diseases = player:GetCharacterData("Diseases");

	if (diseases and istable(diseases)) then
		return diseases;
	else
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to get if a player has any diseases.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:HasDiseases(player)
	local diseases = self:GetDiseases(player);

	return (#diseases > 0);
end;

--[[
	@codebase Shared
	@details A function which returns the unique ID and callbacks of any symptoms a player suffers.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetSymptoms(player)
	local diseases = self:GetDiseases(player);
	local symptoms = {};

	for k, v in pairs(diseases) do
		if (Clockwork.disease:IsValid(v)) then
			local diseaseSymptoms = Clockwork.disease:GetSymptoms(v);

			for k2, v2 in pairs(diseaseSymptoms) do
				symptoms[k2] = v2;
			end;
		end;
	end;

	return symptoms;
end;

--[[
	@codebase Shared
	@details A function which gives a player a disease.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.player:AddDisease(player, uniqueID)
	if (uniqueID) then
		if (Clockwork.disease:IsValid(uniqueID)) then
			local diseases = self:GetDiseases(player);

			table.insert(diseases, uniqueID);

			player:SetCharacterData("Diseases", diseases);
		else
			ErrorNoHalt("Attempting to give player invalid disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to give player nil disease.");
	end;
end;

--[[
	@codebase Shared
	@details A function which cures a player of all diseases.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:CureAll(player)
	player:SetCharacterData("Diseases", {});
end;

--[[
	@codebase Shared
	@details A function which cures a player of a disease.
	@param {Unknown} Missing description for player.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.player:Cure(player, uniqueID)
	if (uniqueID) then
		if (Clockwork.disease:IsValid(uniqueID)) then
			local diseases = self:GetDiseases(player);

			table.RemoveByValue(diseases, uniqueID);

			player:SetCharacterData("Diseases", diseases);
		else
			ErrorNoHalt("Attempting to cure of invalid disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to cure of nil disease.");
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player's global flags.
	@param {Unknown} Missing description for player.
	@returns {Unknown}
--]]
function Clockwork.player:GetPlayerFlags(player)
	return player:GetData("Flags") or "";
end;

end;

Clockwork.player.playerData = Clockwork.player.playerData or {};
Clockwork.player.characterData = Clockwork.player.characterData or {};

--[[
	@codebase Shared
	@details Add a new character data type that can be synced over the network.
	@param {String} The name of the data type (can be pretty much anything.)
	@param {Number} The type of the object (must be a type of NWTYPE_* enum).
	@param {Mixed} The default value of the data type.
	@param {Bool} Whether or not the data is networked to the player only (defaults to false.)
	@param {Function} Alter the value that gets networked.
--]]
function Clockwork.player:AddCharacterData(name, nwType, default, playerOnly, callback)
	Clockwork.player.characterData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	};
end;

--[[
	@codebase Shared
	@details Add a new player data type that can be synced over the network.
	@param {String} The name of the data type (can be pretty much anything.)
	@param {Number} The type of the object (must be a type of NWTYPE_* enum).
	@param {Mixed} The default value of the data type.
	@param {Function} Alter the value that gets networked.
	@param {Bool} Whether or not the data is networked to the player only (defaults to false.)
--]]
function Clockwork.player:AddPlayerData(name, nwType, default, playerOnly, callback)
	Clockwork.player.playerData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	};
end;

--[[
	@codebase Shared
	@details A function to get a player's rank within their faction.
	@param {Userdata} The player whose faction rank you are trying to obtain.
--]]
function Clockwork.player:GetFactionRank(player, character)
	if (character) then
		local faction = Clockwork.faction:FindByID(character.faction);
		
		if (faction and istable(faction.ranks)) then
			local rank;
			
			for k, v in pairs(faction.ranks) do
				if (k == character.data["FactionRank"]) then
					rank = v;
					break;
				end;
			end;
			
			return character.data["FactionRank"], rank;
		end;
	else
		local faction = Clockwork.faction:FindByID(player:GetFaction());
		
		if (faction and istable(faction.ranks)) then
			local rank;
			
			for k, v in pairs(faction.ranks) do
				if (k == player:GetCharacterData("FactionRank")) then
					rank = v;
					break;
				end;
			end;
			
			return player:GetCharacterData("FactionRank"), rank;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player can promote the target.
	@param {Userdata} The player whose permissions you are trying to check.
	@param {Userdata} The player who may be promoted.
--]]
function Clockwork.player:CanPromote(player, target)
	local stringRank, rank = Clockwork.player:GetFactionRank(player);

	if (rank) then
		if (rank.canPromote) then
			local stringTargetRank, targetRank = Clockwork.player:GetFactionRank(target);
			local highestRank, rankTable = Clockwork.faction:GetHighestRank(player:Faction()).position;

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canPromote <= targetRank.position);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player can demote the target.
	@param {Userdata} The player whose permissions you are trying to check.
	@param {Userdata} The player who may be demoted.
--]]
function Clockwork.player:CanDemote(player, target)
	local stringRank, rank = Clockwork.player:GetFactionRank(player);

	if (rank) then
		if (rank.canDemote) then
			local stringTargetRank, targetRank = Clockwork.player:GetFactionRank(target);
			local lowestRank, rankTable = Clockwork.faction:GetLowestRank(player:Faction()).position;

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canDemote <= targetRank.position);
			end;
		end;
	end;
end;
