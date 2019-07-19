--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharCheckFlags");

COMMAND.tip = "CmdCharCheckFlags";
COMMAND.text = "CmdCharCheckFlagsDesc";
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (target) then
		Clockwork.player:Notify(player, {"PlayerHasFlags", target:GetFlags()});
	else
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
	end;
end;

COMMAND:Register();