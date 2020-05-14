--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.config:Add("take_physcannon", true);

-- A function to force a player to throw the entity that they are holding.
function cwPickupObjects:ForceThrowEntity(player)
	local entity = self:ForceDropEntity(player);
	local force = player:GetAimVector() * 768;
	
	timer.Simple(FrameTime() * 0.5, function()
		if (IsValid(entity) and IsValid(player)) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:ApplyForceCenter(force);
			end;
		end;
	end);
end;

-- A function to force a player to drop the entity that they are holding.
function cwPickupObjects:ForceDropEntity(player)
	local holdingGrab = player.cwHoldingGrab;
	local curTime = CurTime();
	local entity = player.cwHoldingEnt;
	
	if (IsValid(holdingGrab)) then
		constraint.RemoveAll(holdingGrab);
		holdingGrab:Remove();
	end;
	
	if (IsValid(entity)) then
		entity.cwNextTakeDmg = curTime + 1;
		entity.cwHoldingGrab = nil;
		
		if (Clockwork.config:Get("prop_kill_protection"):Get()
		and entity.cwLastCollideGroup) then
			Clockwork.entity:ReturnCollisionGroup(entity, entity.cwLastCollideGroup);
			
			entity.cwLastCollideGroup = nil;
		end;
		
		entity.cwDamageImmunity = CurTime() + 60;
	end;
	
	if (player.cwHoldingEnt) then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	end;
	
	player.nextPunchTime = curTime + 1;
	player.cwHoldingEnt = nil;
	player.cwHoldingGrab = nil;
	
	return entity;
end;

-- A function to foorce a player to pickup an entity.
function cwPickupObjects:ForcePickup(player, entity, trace)
	self:ForceDropEntity(player);
	
	player.cwHoldingGrab = ents.Create("cw_grab");
	player.cwHoldingGrab:SetOwner(player);
	player.cwHoldingGrab:SetPos(trace.HitPos);
	player.cwHoldingGrab:Spawn();
	
	player.cwHoldingGrab:StartMotionController();
	player.cwHoldingGrab:SetComputePosition(trace.HitPos);
	player.cwHoldingGrab:SetPlayer(player);
	player.cwHoldingGrab:SetTarget(entity);
	
	player.cwHoldingEnt = entity;
	player.cwHoldingGrab:SetCollisionGroup(COLLISION_GROUP_WORLD);
	player.cwHoldingGrab:SetNotSolid(true);
	player.cwHoldingGrab:SetNoDraw(true);
	
	entity.cwHoldingGrab = player.cwHoldingGrab;
	
	if (Clockwork.config:Get("prop_kill_protection"):Get()
	and !entity.cwLastCollideGroup) then
		Clockwork.entity:StopCollisionGroupRestore(entity);
		entity.cwLastCollideGroup = entity:GetCollisionGroup();
		entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	end;
	
	player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	
	if (entity:GetClass() == "prop_ragdoll") then
		constraint.Weld(entity, player.cwHoldingGrab, trace.PhysicsBone, 0, 0);
	else
		constraint.Weld(entity, player.cwHoldingGrab, 0, 0, 0);
	end
end;

-- A function to calculate a player's entity position.
function cwPickupObjects:CalculatePosition(player)
	local holdingGrab = player.cwHoldingGrab;
	local curTime = CurTime();
	local entity = player.cwHoldingEnt;
	
	if (IsValid(entity) and IsValid(holdingGrab) and player:Alive() and !player:IsRagdolled()) then
		if (player:IsUsingHands()) then
			local shootPosition = player:GetShootPos();
			local isRagdoll = entity:GetClass() == "prop_ragdoll";
			local filter = {holdingGrab, entity, player};
			local length = 32 + entity:BoundingRadius();
			
			if (isRagdoll) then
				length = 0;
			end;
			
			if (player:KeyDown(IN_FORWARD)) then
				length = length + (player:GetVelocity():Length() / 2);
			elseif (player:KeyDown(IN_BACK) and player:KeyDown(IN_SPEED)) then
				length = -16;
			end;
			
			local trace = util.TraceLine({
				start = shootPosition,
				endpos = shootPosition + (player:GetAimVector() * length),
				filter = filter
			});
			
			holdingGrab:SetComputePosition(trace.HitPos - holdingGrab:OBBCenter());
			
			if (entity:GetClass() == "prop_ragdoll") then
				holdingGrab.cwComputePos.z = math.min(holdingGrab.cwComputePos.z, shootPosition.z - 32);
			else
				holdingGrab.cwComputePos.z = math.min(holdingGrab.cwComputePos.z, shootPosition.z + 8);
			end;
			
			return true;
		end;
	end;
end;