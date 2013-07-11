--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
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