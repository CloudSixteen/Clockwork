--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("PlySearch");
COMMAND.tip = "Search a players inventory.";
COMMAND.text = "<string Name>";
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		if (!target.cwBeingSearched) then
			if (!player.cwSearching) then
				target.cwBeingSearched = true;
				player.cwSearching = target;
				
				Clockwork.storage:Open(player, {
					name = target:Name(),
					cash = target:GetCash(),
					weight = target:GetMaxWeight(),
					space = target:GetMaxSpace(),
					entity = target,
					inventory = target:GetInventory(),
					OnClose = function(player, storageTable, entity)
						player.cwSearching = nil;
						
						if (IsValid(entity)) then
							entity.cwBeingSearched = nil;
						end;
					end,
					OnTakeItem = function(player, storageTable, itemTable)
						local target = Clockwork.entity:GetPlayer(storageTable.entity);
						if (target) then
							if (target:GetCharacterData("clothes") == itemTable.index) then
								if (!target:HasItemByID(itemTable.index)) then
									target:SetCharacterData("clothes", nil);
									
									if (itemTable.OnChangeClothes) then
										itemTable:OnChangeClothes(target, false);
									end;
								end;
							end;
						end;
					end,
					OnGiveItem = function(player, storageTable, itemTable)
						if (player:GetCharacterData("clothes") == itemTable.index) then
							if (!player:HasItemByID(itemTable.index)) then
								player:SetCharacterData("clothes", nil);
								
								if (itemTable.OnChangeClothes) then
									itemTable:OnChangeClothes(player, false);
								end;
							end;
						end;
					end
				});
			else
				Clockwork.player:Notify(player, "You are already searching a character!");
			end;
		else
			Clockwork.player:Notify(player, target:Name().." is already being searched!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();