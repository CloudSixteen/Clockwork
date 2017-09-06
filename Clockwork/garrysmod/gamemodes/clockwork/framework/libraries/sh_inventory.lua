--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;
local IsValid = IsValid;
local pairs = pairs;
local string = string;
local table = table;

Clockwork.inventory = Clockwork.kernel:NewLibrary("Inventory");

-- A function to add an instance to a table.
function Clockwork.inventory:AddInstance(inventory, itemTable, quantity)
	quantity = quantity or 1;

	if (itemTable == nil) then
		return false;
	end;

	if (!itemTable:IsInstance()) then
		debug.Trace();
		return false;
	end;
	
	if (!inventory[itemTable("uniqueID")]) then
		inventory[itemTable("uniqueID")] = {};
	end;
	
	inventory[itemTable("uniqueID")][itemTable("itemID")] = itemTable;
	
	if (quantity != 1) then
		self:AddInstance(inventory, Clockwork.item:CreateInstance(itemTable("uniqueID")), quantity - 1);
	end;
	
	return itemTable;
end;

-- A function to calculate the space of an inventory.
function Clockwork.inventory:CalculateSpace(inventory)
	local space = 0;
	
	for k, v in pairs(self:GetAsItemsList(inventory)) do
		local spaceUsed = v("space");
		if (spaceUsed) then space = space + spaceUsed; end;
	end;
	
	return space;
end;

-- A function to calculate the weight of an inventory.
function Clockwork.inventory:CalculateWeight(inventory)
	local weight = 0;
	
	for k, v in pairs(self:GetAsItemsList(inventory)) do
		if (v("weight")) then
			weight = weight + v("weight");
		end;
	end;
	
	return weight;
end;

-- A function to create a duplicate of an inventory.
function Clockwork.inventory:CreateDuplicate(inventory)
	local duplicate = {};
		for k, v in pairs(inventory) do
			duplicate[k] = {};
			for k2, v2 in pairs(v) do
				duplicate[k][k2] = v2;
			end;
		end;
	return duplicate;
end;

-- A function to find an item within an inventory by ID.
function Clockwork.inventory:FindItemByID(inventory, uniqueID, itemID)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	
	if (!inventory) then
		debug.Trace();
		return;
	end;
	
	if (itemID) then
		itemID = tonumber(itemID);
	end;
	
	if (!itemTable or !inventory[itemTable("uniqueID")]) then
		return;
	end;
	
	local itemsList = inventory[itemTable("uniqueID")];
	
	if (itemID) then
		if (itemsList) then
			return itemsList[itemID];
		end;
	else
		local firstValue = table.GetFirstValue(itemsList);
		if (firstValue) then
			return itemsList[firstValue.itemID];
		end;
	end;
end;

-- A function to find an item within an inventory by name.
function Clockwork.inventory:FindItemByName(inventory, uniqueID, name)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	
	if (!itemTable or !inventory[itemTable("uniqueID")]) then
		return;
	end;
	
	for k, v in pairs(inventory[itemTable("uniqueID")]) do
		if (string.lower(v("name")) == string.lower(name)) then
			return v;
		end;
	end;
end;

-- A function to get an inventory's items by unique ID.
function Clockwork.inventory:GetItemsByID(inventory, uniqueID)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	
	if (itemTable) then
		return inventory[itemTable("uniqueID")];
	else
		return {};
	end;
end;

