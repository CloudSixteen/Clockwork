--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("StorageClose");
COMMAND.tip = "Close the active storage.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		Clockwork.storage:Close(player, true);
	else
		Clockwork.player:Notify(player, "You do not have storage open!");
	end;
end;

COMMAND:Register();