--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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

--[[
	@codebase Shared
	@details A library adding additional functionality to entities.
--]]
Clockwork.entity = Clockwork.kernel:NewLibrary("Entity");

if (CLIENT) then
	--[[
		@codebase Client
		@details A function to get a weapon's muzzle position from its viewmodel.
		@param {Entity} The player's current weapon.
		@param {Entity} The player's attachment on the weapon.
		@returns {Vector} The coordinates of weapon's muzzle position.
		@returns {Angle} The angle of the weapon's muzzle position.
	--]]
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
else
	--[[
		@codebase Server
		@details A function to get all door entities which are stored from server start.
		@returns {Table} A list of all door entities.
	--]]
	function Clockwork.entity:GetDoorEntities()
		return self.DoorEntities or {};
	end;
end;

--[[
	@codebase Shared
	@details A function to check if an entity is a door or not by seeing if its name includes "door" or if the entity is one of the following classes: "func_door", "func_door_rotating", "prop_door_rotating", "func_movelinear"
	@param {Entity} The entity being check as a door.
	@returns {Bool} Whether the entity is a door or not.
--]]
function Clockwork.entity:IsDoor(entity)
	if (IsValid(entity)) then
		local class = entity:GetClass();
		local model = entity:GetModel();
		
		if (class and model) then
			class = string.lower(class);
			model = string.lower(model);
			
			if (class == "func_door" 
    			    or class == "func_door_rotating" 
    			    or class == "prop_door_rotating"
    			    or (class == "prop_dynamic" and string.find(model, "door")) 
    			    or class == "func_movelinear") then
    			
				return true;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether an entity is decaying by being in the process of fading out and being removed.
	@param {Entity} The entity being checked as decaying or not.
	@returns {Bool} Whether or not the entity is decaying.
--]]
function Clockwork.entity:IsDecaying(entity)
	return entity.cwIsDecaying;
end;

--[[
	@codebase Shared
	@details A function to get a door entity's partners which are doors that open along with it.
	@param {Entity} The entity to get the door partners from.
	@returns {Table} A list of partners on the door entity.
--]]
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

--[[
	@codebase Shared
	@details A function to check if an entity is in a specified box area.
	@param {Entity} The entity to check if it's in a box.
	@param {Number} Minimum position to check in.
	@param {Number} Maximum position to check in.
	@returns {Bool} Whether or not an entity is within the defined box.
--]]
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

--[[
	@codebase Shared
	@details A function to get a ragdoll entity's pelvis position.
	@param {Entity} The entity to get the pelvis position from.
	@returns {Vector} Coordinates of the entity's pelvis.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether an entity can see a position from its own position.
	@param {Entity} The entity that's being checked on if it can see a position.
	@param {Vector} Location being checked if the entity can see it.
	@param {Number} Optional: Variance around the position being checked.
	@param {Entity} Optional: Entities that should be ignored when checking if an entity can see a position.
	@returns {Bool} Whether or not the entity can see a position.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether an entity can see an NPC from its own position.
	@param {Entity} The entity that's being checked on if it can see an NPC.
	@param {Entity} The NPC being check if it can be seen.
	@param {Number} Optional: Variance around the position being checked.
	@param {Entity} Optional: Entities that should be ignored when checking if an entity can see an NPC.
	@returns {Bool} Whether or not the entity can see an NPC.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether an entity can see a player from its own position.
	@param {Entity} The entity that's being checked on if it can see a player.
	@param {Entity} The player being checked if it can be seen.
	@param {Number} Optional: Variance around the position being checked.
	@param {Entity} Optional: Entities that should be ignored when checking if an entity can see a player.
	@returns {Bool} Whether or not the entity can see a player.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether an entity can see an entity from its own position.
	@param {Entity} The entity that's being checked on if it can see another entity.
	@param {Entity} The entity being checked if it can be seen.
	@param {Number} Optional: Variance around the entity being checked.
	@param {Entity} Optional: Entities that should be ignored when checking if an entity can see another entity.
	@returns {Bool} Whether or not the entity can see another entity.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether a door is unownable by a player.
	@param {Entity} Door being checked as unownable.
	@returns {Bool} Whether or not the door is unownable.
--]]
function Clockwork.entity:IsDoorUnownable(entity)
	return entity:GetNetworkedBool("Unownable");
