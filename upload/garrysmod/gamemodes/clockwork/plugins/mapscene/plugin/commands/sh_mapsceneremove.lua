--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("MapSceneRemove");

COMMAND.tip = "Remove map scenes at your current position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (#cwMapScene.storedList > 0) then
		local position = player:EyePos();
		local removed = 0;
		
		for k, v in pairs(cwMapScene.storedList) do
			if (v.position:Distance(position) <= 256) then
				cwMapScene.storedList[k] = nil;
				
				removed = removed + 1;
			end;
		end;
		
		if (removed > 0) then
			Clockwork.player:Notify(player, {"MapSceneRemoved", removed});
		else
			Clockwork.player:Notify(player, {"MapSceneNoneNearPosition"});
		end;
	else
		Clockwork.player:Notify(player, {"MapSceneNoneExist"});
	end;
end;

COMMAND:Register();