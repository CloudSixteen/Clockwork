--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharTakeFlags");
COMMAND.tip = "Take flags from a character.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		if (string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o")) then
			Clockwork.player:Notify(player, "You cannot take 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		Clockwork.player:TakeFlags(target, arguments[2]);
		
		Clockwork.player:NotifyAll(player:Name().." took '"..arguments[2].."' flags from "..target:Name()..".");
	else
		Clockwork.player:Notify(player, L(player, "NotValidCharacter", arguments[1]));
	end;
end;

COMMAND:Register();