end;

--[[
	@codebase Shared
	@details A function to get whether a door is false.
	@param {Entity} Door being check as false.
	@returns {Bool} Whether or not the door is false or not.
--]]
function Clockwork.entity:IsDoorFalse(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "false";
end;

--[[
	@codebase Shared
	@details A function to get whether a door is hidden.
	@param {Entity} Door being checked as hidden.
	@returns {Bool} Whether or not the door is hidden or not.
--]]
function Clockwork.entity:IsDoorHidden(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "hidden";
end;

--[[
	@codebase Shared
	@details A function to get a door's name.
	@param {Entity} Door getting its name checked.
	@returns {String} Name of the door.
--]]
function Clockwork.entity:GetDoorName(entity)
	return entity:GetNetworkedString("Name");
end;

--[[
	@codebase Shared
	@details A function to get the text being displayed on a door.
	@param {Entity} Door getting its text from.
	@returns {String} Text being displayed on the door.
--]]
function Clockwork.entity:GetDoorText(entity)
	return entity:GetNetworkedString("Text");
end;

--[[
	@codebase Shared
	@details A function to get whether an entity is a player in ragdoll form.
	@param {Entity} The entity getting checked as a player ragdoll.
	@returns {Bool} Whether or not the entity is a player ragdoll.
--]]
function Clockwork.entity:IsPlayerRagdoll(entity)
	local player = entity:GetNetworkedEntity("Player");
	
	if (IsValid(player)) then
		if (player:GetRagdollEntity() == entity) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a player from an entity.
	@param {Entity} The entity getting the player from.
	@returns {Entity} The player from the entity.
--]]
function Clockwork.entity:GetPlayer(entity)
	local player = entity:GetNetworkedEntity("Player");
	
	if (IsValid(player)) then
		return player;
	elseif (entity:IsPlayer()) then
		return entity;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether an entity is interactable.
	@param {Entity} The entity being checked if it is interactable.
	@returns {Bool} Whether or not the entity is interactable.
--]]
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

--[[
	@codebase Shared
	@details A function to get whether an entity is a physics entity.
	@param {Entity} The entity being checked if it is a physics entity.
	@returns {Bool} Whether or not the entity is a physicas entity.
--]]
function Clockwork.entity:IsPhysicsEntity(entity)
	local class = string.lower(entity:GetClass());
	
	if (class == "prop_physicsmultiplayer" or class == "prop_physics") then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether an entity is a pod.
	@param {Entity} The entity being checked if it is a pod entity.
	@returns {Bool} Whether or not the entity is a pod entity.
--]]
function Clockwork.entity:IsPodEntity(entity)
	local entityModel = string.lower(entity:GetModel());
	
	if (string.find(entityModel, "prisoner")) then
		return true;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether an entity is a chair.
	@param {Entity} The Entity being checked if it is a chair entity.
	@returns {Bool} Whether or not the entity is a chair entity.
--]]
function Clockwork.entity:IsChairEntity(entity)
	if (entity:GetModel()) then
		local entityModel = string.lower(entity:GetModel());
		
		if (string.find(entityModel, "chair") or string.find(entityModel, "seat")) then
			return true;
		end;
	end;
end;

