--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharGiveItem");
COMMAND.tip = "Give an item to a character.";
COMMAND.text = "<string Name> <string Item>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.player:HasFlags(player, "G")) then
		local target = Clockwork.player:FindByID(arguments[1]);
		
		if (target) then
			local itemTable = Clockwork.item:FindByID(arguments[2]);
			
			if (itemTable and !itemTable.isBaseItem) then
				local itemTable = Clockwork.item:CreateInstance(itemTable("uniqueID"));
				local bSuccess, fault = target:GiveItem(itemTable, true);
				
				if (bSuccess) then
					if (string.sub(itemTable("name"), -1) == "s") then
						Clockwork.player:Notify(player, "You have given "..target:Name().." some "..itemTable("name")..".");
					else
						Clockwork.player:Notify(player, "You have given "..target:Name().." a "..itemTable("name")..".");
					end;
					
					if (player != target) then
						if (string.sub(itemTable("name"), -1) == "s") then
							Clockwork.player:Notify(target, player:Name().." has given you some "..itemTable("name")..".");
						else
							Clockwork.player:Notify(target, player:Name().." has given you a "..itemTable("name")..".");
						end;
					end;
				else
					Clockwork.player:Notify(player, target:Name().." does not have enough space for this item!");
				end;
			else
				Clockwork.player:Notify(player, "This is not a valid item!");
			end;
		else
			Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		Clockwork.player:Notify(player, "I'm sorry, it seems like you cannot be trusted with this command!");
	end;
end;

COMMAND:Register();