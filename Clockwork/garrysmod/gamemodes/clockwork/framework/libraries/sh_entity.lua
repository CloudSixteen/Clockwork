--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local GetViewEntity = GetViewEntity;
local EffectData = EffectData;
local tostring = tostring;
local IsValid = IsValid;
local CurTime = CurTime;
local Color = Color;
local Angle = Angle;
local type = type;
local string = string;
local timer = timer;
local table = table;
local math = math;
local ents = ents;
local util = util;

Clockwork.entity = Clockwork.kernel:NewLibrary("Entity");

if (CLIENT) then
	-- A function to get a weapon's muzzle position.
	function Clockwork.entity:GetMuzzlePos(weapon, attachment)
		if (!IsValid(weapon)) then
			return vector_origin, Angle(0, 0, 0);
		end;

		local origin = weapon:GetPos();
		local angle = weapon:GetAngles();
		
		if (weapon:IsWeapon() and weapon:IsCarriedByLocalPlayer()) then
			local owner = weapon:GetOwner();
			
			if (IsValid(owner) and GetViewEntity() == owner) then
				local viewmodel = owner:GetViewModel();
				
				if (IsValid(viewmodel)) then
					weapon = viewmodel;
				end;
			end;
		end;

		local attachment = weapon:GetAttachment(attachment or 1);
		
		if (!attachment) then
			return origin, angle;
		end;
		
		return attachment.Pos, attachment.Ang;
	end;
end;

-- A function to check if an entity is a door.
function Clockwork.entity:IsDoor(entity)
	if (IsValid(entity)) then
		local class = entity:GetClass();
		local model = entity:GetModel();
		
		if (class and model) then
			class = string.lower(class);
			model = string.lower(model);
			
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
			or (class == "prop_dynamic" and string.find(model, "door")) or class == "func_movelinear") then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether an entity is decaying.
function Clockwork.entity:IsDecaying(entity)
	return entity.cwIsDecaying;
end;

