--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("MapChange");

COMMAND.tip = "CmdMapChange";
COMMAND.text = "CmdMapChangeDesc";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local newMap = string.lower(arguments[1]);

	if (file.Exists("maps/"..newMap..".bsp", "GAME")) then
		local delay = tonumber(arguments[2]) or 5;
		
		Clockwork.player:NotifyAll({"PlayerChangingMapIn", player:Name(), newMap, delay});

		timer.Simple(delay, function()
			RunConsoleCommand("changelevel", newMap);
		end);
	else
		Clockwork.player:Notify(player, {"MapNameIsNotValid", newMap});
	end;
end;

COMMAND:Register();