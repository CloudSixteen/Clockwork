--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("MapChange");
COMMAND.tip = "Change the current map.";
COMMAND.text = "<string Map> [number Delay]";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local sNewMap = string.lower(arguments[1]);

	if (file.Exists("maps/"..sNewMap..".bsp", "GAME")) then
		Clockwork.player:NotifyAll(player:Name().." is changing the map to "..sNewMap.." in five seconds!");

		timer.Simple(tonumber(arguments[2]) or 5, function()
			RunConsoleCommand("changelevel", sNewMap);
		end);
	else
		Clockwork.player:Notify(player, sNewMap.." is not a valid map!");
	end;
end;

COMMAND:Register();