-- A function to get a door entity's partners.
function Clockwork.entity:GetDoorPartners(entity)
	local doorPartners = {entity};
	local doorEntities = ents.FindByClass(entity:GetClass());
	local doorAngles = entity:GetAngles();
	local doorModel = entity:GetModel();
	local doorSkin = entity:GetSkin();
	local doorPos = entity:GetPos();
	
	for k, v in pairs(doorEntities) do
		if (entity != v and v:GetModel() == doorModel
		and v:GetSkin() == doorSkin) then
			local tempPosition = v:GetPos();
			local distance = tempPosition:Distance(doorPos);
			
			if (distance >= 90 and distance <= 100
			and v:GetAngles() != doorAngles) then
				if (math.floor(tempPosition.z) == math.floor(doorPos.z)) then
					doorPartners[#doorPartners + 1] = v;
				end;
			end;
		end;
	end;
	
	return doorPartners;
end;

-- A function to check if an entity is in a box.
function Clockwork.entity:IsInBox(entity, minimum, maximum)
	local position = entity:GetPos();
	
	if (entity:IsPlayer() or entity:IsNPC()) then
		position = entity:GetShootPos();
	end;
	
	if ((position.x >= math.min(minimum.x, maximum.x) and position.x <= math.max(minimum.x, maximum.x))
	and (position.y >= math.min(minimum.y, maximum.y) and position.y <= math.max(minimum.y, maximum.y))
	and (position.z >= math.min(minimum.z, maximum.z) and position.z <= math.max(minimum.z, maximum.z))) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a ragdoll entity's pelvis position.
function Clockwork.entity:GetPelvisPosition(entity)
	local position = entity:GetPos();
	local physBone = entity:LookupBone("ValveBiped.Bip01_Pelvis");

	if (physBone) then
		local bonePosition = entity:GetBonePosition(physBone);
		
		if (bonePosition) then
			position = bonePosition;
		end;
	end;
	
	return position;
end;

-- A function to get whether an entity can see a position.
function Clockwork.entity:CanSeePosition(entity, position, iAllowance, tIgnoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld(entity:OBBCenter());
	trace.endpos = position;
	trace.filter = {entity};
	
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

-- A function to get whether an entity can see an NPC.
function Clockwork.entity:CanSeeNPC(entity, target, iAllowance, tIgnoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld(entity:OBBCenter());
	trace.endpos = target:GetShootPos();
	trace.filter = {entity, target};
	
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

-- A function to get whether an entity can see a player.
function Clockwork.entity:CanSeePlayer(entity, target, iAllowance, tIgnoreEnts)
	if (target:GetEyeTraceNoCursor().Entity == entity) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = entity:LocalToWorld(entity:OBBCenter());
		trace.endpos = target:GetShootPos();
		trace.filter = {entity, target};
		
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
end;

-- A function to get whether an entity can see an entity.
function Clockwork.entity:CanSeeEntity(entity, target, iAllowance, tIgnoreEnts)
	local trace = {};
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld(entity:OBBCenter());
	trace.endpos = target:LocalToWorld(target:OBBCenter());
	trace.filter = {entity, target};
	
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

-- A function to get whether a door is unownable.
function Clockwork.entity:IsDoorUnownable(entity)
	return entity:GetNetworkedBool("Unownable");
end;

-- A function to get whether a door is false.
function Clockwork.entity:IsDoorFalse(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "false";
end;

-- A function to get whether a door is hidden.
function Clockwork.entity:IsDoorHidden(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "hidden";
end;

-- A function to get a door's name.
function Clockwork.entity:GetDoorName(entity)
	return entity:GetNetworkedString("Name");
end;

-- A function to get a door's text.
function Clockwork.entity:GetDoorText(entity)
	return entity:GetNetworkedString("Text");
end;

-- A function to get whether an entity is a player ragdoll.
function Clockwork.entity:IsPlayerRagdoll(entity)
	local player = entity:GetNetworkedEntity("Player");
	
	if (IsValid(player)) then
		if (player:GetRagdollEntity() == entity) then
			return true;
		end;
	end;
end;

-- A function to get an entity's player.
function Clockwork.entity:GetPlayer(entity)
	local player = entity:GetNetworkedEntity("Player");
	
	if (IsValid(player)) then
		return player;
	elseif (entity:IsPlayer()) then
		return entity;
	end;
end;

-- A function to get whether an entity is interactable.
function Clockwork.entity:IsInteractable(entity)
	local class = entity:GetClass();
	
	if (string.find(class, "prop_")) then
		if (entity:HasSpawnFlags(SF_PHYSPROP_MOTIONDISABLED) or entity:HasSpawnFlags(SF_PHYSPROP_PREVENT_PICKUP)) then
			return false;
		end;
	end;
	
	if (entity:IsNPC() or entity:IsPlayer() or string.find(class, "prop_dynamic")) then
		return false;
	end;
	
	if (class == "func_physbox" and entity:HasSpawnFlags(SF_PHYSBOX_MOTIONDISABLED)) then
		return false;
	end
	
	if (class != "func_physbox" and string.find(class, "func_")) then
		return false;
	end;
	
	if (self:IsDoor(entity)) then
		return false;
	end;
	
	return true;
end;

-- A function to get whether an entity is a physics entity.
function Clockwork.entity:IsPhysicsEntity(entity)
	local class = string.lower(entity:GetClass());
	
	if (class == "prop_physicsmultiplayer" or class == "prop_physics") then
		return true;
	end;
end;

-- A function to get whether an entity is a pod.
function Clockwork.entity:IsPodEntity(entity)
	local entityModel = string.lower(entity:GetModel());
	
	if (string.find(entityModel, "prisoner")) then
		return true;
	end;
end;

-- A function to get whether an entity is a chair.
function Clockwork.entity:IsChairEntity(entity)
	if (entity:GetModel()) then
		local entityModel = string.lower(entity:GetModel());
		
		if (string.find(entityModel, "chair") or string.find(entityModel, "seat")) then
			return true;
		end;
	end;
end;

if (CLIENT) then
	function Clockwork.entity:HasFetchedItemData(entity)
		return (entity.cwFetchedItemData == true);
	end;
	
	-- A function to fetch the entity's item table.
	function Clockwork.entity:FetchItemTable(entity)
		return entity.cwItemTable;
	end;
	
	-- A function to fetch the entity's item data.
	function Clockwork.entity:FetchItemData(entity)
		local curTime = CurTime();
		
		if (!entity.m_iNextFetchItemData) then
			entity.m_iNextFetchItemData = 0;
		end;
	
		if (curTime > entity.m_iNextFetchItemData) then
			entity.m_iNextFetchItemData = curTime + 4;
			
			if (entity:GetClass() == "prop_vehicle_jeep") then
				Clockwork.datastream:Start("FetchItemData", entity:EntIndex());
			elseif (!Clockwork.entity:IsChairEntity(entity)) then
				Clockwork.datastream:Start("FetchItemData", entity);
			end;
		end;
	end;
	
	Clockwork.datastream:Hook("FetchItemData", function(data)
		if (type(data.entity) == "number") then
			data.entity = ents.GetByIndex(data.entity);
		end;
		
		if (IsValid(data.entity)) then
			data.entity.cwFetchedItemData = true;
			data.entity.cwItemTable = Clockwork.item:CreateInstance(
				data.definition.index, data.definition.itemID, data.definition.data
			);
		end;
	end);
else
	Clockwork.datastream:Hook("FetchItemData", function(player, data)
		local entity = data;
		
		if (type(data) == "number") then
			entity = ents.GetByIndex(data);
		end;

		if (!IsValid(entity)) then return; end;
		
		--[[
			Find out what the entity's item table is
			by trying a couple of common methods.
		--]]
		
		local itemTable = entity.cwItemTable;
		
		if (entity.GetItemTable) then
			itemTable = entity:GetItemTable();
		end;
		
		if (itemTable) then
			local definition = Clockwork.item:GetDefinition(itemTable, true);
			
			Clockwork.datastream:Start(player, "FetchItemData", {
				definition = definition,
				entity = data
			});
		end;
	end);
	
	-- A function to dissolve an entity using a Source effect.
	function Clockwork.entity:Dissolve(entity, dissolveType, iRemoveDelay, attacker)
		local dissolver = ents.Create("env_entity_dissolver");
		local oldName = entity:GetName();
		
		if (!oldName or oldName == "") then
			entity:SetName("dissolve_"..entity:EntIndex());
		end;
		
		dissolver:SetKeyValue("dissolvetype", dissolveType);
		dissolver:SetKeyValue("magnitude", 0);
		dissolver:SetPos(entity:GetPos());
		
		if (IsValid(attacker)) then
			dissolver:SetPhysicsAttacker(attacker);
		end;
		
		dissolver:Spawn();
		
		--[[ Dissolve the entity now using Fire commands. --]]
		dissolver:Fire("Dissolve", entity:GetName(), 0);
		dissolver:Fire("Kill", "", 0.1);
		dissolver:Remove();
		
		--[[ Give the entity its old name back! --]]
		entity:SetName(oldName);
		
		if (iRemoveDelay) then
			timer.Simple(iRemoveDelay, function()
				if (IsValid(entity)) then
					entity:Remove();
				end;
			end);
		end;
		
		return dissolver;
	end;
	
	-- A function to temporarily set a door's speed to fast.
	function Clockwork.entity:SetDoorSpeedFast(entity)
		local curTime = CurTime();
		local iSpeed = entity:GetSaveTable().speed;

		if (Clockwork.entity:IsDoor(entity) and iSpeed
		and (!entity.cwNextDoorSpeed or curTime >= entity.cwNextDoorSpeed)) then
			entity:Fire("SetSpeed", tostring(iSpeed * 3), 0);
			
			timer.Simple(1, function()
				if (IsValid(entity)) then
					entity:Fire("SetSpeed", tostring(iSpeed), 0);
				end;
			end);
			
			entity.cwNextDoorSpeed = curTime + 2;
		end;
	end;
	
	-- A function to blast down a door off its hinges.
	function Clockwork.entity:BlastDownDoor(entity, force, attacker)
		entity.cwIsBustedDown = true;
		entity:SetNotSolid(true);
		entity:DrawShadow(false);
		entity:SetNoDraw(true);
		entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
		entity:Fire("Unlock", "", 0);
		
		if (IsValid(entity.cwCombineLock)) then
			entity.cwCombineLock:Explode();
			entity.cwCombineLock:Remove();
		end;
		
		if (IsValid(entity.cwBreachEnt)) then
			entity.cwBreachEnt:BreachEntity();
		end;
		
		local fakeDoor = ents.Create("prop_physics");
		
		fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
		fakeDoor:SetAngles(entity:GetAngles());
		fakeDoor:SetModel(entity:GetModel());
		fakeDoor:SetSkin(entity:GetSkin());
		fakeDoor:SetPos(entity:GetPos());
		fakeDoor:Spawn();
		
		Clockwork.entity:Decay(fakeDoor, 300);
		
		Clockwork.kernel:CreateTimer("ResetDoor"..entity:EntIndex(), 300, 1, function()
			if (IsValid(door)) then
				entity.cwIsBustedDown = nil;
				entity:SetNotSolid(false);
				entity:DrawShadow(true);
				entity:SetNoDraw(false);
			end;
		end);
		
		local physicsObject = fakeDoor:GetPhysicsObject();
		if (!IsValid(physicsObject)) then return; end;
		
		if (IsValid(attacker)) then
			local position = entity:GetPos() - attacker:GetPos();
				position:Normalize();
			force = position * 10000;
		end;
		
		if (force) then
			physicsObject:ApplyForceCenter(force);
		end;
	end;
end;

-- A function to get an entity's door state.
function Clockwork.entity:GetDoorState(entity)
	return entity:GetSaveTable().m_eDoorState or DOOR_STATE_CLOSED;
end;

-- A function to get whether a door is locked.
function Clockwork.entity:IsDoorLocked(entity)
	return (entity:GetSaveTable().m_bLocked == true);
end;

if (SERVER) then
	function Clockwork.entity:OpenDoor(entity, delay, bUnlock, bSound, origin, fSpeed)
		if (self:IsDoor(entity)) then
			if (bUnlock) then
				entity:Fire("Unlock", "", delay);
				delay = delay + 0.025;
				
				if (bSound) then
					entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
				end;
			end;
			
			if (entity:GetClass() == "prop_dynamic") then
				entity:Fire("SetAnimation", "open", delay);
				entity:Fire("SetAnimation", "close", delay + 5);
			elseif (origin and string.lower(entity:GetClass()) == "prop_door_rotating") then
				local target = ents.Create("info_target");
					target:SetName(tostring(target));
					target:SetPos(origin);
					target:Spawn();
				entity:Fire("OpenAwayFrom", tostring(target), delay);
				
				timer.Simple(delay + 1, function()
					if (IsValid(target)) then
						target:Remove();
					end;
				end);
			else
				entity:Fire("Open", "", delay);
			end;
		end;
	end;
	
	-- A function to bash in a door entity.
	function Clockwork.entity:BashInDoor(entity, eBasher)
		local curTime = CurTime();
	
		if (self:GetDoorState(entity) != DOOR_STATE_CLOSED) then
			return;
		end;
		
		local oldCollisionGroup = entity:GetCollisionGroup();
		
		Clockwork.entity:SetDoorSpeedFast(entity);
		Clockwork.entity:OpenDoor(
			entity, 0, nil, nil, eBasher:GetPos()
		);
		
		entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
		entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
		entity.cwNextBashDoor = curTime + 3;
		
		Clockwork.entity:ReturnCollisionGroup(
			entity, oldCollisionGroup
		);
	end;
	
	-- A function to make an entity safe.
	function Clockwork.entity:MakeSafe(entity, bPhysgunProtect, tToolProtect, bFreezeEntity)
		if (bPhysgunProtect) then
			entity.PhysgunDisabled = true;
		end;
		
		if (tToolProtect) then
			entity.CanTool = function(entity, player, trace, tool)
				if (type(tToolProtect) == "table") then
					return !table.HasValue(tToolProtect, tool);
				else
					return false;
				end;
			end;
		end;
		
		if (bFreezeEntity) then
			if (IsValid(entity:GetPhysicsObject())) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
	end;
	
	-- A function to statue a ragdoll.
	function Clockwork.entity:StatueRagdoll(entity, forceLimit)
		local bones = entity:GetPhysicsObjectCount()
		
		if (!entity.cwStatueInfo) then
			entity.cwStatueInfo = {
				Welds = {}
			};
		end;
		
		if (!forceLimit) then
			forceLimit = 0;
		end;
	
		for bone = 1, bones do
			local boneOne = bone - 1;
			local boneTwo = bones - bone;
			
			if (!entity.cwStatueInfo.Welds[boneTwo]) then
				local constraintOne = constraint.Weld(entity, entity, boneOne, boneTwo, forceLimit);
				
				if (constraintOne) then
					entity.cwStatueInfo.Welds[boneOne] = constraintOne
				end;
			end;
			
			local constraintTwo = constraint.Weld(entity, entity, boneOne, 0, forceLimit);
			
			if (constraintTwo) then
				entity.cwStatueInfo.Welds[boneOne + bones] = constraintTwo;
			end;
			
			local effectData = EffectData();
				effectData:SetScale(1);
				effectData:SetOrigin(entity:GetPhysicsObjectNum(boneOne):GetPos());
				effectData:SetMagnitude(1);
			util.Effect("GlassImpact", effectData, true, true);
		end;
	end;
	
	-- A function to drop items and cash.
	function Clockwork.entity:DropItemsAndCash(inventory, cash, position, entity)
		if (!Clockwork.inventory:IsEmpty(inventory)) then
			for k, v in pairs(inventory) do
				for k2, v2 in pairs(v) do
					local itemEntity = self:CreateItem(nil, v2, position);
					
					if (IsValid(itemEntity) and IsValid(entity)) then
						self:CopyOwner(entity, itemEntity);
					end;
				end;
			end;
		end;
			
		if (cash and cash > 0) then
			self:CreateCash(nil, cash, position);
		end;
	end;
	
	-- A function to make an entity into a ragdoll.
	function Clockwork.entity:MakeIntoRagdoll(entity, force, overrideVelocity, overrideAngles)
		local velocity = entity:GetVelocity() * 1.5;
		local ragdoll = ents.Create("prop_ragdoll");
		
		if (overrideVelocity) then
			velocity = overrideVelocity;
		end;
		
		if (overrideAngles) then
			ragdoll:SetAngles(overrideAngles);
		else
			ragdoll:SetAngles(entity:GetAngles());
		end;
		
		ragdoll:SetMaterial(entity:GetMaterial());
		ragdoll:SetAngles(entity:GetAngles() - Angle(0, -45, 0));
		ragdoll:SetColor(entity:GetColor());
		ragdoll:SetModel(entity:GetModel());
		ragdoll:SetSkin(entity:GetSkin());
		ragdoll:SetPos(entity:GetPos());
		ragdoll:Spawn();
		
		if (IsValid(ragdoll)) then
			local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
			
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local physicsObject = ragdoll:GetPhysicsObjectNum(i);
				local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
				local position, angle = entity:GetBonePosition(boneIndex);
				
				if (IsValid(physicsObject)) then
					physicsObject:SetPos(position);
					physicsObject:SetAngles(angle);
					
					if (boneIndex == headIndex) then
						physicsObject:SetVelocity(velocity * 2);
					else
						physicsObject:SetVelocity(velocity);
					end;
					
					if (force) then
						if (boneIndex == headIndex) then
							physicsObject:ApplyForceCenter(force * 2);
						else
							physicsObject:ApplyForceCenter(force);
						end;
					end;
				end;
			end;
		end;
		
		if (entity:IsOnFire()) then
			ragdoll:Ignite(8, 0);
		end;
		
		return ragdoll;
	end;
	
	-- A function to get whether a door is unsellable.
	function Clockwork.entity:IsDoorUnsellable(door)
		return door.unsellable;
	end;
	
	-- A function to set a door's parent.
	function Clockwork.entity:SetDoorParent(door, parent)
		if (self:IsDoor(door)) then
			for k, v in pairs(self:GetDoorChildren(door)) do
				if (IsValid(v)) then
					self:SetDoorParent(v, false);
				end;
			end;
			
			if (IsValid(door.doorParent)) then
				if (door.doorParent.doorChildren) then
					door.doorParent.doorChildren[door] = nil;
				end;
			end;
			
			if (IsValid(parent) and self:IsDoor(parent)) then
				if (parent.doorChildren) then
					parent.doorChildren[door] = door;
				else
					parent.doorChildren = { [door] = door };
				end;
				
				door.doorParent = parent;
			else
				door.doorParent = nil;
			end;
			
			door.cwDoorSharedAxs = nil;
			door.cwDoorSharedTxt = nil;
		end;
	end;
	
	-- A function to get whether is a door is a parent.
	function Clockwork.entity:IsDoorParent(door)
		return table.Count(self:GetDoorChildren(door)) > 0;
	end;

	-- A function to get a door's parent.
	function Clockwork.entity:GetDoorParent(door)
		if (IsValid(door.doorParent)) then
			return door.doorParent;
		end;
	end;

	-- A function to get a door's children.
	function Clockwork.entity:GetDoorChildren(door)
		return door.doorChildren or {};
	end;
	
	-- A function to set a door as unownable.
	function Clockwork.entity:SetDoorUnownable(entity, unownable)
		if (self:IsDoor(entity)) then
			if (unownable) then
				entity:SetNetworkedBool("Unownable", true);
				
				if (self:GetOwner(entity)) then
					Clockwork.player:TakeDoor(self:GetOwner(entity), entity, true);
				elseif (self:HasOwner(entity)) then
					self:ClearProperty(entity);
				end;
			else
				entity:SetNetworkedBool("Unownable", false);
			end;
		end;
	end;
	
	-- A function to set whether a door is false.
	function Clockwork.entity:SetDoorFalse(entity, isFalse)
		if (self:IsDoor(entity)) then
			if (isFalse) then
				self:SetDoorUnownable(entity, true);
				self:SetDoorName(entity, "false");
			else
				self:SetDoorUnownable(entity, false);
				self:SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door is hidden.
	function Clockwork.entity:SetDoorHidden(entity, hidden)
		if (self:IsDoor(entity)) then
			if (hidden) then
				self:SetDoorUnownable(entity, true);
				self:SetDoorName(entity, "hidden");
			else
				self:SetDoorUnownable(entity, false);
				self:SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function Clockwork.entity:SetDoorSharedAccess(entity, sharedAccess)
		if (self:IsDoorParent(entity)) then
			entity.cwDoorSharedAxs = sharedAccess;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function Clockwork.entity:SetDoorSharedText(entity, sharedText)
		if (self:IsDoorParent(entity)) then
			entity.cwDoorSharedTxt = sharedText;
			
			if (sharedText) then
				for k, v in pairs(self:GetDoorChildren(entity)) do
					if (IsValid(v)) then
						 self:SetDoorText(v, self:GetDoorText(entity));
					end;
				end;
			end;
		end;
	end;
	
	-- A function to get whether a door has shared access.
	function Clockwork.entity:DoorHasSharedAccess(entity)
		return entity.cwDoorSharedAxs;
	end;
	
	-- A function to get whether a door has shared text.
	function Clockwork.entity:DoorHasSharedText(entity)
		return entity.cwDoorSharedTxt;
	end;
	
	-- A function to set a door's text.
	function Clockwork.entity:SetDoorText(entity, text)
		if (self:IsDoor(entity)) then
			if (self:IsDoorParent(entity)) then
				if (self:DoorHasSharedText(entity)) then
					for k, v in pairs(self:GetDoorChildren(entity)) do
						if (IsValid(v)) then
							 self:SetDoorText(v, text);
						end;
					end;
				end;
			end;
			
			if (text) then
				if (!string.find(string.gsub(string.lower(text), "%s", ""), "thisdoorcanbepurchased")) then
					entity:SetNetworkedString("Text", text);
				end;
			else
				entity:SetNetworkedString("Text", "");
			end;
		end;
	end;
	
	-- A function to set a door's name.
	function Clockwork.entity:SetDoorName(entity, name)
		if (self:IsDoor(entity)) then
			if (name) then
				entity:SetNetworkedString("Name", name);
			else
				entity:SetNetworkedString("Name", "");
			end;
		end;
	end;
	
	-- A function to set an entity's chair animations.
	function Clockwork.entity:SetChairAnimations(entity)
		if (!entity.VehicleTable) then
			local targetFaction = "prop_vehicle_prisoner_pod";
			
			if (entity:GetClass() == targetFaction) then
				local entityModel = string.lower(entity:GetModel());
				
				if (entityModel == "models/props_c17/furniturechair001a.mdl"
				or entityModel == "models/props_furniture/chair1.mdl") then
					entity:SetModel("models/nova/chair_wood01.mdl");
				elseif (entityModel == "models/props_c17/chair_office01a.mdl") then
					entity:SetModel("models/nova/chair_office01.mdl");
				elseif (entityModel == "models/props_combine/breenchair.mdl") then
					entity:SetModel("models/nova/chair_office02.mdl");
				elseif (entityModel == "models/props_interiors/furniture_chair03a.mdl"
				or entityModel == "models/props_wasteland/controlroom_chair001a.mdl") then
					entity:SetModel("models/nova/chair_plastic01.mdl");
				end;
				
				if (self:IsChairEntity(entity)) then
					local entityModel = string.lower(entity:GetModel());
					local vehicles = list.Get("Vehicles");
					-- local k2, v2;
					
					for k, v in pairs(vehicles) do
						local keyValues = v.KeyValues;
						local members = v.Members;
						local model = v.Model;
						local class = v.Class;
						
						if (string.lower(class) == targetFaction) then
							if (string.lower(model) == entityModel) then
								for k2, v2 in pairs(keyValues) do
									entity:SetKeyValue(k2, v2);
								end;
								
								entity.VehicleTable = v;
								entity.ClassOverride = class;
								
								table.Merge(entity, members);
								
								return true;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to set an entity's start angles.
	function Clockwork.entity:SetStartAngles(entity, angles)
		entity.cwStartAng = angles;
	end;
	
	-- A function to get an entity's start angles.
	function Clockwork.entity:GetStartAngles(entity)
		return entity.cwStartAng;
	end;
	
	-- A function to set an entity's start position.
	function Clockwork.entity:SetStartPosition(entity, position)
		entity.cwStartPos = position;
	end;
	
	-- A function to get an entity's start position.
	function Clockwork.entity:GetStartPosition(entity)
		return entity.cwStartPos;
	end;
	
	-- A function to stop an entity's collision group restore.
	function Clockwork.entity:StopCollisionGroupRestore(entity)
		Clockwork.kernel:DestroyTimer("CollisionGroup"..entity:EntIndex());
	end;
	
	-- A function to return an entity's collision group.
	function Clockwork.entity:ReturnCollisionGroup(entity, collisionGroup)
		if (IsValid(entity)) then
			local physicsObject = entity:GetPhysicsObject();
			local index = entity:EntIndex();
			
			if (IsValid(physicsObject)) then
				if (!physicsObject:IsPenetrating()) then
					entity:SetCollisionGroup(collisionGroup);
				else
					Clockwork.kernel:CreateTimer("CollisionGroup"..index, 1, 1, function()
						self:ReturnCollisionGroup(entity, collisionGroup);
					end);
				end;
			end;
		end;
	end;

	-- A function to set whether an entity is a map entity.
	function Clockwork.entity:SetMapEntity(entity, isMapEntity)
		if (isMapEntity) then
			Clockwork.Entities[entity] = entity;
		else
			Clockwork.Entities[entity] = nil;
		end;
	end;
	
	-- A function to get whether an entity is a map entity.
	function Clockwork.entity:IsMapEntity(entity)
		if (Clockwork.Entities[entity]) then
			return true;
		end;
	end;
	
	-- A function to make an entity flush with the ground.
	function Clockwork.entity:MakeFlushToGround(entity, position, normal)
		entity:SetPos(position + (entity:GetPos() - entity:NearestPoint(position - (normal * 512))));
	end;
	
	-- A function to make an entity disintegrate.
	function Clockwork.entity:Disintegrate(entity, delay, velocity, Callback)
		if (velocity) then
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if (IsValid(physicsObject)) then
						physicsObject:AddVelocity(velocity);
					end;
				end;
			elseif (IsValid(entity:GetPhysicsObject())) then
				entity:GetPhysicsObject():AddVelocity(velocity);
			end;
		end;
		
		self:Decay(entity, delay, Callback);
		
		if (velocity) then
			timer.Simple(math.min(1, delay / 2), function()
				if (IsValid(entity)) then
					entity:SetNotSolid(true);
					
					if (entity:GetClass() == "prop_ragdoll") then
						for i = 1, entity:GetPhysicsObjectCount() do
							local physicsObject = entity:GetPhysicsObjectNum(i);
							
							if (IsValid(physicsObject)) then
								physicsObject:EnableMotion(false);
							end;
						end;
					elseif (IsValid(entity:GetPhysicsObject())) then
						entity:GetPhysicsObject():EnableMotion(false);
					end;
				end;
			end);
		else
			entity:SetNotSolid(true);
			
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if (IsValid(physicsObject)) then
						physicsObject:EnableMotion(false);
					end;
				end;
			elseif (IsValid(entity:GetPhysicsObject())) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
		
		local effectData = EffectData();
			effectData:SetEntity(entity);
		util.Effect("entity_remove", effectData, true, true);
	end;
	
	-- A function to set an entity's player.
	function Clockwork.entity:SetPlayer(entity, player)
		entity:SetNetworkedEntity("Player", player);
	end;
	
	-- A function to make an entity decay.
	function Clockwork.entity:Decay(entity, seconds, Callback)
		local color = entity:GetColor();		
		local subtract = math.ceil(color.a / seconds);
		local index = tostring({});
		local alpha = color.a;
		
		if (!entity.cwIsDecaying) then
			entity.cwIsDecaying = index;
		end;
		
		self:SetPlayer(entity, NULL);
		index = entity.cwIsDecaying;
		
		Clockwork.kernel:CreateTimer("Decay"..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if (IsValid(entity)) then
				local color = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (color.a <= 0) then
					if (Callback) then Callback(); end;
					
					entity:Remove();
					Clockwork.kernel:DestroyTimer("Decay"..index);
				else
					entity:SetColor(Color(color.r, color.g, color.b, decayed));
				end;
			else
				Clockwork.kernel:DestroyTimer("Decay"..index);
			end;
		end);
	end;
	
	-- A function to create cash.
	function Clockwork.entity:CreateCash(ownerObj, cash, position, angles)
		if (Clockwork.config:Get("cash_enabled"):Get()) then
			local entity = ents.Create("cw_cash");
			
			if (type(ownerObj) == "table") then
				if (ownerObj.key and ownerObj.uniqueID) then
					Clockwork.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true);
				end;
			elseif (IsValid(ownerObj) and ownerObj:IsPlayer()) then
				Clockwork.player:GiveProperty(ownerObj, entity);
			end;
			
			if (!angles) then
				angles = Angle(0, 0, 0);
			end;
			
			entity:SetPos(position);
			entity:SetAngles(angles);
			entity:Spawn();
			
			if (IsValid(entity)) then
				entity:SetAmount(math.Round(cash));
				
				return entity;
			end;
		end;
	end;
	
	-- A function to create generator.
	function Clockwork.entity:CreateGenerator(ownerObj, class, position, angles)
		local entity = ents.Create(class);
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(ownerObj) == "table") then
			if (ownerObj.key and ownerObj.uniqueID) then
				Clockwork.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true);
			end;
		elseif (IsValid(ownerObj) and ownerObj:IsPlayer()) then
			Clockwork.player:GiveProperty(ownerObj, entity);
		end;
		
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create a shipment.
	function Clockwork.entity:CreateShipment(ownerObj, uniqueID, batch, position, angles)
		local entity = ents.Create("cw_shipment");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(ownerObj) == "table") then
			if (ownerObj.key and ownerObj.uniqueID) then
				Clockwork.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true);
			end;
		elseif (IsValid(ownerObj) and ownerObj:IsPlayer()) then
			Clockwork.player:GiveProperty(ownerObj, entity);
		end;
		
		entity:SetItemTable(uniqueID, batch);
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create an item.
	function Clockwork.entity:CreateItem(ownerObj, itemTable, position, angles)
		local entity = ents.Create("cw_item");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(itemTable) == "string") then
			itemTable = Clockwork.item:CreateInstance(itemTable);
		end;
		
		if (type(ownerObj) == "table") then
			if (ownerObj.key and ownerObj.uniqueID) then
				Clockwork.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true);
			end;
		elseif (IsValid(ownerObj) and ownerObj:IsPlayer()) then
			Clockwork.player:GiveProperty(ownerObj, entity);
		end;
		
		if (!itemTable:IsInstance()) then
			itemTable = Clockwork.item:CreateInstance(itemTable("uniqueID"));
		end;
		
		entity:SetItemTable(itemTable);
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		if (itemTable.OnEntitySpawned) then
			itemTable:OnEntitySpawned(entity);
		end;
		
		local itemBodyGroup = itemTable("bodyGroup");
		
		if (itemBodyGroup) then
			entity:SetBodygroup(itemBodyGroup, 1);
		end;
		
		return entity;
	end;
	
	-- A function to copy an entity's owner.
	function Clockwork.entity:CopyOwner(entity, target)
		local removeDelay = self:QueryProperty(entity, "removeDelay");
		local networked = self:QueryProperty(entity, "networked");
		local uniqueID = self:QueryProperty(entity, "uniqueID");
		local key = self:QueryProperty(entity, "key");
		
		Clockwork.player:GivePropertyOffline(key, uniqueID, target, networked, removeDelay);
	end;
	
	-- A function to get whether an entity belongs to a player's other character.
	function Clockwork.entity:BelongsToAnotherCharacter(player, entity)
		local uniqueID = self:QueryProperty(entity, "uniqueID");
		local key = self:QueryProperty(entity, "key");
		
		if (uniqueID and key) then
			if (uniqueID == player:UniqueID() and key != player:GetCharacterKey()) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	-- A function to set a property variable for an entity.
	function Clockwork.entity:SetPropertyVar(entity, key, value)
		if (entity.cwPropertyTab) then entity.cwPropertyTab[key] = value; end;
	end;
	
	-- A function to query an entity's property table.
	function Clockwork.entity:QueryProperty(entity, key, default)
		if (entity.cwPropertyTab) then
			return entity.cwPropertyTab[key] or default;
		else
			return default;
		end;
	end;
	
	-- A function to clear an entity as property.
	function Clockwork.entity:ClearProperty(entity)
		local owner = self:GetOwner(entity);

		if (owner) then
			Clockwork.player:TakeProperty(owner, entity);
		elseif (self:HasOwner(entity)) then
			local uniqueID = self:QueryProperty(entity, "uniqueID");
			local key = self:QueryProperty(entity, "key");
			
			Clockwork.player:TakePropertyOffline(key, uniqueID, entity);
		end;
	end;

	-- A function to get whether an entity has an owner.
	function Clockwork.entity:HasOwner(entity)
		return self:QueryProperty(entity, "owned");
	end;
	
	-- A function to get an entity's owner.
	function Clockwork.entity:GetOwner(entity, bAnyCharacter)
		local owner = self:QueryProperty(entity, "owner");
		local key = self:QueryProperty(entity, "key");
		
		if (IsValid(owner) and (bAnyCharacter
		or owner:GetCharacterKey() == key)) then
			return owner;
		end;
	end;
