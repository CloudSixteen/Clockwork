--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local COMMAND = Clockwork.command:New("MapSceneAdd");
COMMAND.tip = "Add a map scene at your current position.";
COMMAND.text = "<bool ShouldSpin>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local data = {
		shouldSpin = Clockwork.kernel:ToBool(arguments[1]),
		position = player:EyePos(),
		angles = player:EyeAngles()
	};
	
	cwMapScene.storedList[#cwMapScene.storedList + 1] = data;
	cwMapScene:SaveMapScenes();
	
	Clockwork.player:Notify(player, "You have added a map scene.");
end;

COMMAND:Register();