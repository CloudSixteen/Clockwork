--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;
local table = table;
local type = type;

--[[
	@codebase Shared
	@details A library for adding blueprints that a player can craft.
	@member buffer A table of values in the buffer.
	@member stored A table of stored values.
	@member version The current version of this Crafting library.
--]]
Clockwork.crafting = Clockwork.kernel:NewLibrary("Crafting");
Clockwork.crafting.buffer = {};
Clockwork.crafting.stored = {};
Clockwork.crafting.version = "1.0.0";

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

CLASS_TABLE.name = "";
CLASS_TABLE.model = "";
CLASS_TABLE.category = "";
CLASS_TABLE.description = "";
CLASS_TABLE.itemRequirements = {};
CLASS_TABLE.takeCash = 0;
CLASS_TABLE.giveCash = 0;
CLASS_TABLE.takeItems = {};
CLASS_TABLE.giveItems = {};

--[[
	@codebase Shared
	@details Called when the blueprint is invoked as a function. Whenever getting a value from a blueprintTable you should always do blueprintTable("varName") instead of blueprintTable.varName so that the query system is used. Note: it would be advised not to use blueprintTable("varName") during a query proxy or a stack overflow may be caused.
	@param {String}
	@param {Bool}
--]]
function CLASS_TABLE:__call(varName, failSafe)
	if (self.queryProxies[varName]) then
		local bNotDefault = self.queryProxies[varName].bNotDefault;
		local dataName = self.queryProxies[varName].dataName;
		
		if (type(dataName) != "function") then
			local defaultValue = self.defaultData[dataName];
			local currentValue = self.data[dataName];
			
			if (defaultValue != nil and currentValue != nil and (defaultValue != currentValue or !bNotDefault)) then
				return self.data[dataName];
			end;
		else
			local returnValue = dataName(self);
			if (returnValue != nil) then
				return returnValue;
			end;
		end;
	end;
	
	return (self[varName] != nil and self[varName] or failSafe);
end;

--[[
	@codebase Shared
	@details Called when the item is converted to a string.
	@returns {String} The blueprint converted to a string.
--]]
function CLASS_TABLE:__tostring()
	return "BLUEPRINT[" ..self("blueprintID").. "]";
end;

--[[
	@codebase Shared
	@details Called when checking if an item can be crafted.
	@param {Entity} Player crafting the blueprint.
--]]
function CLASS_TABLE:CanCraft(player) end;

--[[
	@codebase Shared
	@details Called when crafting is unsuccessful.
	@param {Entity} Player crafting the blueprint.
--]]
function CLASS_TABLE:FailedCraft(player) end;

--[[
	@codebase Shared
	@details A function to get whether the item is an instance.
	@returns {Bool} Whether the blueprint is an instance or not.
--]]
function CLASS_TABLE:IsInstance() return (self("itemID") != 0); end;

--[[
	@codebase Shared
	@details Called just before crafting.
	@param {Entity} Player crafting the blueprint.
--]]
function CLASS_TABLE:OnCraft(player) end;

--[[
	@codebase Shared
	@details A function to override an item's base data. This is just a nicer way to set a value to go along with the method of querying.
--]]
function CLASS_TABLE:Override(varName, value)
	self[varName] = value;
end;

--[[
	@codebase Shared
	@details Called just after crafting.
	@param {Entity} Player crafting the blueprint.
--]]
function CLASS_TABLE:PostCraft(player) end;

--[[
	@codebase Shared
	@details A function to register a new blueprint.
--]]
function CLASS_TABLE:Register()
	return Clockwork.crafting:Register(self);
end;

--[[
	@codebase Shared
	@details A function to craft a blueprint.
	@param {Entity} Player crafting the blueprint.
	@param {Table} Blueprint being crafted.
--]]
function Clockwork.crafting:Craft(player, blueprintTable)
	if (type(blueprintTable) == "string") then
		blueprintTable = Clockwork.crafting:FindByID(blueprintTable);
	end;
	
	if (!blueprintTable or !blueprintTable:IsInstance()) then
		debug.Trace();
		
		return false, {"ErrorCraftingNonInstance"};
	end;
	
	local canCraft, message = Clockwork.crafting:CanCraft(player, blueprintTable);
	
	if (canCraft) then
		if (message) then
			message = {"SuccessfulCraftWithMsg", {blueprintTable("name")}, message};
		else
			message = {"SuccessfulCraft", {blueprintTable("name")}};
		end;
		
		blueprintTable:OnCraft(player);
		
		Clockwork.crafting:TakeItems(player, blueprintTable);
		Clockwork.crafting:GiveItems(player, blueprintTable);
		
		Clockwork.player:GiveCash(player, blueprintTable("giveCash"), "", true);
		Clockwork.player:GiveCash(player, -blueprintTable("takeCash"), "", true);
		
		blueprintTable:PostCraft(player);
		
		Clockwork.player:Notify(player, message);
	else
		message = {"ErrorCraftingWithMsg", {blueprintTable("name")}, message};
		
		blueprintTable:FailedCraft(player);
		
		Clockwork.player:Notify(player, message);
	end;
