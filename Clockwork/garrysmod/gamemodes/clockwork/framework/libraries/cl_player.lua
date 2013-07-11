--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local CurTime = CurTime;
local EyePos = EyePos;
local pairs = pairs;
local type = type;
local player = player;
local string = string;
local table = table;
local util = util;

Clockwork.player = Clockwork.kernel:NewLibrary("Player");

-- A function to get whether the local player can hold a weight.
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

-- A function to get the maximum amount of weight the local player can carry.
function Clockwork.player:GetMaxWeight()
	local itemsList = Clockwork.inventory:GetAsItemsList(
		Clockwork.inventory:GetClient()
	);
	local weight = Clockwork.Client:GetSharedVar(
		"InvWeight", Clockwork.config:Get("default_inv_weight"):Get()
	);
	
	for k, v in pairs(itemsList) do
		local addInvSpace = v("addInvSpace");
		
		if (addInvSpace) then
			weight = weight + addInvSpace;
		end;
	end;
	
	return weight;
end;

-- A function to find a player by an identifier.
function Clockwork.player:FindByID(identifier)
	for k, v in pairs(player.GetAll()) do
		if (v:HasInitialized() and (v:SteamID() == identifier
		or string.find(string.lower(v:Name()), string.lower(identifier), 1, true))) then
			return v;
		end;
	end;
end;

-- A function to get the local player's clothes data.
function Clockwork.player:GetClothesData()
	return Clockwork.ClothesData;
end;

-- A function to get the local player's accessory data.
function Clockwork.player:GetAccessoryData()
	return Clockwork.AccessoryData;
end;

-- A function to get the local player's clothes item.
function Clockwork.player:GetClothesItem()
	local clothesData = self:GetClothesData();

	if (clothesData.itemID != nil and clothesData.uniqueID != nil) then
		return Clockwork.inventory:FindItemByID(
			Clockwork.inventory:GetClient(),
			clothesData.uniqueID, clothesData.itemID
		);
	end;
end;

-- A function to get whether the local player is wearing clothes.
function Clockwork.player:IsWearingClothes()
	return (self:GetClothesItem() != nil);
end;

-- A function to get whether the local player has an accessory.
function Clockwork.player:HasAccessory(uniqueID)
	local accessoryData = self:GetAccessoryData();
	
	for k, v in pairs(accessoryData) do
		if (string.lower(v) == string.lower(uniqueID)) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to get whether the local player is wearing an accessory.
function Clockwork.player:IsWearingAccessory(itemTable)
	local accessoryData = self:GetAccessoryData();
	local itemID = itemTable("itemID");
	
	if (accessoryData[itemID]) then
		return true;
	else
		return false;
	end;
end;

-- A function to get whether the local player is wearing an item.
function Clockwork.player:IsWearingItem(itemTable)
	local clothesItem = self:GetClothesItem();
	return (clothesItem and clothesItem:IsTheSameAs(itemTable));
end;

-- A function to get whether a player is noclipping.
function Clockwork.player:IsNoClipping(player)
	if (player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle()) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function Clockwork.player:IsAdmin(player)
	if (self:HasFlags(player, "o")) then
		return true;
	end;
end;

-- A function to get whether the local player's data has streamed.
function Clockwork.player:HasDataStreamed()
	return Clockwork.DataHasStreamed;
end;

-- A function to get whether a player can hear another player.
function Clockwork.player:CanHearPlayer(player, target, allowance)
	if (Clockwork.config:Get("messages_must_see_player"):Get()) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;
	
-- A function to get whether the target recognises the local player.
function Clockwork.player:DoesTargetRecognise()
	if (Clockwork.config:Get("recognise_system"):Get()) then
		return Clockwork.Client:GetSharedVar("TargetKnows");
	else
		return true;
	end;
end;

-- A function to get a player's real trace.
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

-- A function to get the local player's action.
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

-- A function to get the local player's maximum characters.
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

-- A function to get whether a player's weapon is raised.
function Clockwork.player:GetWeaponRaised(player)
	return player:GetSharedVar("IsWepRaised");
