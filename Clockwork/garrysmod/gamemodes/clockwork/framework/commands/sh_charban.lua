--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharBan");
COMMAND.tip = "Ban a character from being used.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(table.concat(arguments, " "));
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			Clockwork.player:SetBanned(target, true);
			Clockwork.player:NotifyAll(player:Name().." banned the character '"..target:Name().."'.");
			
			target:KillSilent();
		else
			Clockwork.player:Notify(player, target:Name().." is protected!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

COMMAND:Register();