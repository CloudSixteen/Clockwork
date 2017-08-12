--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharTie");

COMMAND.tip = "Tie/Untie a character.";
COMMAND.text = "<string Name>";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (!Clockwork.command:FindByID("InvZipTie")) then
		player:Notify({"TieCommandNotFound"});
		return;
	end;

	if (target) then
		if (target:GetSharedVar("tied") != 0) then
			Schema:TiePlayer(target, false);
			
			player:Notify({"YouHaveUntiedPlayer"});
			target:Notify({"YouWereUntiedByPlayer"});
		else
			Schema:TiePlayer(target, true);
			
			player:Notify({"YouHaveTiedPlayer"});
			target:Notify({"YouWereTiedByPlayer"});
		end
	else
		player:Notify({"NotValidPlayer", arguments[1]});
	end
end;

COMMAND:Register();