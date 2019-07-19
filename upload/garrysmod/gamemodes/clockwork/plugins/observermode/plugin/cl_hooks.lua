--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called to get whether the local player can see the admin ESP.
function cwObserverMode:PlayerCanSeeAdminESP()
	if (!Clockwork.player:IsNoClipping(Clockwork.Client)) then
		return false;
	end;
end;

-- Called to get the action text of a player.
function cwObserverMode:GetStatusInfo(player, text)
	if (Clockwork.player:IsNoClipping(player)) then
		table.insert(text, "[Observer]");
	end;
end;

-- Called when a player attempts to NoClip.
function cwObserverMode:PlayerNoClip(player)
	return false;
end;