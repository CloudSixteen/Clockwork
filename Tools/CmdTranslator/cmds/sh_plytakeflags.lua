--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyTakeFlags");

COMMAND.tip = "CmdPlyTakeFlags";
COMMAND.text = "CmdPlyTakeFlagsDesc";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		if (string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o")) then
			Clockwork.player:Notify(player, {"CannotTakeAdminFlags"});
			
			return;
		end;
		
		Clockwork.player:TakePlayerFlags(target, arguments[2]);
		
		Clockwork.player:NotifyAll({"PlayerTookFlagsFrom", player:Name(), arguments[2], target:SteamName()});
	else
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
	end;
end;

COMMAND:Register();