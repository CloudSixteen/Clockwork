--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when a player's character data should be saved.
function cwStamina:PlayerSaveCharacterData(player, data)
	if (data["stamina"]) then
		data["stamina"] = math.Round(data["stamina"]);
	end;
end;

-- Called when a player's character data should be restored.
function cwStamina:PlayerRestoreCharacterData(player, data)
	if (!data["Stamina"]) then
		data["Stamina"] = 100;
	end;
end;

-- Called just after a player spawns.
function cwStamina:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Stamina", 100);
	end;
end;

-- Called when a player attempts to throw a punch.
function cwStamina:PlayerCanThrowPunch(player)
	if (player:GetCharacterData("Stamina") <= 10) then
		return false;
	end;
end;

-- Called when a player throws a punch.
function cwStamina:PlayerPunchThrown(player)
	local attribute = Clockwork.attributes:Fraction(player, ATB_STAMINA, 1.5, 0.25);
	local decrease = 5 / (1 + attribute);
	
	player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") - decrease, 0, 100));
end;

-- Called when a player's shared variables should be set.
function cwStamina:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Stamina", math.Round(player:GetCharacterData("Stamina")));
end;

-- Called when a player's stamina should regenerate.
function cwStamina:PlayerShouldStaminaRegenerate(player)
	return true;
end;

-- Called at an interval while a player is connected.
function cwStamina:PlayerThink(player, curTime, infoTable)
	local regenscale = Clockwork.config:Get("stam_regen_scale"):Get();
	local drainscale = Clockwork.config:Get("stam_drain_scale"):Get();
	local attribute = Clockwork.attributes:Fraction(player, ATB_STAMINA, 1, 0.25);
	local decrease = (drainscale + (drainscale - (math.min(player:Health(), 500) / 500))) / (drainscale + attribute);
	
	if (!player:IsNoClipping() and player:IsOnGround()
	and (infoTable.isRunning or infoTable.isJogging)) then
		regeneration = 0
		player:SetCharacterData(
			"Stamina", math.Clamp(
				player:GetCharacterData("Stamina") - decrease, 0, 100
			)
		);
		
		if (player:GetCharacterData("Stamina") > 1) then
			if (infoTable.isRunning) then
				player:ProgressAttribute(ATB_STAMINA, 0.025, true);
			elseif (infoTable.isJogging) then
				player:ProgressAttribute(ATB_STAMINA, 0.0125, true);
			end;
		end;
	elseif (player:GetVelocity():Length() == 0) then
		if (player:Crouching()) then
			regeneration = regenscale * 2;
		end;
	else
		regeneration = 0;
	end;

	if (regeneration > 0 and Clockwork.plugin:Call("PlayerShouldStaminaRegenerate", player)) then
		player:SetCharacterData(
			"Stamina", math.Clamp(
				player:GetCharacterData("Stamina") + regeneration, 0, 100
			)
		);
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
	local maxRunSpeed = Clockwork.config:Get("run_speed"):Get();

	infoTable.runSpeed = math.Clamp(newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina"))), infoTable.walkSpeed, maxRunSpeed);
	
	if (infoTable.isJogging) then
		local walkSpeed = Clockwork.config:Get("walk_speed"):Get();
		local newWalkSpeed = walkSpeed * 1.75;
		local diffWalkSpeed = newWalkSpeed - walkSpeed;

		infoTable.walkSpeed = newWalkSpeed - (diffWalkSpeed - ((diffWalkSpeed / 100) * player:GetCharacterData("Stamina")));
		
		if (player:GetCharacterData("Stamina") < 1) then
			player:SetSharedVar("IsJogMode", false);
		end;
	end;
	
	local stamina = player:GetCharacterData("Stamina");
	
	if (stamina < 30 and Clockwork.event:CanRun("sounds", "breathing")) then
		bPlayerBreathSnd = true;
	end;
	
	if (!player.nextBreathingSound or curTime >= player.nextBreathingSound) then
		if (!Clockwork.player:IsNoClipping(player)) then
			player.nextBreathingSound = curTime + 1;
			
			if (bPlayerBreathSnd) then
				local volume = Clockwork.config:Get("breathing_volume"):Get() - stamina;

				Clockwork.player:StartSound(player, "LowStamina", "player/breathe1.wav", volume / 100);
			else
				Clockwork.player:StopSound(player, "LowStamina", 4);
			end;
		end;
	end;
end;
