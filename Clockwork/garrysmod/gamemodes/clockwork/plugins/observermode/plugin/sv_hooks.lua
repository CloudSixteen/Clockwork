--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when a player attempts to NoClip.
function cwObserverMode:PlayerNoClip(player)
	Clockwork.player:RunClockworkCommand(player, "Observer");
	return false;
end;

-- Called at an interval while a player is connected.
function cwObserverMode:PlayerThink(player, curTime, infoTable)
	if (!player:InVehicle() and !player:IsRagdolled() and !player:IsBeingHeld()
	and player:Alive() and player:GetMoveType() == MOVETYPE_NOCLIP) then
		local color = player:GetColor();
			player:DrawWorldModel(false);
			player:DrawShadow(false);
			player:SetNoDraw(true);
			player:SetNotSolid(true);
		player:SetColor(Color(color.r, color.g, color.b, 0));
	elseif (player.cwObserverMode) then
		if (!player.cwObserverReset) then
			cwObserverMode:MakePlayerExitObserverMode(player)
		end;
	end;
end;