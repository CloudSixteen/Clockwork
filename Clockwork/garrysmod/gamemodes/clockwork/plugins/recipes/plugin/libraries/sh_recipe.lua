local Clockwork = Clockwork;
local PLUGIN = PLUGIN;

Clockwork.recipe = Clockwork.kernel:NewLibrary("Recipe");
Clockwork.recipe.stored = {};

local RECIPE = {__index = RECIPE};

-- A function to register a new recipe.
function RECIPE:Register()
	return Clockwork.recipe:Register(self, self.name);
end;

-- A function to add an item to a recipe's requirements.
function RECIPE:Require(uniqueID, amount)
	if (!uniqueID) then return; end;

	self.required[uniqueID] = amount or 1;
end;

-- A function to add an item to a recipe's output.
function RECIPE:Output(uniqueID, amount)
	if (!uniqueID) then return; end;

	self.output[uniqueID] = amount or 1;
end;

-- A function to craft the recipe.
function RECIPE:Craft(player)
	for k, v in pairs(self.required) do
		local name = Clockwork.item:FindByID(k)("name");
		local itemsList = Clockwork.inventory:FindItemsByName(player:GetInventory(), k, name);
		
		if (!itemsList or table.Count(itemsList) < v) then
			Clockwork.plugin:Call("PlayerFailedToCraftRecipe", player, self);

			return;			
		end;
	end;

	Clockwork.plugin:Call("PlayerCraftedRecipe", player, self);
end;

-- A function to register a new recipe.
function Clockwork.recipe:Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);
	
	self.stored[uniqueID] = data;
	
	return self.stored[uniqueID];
end;

-- A function to create a new recipe.
function Clockwork.recipe:New(name)
	local object = Clockwork.kernel:NewMetaTable(RECIPE);
		object.name = name or "Unknown";
		object.required = {};
		object.output = {};
	return object;
end;

-- A function to find a recipe by an identifier.
function Clockwork.recipe:FindByID(identifier)
	return self.stored[string.lower(string.gsub(identifier, "%s", ""))];
end;

--[[
	EXAMPLE:

	local RECIPE = Clockwork.recipe:New("Example");
		RECIPE:Require("ingredient1");
		RECIPE:Require("ingredient2", 3);
		RECIPE:Require("ingredient3");
		RECIPE:Require("ingredient4", 2);
		RECIPE:Output("final_item");
	RCP_EXAMPLE = RECIPE:Register();
--]]