--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("StorageTakeItem");
COMMAND.tip = "Take an item from storage.";
COMMAND.text = "<string uniqueID> <string ItemID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	local uniqueID = arguments[1];
	local itemID = tonumber(arguments[2]);
	
	if (storageTable and IsValid(storageTable.entity)) then
		local itemTable = Clockwork.inventory:FindItemByID(
			storageTable.inventory, uniqueID, itemID
		);
		
		if (!itemTable) then
			Clockwork.player:Notify(player, "The storage does not contain an instance of this item!");
			return;
		end;
		
		Clockwork.storage:TakeFrom(player, itemTable);
	else
		Clockwork.player:Notify(player, "You do not have storage open!");
	end;
end;

COMMAND:Register();