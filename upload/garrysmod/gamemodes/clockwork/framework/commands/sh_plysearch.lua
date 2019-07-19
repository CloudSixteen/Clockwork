--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("PlySearch");

COMMAND.tip = "CmdPlySearch";
COMMAND.text = "CmdPlySearchDesc";
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
						
					end,
					OnGiveItem = function(player, storageTable, itemTable)
						
					end
				});
			else
				Clockwork.player:Notify(player, {"YouAreAlreadySearchingCharacter"});
			end;
		else
			Clockwork.player:Notify(player, {"PlayerAlreadyBeingSearched", target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();