if (CLIENT) then
	--[[
		@codebase Client
		@details A function to get whether an item's data has been fetched.
		@param {Entity} The entity being checked if the item data has been fetched.
		@returns {Bool} Whether or not the item data has been fetched.
	--]]
	function Clockwork.entity:HasFetchedItemData(entity)
		return (entity.cwFetchedItemData == true);
	end;
	
	--[[
		@codebase Client
		@details A function to fetch the entity's item table.
		@param {Entity} The entity getting the item table from.
		@returns {Table} Contains the entity's item table.
	--]]
	function Clockwork.entity:FetchItemTable(entity)
		return entity.cwItemTable;
	end;
	
	--[[
		@codebase Client
		@details A function to fetch the entity's item data.
		@param {Entity} The entity getting the item data from.
	--]]
	function Clockwork.entity:FetchItemData(entity)
		local curTime = CurTime();
		
		if (!entity.m_iNextFetchItemData) then
			entity.m_iNextFetchItemData = 0;
		end;
	
		if (curTime > entity.m_iNextFetchItemData) then
			entity.m_iNextFetchItemData = curTime + 4;
			
			if (entity:IsVehicle()) then
				Clockwork.datastream:Start("FetchItemData", entity:EntIndex());
			else
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
			
			if (entity:IsVehicle()) then
				data = entity:EntIndex();
			end;
			
			Clockwork.datastream:Start(player, "FetchItemData", {
				definition = definition,
				entity = data
			});
		end;
	end);
	
	--[[
		@codebase Server
		@details A function to dissolve an entity using a Source effect.
		@param {Entity} The entity that will be dissolved.
		@param {String} Dissolving effect to be applied to the entity.
		@param {Number} Optional: Time until the entity is removed.
		@param {Entity} Optional: The entity that is set as the dissolved entity's attacker.
		@returns {Entity} Reference to the entity making the dissolving effects.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to temporarily set a door's speed to fast.
		@param {Entity} The door getting its speed set to fast.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to blast down a door off its hinges.
		@param {Entity} The door being blasted off its hinges.
		@param {Number} The blast strength that should be applied to the door.
		@param {Entity} The entity that is blasting the door off its hinges.
	--]]
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

--[[
	@codebase Shared
	@details A function to get an entity's door state.
	@returns {Table} The state of the door.
--]]
function Clockwork.entity:GetDoorState(entity)
	return entity:GetSaveTable().m_eDoorState or DOOR_STATE_CLOSED;
end;

--[[
	@codebase Shared
	@details A function to get whether a door is locked.
	@returns {Bool} Whether or not the door is locked.
--]]
function Clockwork.entity:IsDoorLocked(entity)
	return (entity:GetSaveTable().m_bLocked == true);
end;

