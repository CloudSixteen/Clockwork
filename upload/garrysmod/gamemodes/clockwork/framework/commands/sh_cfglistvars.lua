--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CfgListVars");

COMMAND.tip = "CmdCfgListVars";
COMMAND.text = "CmdCfgListVarsDesc";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local searchData = arguments[1] or "";
		Clockwork.datastream:Start(player, "CfgListVars", searchData);
	Clockwork.player:Notify(player, {"ConfigVariablesPrinted"});
end;

COMMAND:Register();
