--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharSetModel");

COMMAND.tip = "CmdCharSetModel";
COMMAND.text = "CmdCharSetModelDesc";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		local model = table.concat(arguments, " ", 2);
		
		target:SetCharacterData("Model", model, true);
		target:SetModel(model);
		
		Clockwork.player:NotifyAll({"PlayerSetPlayerModel", player:Name(), target:Name(), model});
	else
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
	end;
end;

COMMAND:Register();