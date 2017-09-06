--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;

Clockwork.storage = Clockwork.kernel:NewLibrary("Storage");

--[[
	@codebase Client
	@details A function to get whether storage is open.
	@returns {Unknown}
--]]
function Clockwork.storage:IsStorageOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether the local player can give to storage.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.storage:CanGiveTo(itemTable)
	local entity = Clockwork.storage:GetEntity();
	local isPlayer = (entity and entity:IsPlayer());
	
	if (itemTable) then
		local allowPlayerStorage = (!isPlayer or itemTable("allowPlayerStorage") != false);
		local allowEntityStorage = (isPlayer or itemTable("allowEntityStorage") != false);
		local allowPlayerGive = (!isPlayer or itemTable("allowPlayerGive") != false);
		local allowEntityGive = (isPlayer or itemTable("allowEntityGive") != false);
		local allowStorage = (itemTable("allowStorage") != false);
		local isShipment = (entity and entity:GetClass() == "cw_shipment");
		local allowGive = (itemTable("allowGive") != false);
		
		if (isShipment or (allowPlayerStorage and allowPlayerGive
		and allowEntityStorage and allowStorage and allowGive
		and allowEntityGive)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether the local player can take from storage.
	@param {Unknown} Missing description for itemTable.
	@returns {Unknown}
--]]
function Clockwork.storage:CanTakeFrom(itemTable)
	local entity = Clockwork.storage:GetEntity();
	local isPlayer = (entity and entity:IsPlayer());
	
	if (itemTable) then
		local allowPlayerStorage = (!isPlayer or itemTable("allowPlayerStorage") != false);
		local allowEntityStorage = (isPlayer or itemTable("allowEntityStorage") != false);
		local allowPlayerTake = (!isPlayer or itemTable("allowPlayerTake") != false);
		local allowEntityTake = (isPlayer or itemTable("allowEntityTake") != false);
		local allowStorage = (itemTable("allowStorage") != false);
		local isShipment = (entity and entity:GetClass() == "cw_shipment");
		local allowTake = (itemTable("allowTake") != false);
		
		if (isShipment or (allowPlayerStorage and allowPlayerTake
		and allowEntityStorage and allowStorage and allowTake
		and allowEntityTake)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether there is no cash weight.
	@returns {Unknown}
--]]
function Clockwork.storage:GetNoCashWeight()
	return self.noCashWeight;
end;

--[[
	@codebase Client
	@details A function to get whether there is no cash space.
	@returns {Unknown}
--]]
function Clockwork.storage:GetNoCashSpace()
	return self.noCashSpace;
end;

--[[
	@codebase Client
	@details A function to get whether the storage is one sided.
	@returns {Unknown}
--]]
function Clockwork.storage:GetIsOneSided()
	return self.isOneSided;
end;

--[[
	@codebase Client
	@details A function to get the storage inventory.
	@returns {Unknown}
--]]
function Clockwork.storage:GetInventory()
	return self.inventory;
end;

--[[
	@codebase Client
	@details A function to get the storage cash.
	@returns {Unknown}
--]]
function Clockwork.storage:GetCash()
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		return self.cash;
	else
		return 0;
	end;
end;

--[[
	@codebase Client
	@details A function to get the storage panel.
	@returns {Unknown}
--]]
function Clockwork.storage:GetPanel()
	return self.panel;
end;

--[[
	@codebase Client
	@details A function to get the storage weight.
	@returns {Unknown}
--]]
function Clockwork.storage:GetWeight()
	return self.weight;
end;

--[[
	@codebase Client
	@details A function to get the storage space.
	@returns {Unknown}
--]]
function Clockwork.storage:GetSpace()
	return self.space;
end;

--[[
	@codebase Client
	@details A function to get the storage entity.
	@returns {Unknown}
--]]
function Clockwork.storage:GetEntity()
	return self.entity;
end;

--[[
	@codebase Client
	@details A function to get the storage name.
	@returns {Unknown}
--]]
function Clockwork.storage:GetName()
	return self.name;
end;