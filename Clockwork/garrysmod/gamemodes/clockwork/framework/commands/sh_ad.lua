--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Ad");
COMMAND.tip = "Send a private message to all admins and above.";
COMMAND.text = "<string Msg>";
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local listeners = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:IsAdmin() or v:IsSuperAdmin()) then
			listeners[#listeners + 1] = v;
		end;
	end;
	
	Clockwork.chatBox:Add(
		listeners, player, "priv", table.concat(arguments, " "), {userGroup = "admin"}
	);
end;

COMMAND:Register();