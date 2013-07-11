--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("StorageGiveItem");
COMMAND.tip = "Give an item to storage.";
COMMAND.text = "<string UniqueID> <string ItemID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	local uniqueID = arguments[1];
	local itemID = tonumber(arguments[2]);
	
	if (storageTable and IsValid(storageTable.entity)) then
		local itemTable = player:FindItemByID(uniqueID, itemID);
		local target = storageTable.entity;
		
		if (!itemTable) then
			Clockwork.player:Notify(player, "You do not have an instance of this item!");
			return;
		end;
		
		if (storageTable.isOneSided) then
			Clockwork.player:Notify(player, "You cannot give items to this container!");
			return;
		end;
		
		Clockwork.storage:GiveTo(player, itemTable);
	else
		Clockwork.player:Notify(player, "You do not have storage open!");
	end;
end;

COMMAND:Register();