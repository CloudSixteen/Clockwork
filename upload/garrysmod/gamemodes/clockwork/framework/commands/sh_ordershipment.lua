--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("OrderShipment");

COMMAND.tip = "CmdOrderShipment";
COMMAND.text = "CmdOrderShipmentDesc";
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
		Clockwork.player:Notify(player, {"NoAccessToOrderItem"});
		return false;
	end;
	
	if (!Clockwork.plugin:Call("PlayerCanOrderShipment", player, itemTable)) then
		return false;
	end;
	
	if (player.cwNextOrderTime and CurTime() < player.cwNextOrderTime) then
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
			
			if (itemTable("batch") > 1 and entity.cwInventory) then
				local itemTables = Clockwork.inventory:GetItemsByID(
					entity.cwInventory, itemTable("uniqueID")
				);
				
				for k, v in pairs(itemTables) do
					if (v.OnOrder) then
						v:OnOrder(player, entity);
					end;
				end;
				
				Clockwork.plugin:Call("PlayerOrderShipment", player, itemTable, entity, itemTables);
			else
				if (entity.GetItemTable) then
					itemTable = entity:GetItemTable();
				end;
				
				Clockwork.plugin:Call("PlayerOrderShipment", player, itemTable, entity);
				
				if (itemTable.OnOrder) then
					itemTable:OnOrder(player, entity);
				end;
			end;
			
			player.cwNextOrderTime = CurTime() + (2 * itemTable("batch"));
			Clockwork.datastream:Start(player, "OrderTime", player.cwNextOrderTime);
		else
			Clockwork.player:Notify(player, {"CannotOrderThatFarAway"});
		end;
	elseif (#itemTable.recipes > 0) then
		Clockwork.player:Notify(player, {"RequiredIngredientsMissing"});
	else
		local amount = (itemTable("cost") * itemTable("batch")) - player:GetCash();
		
		player:NotifyMissingCash(amount);
	end;
end;

COMMAND:Register();