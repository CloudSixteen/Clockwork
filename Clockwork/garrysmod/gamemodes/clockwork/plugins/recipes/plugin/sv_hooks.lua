local Clockwork = Clockwork;
local PLUGIN = PLUGIN;

-- Called when a player crafts a recipe.
function PLUGIN:PlayerCraftedRecipe(player, recipeTable)
	local message = "Success! Crafted the "..recipeTable.name.." recipe!";

	for k, v in pairs(recipeTable.required) do
		for i = 1, v do
			player:TakeItem(player:FindItemByID(k));
		end;
	end;

	for k, v in pairs(recipeTable.output) do
		local itemTable = Clockwork.item:FindByID(k);

		for i = 1, v do
			itemTable = Clockwork.item:CreateInstance(k);
			player:GiveItem(itemTable, true);
		end;
	end;

	if (recipeTable.OnSuccess) then
		local returnedMessage = recipeTable:OnSuccess(player);

		player:Notify(returnedMessage or message);
	else
		player:Notify(message);
	end;
end;

-- Called when a player fails to craft a recipe.
function PLUGIN:PlayerFailedToCraftRecipe(player, recipeTable)
	local message = "You do not have all of the required materials for this recipe!";

	if (recipeTable.OnFailure) then
		local returnedMessage = recipeTable:OnFailure(player);

		player:Notify(returnedMessage or message);
	else
		player:Notify(message);
	end;
end;

-- Called when the server has initialized.
function PLUGIN:Initialize()
	local directory = Clockwork.kernel:GetSchemaFolder("recipes");

	for k, v in pairs(cwFile.Find(directory.."/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/"..v);
	end;
end;