if (SERVER) then
	--[[
		@codebase Server
		@details A function to open a door.
		@param {Entity} The door to be opened.
		@param {Number} Delay until the door should be opened.
		@param {Bool} Whether or not the door should be unlocked.
		@param {Bool} Whether or not a sound should be played for unlocking the door.
		@param {Vector} Postition that the info_target is created at.
		@param {Float} Not implemented.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to bash in a door entity.
		@param {Entity} The door being bashed in.
		@param {Entity} The entity bashing in the door.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to make an entity safe.
		@param {Entity} The entity being made safe.
		@param {Bool} Whether or not the entity should be safe from physguns.
		@param {Table} List of tools that can't be used on the entity.
		@param {Bool} Whether or not the entity should be frozen.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to statue a ragdoll.
		@param {Entity} The entity being set as a statue.
		@param {Number} How much force a bone can take before the weld breaks.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to drop items and cash.
		@param {Table} The inventory being dropped.
		@param {Number} How much cash to drop.
		@param {Vector} Where the items and cash should drop.
		@param {Entity} The owner of the items and cash being dropped.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to make an entity into a ragdoll.
		@param {Entity} The entity being made in to a ragdoll.
		@param {Number} The amount of force applied to the entity upon being made in to a ragdoll.
		@param {Number} What the entity's velocity should be forcibly set to.
		@param {Angle} What the entity's angles should be set to.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to get whether a door is unsellable.
		@param {Entity} The door being checked as unsellable.
		@returns {Bool} Whether or not the door is unsellable.
	--]]
	function Clockwork.entity:IsDoorUnsellable(door)
		return door.unsellable;
	end;
	
	--[[
		@codebase Server
		@details A function to set a door's parent.
		@param {Entity} The door being set as a child.
		@param {Entity} The door being set as the parent for the child.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to get whether a door is a parent or not.
		@param {Entity} The door being checked as a parent.
		@returns {Bool} Whether or not the door has any children (thus making it a parent door if it does, otherwise if not).
	--]]
	function Clockwork.entity:IsDoorParent(door)
		return table.Count(self:GetDoorChildren(door)) > 0;
	end;

	--[[
		@codebase Server
		@details A function to get a door's parent.
		@param {Entity} The door that the parent should be gotten from.
		@returns {Table} The parent of the door (if it exists).
	--]]
	function Clockwork.entity:GetDoorParent(door)
		if (IsValid(door.doorParent)) then
			return door.doorParent;
		end;
	end;

	--[[
		@codebase Server
		@details A function to get a door's children.
		@param {Entity} The door to get the children from.
		@returns {Table} The children of the door.
	--]]
	function Clockwork.entity:GetDoorChildren(door)
		return door.doorChildren or {};
	end;
	
	--[[
		@codebase Server
		@details A function to set a door as unownable.
		@param {Entity} The door being set to unownable.
		@param {Bool} Whether or not the door should be set to unownable.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set whether a door is false.
		@param {Entity} The door being set to false.
		@param {Bool} Whether the door should be false or not.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set whether a door is hidden.
		@param {Entity} The door being set to hidden.
		@param {Bool} Whether or not the doro should be set to hidden.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set whether a door has shared access.
		@param {Entity} The door being given shared access.
		@param {Entity} What has shared access to the door.
	--]]
	function Clockwork.entity:SetDoorSharedAccess(entity, sharedAccess)
		if (self:IsDoorParent(entity)) then
			entity.cwDoorSharedAxs = sharedAccess;
		end;
	end;
	
	--[[
		@codebase Server
		@details A function to set a shared door's text
		@param {Entity} The door having its shared text set.
		@param {String} The text that will be displayed on the shared door.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to get whether a door has shared access.
		@param {Entity} The door being checked if it has a shared access.
		@returns {Bool} Whether or not the door has a shared access to another door.
	--]]
	function Clockwork.entity:DoorHasSharedAccess(entity)
		return entity.cwDoorSharedAxs;
	end;
	
	--[[
		@codebase Server
		@details A function to get whether a door has shared text.
		@param {Entity} The door being checked if it has shared text.
		@returns {Bool} Whether or not the door has shared text.
	--]]
	function Clockwork.entity:DoorHasSharedText(entity)
		return entity.cwDoorSharedTxt;
	end;
	
	--[[
		@codebase Server
		@details A function to set a door's text.
		@param {Entity} The door getting its text set.
		@param {String} What the door's text will be set to.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set a door's name.
		@param {Entity} The door getting its name set.
		@param {String} What the door's name will be set to.
	--]]
	function Clockwork.entity:SetDoorName(entity, name)
		if (self:IsDoor(entity)) then
			entity:SetNetworkedString("Name", name or "");
		end;
	end;
	
	--[[
		@codebase Server
		@details A function to set an entity's chair animations.
		@param {Entity} The entity having its animation set.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set an entity's start angles.
		@param {Entity} The entity having its start angles being set.
		@param {Angle} What the start angles are set to.
	--]]
	function Clockwork.entity:SetStartAngles(entity, angles)
		entity.cwStartAng = angles;
	end;
	
	--[[
		@codebase Server
		@details A function to get an entity's start angles.
		@param {Entity} The entity to get the angles from
		@returns {Angle} Start angle for the entity.
	--]]
	function Clockwork.entity:GetStartAngles(entity)
		return entity.cwStartAng;
	end;
	
	--[[
		@codebase Server
		@details A function to set an entity's start position.
		@param {Entity} The entity having its start position set.
		@param {Vector} Start position the entity is set to.
	--]]
	function Clockwork.entity:SetStartPosition(entity, position)
		entity.cwStartPos = position;
	end;
	
	--[[
		@codebase Server
		@details A function to get an entity's start position.
		@param {Entity} The entity getting the start position from.
		@returns {Vector} The start position of the entity.
	--]]
	function Clockwork.entity:GetStartPosition(entity)
		return entity.cwStartPos;
	end;
	
	--[[
		@codebase Server
		@details A function to stop an entity's collision group restore.
		@param {Entity} Which entity to stop the collision group restore on.
	--]]
	function Clockwork.entity:StopCollisionGroupRestore(entity)
		Clockwork.kernel:DestroyTimer("CollisionGroup"..entity:EntIndex());
	end;
	
	--[[
		@codebase Server
		@details A function to return an entity's collision group.
		@param {Entity} Which entity to restore the collision group on.
		@param {String} What the collision group is set to on the entity.
	--]]
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

	--[[
		@codebase Server
		@details A function to set whether an entity is a map entity.
		@param {Entity} The entity being set as a map entity or not.
		@param {Bool} Whether or not the entity is a map entity.
	--]]
	function Clockwork.entity:SetMapEntity(entity, isMapEntity)
		local entIndex = entity:EntIndex();

		if (isMapEntity) then
			Clockwork.Entities[entity] = true;
		else
			Clockwork.Entities[entity] = false;
		end;
	end;
	
	--[[
		@codebase Server
		@details A function to get whether an entity is a map entity.
		@param {Entity} The entity being checked as a map entity.
		@returns {Bool} Whether or not the entity is a map entity.
	--]]
	function Clockwork.entity:IsMapEntity(entity)
		return Clockwork.Entities[entity] or false;
	end;
	
	--[[
		@codebase Server
		@details A function to make an entity flush with the ground.
		@param {Entity} The entity being flushed the the ground.
		@param {Vector} Initial position of the entity being flushed.
		@param {Number} Normalization for refining flushing.
	--]]
	function Clockwork.entity:MakeFlushToGround(entity, position, normal)
		entity:SetPos(position + (entity:GetPos() - entity:NearestPoint(position - (normal * 512))));
	end;
	
	--[[
		@codebase Server
		@details A function to make an entity disintegrate.
		@param {Entity} The entity being disintegrated.
		@param {Number} How long to wait until disintegrating the entity.
		@param {Number} Optional: Adds speed to the entity once it gets disintegrated.
		@param {Function} What to run after the entity disintegrates.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set an entity's player.
		@param {Entity} The entity being set to a player.
		@param {Entity} What to set the entity's player to.
	--]]
	function Clockwork.entity:SetPlayer(entity, player)
		entity:SetNetworkedEntity("Player", player);
	end;
	
	--[[
		@codebase Server
		@details A function to make an entity decay.
		@param {Entity} The entity being decayed.
		@param {Number} How fast the entity should decay.
		@param {Function} What to run just before the entity is removed.
	--]]
	function Clockwork.entity:Decay(entity, seconds, Callback)
		local color = entity:GetColor();		
		local subtract = math.ceil(color.a / seconds);
		local index = tostring({});
		local alpha = color.a;
		
		if (!entity.cwIsDecaying) then
			entity.cwIsDecaying = index;
		end;

		entity:SetRenderMode(RENDERMODE_TRANSALPHA);
		
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
	
	--[[
		@codebase Server
		@details A function to create cash.
		@param {Entity:Table} The owner(s) of the cash being created.
		@param {Number} How much cash to create.
		@param {Vector} Where to create the cash.
		@param {Angle} Optional: Angles to set the created cash to.
		@returns {Entity} Reference to the cash just created.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to create generator.
		@param {Entity:Table} The owner(s) of the generator being created.
		@param {String} Entity class for the generator to be assigned to.
		@param {Vector} Position the generator is set to.
		@param {Angle} Optional: Angles the generator is set to.
		@returns {Entity} Reference to the generator created.
	--]]
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
			Clockwork.player:GiveProperty(ownerObj, entity, true);
		end;
		
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	--[[
		@codebase Server
		@details A function to create a shipment.
		@param {Entity:Table} The owner(s) of the shipment being created.
		@param {String} Unique ID of the item being stored in the shipment.
		@param {Number} How many items stored in the shipment.
		@param {Vector} Position the shipment is created at.
		@param {Angle} Optional: Angles the shipment is set to.
		@returns {Entity} Reference to the shipment that was created.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to create an item.
		@param {Entity:Table} The owner(s) of the item being created.
		@param {String} ID for the item that is to be created.
		@param {Vector} Position the item is set to when created.
		@param {Angle} Optional: Angles the item is set to.
		@returns {Entity} Reference to the item created.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to copy an entity's owner.
		@param {Entity} The entity getting the properties copied from.
		@param {Entity} The entity getting the properties pasted to.
	--]]
	function Clockwork.entity:CopyOwner(entity, target)
		local removeDelay = self:QueryProperty(entity, "removeDelay");
		local networked = self:QueryProperty(entity, "networked");
		local uniqueID = self:QueryProperty(entity, "uniqueID");
		local key = self:QueryProperty(entity, "key");
		
		Clockwork.player:GivePropertyOffline(key, uniqueID, target, networked, removeDelay);
	end;
	
	--[[
		@codebase Server
		@details A function to get whether an entity belongs to a player's other character.
		@param {Entity} The player being checked if the item belongs to it.
		@param {Entity} The entity being checked for ownership.
		@returns {Bool} Whether or not the entity belongs to the player.
	--]]
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
	
	--[[
		@codebase Server
		@details A function to set a property variable for an entity.
		@param {Entity} The entity having its property var set.
		@param {String} ID for the property being set.
		@param {String} Value the property is being set to.
	--]]
	function Clockwork.entity:SetPropertyVar(entity, key, value)
		if (entity.cwPropertyTab) then entity.cwPropertyTab[key] = value; end;
	end;
	
	--[[
		@codebase Server
		@details A function to query an entity's property table.
		@param {Entity} The entity getting the properties from.
		@param {String} Which property is being queried.
		@param {String} Fallback value to return if no property is found.
		@returns {String} Value of the property that was queried.
	--]]
	function Clockwork.entity:QueryProperty(entity, key, default)
		if (entity.cwPropertyTab) then
			return entity.cwPropertyTab[key] or default;
		else
			return default;
		end;
	end;
	
	--[[
		@codebase Server
		@details A function to clear an entity as property.
		@param {Entity} The entity being cleared from the properties
	--]]
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

	--[[
		@codebase Server
		@details A function to get whether an entity has an owner.
		@param {Entity} The entity being checked if it has an owner.
		@returns {Bool} Whether or not the entity has an owner.
	--]]
	function Clockwork.entity:HasOwner(entity)
		return self:QueryProperty(entity, "owned");
	end;
	
	--[[
		@codebase Server
		@details A function to get an entity's owner.
		@param {Entity} The entity getting the owner from.
		@param {Bool} Whether or not to get the owner even if the entity has no entity key.
		@returns {Entity} The owner of the entity.
	--]]
	function Clockwork.entity:GetOwner(entity, bAnyCharacter)
		local owner = self:QueryProperty(entity, "owner");
		local key = self:QueryProperty(entity, "key");
		
		if (IsValid(owner) and (bAnyCharacter or owner:GetCharacterKey() == key)) then
			return owner;
		end;
	end;