-- A function to find an item within an inventory by name.
function Clockwork.inventory:FindItemsByName(inventory, uniqueID, name)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	local itemsList = {};
	
	if (!itemTable or !inventory[itemTable("uniqueID")]) then
		return;
	end;
	
	for k, v in pairs(inventory[itemTable("uniqueID")]) do
		if (string.lower(v("name")) == string.lower(name)) then
			itemsList[#itemsList + 1] = v;
		end;
	end;
	
	return itemsList;
end;

-- A function to get an inventory as an items list.
function Clockwork.inventory:GetAsItemsList(inventory)
	local itemsList = {};
	
	for k, v in pairs(inventory) do
		table.Add(itemsList, v);
	end;
	
	return itemsList;
end;

--[[
	@codebase Shared
	@details A function to get the amount of items an entity has in its inventory by ID.
	@param {Table} Inventory of the entity.
	@param {Number} ID of item looked up in the inventory to get the amount.
	@returns {Number} Number of items in the inventory that match the ID.
--]]
function Clockwork.inventory:GetItemCountByID(inventory, uniqueID)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	
	if (itemTable and inventory[itemTable("uniqueID")]) then
		return table.Count(inventory[itemTable("uniqueID")]);
	else
		return 0;
	end;
end;

-- A function to get whether an inventory has an item by ID.
function Clockwork.inventory:HasItemByID(inventory, uniqueID)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	
	if (itemTable) then
		return (inventory[itemTable("uniqueID")] and table.Count(inventory[itemTable("uniqueID")]) > 0);
	else
		return false;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a player has a specific amount of items in their inventory by ID.
	@param {Table} Inventory of the entity.
	@param {Number} ID of the item being checked for its amount in the inventory.
	@param {Number} Amount of items the entity needs to have in order to return true.
	@returns {Bool} Whether the entity has a specific amount of items in its inventory or not.
--]]
function Clockwork.inventory:HasItemCountByID(inventory, uniqueID, amount)
	local amountInInventory = self:GetItemCountByID(inventory, uniqueID);
	
	if (amountInInventory >= amount) then
		return true;
	else
		return false;
	end;
end;

-- A function to get whether an inventory item instance.
function Clockwork.inventory:HasItemInstance(inventory, itemTable)
	local uniqueID = itemTable("uniqueID");
	return (inventory[uniqueID] and inventory[uniqueID][itemTable("itemID")] != nil);
end;

-- A function to get whether an inventory is empty.
function Clockwork.inventory:IsEmpty(inventory)
	if (!inventory) then return true; end;
	local bEmpty = true;
	
	for k, v in pairs(inventory) do
		if (table.Count(v) > 0) then
			return false;
		end;
	end;
	
	return true;
end;

-- A function to remove an instance from a table.
function Clockwork.inventory:RemoveInstance(inventory, itemTable)
	if (!itemTable:IsInstance()) then
		debug.Trace();
		return false;
	end;
	
	if (inventory[itemTable("uniqueID")]) then
		inventory[itemTable("uniqueID")][itemTable("itemID")] = nil;
		return Clockwork.item:FindInstance(itemTable("itemID"));
	end;
end;

-- A function to remove a uniquen ID from a table.
function Clockwork.inventory:RemoveUniqueID(inventory, uniqueID, itemID)
	local itemTable = Clockwork.item:FindByID(uniqueID);
	if (itemID) then itemID = tonumber(itemID); end;
	
	if (itemTable and inventory[itemTable("uniqueID")]) then
		if (!itemID) then
			local firstValue = table.GetFirstValue(inventory[itemTable("uniqueID")]);
			
			if (firstValue) then
				inventory[itemTable("uniqueID")][firstValue.itemID] = nil;
				return Clockwork.item:FindInstance(firstValue.itemID);
			end;
		else
			inventory[itemTable("uniqueID")][itemID] = nil;
		end;
	end;
end;

-- A function to make an inventory loadable.
function Clockwork.inventory:ToLoadable(inventory)
	local newTable = {};

	for k, v in pairs(inventory) do
		local itemTable = Clockwork.item:FindByID(k);
		
		if (itemTable) then
			local uniqueID = itemTable("uniqueID");

			if (uniqueID != k) then
				continue;
			end;
			
			if (!newTable[uniqueID]) then
				newTable[uniqueID] = {};
			end;
			
			for k2, v2 in pairs(v) do
				local itemID = tonumber(k2);
				local instance = Clockwork.item:CreateInstance(
					k, itemID, v2
				);
				
				if (instance and !instance.OnLoaded
				or instance:OnLoaded() != false) then
					newTable[uniqueID][itemID] = instance;
				end;
			end;
		end;
	end;
	
	return newTable;
end;

