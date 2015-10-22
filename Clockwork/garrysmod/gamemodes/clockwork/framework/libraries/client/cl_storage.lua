--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;

Clockwork.storage = Clockwork.kernel:NewLibrary("Storage");

-- A function to get whether storage is open.
function Clockwork.storage:IsStorageOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

-- A function to get whether the local player can give to storage.
function Clockwork.storage:CanGiveTo(itemTable)
	local entity = Clockwork.storage:GetEntity();
	local isPlayer = (entity and entity:IsPlayer());
	
	if (itemTable) then
		local bAllowPlayerStorage = (!isPlayer or itemTable("allowPlayerStorage") != false);
		local bAllowEntityStorage = (isPlayer or itemTable("allowEntityStorage") != false);
		local bAllowPlayerGive = (!isPlayer or itemTable("allowPlayerGive") != false);
		local bAllowEntityGive = (isPlayer or itemTable("allowEntityGive") != false);
		local bAllowStorage = (itemTable("allowStorage") != false);
		local bIsShipment = (entity and entity:GetClass() == "cw_shipment");
		local bAllowGive = (itemTable("allowGive") != false);
		
		if (bIsShipment or (bAllowPlayerStorage and bAllowPlayerGive
		and bAllowEntityStorage and bAllowStorage and bAllowGive
		and bAllowEntityGive)) then
			return true;
		end;
	end;
end;

-- A function to get whether the local player can take from storage.
function Clockwork.storage:CanTakeFrom(itemTable)
	local entity = Clockwork.storage:GetEntity();
	local isPlayer = (entity and entity:IsPlayer());
	
	if (itemTable) then
		local bAllowPlayerStorage = (!isPlayer or itemTable("allowPlayerStorage") != false);
		local bAllowEntityStorage = (isPlayer or itemTable("allowEntityStorage") != false);
		local bAllowPlayerTake = (!isPlayer or itemTable("allowPlayerTake") != false);
		local bAllowEntityTake = (isPlayer or itemTable("allowEntityTake") != false);
		local bAllowStorage = (itemTable("allowStorage") != false);
		local bIsShipment = (entity and entity:GetClass() == "cw_shipment");
		local bAllowTake = (itemTable("allowTake") != false);
		
		if (bIsShipment or (bAllowPlayerStorage and bAllowPlayerTake
		and bAllowEntityStorage and bAllowStorage and bAllowTake
		and bAllowEntityTake)) then
			return true;
		end;
	end;
end;

-- A function to get whether there is no cash weight.
function Clockwork.storage:GetNoCashWeight()
	return self.noCashWeight;
end;

-- A function to get whether there is no cash space.
function Clockwork.storage:GetNoCashSpace()
	return self.noCashSpace;
end;

-- A function to get whether the storage is one sided.
function Clockwork.storage:GetIsOneSided()
	return self.isOneSided;
end;

-- A function to get the storage inventory.
function Clockwork.storage:GetInventory()
	return self.inventory;
end;

-- A function to get the storage cash.
function Clockwork.storage:GetCash()
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		return self.cash;
	else
		return 0;
	end;
end;

-- A function to get the storage panel.
function Clockwork.storage:GetPanel()
	return self.panel;
end;

-- A function to get the storage weight.
function Clockwork.storage:GetWeight()
	return self.weight;
end;

-- A function to get the storage space.
function Clockwork.storage:GetSpace()
	return self.space;
end;

-- A function to get the storage entity.
function Clockwork.storage:GetEntity()
	return self.entity;
end;

-- A function to get the storage name.
function Clockwork.storage:GetName()
	return self.name;
end;