else
	function Clockwork.entity:Decay(entity, seconds, Callback)
		local color = entity:GetColor();
		local subtract = math.ceil(color.a / seconds);
		local index = tostring({});
		local alpha = color.a;
		
		if (!entity.cwIsDecaying) then
			entity.cwIsDecaying = index;
		end;
		
		index = entity.cwIsDecaying;
		
		Clockwork.kernel:CreateTimer("Decay"..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if (IsValid(entity)) then
				local color = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (color.a <= 0) then
					if (Callback) then Callback(); end;
					
					entity:Remove();
					Clockwork.kernel:DestroyTimer("Decay"..index);
				else
					entity:SetColor(Color(color.r, color.g, color.b, decayed));
				end;
			else
				Clockwork.kernel:DestroyTimer("Decay"..index);
			end;
		end);
	end;
	
	--[[ 
		Description: A function to calculate a door's text position.
		Author: Nori (thanks a lot mate, if you're reading this, check out
		CakeScript G3 - it's epic!).
	]]--
	function Clockwork.entity:CalculateDoorTextPosition(door, reversed)
		local traceData = {};
		local obbCenter = door:OBBCenter();
		local obbMaxs = door:OBBMaxs();
		local obbMins = door:OBBMins();
		
		traceData.endpos = door:LocalToWorld(obbCenter);
		traceData.filter = ents.FindInSphere(traceData.endpos, 20);
		
		for k, v in pairs(traceData.filter) do
			if (v == door) then
				traceData.filter[k] = nil;
			end;
		end;
		
		local length = 0;
		local width = 0;
		local size = obbMins - obbMaxs;
		
		size.x = math.abs(size.x);
		size.y = math.abs(size.y);
		size.z = math.abs(size.z);
		
		if (size.z < size.x and size.z < size.y) then
			length = size.z;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetUp() * length);
			else
				traceData.start = traceData.endpos + (door:GetUp() * length);
			end;
		elseif (size.x < size.y) then
			length = size.x;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetForward() * length);
			else
				traceData.start = traceData.endpos + (door:GetForward() * length);
			end;
		elseif (size.y < size.x) then
			length = size.y;
			width = size.x;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetRight() * length);
			else
			
				traceData.start = traceData.endpos + (door:GetRight() * length);
			end;
		end;

		local trace = util.TraceLine(traceData);
		local angles = trace.HitNormal:Angle();
		
		if (trace.HitWorld and !reversed) then
			return self:CalculateDoorTextPosition(door, true);
		end;
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		local position = trace.HitPos - (((traceData.endpos - trace.HitPos):Length() * 2) + 2) * trace.HitNormal;
		local anglesBack = trace.HitNormal:Angle();
		local positionBack = trace.HitPos + (trace.HitNormal * 2);
		
		anglesBack:RotateAroundAxis(anglesBack:Forward(), 90);
		anglesBack:RotateAroundAxis(anglesBack:Right(), -90);
		
		return {
			positionBack = positionBack,
			anglesBack = anglesBack,
			position = position,
			hitWorld = trace.HitWorld,
			angles = angles,
			width = math.abs(width)
		};
	end;
	
	-- A function to force a menu option.
	function Clockwork.entity:ForceMenuOption(entity, option, arguments)
		Clockwork.datastream:Start("EntityMenuOption", {entity, option, arguments});
	end;
	
	-- A function to get whether an entity has an owner.
	function Clockwork.entity:HasOwner(entity)
		return entity:GetNetworkedBool("Owned");
	end;
	
	-- A function to get an entity's owner.
	function Clockwork.entity:GetOwner(entity, bAnyCharacter)
		local owner = entity:GetNetworkedEntity("Owner");
		local key = entity:GetNetworkedInt("Key");
		
		if (IsValid(owner) and (bAnyCharacter
		or Clockwork.player:GetCharacterKey(owner) == key)) then
			return owner;
		end;
	end;
end;