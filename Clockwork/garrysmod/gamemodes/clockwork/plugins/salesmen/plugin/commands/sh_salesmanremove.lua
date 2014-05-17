--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("SalesmanRemove");
COMMAND.tip = "Remove a salesman at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (target:GetClass() == "cw_salesman") then
			for k, v in pairs(cwSalesmen.salesmen) do
				if (target == v) then
					target:Remove();
					cwSalesmen.salesmen[k] = nil;
					cwSalesmen:SaveSalesmen();
					
					Clockwork.player:Notify(player, "You have removed a salesman.");
					
					return;
				end;
			end;
		else
			Clockwork.player:Notify(player, "This entity is not a salesman!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

COMMAND:Register();