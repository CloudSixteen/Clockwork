--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharBan");

COMMAND.tip = "CmdCharBan";
COMMAND.text = "CmdCharBanDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(table.concat(arguments, " "));
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			Clockwork.player:SetBanned(target, true);
			Clockwork.player:NotifyAll({"PlayerBannedPlayer", player:Name(), target:Name()});
			
			target:KillSilent();
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
	end;
end;

COMMAND:Register();