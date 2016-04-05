--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlySetFlags");
COMMAND.tip = "Set a player's flags.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (target) then
		if (string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o")) then
			Clockwork.player:Notify(player, "You cannot give 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		Clockwork.player:SetPlayerFlags(target, arguments[2]);		
		Clockwork.player:NotifyAll(player:Name().." set "..target:SteamName().."'s flags to "..arguments[2]..".");
	else
		Clockwork.player:Notify(player, L(player, "NotValidCharacter", arguments[1]));
	end;
end;

COMMAND:Register();