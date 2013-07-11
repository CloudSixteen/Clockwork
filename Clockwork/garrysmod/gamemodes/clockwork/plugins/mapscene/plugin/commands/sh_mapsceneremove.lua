--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
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
			if (removed == 1) then
				Clockwork.player:Notify(player, "You have removed "..removed.." map scene.");
			else
				Clockwork.player:Notify(player, "You have removed "..removed.." map scenes.");
			end;
		else
			Clockwork.player:Notify(player, "There were no map scenes near this position.");
		end;
	else
		Clockwork.player:Notify(player, "There are no map scenes.");
	end;
end;

COMMAND:Register();