-- A function to make an inventory saveable.
function Clockwork.inventory:ToSaveable(inventory)
	local newTable = {};
	
	for k, v in pairs(inventory) do
		local itemTable = Clockwork.item:FindByID(k);
		
		if (itemTable) then
			local defaultData = itemTable("defaultData");
			local uniqueID = itemTable("uniqueID");
			
			if (!newTable[uniqueID]) then
				newTable[uniqueID] = {};
			end;
			
			for k2, v2 in pairs(v) do
				if (type(v2) == "table"
				and (v2.IsInstance and v2:IsInstance())) then
					local newData = {};
					local itemID = tostring(k2);
					
					for k3, v3 in pairs(v2("data")) do
						if (defaultData[k3] != v3) then
							newData[k3] = v3;
						end;
					end;
					
					if (!v2.OnSaved
					or v2:OnSaved(newData) != false) then
						newTable[uniqueID][itemID] = newData;
					end;
				end;
			end;
		end
	end;
	
	return newTable;
end;

-- A function to get whether we should use the space system.
function Clockwork.inventory:UseSpaceSystem()
	return Clockwork.config:Get("enable_space_system"):Get();
end;

if (CLIENT) then
	Clockwork.inventory.client = {};
	
	-- A function to get the local player's inventory.
	function Clockwork.inventory:GetClient()
		return self.client;
	end;
	
	-- A function to get the inventory panel.
	function Clockwork.inventory:GetPanel()
		return self.panel;
	end;
	
	-- A function to get whether the client has an item equipped.
	function Clockwork.inventory:HasEquipped(itemTable)
		if (itemTable.HasPlayerEquipped) then
			return (itemTable:HasPlayerEquipped(Clockwork.Client) == true);
		end;
		
		return false;
	end;
	
	-- A function to rebuild the local player's inventory.
	function Clockwork.inventory:Rebuild(bForceRebuild)
		if (Clockwork.menu:IsPanelActive(self:GetPanel()) or bForceRebuild) then
			Clockwork.kernel:OnNextFrame("RebuildInv", function()
				if (IsValid(self:GetPanel())) then
					self:GetPanel():Rebuild();
				end;
			end);
		end;
	end;
	
	Clockwork.datastream:Hook("InvClear", function(data)
		Clockwork.inventory.client = {};
		Clockwork.inventory:Rebuild();
	end);

	Clockwork.datastream:Hook("InvGive", function(data)
		local itemTable = Clockwork.item:CreateInstance(
			data.index, data.itemID, data.data
		);
		
		Clockwork.inventory:AddInstance(
			Clockwork.inventory.client, itemTable
		);
		
		Clockwork.inventory:Rebuild();
		Clockwork.plugin:Call("PlayerItemGiven", itemTable);
	end);
	
	Clockwork.datastream:Hook("InvNetwork", function(data)
		local itemTable = Clockwork.item:FindInstance(data.itemID);
		
		if (itemTable) then
			local bHasEquipped = Clockwork.inventory:HasEquipped(itemTable);
			
			table.Merge(itemTable("data"), data.data);
			Clockwork.plugin:Call("ItemNetworkDataUpdated", itemTable, data.data);
			
			if (bHasEquipped != Clockwork.inventory:HasEquipped(itemTable)) then
				Clockwork.inventory:Rebuild(
					Clockwork.menu:GetOpen()
				);
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("InvRebuild", function(data)
		Clockwork.inventory:Rebuild();
	end);
	
	Clockwork.datastream:Hook("InvTake", function(data)
		local itemTable = Clockwork.inventory:FindItemByID(
			Clockwork.inventory.client, data[1], data[2]
		);
		
		if (itemTable) then
			Clockwork.inventory:RemoveInstance(
				Clockwork.inventory.client, itemTable
			);
			
			Clockwork.inventory:Rebuild();
			Clockwork.plugin:Call("PlayerItemTaken", itemTable);
		end;
	end);
	
	Clockwork.datastream:Hook("InvUpdate", function(data)
		for k, v in pairs(data) do
			local itemTable = Clockwork.item:CreateInstance(
				v.index, v.itemID, v.data
			);
			
			Clockwork.inventory:AddInstance(
				Clockwork.inventory.client, itemTable
			);
		end;
		
		Clockwork.inventory:Rebuild();
	end);
end;