end;

--[[
	@codebase Shared
	@details A function to check if an item can be crafted.
	@param {Entity} Player crafting the blueprint.
	@param {Table} Blueprint being crafted.
--]]
function Clockwork.crafting:CanCraft(player, blueprintTable)
	if (!Clockwork.kernel:HasObjectAccess(player, blueprintTable)) then
		return false, {"CraftErrorNotAllowed"};
	end;
	
	local requirements = blueprintTable.itemRequirements;
	
	if (player:GetCash() < blueprintTable.takeCash) then
		return false, {"YouCannotAffordToDoThat"};
	end;
	
	local canCraft = false;
	local itemsChecked = {};
	
	if (type(requirements) == "table") then
		for k, v in pairs (requirements) do
			if (type(k) == "number" and type(v) == "string") then
				canCraft, itemsChecked[#itemsChecked + 1] = Clockwork.crafting:CheckCanCraft(player, v, 1);
				
				if (!canCraft) then
					return false, {"MissingItemRequirements"};
				end;
			elseif (type(k) == "string" and type(v) == "number") then
				canCraft, itemsChecked[#itemsChecked + 1] = Clockwork.crafting:CheckCanCraft(player, k, v);
				
				if (!canCraft) then
					return false, {"MissingItemRequirements"};
				end;
			elseif (type(v) == "table") then
				local amount, item = nil;
				
				if (type(v[1]) == "number") then
					canCraft, itemsChecked[#itemsChecked + 1] = Clockwork.crafting:CheckCanCraft(player, v[2], v[1]);
					
					if (!canCraft) then
						return false, {"MissingItemRequirements"};
					end;
				elseif (type(v[2]) == "number") then
					canCraft, itemsChecked[#itemsChecked + 1] = Clockwork.crafting:CheckCanCraft(player, v[1], v[2]);
					
					if (!canCraft) then
						return false, {"MissingItemRequirements"};
					end;
				end;
			end;
		end;
	elseif (type(requirements) == "string") then
		canCraft, itemsChecked[#itemsChecked + 1] = Clockwork.crafting:CheckCanCraft(player, requirements, 1);
		
		if (!canCraft) then
			return false, {"MissingItemRequirements"};
		end;
	end;
	
	local itemsWeight = 0;
	local itemsSpace = 0;
	
	for k, v in pairs (itemsChecked) do
		local itemTable = Clockwork.item:FindByID(v);
		
		if (itemTable) then
			itemsWeight = itemsWeight + itemTable("weight");
		end;
	end;
	
	for k, v in pairs (itemsChecked) do
		local itemTable = Clockwork.item:FindByID(v);
		
		if (itemTable) then
			itemsSpace = itemsSpace + itemTable("space");
		end;
	end;
	
	if (!player:CanHoldWeight(itemsWeight)) then
		return false, {"YourInventoryFull"};
	end;
	
	if (!player:CanHoldSpace(itemsSpace)) then
		return false, {"YourInventoryFull"};
	end;
	
	if (blueprintTable.CanCraft) then
		local canCraft = blueprintTable:CanCraft(player);

		if (isbool(canCraft)) then
			return canCraft;
		end;
	end;
	
	return true, "";
end;

--[[
	@codebase Shared
	@details Checks if the player has the items required to craft the blueprint.
	@param {Entity} Player crafting the blueprint.
	@param {String} ID of the item being checked.
	@param {Number} Amount of items the player needs to have.
	@returns {Bool} Whether player can craft the blueprint.
	@returns {String} ID of the item that was checked.
--]]
function Clockwork.crafting:CheckCanCraft(player, item, amount)
	if (player and item and amount) then
		if (amount > 1) then
			if (!player:HasItemCountByID(item, amount)) then
				return false, item;
			end;
		elseif (!player:HasItemByID(item)) then
			return false, item;
		end;
	end;
	
	return true, item;
end;

--[[
	@codebase Shared
	@details Gets the formatted requirement dependent on whether an inventory has the required ingredients.
	@param {Table} The inventory to check against.
	@param {String} ID of the item being checked.
	@param {Number} Amount of items the player needs to have.
	@returns {String} Formatted requirement.
--]]
function Clockwork.crafting:CheckFormatRequirements(inventory, uniqueID, amount)
	local requirement = nil;
	
	if (inventory and uniqueID and amount) then
		local itemTable = Clockwork.item:FindByID(uniqueID);
		
		if (itemTable) then
			local positiveColor = Clockwork.option:GetColor("positive_hint");
			local negativeColor = Clockwork.option:GetColor("negative_hint");
			
			if (amount > 1) then
				if (Clockwork.inventory:HasItemCountByID(inventory, uniqueID, amount)) then
					requirement = Clockwork.kernel:MarkupTextWithColor(L("AmountOfThing", amount, L(itemTable("name"))), positiveColor);
				else
					requirement = Clockwork.kernel:MarkupTextWithColor(L("AmountOfThing", amount, L(itemTable("name"))), negativeColor);
				end;
			else
				if (Clockwork.inventory:HasItemByID(inventory, uniqueID)) then
					requirement = Clockwork.kernel:MarkupTextWithColor(L("AmountOfThing", amount, L(itemTable("name"))), positiveColor);
				else
					requirement = Clockwork.kernel:MarkupTextWithColor(L("AmountOfThing", amount, L(itemTable("name"))), negativeColor);
				end;
			end;
		end;
	end;
	
	return requirement;
end;

--[[
	@codebase Shared
	@details Gives the player items crafted from the blueprint.
	@param {Entity} Player being given the items.
	@param {String} ID of the item being given.
	@param {Number} Amount of items to give.
--]]
function Clockwork.crafting:CheckGiveItems(player, item, amount)
	if (player and item and amount) then
		if (amount > 1) then
			local itemsToGive = {};
			
			for i = 1, amount do
				itemsToGive[#itemsToGive + 1] = item;
			end;
			
			player:GiveItems(itemsToGive);
		else
			player:GiveItem(item);
		end;
	end;
end;

--[[
	@codebase Shared
	@details Takes items from the player required to be taken by the blueprint that was crafted.
	@param {Entity} Player having the items taken from.
	@param {String} ID of the item to take.
	@param {Number} Amount of items to take.
--]]
function Clockwork.crafting:CheckTakeItems(player, item, amount)
	if (player and item and amount) then
		if (amount > 1) then
			local itemsToTake = {};
			local itemsInInventoryWithSameID = Clockwork.inventory:GetItemsByID(player:GetInventory(), item);
			local amountAddedInItemsToTake = 1;

			for k, v in pairs(itemsInInventoryWithSameID) do
				if (amountAddedInItemsToTake <= amount) then
					itemsToTake[#itemsToTake + 1] = v;
					amountAddedInItemsToTake = amountAddedInItemsToTake + 1;
				else
					break;
				end;
			end;

			player:TakeItems(itemsToTake);
		else
			player:TakeItem(player:FindItemByID(item));
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a blueprint by its ID.
	@param {String} ID of the blueprint being found.
	@returns {Table} Blueprint that was found.
--]]
function Clockwork.crafting:FindByID(identifier)
	if (identifier and identifier != 0 and type(identifier) != "boolean") then
		if (self.buffer[identifier]) then
			return self.buffer[identifier];
		elseif (self.stored[identifier]) then
			return self.stored[identifier];
		end;
		
		local lowerName = string.lower(identifier);
		local blueprintTable = nil;
		
		for k, v in pairs(self.stored) do
			local blueprintName = v("name");
			
			if (string.find(string.lower(blueprintName), lowerName)
			and (!blueprintTable or string.len(blueprintName) < string.len(blueprintTable("name")))) then
				blueprintTable = v;
			end;
		end;
		
		return blueprintTable;
	end;
end;

--[[
	@codebase Shared
	@details Formats the requirements to a specific way to improve readability when looking at the tooltip.
	@param {Table} The inventory table to check against.
	@param {Table} Blueprint having its requirements formatted.
	@returns {String} Formatted requirements for the blueprint.
--]]
function Clockwork.crafting:FormatRequirements(inventory, blueprintTable)
	local itemRequirements = blueprintTable.itemRequirements;
	local formattedRequirements = "";
	
	if (type(itemRequirements) == "table") then
		for k, v in pairs (itemRequirements) do
			if (type(k) == "number" and type(v) == "string") then
				formattedRequirements = formattedRequirements .. Clockwork.crafting:CheckFormatRequirements(inventory, v, 1);
			elseif (type(k) == "string" and type(v) == "number") then
				formattedRequirements = formattedRequirements .. Clockwork.crafting:CheckFormatRequirements(inventory, k, v);
			elseif (type(v) == "table") then
				local amount, item = nil;
				
				if (type(v[1]) == "number") then
					formattedRequirements = formattedRequirements .. Clockwork.crafting:CheckFormatRequirements(inventory, v[2], v[1]);
				elseif (type(v[2]) == "number") then
					formattedRequirements = formattedRequirements .. Clockwork.crafting:CheckFormatRequirements(inventory, v[1], v[2]);
				end;
			end;
			
			formattedRequirements = formattedRequirements .. "\n";
		end;
		
		formattedRequirements = string.TrimRight(formattedRequirements, "\n");
	elseif (type(itemRequirements) == "string") then
		formattedRequirements = formattedRequirements .. Clockwork.crafting:CheckFormatRequirements(inventory, itemRequirements, 1);
	end;
	
	return formattedRequirements;
end;

--[[
	@codebase Shared
	@details A function to get all blueprints.
	@returns {Table} All blueprints that are stored.
--]]
function Clockwork.crafting:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to get the blueprint buffer.
	@returns {Table} All blueprints in the buffer.
--]]
function Clockwork.crafting:GetBuffer()
	return self.buffer;
end;

--[[
	@codebase Shared
	@details A function to give items to a player from crafting a blueprint.
	@param {Entity} Player crafting the blueprint.
	@param {Table} Blueprint being crafted.
--]]
function Clockwork.crafting:GiveItems(player, blueprintTable)
	local giveItems = blueprintTable.giveItems;
	
	if (type(giveItems) == "table") then
		for k, v in pairs (giveItems) do
			if (type(k) == "number" and type(v) == "string") then
				Clockwork.crafting:CheckGiveItems(player, v, k);
			elseif (type(k) == "string" and type(v) == "number") then
				Clockwork.crafting:CheckGiveItems(player, k, v);
			elseif (type(v) == "table") then
				if (type(v[1]) == "number") then
					Clockwork.crafting:CheckGiveItems(player, v[2], v[1]);
				elseif (type(v[2]) == "number") then
					Clockwork.crafting:CheckGiveItems(player, v[1], v[2]);
				end;
			end;
		end;
	elseif (type(giveItems) == "string") then
		Clockwork.crafting:CheckGiveItems(player, giveItems, 1);
	end;
end;

--[[
	@codebase Shared
	@details A function to create a new blueprint.
	@param {String} Blueprint base to inherit from.
	@param {Bool} Whether blueprint being created is a base blueprint.
	@returns {Table} Blueprint just created.
--]]
function Clockwork.crafting:New(baseBlueprint, isBaseBlueprint)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
	
	object.networkQueue = {};
	object.networkData = {};
	object.defaultData = {};
	object.queryProxies = {};
	object.isBaseBlueprint = isBaseBlueprint;
	object.baseBlueprint = baseBlueprint;
	object.data = {};
	
	return object;
end;

--[[
	@codebase Shared
	@details A function to register a new blueprint.
	@param {Table} Blueprint to register.
--]]
function Clockwork.crafting:Register(blueprintTable)
	blueprintTable.uniqueID = string.lower(string.gsub(blueprintTable.uniqueID or string.gsub(blueprintTable.name, "%s", "_"), "['%.]", ""));
	blueprintTable.index = Clockwork.kernel:GetShortCRC(blueprintTable.uniqueID);
	
	self.stored[blueprintTable.uniqueID] = blueprintTable;
	self.buffer[blueprintTable.index] = blueprintTable;
	
	if (blueprintTable.model) then
		util.PrecacheModel(blueprintTable.model);
		
		if (SERVER) then
			Clockwork.kernel:AddFile(blueprintTable.model);
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to take items from a player from crafting a blueprint.
	@param {Entity} Player crafting the blueprint.
	@param {Table} Blueprint being crafted.
--]]
function Clockwork.crafting:TakeItems(player, blueprintTable)
	local takeItems = blueprintTable.takeItems;
	
	if (type(takeItems) == "table") then
		local itemsToTake = {};
		
		for k, v in pairs (takeItems) do
			if (type(k) == "number" and type(v) == "string") then
				Clockwork.crafting:CheckTakeItems(player, v, k);
			elseif (type(k) == "string" and type(v) == "number") then
				Clockwork.crafting:CheckTakeItems(player, k, v);
			elseif (type(v) == "table") then
				local amount, item = nil;
				
				if (type(v[1]) == "number") then
					Clockwork.crafting:CheckTakeItems(player, v[2], v[1]);
				elseif (type(v[2]) == "number") then
					Clockwork.crafting:CheckTakeItems(player, v[1], v[2]);
				end;
			end;
		end;
	elseif (type(takeItems) == "string") then
		Clockwork.crafting:CheckTakeItems(player, takeItems, 1);
	end;
end;

if (SERVER) then

end;

if (CLIENT) then
	--[[
		@codebase Client
		@details Gets the appropriate icon for the blueprint when being displayed in the crafting menu.
		@param {Table} Blueprint getting the icon for.
		@returns {String} Model the blueprint will be set to.
		@returns {String} Skin the model will be set to.
	--]]
	function Clockwork.crafting:GetIconInfo(blueprintTable)
		local model = blueprintTable("iconModel", blueprintTable("model"));
		local skin = blueprintTable("iconSkin", blueprintTable("skin"));
		
		if (blueprintTable.GetClientSideModel) then
			model = blueprintTable:GetClientSideModel();
		end;
		
		if (blueprintTable.GetClientSideSkin) then
			skin = blueprintTable:GetClientSideSkin();
		end;
		
		if (!model) then
			model = "models/props_c17/oildrum001.mdl";
		end;
		
		return model, skin;
	end;
	
	--[[
		@codebase Client
		@details A function to get an item's markup tool tip.
		@param {Table} Blueprint getting the tooltip for.
		@param {Bool} Whether or not the tool tip wil be displayed in the business style.
		@param {Function} Called when the tooltip is displayed.
		@returns {String} The tool tip to be displayed.
	--]]
	function Clockwork.crafting:GetMarkupToolTip(blueprintTable, isBusinessStyle, Callback)
		local informationColor = Clockwork.option:GetColor("information");
		local description = L(blueprintTable("description"));
		local name = L(blueprintTable("name"));
		
		if (blueprintTable.GetClientSideName and blueprintTable:GetClientSideName()) then
			name = blueprintTable:GetClientSideName();
		end;
		
		if (blueprintTable.GetClientSideDescription and blueprintTable:GetClientSideDescription()) then
			description = blueprintTable:GetClientSideDescription();
		end;
		
		local displayInfo = {
			itemTitle = nil,
			name = name
		};
		
		if (Callback) then
			Callback(displayInfo);
		end;
		
		local markupObject = Clockwork.theme:GetMarkupObject();
		
		local toolTipTitle = displayInfo.name;
		local toolTipColor = informationColor;
		
		if (displayInfo.itemTitle) then
			toolTipTitle = displayInfo.itemTitle;
		end;
		
		if (blueprintTable("color")) then
			toolTipColor = blueprintTable("color");
		end;
		
		markupObject:Title(toolTipTitle, toolTipColor);
		
		if (displayInfo.toolTip) then
			markupObject:Add(description);
			markupObject:Title(L("Information"));
			markupObject:Add(displayInfo.toolTip);
		else
			markupObject:Add(description);
		end;
		
		if (blueprintTable("takeCash") > 0) then
			markupObject:Title(L("Cost"), informationColor);
			markupObject:Add(blueprintTable("takeCash"));
		end;
		
		markupObject:Title(L("Requirements"), informationColor);
		markupObject:Add(Clockwork.crafting:FormatRequirements(Clockwork.inventory.client, blueprintTable));
		
		markupObject:Title(L("Category"));
		markupObject:Add(blueprintTable("category"));
		
		return markupObject:GetText();
	end;
	
	Clockwork.datastream:Hook("BlueprintData", function(data)
		Clockwork.item:CreateInstance(
			data.index, data.blueprintID, data.data
		);
	end);
end;
