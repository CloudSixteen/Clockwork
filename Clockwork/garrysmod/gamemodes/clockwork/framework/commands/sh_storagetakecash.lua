--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local NAME_CASH = Clockwork.option:GetKey("name_cash");

local COMMAND = Clockwork.command:New("StorageTake"..string.gsub(NAME_CASH, "%s", ""));
COMMAND.tip = "Take some "..string.lower(NAME_CASH).." from storage.";
COMMAND.text = "<number "..string.gsub(NAME_CASH, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		local target = storageTable.entity;
		local cash = math.floor(tonumber(arguments[1]));
		
		if ((target and !IsValid(target)) or !Clockwork.config:Get("cash_enabled"):Get()) then
			return;
		end;
		
		if (cash and cash > 1 and cash <= storageTable.cash) then
			if (!storageTable.CanTakeCash
			or (storageTable.CanTakeCash(player, storageTable, cash) != false)) then
				if (!target or !target:IsPlayer()) then
					Clockwork.player:GiveCash(player, cash, nil, true);
					Clockwork.storage:UpdateCash(player, storageTable.cash - cash);
				else
					Clockwork.player:GiveCash(player, cash, nil, true);
					Clockwork.player:GiveCash(target, -cash, nil, true);
					Clockwork.storage:UpdateCash(player, target:GetCash());
				end;
				
				if (storageTable.OnTakeCash
				and storageTable.OnTakeCash(player, storageTable, cash)) then
					Clockwork.storage:Close(player);
				end;
			end;
		end;
	else
		Clockwork.player:Notify(player, "You do not have storage open!");
	end;
end;

COMMAND:Register();