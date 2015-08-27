--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharSetModel");
COMMAND.tip = "Set a character's model permanently.";
COMMAND.text = "<string Name> <string Model>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		local model = table.concat(arguments, " ", 2);
		
		target:SetCharacterData("Model", model, true);
		target:SetModel(model);
		
		Clockwork.player:NotifyAll(player:Name().." set "..target:Name().."'s model to "..model..".");
	else
		Clockwork.player:Notify(player, L(player, "NotValidCharacter", arguments[1]));
	end;
end;

COMMAND:Register();