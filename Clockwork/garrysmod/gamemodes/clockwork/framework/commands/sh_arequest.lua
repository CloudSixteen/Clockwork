--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("ARequest");
COMMAND.tip = "Send a request to all online staff.";
COMMAND.text = "<string Text>";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
   if (!Clockwork.player:IsAdmin(player)) then
      Clockwork.player:NotifyAdmins("o", "REQUEST from "..player:Name()..": "..table.concat(arguments, " "), nil);
   else
      Clockwork.player:Notify(player, "You are an admin. Use /a instead.");
   end;
end;

COMMAND:Register();
