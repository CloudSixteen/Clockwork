--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local ITEM = Clockwork.item:New();

ITEM.name = "Container Base";
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.weight = 2;
ITEM.category = "Storage";
ITEM.isRareItem = true;
ITEM.description = "A basic container to hold other items.";
ITEM.isContainer = true;
ITEM.storageWeight = 5;
ITEM.storageSpace = 10;

ITEM:AddData("Inventory", nil);
ITEM:AddData("Cash", 0);

function ITEM:OnSaved(newData)
	if (newData["Inventory"] != nil) then
		newData["Inventory"] = Clockwork.inventory:ToSaveable(newData["Inventory"]);
		
		if (CloudAuthX.Base64Encode) then
			newData["Inventory"] = "@"..CloudAuthX.Base64Encode(newData["Inventory"]);
		end;
	end;
end;

function ITEM:OnLoaded()
	local inventory = self("Inventory");
	
	if (inventory != nil) then
		if (CloudAuthX.Base64Decode and string.utf8sub(inventory, 1, 1) == "@") then
			inventory = CloudAuthX.Base64Decode(string.utf8sub(inventory, 2));
		end;
		
		self:SetData("Inventory", Clockwork.inventory:ToLoadable(inventory));
	end;
end;

if (SERVER) then
	function ITEM:GetInventory()
		local inventory = self:GetData("Inventory");
		
		if (inventory == nil) then
			self:SetData("Inventory", {});
		end;
		
		return inventory;
	end;
		
	function ITEM:HasItem(itemTable)
		if (type(itemTable) == "string") then
			Clockwork.inventory:HasItemByID(self:GetInventory(), itemTable);
		else
			Clockwork.inventory:HasItemInstance(self:GetInventory(), itemTable);
		end;
	end;

	function ITEM:RemoveFromInventory(itemTable)
		if (type(itemTable) == "string") then
			Clockwork.inventory:RemoveUniqueID(self:GetInventory(), itemTable);
		else
			Clockwork.inventory:RemoveInstance(self:GetInventory(), itemTable);
		end;
	end;

	function ITEM:InventoryAsItemsList()
		return Clockwork.inventory:GetAsItemsList(self:GetInventory());
	end;

	function ITEM:AddToInventory(itemTable)
		Clockwork.inventory:AddInstance(self:GetInventory(), itemTable);
	end;

	function ITEM:GetCash()
		return self("Cash");
	end;
end;

function ITEM:OnUse(player, itemEntity)
	self:OpenFor(player, itemEntity);
	
	return false;
end;

function ITEM:OpenFor(player, itemEntity)
	local inventory = self:GetInventory();
	local cash = self:GetCash();
	local name = self("name");
	
	Clockwork.storage:Open(player, {
		name = name,
		weight = self("storageWeight"),
		space = self("storageSpace"),
		entity = itemEntity or false,
		distance = 192,
		cash = cash,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			self:SetData("Cash", self:GetCash() + cash);
		end,
		OnTakeCash = function(player, storageTable, cash)
			self:SetData("Cash", self:GetCash() - cash);
		end
	});
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();
