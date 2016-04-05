--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyRespawnStay");
COMMAND.tip = "Respawn a player at their position of death.";
COMMAND.text = "<string Target>";
COMMAND.arguments = 1;
COMMAND.access = "o";
COMMAND.alias = {"PlyRStay"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (target) then
		Clockwork.player:LightSpawn(target, true, true, false);
		Clockwork.player:Notify(player, target:GetName().." was respawned at their position of death.");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid target!");
	end;
end;

COMMAND:Register();