--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("SalesmanEdit");

COMMAND.tip = "Edit a salesman at your target position.";
COMMAND.text = "[number Animation]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (target:GetClass() == "cw_salesman") then
			local salesmanTable = cwSalesmen:GetTableFromEntity(target);
			
			player.cwSalesmanSetup = true;
			player.cwSalesmanAnim = tonumber(arguments[1]);
			player.cwSalesmanPos = target:GetPos();
			player.cwSalesmanAng = target:GetAngles();
			player.cwSalesmanHitPos = player:GetEyeTraceNoCursor().HitPos;
			
			if (!player.cwSalesmanAnim and type(arguments[1]) == "string") then
				player.cwSalesmanAnim = tonumber(_G[arguments[1]]);
			end;
			
			if (!player.cwSalesmanAnim and salesmanTable.animation) then
				player.cwSalesmanAnim = salesmanTable.animation;
			end;
			
			Clockwork.datastream:Start(player, "SalesmanEdit", salesmanTable);
			
			for k, v in pairs(cwSalesmen.salesmen) do
				if (target == v) then
					target.cwCash = nil;
					target:Remove();
					cwSalesmen.salesmen[k] = nil;
					cwSalesmen:SaveSalesmen();
					
					return;
				end;
			end;
		else
			Clockwork.player:Notify(player, {"EntityNotSalesman"});
		end;
	else
		Clockwork.player:Notify(player, {"LookAtValidEntity"});
	end;
end;

COMMAND:Register();