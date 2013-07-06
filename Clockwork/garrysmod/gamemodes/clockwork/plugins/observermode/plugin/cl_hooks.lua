--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called to get whether the local player can see the admin ESP.
function cwObserverMode:PlayerCanSeeAdminESP()
	if (!Clockwork.player:IsNoClipping(Clockwork.Client)) then
		return false;
	end;
end;

-- Called when a player attempts to NoClip.
function cwObserverMode:PlayerNoClip(player)
	return false;
end;