--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CfgSetVar");

COMMAND.tip = "CmdCfgSetVar";
COMMAND.text = "CmdCfgSetVarDesc";
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local key = arguments[1];
	local value = arguments[2] or "";
	local configObject = Clockwork.config:Get(key);

	if (configObject:IsValid()) then
		local keyPrefix = "";
		local useMap = arguments[3];

		if (useMap == "") then
			useMap = nil;
		end;

		if (useMap) then
			useMap = string.lower(Clockwork.kernel:Replace(useMap, ".bsp", ""));
			keyPrefix = useMap.."'s ";

			if (!file.Exists("maps/"..useMap..".bsp", "GAME")) then
				Clockwork.player:Notify(player, {"NotValidMap", useMap});
				return;
			end;
		end;

		if (!configObject("isStatic")) then
			value = configObject:Set(value, useMap);

			if (value != nil) then
				local printValue = tostring(value);

				if (configObject("isPrivate")) then
					if (configObject("needsRestart")) then
						Clockwork.player:NotifyAll({"PlayerConfigSetNextRestart", player:Name(), keyPrefix, key, string.rep("*", string.utf8len(printValue))});
					else
						Clockwork.player:NotifyAll({"PlayerConfigSet", player:Name(), keyPrefix, key, string.rep("*", string.utf8len(printValue))});
					end;
				elseif (configObject("needsRestart")) then
					Clockwork.player:NotifyAll({"PlayerConfigSetNextRestart", player:Name(), keyPrefix, key, printValue});
				else
					Clockwork.player:NotifyAll({"PlayerConfigSet", player:Name(), keyPrefix, key, printValue});
				end;
			else
				Clockwork.player:Notify(player, {"ConfigUnableToSet", key});
			end;
		else
			Clockwork.player:Notify(player, {"ConfigIsStaticKey", key});
		end;
	else
		Clockwork.player:Notify(player, {"ConfigKeyNotValid", key});
	end;
end;

COMMAND:Register();
