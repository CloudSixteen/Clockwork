--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CfgSetVar");
COMMAND.tip = "Set a Clockwork config variable.";
COMMAND.text = "<string Key> [all Value] [string Map]";
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
				Clockwork.player:Notify(player, useMap.." is not a valid map!");
				return;
			end;
		end;
		
		if (!configObject("isStatic")) then
			value = configObject:Set(value, useMap);
			
			if (value != nil) then
				local printValue = tostring(value);
				
				if (configObject("isPrivate")) then
					if (configObject("needsRestart")) then
						Clockwork.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep("*", string.len(printValue)).."' for the next restart.");
					else
						Clockwork.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep("*", string.len(printValue)).."'.");
					end;
				elseif (configObject("needsRestart")) then
					Clockwork.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."' for the next restart.");
				else
					Clockwork.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."'.");
				end;
			else
				Clockwork.player:Notify(player, key.." was unable to be set!");
			end;
		else
			Clockwork.player:Notify(player, key.." is a static config key!");
		end;
	else
		Clockwork.player:Notify(player, key.." is not a valid config key!");
	end;
end;

COMMAND:Register();