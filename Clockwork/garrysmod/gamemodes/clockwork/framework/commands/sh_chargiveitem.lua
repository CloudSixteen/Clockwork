--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local amountTable = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"};

local COMMAND = Clockwork.command:New("CharGiveItem");
COMMAND.tip = "Give an item to a character.";
COMMAND.text = "<string Name> <string Item> [number Amount]";
COMMAND.access = "s";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;
COMMAND.alias = {"PlyGiveItem"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.player:HasFlags(player, "G")) then
		local target = Clockwork.player:FindByID(arguments[1]);
		local amount = tonumber(arguments[3]) or 1;
		
		if (target) then
			if (amount > 0 and amount <= 10) then
				local itemTable = Clockwork.item:FindByID(arguments[2]);
			
				if (itemTable and !itemTable.isBaseItem) then
					for i = 1, amount do
						local itemTable = Clockwork.item:CreateInstance(itemTable("uniqueID"));
						local bSuccess, fault = target:GiveItem(itemTable, true);
				
						if (!bSuccess) then
							Clockwork.player:Notify(player, fault);

							break;
						end;
					end;

					if (string.utf8sub(itemTable("name"), -1) == "s" and amount == 1) then
						Clockwork.player:Notify(player, "You have given "..target:Name().." some "..itemTable("name")..".");
					elseif (amount > 1) then
						Clockwork.player:Notify(player, "You have given "..target:Name().." "..amountTable[amount].." "..Clockwork.kernel:Pluralize(itemTable("name"))..".");
					else
						Clockwork.player:Notify(player, "You have given "..target:Name().." a "..itemTable("name")..".");
					end;
					
					if (player != target) then
						if (string.utf8sub(itemTable("name"), -1) == "s" and amount == 1) then
							Clockwork.player:Notify(target, player:Name().." has given you some "..itemTable("name")..".");
						elseif (amount > 1) then
							Clockwork.player:Notify(target, player:Name().." has given you "..amountTable[amount].." "..Clockwork.kernel:Pluralize(itemTable("name"))..".");
						else
							Clockwork.player:Notify(target, player:Name().." has given you a "..itemTable("name")..".");
						end;
					end;
				else
					Clockwork.player:Notify(player, "This is not a valid item!");
				end;
			else
				Clockwork.player:Notify(player, "You must specify an amount between 1 and 10!");
			end;
		else
			Clockwork.player:Notify(player, L(player, "NotValidCharacter", arguments[1]));
		end;
	else
		Clockwork.player:Notify(player, "I'm sorry, it seems like you cannot be trusted with this command!");
	end;
end;

COMMAND:Register();