--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("OrderShipment");
COMMAND.tip = "Order an item shipment at your target position.";
COMMAND.text = "<string UniqueID>";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER);
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local itemTable = Clockwork.item:FindByID(arguments[1]);
	
	if (!itemTable or !itemTable:CanBeOrdered()) then
		return false;
	end;
	
	itemTable = Clockwork.item:CreateInstance(itemTable("uniqueID"));
	Clockwork.plugin:Call("PlayerAdjustOrderItemTable", player, itemTable);
	
	if (!Clockwork.kernel:HasObjectAccess(player, itemTable)) then
		Clockwork.player:Notify(player, "You not have access to order this item!");
		return false;
	end;
	
	if (!Clockwork.plugin:Call("PlayerCanOrderShipment", player, itemTable)) then
		return false;
	end;
	
	if (itemTable:CanPlayerAfford(player)) then
		local trace = player:GetEyeTraceNoCursor();
		local entity = nil;

		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if (itemTable.CanOrder and itemTable:CanOrder(player, v) == false) then
				return false;
			end;
			
			if (itemTable.OnCreateShipmentEntity) then
				entity = itemTable:OnCreateShipmentEntity(player, itemTable("batch"), trace.HitPos);
			end;
			
			if (!IsValid(entity)) then
				if (itemTable("batch") > 1) then
					entity = Clockwork.entity:CreateShipment(player, itemTable("uniqueID"), itemTable("batch"), trace.HitPos);
				else
					entity = Clockwork.entity:CreateItem(player, itemTable, trace.HitPos);
				end;
			end;
			
			if (IsValid(entity)) then
				Clockwork.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
			end;
			
			itemTable:DeductFunds(player);
			
			if (itemTable.OnOrder) then
				itemTable:OnOrder(player, entity);
			end;
			
			Clockwork.plugin:Call("PlayerOrderShipment", player, itemTable, entity);
			player.cwNextOrderTime = CurTime() + (2 * itemTable("batch"));
			
			Clockwork.datastream:Start(player, "OrderTime", player.cwNextOrderTime);
		else
			Clockwork.player:Notify(player, "You cannot order this item that far away!");
		end;
	elseif (#itemTable.recipes > 0) then
		Clockwork.player:Notify(player, "You do not have the required ingredients to craft this recipe!");
	else
		local amount = (itemTable("cost") * itemTable("batch")) - player:GetCash();
		Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(amount, nil, true).."!");
	end;
end;

COMMAND:Register();