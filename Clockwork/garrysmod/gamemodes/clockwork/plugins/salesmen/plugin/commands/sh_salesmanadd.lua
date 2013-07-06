--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SalesmanAdd");
COMMAND.tip = "Add a salesman at your target position.";
COMMAND.text = "[number Animation]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player.cwSalesmanSetup = true;
	player.cwSalesmanAnim = tonumber(arguments[1]);
	player.cwSalesmanHitPos = player:GetEyeTraceNoCursor().HitPos;
	
	if (!player.cwSalesmanAnim and type(arguments[1]) == "string") then
		player.cwSalesmanAnim = tonumber(_G[arguments[1]]);
	end;
	
	Clockwork.datastream:Start(player, "SalesmanAdd", true);
end;

COMMAND:Register();