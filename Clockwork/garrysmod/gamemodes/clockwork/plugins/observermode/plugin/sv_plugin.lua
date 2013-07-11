--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.config:Add("observerReset", true, true);

-- A function to make a player exit observer mode.
function cwObserverMode:MakePlayerExitObserverMode(player)
	local observerReset = Clockwork.config:Get("observerReset"):Get()
	player.cwObserverReset = true;
	player:DrawWorldModel(true);
	player:DrawShadow(true);
	player:SetNoDraw(false);
	player:SetNotSolid(false);
	player:SetMoveType(player.cwObserverMoveType or MOVETYPE_WALK);
	
	timer.Simple(FrameTime() * 0.5, function()
		if (IsValid(player)) then
			if(observerReset == true) then
				if (player.cwObserverPos) then
					player:SetPos(player.cwObserverPos);
				end;
			
				if (player.cwObserverAng) then
					player:SetEyeAngles(player.cwObserverAng);
				end;
			end;
			
			if (player.cwObserverColor) then
				player:SetColor(player.cwObserverColor);
			end;
			
			player.cwObserverMoveType = nil;
			player.cwObserverReset = nil;
			player.cwObserverPos = nil;
			player.cwObserverAng = nil;
			player.cwObserverMode = nil;
		end;
	end);
end;

-- A function to make a player enter observer mode.
function cwObserverMode:MakePlayerEnterObserverMode(player)
	player.cwObserverMoveType = player:GetMoveType();
	player.cwObserverPos = player:GetPos();
	player.cwObserverAng = player:EyeAngles();
	player.cwObserverColor = player:GetColor();
	player.cwObserverMode = true;
	player:SetMoveType(MOVETYPE_NOCLIP);
end;