else
	--[[
		@codebase Client
		@details A function to make an entity decay.
		@param {Entity} The entity being decayed.
		@param {Number} How fast the entity should decay.
		@param {Function} What to run just before the entity is removed.
	--]]
	function Clockwork.entity:Decay(entity, seconds, Callback)
		local color = entity:GetColor();
		local subtract = math.ceil(color.a / seconds);
		local index = tostring({});
		local alpha = color.a;
		
		if (!entity.cwIsDecaying) then
			entity.cwIsDecaying = index;
		end;
		
		entity:SetRenderMode(RENDERMODE_TRANSALPHA);
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
	--[[
		@codebase Client
		@details A function to calculate a door's text position.
		@param {Entity} The door getting its text position calculated.
		@param {Bool} Optional: Whether or not the other side of the door text position is being calculated.
		@returns {Function} Recall to this function.
	--]]
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
	
	--[[
		@codebase Client
		@details A function to force a menu option.
		@param {Entity} The entity having the menu option created on.
		@param {String} The name of the option to be displayed (not implemented?).
		@param {String} Interaction action to be done (e.g. cwItemTake).
	--]]
	function Clockwork.entity:ForceMenuOption(entity, option, arguments)
		Clockwork.datastream:Start("EntityMenuOption", {entity, option, arguments});
	end;
	
	--[[
		@codebase Client
		@details A function to get whether an entity has an owner.
		@param {Entity} The entity being checked if it has an owner.
		@returns {Bool} Whether or not the entity has an owner.
	--]]
	function Clockwork.entity:HasOwner(entity)
		return entity:GetNetworkedBool("Owned");
	end;
	
	--[[
		@codebase Client
		@details A function to get an entity's owner.
		@param {Entity} The entity getting the owner from.
		@param {Bool} Whether or not to get the owner even if the entity has no entity key.
		@returns {Entity} The owner of the entity.
	--]]
	function Clockwork.entity:GetOwner(entity, bAnyCharacter)
		local owner = entity:GetNetworkedEntity("Owner");
		local key = entity:GetNetworkedInt("Key");
		
		if (IsValid(owner) and (bAnyCharacter or Clockwork.player:GetCharacterKey(owner) == key)) then
			return owner;
		end;
	end;
end;