end;

-- A function to get a player's unrecognised name.
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

-- A function to get whether a player can see an NPC.
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

-- A function to get whether a player can see a player.
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

-- A function to get whether a player can see an entity.
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

-- A function to get whether a player can see a position.
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

-- A function to get a player's wages name.
function Clockwork.player:GetWagesName(player)
	return Clockwork.class:Query(player:Team(), "wagesName", Clockwork.config:Get("wages_name"):Get());
end;

-- A function to check whether a player is ragdolled
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

-- A function to get whether the local player recognises another player.
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

-- A function to get a player's character key.
function Clockwork.player:GetCharacterKey(player)
	if (IsValid(player)) then
		return player:GetSharedVar("Key");
	end;
end;

-- A function to get a player's ragdoll state.
function Clockwork.player:GetRagdollState(player)
	if (player:GetSharedVar("IsRagdoll") == 0) then
		return false;
	else
		return player:GetSharedVar("IsRagdoll");
	end;
end;

-- A function to get a player's physical description.
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

-- A function to get the local player's wages.
function Clockwork.player:GetWages()
	return Clockwork.Client:GetSharedVar("Wages");
end;

-- A function to get the local player's cash.
function Clockwork.player:GetCash()
	return Clockwork.Client:GetSharedVar("Cash");
end;

-- A function to get a player's ragdoll entity.
function Clockwork.player:GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("Ragdoll");
	
	if (IsValid(ragdollEntity)) then
		return ragdollEntity;
	end;
end;

-- A function to get a player's default skin.
function Clockwork.player:GetDefaultSkin(player)
	local model, skin = Clockwork.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- A function to get a player's default model.
function Clockwork.player:GetDefaultModel(player)
	local model, skin = Clockwork.class:GetAppropriateModel(player:Team(), player);
	return model;
end;

-- A function to check if a player has any flags.
function Clockwork.player:HasAnyFlags(player, flags, bByDefault)
	local playerFlags = player:GetSharedVar("Flags")
	
	if (playerFlags != "") then
		if (Clockwork.class:HasAnyFlags(player:Team(), flags) and !bByDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.sub(flags, i, i);
			local bSuccess = true;
			
			if (!bByDefault) then
				local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						return true;
					end;
				else
					bSuccess = nil;
				end;
			end;
			
			if (bSuccess) then
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

-- A function to check if a player has access.
function Clockwork.player:HasFlags(player, flags, bByDefault)
	local playerFlags = player:GetSharedVar("Flags")
	
	if (playerFlags != "") then
		if (Clockwork.class:HasFlags(player:Team(), flags) and !bByDefault) then
			return true;
		end;
		
		for i = 1, #flags do
			local flag = string.sub(flags, i, i);
			local bSuccess;
			
			if (!bByDefault) then
				local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
				
				if (hasFlag != false) then
					if (hasFlag) then
						bSuccess = true;
					end;
				else
					return;
				end;
			end;
			
			if (!bSuccess) then
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

-- A function to set a shared variable for a player.
function Clockwork.player:SetSharedVar(player, key, value)
	if (IsValid(player)) then
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		
		if (!sharedVars or not sharedVars[key]) then
			player:SetNetworkedVar(key);
			return;
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData) then
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
				else
					player:SetNetworkedVar(key, value);
				end;
			end;
		else
			player:SetNetworkedVar(key, value);
		end;
	end;
end;

-- A function to get a player's shared variable.
function Clockwork.player:GetSharedVar(player, key)
	if (IsValid(player)) then
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		
		if (!sharedVars or not sharedVars[key]) then
			return player:GetNetworkedVar(key);
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData) then
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
				else
					return player:GetNetworkedVar(key);
				end;
			end;
		else
			return player:GetNetworkedVar(key);
		end;
	end;
end;

-- A function to get whether the local player is drunk.
function Clockwork.player:GetDrunk()
	local isDrunk = Clockwork.Client:GetSharedVar("IsDrunk");
	
	if (isDrunk and isDrunk > 0) then
		return isDrunk;
	end;
end;