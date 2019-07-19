--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called just after a player spawns.
function cwEmoteAnims:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		self:MakePlayerExitStance(player, true);
	end;
end;
	
-- Called when a player spawns lightly.
function cwEmoteAnims:PostPlayerLightSpawn(player, weapons, ammo, special)
	self:MakePlayerExitStance(player);
end;

-- Called when a player has been ragdolled.
function cwEmoteAnims:PlayerRagdolled(player, state, ragdoll)
	self:MakePlayerExitStance(player, true);
end;

-- Called when a player attempts to fire a weapon.
function cwEmoteAnims:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if (self:IsPlayerInStance(player)) then
		return false;
	end;
end;

-- Called at an interval while a player is connected.
function cwEmoteAnims:PlayerThink(player, curTime, infoTable)
	local forcedAnimation = player:GetForcedAnimation();
	local isMoving = false;
	local uniqueID = player:UniqueID();
	
	if (player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVELEFT)
	or player:KeyDown(IN_MOVERIGHT)) then
		isMoving = true;
	end;
	
	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		if (player:GetPos():Distance(player:GetSharedVar("StancePos")) > 16
		or !player:IsOnGround() or isMoving) then
			player:SetForcedAnimation(false);
			player.cwPreviousPos = nil;
			player:SetSharedVar("StancePos", Vector(0, 0, 0));
			player:SetSharedVar("StanceAng", Angle(0, 0, 0));
			player:SetSharedVar("StanceIdle", false);
		end;
	elseif (self:IsPlayerInStance(player)) then
		if (!Clockwork.kernel:TimerExists("ExitStance"..uniqueID)) then
			Clockwork.kernel:CreateTimer("ExitStance"..uniqueID, 1, 1, function()
				if (IsValid(player)) then
					player:SetSharedVar("StancePos", Vector(0, 0, 0));
					player:SetSharedVar("StanceAng", Angle(0, 0, 0));
				end;
			end);
		end;
	end;
end;

-- Called when the player attempts to be ragdolled.
function cwEmoteAnims:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	local forcedAnimation = player:GetForcedAnimation();
	
	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		if (player:Alive()) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to NoClip.
function cwEmoteAnims:PlayerNoClip(player)
	local forcedAnimation = player:GetForcedAnimation();
	
	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		return false;
	end;
end;