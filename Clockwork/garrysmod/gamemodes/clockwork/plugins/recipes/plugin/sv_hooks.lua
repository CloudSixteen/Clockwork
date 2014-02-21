local Clockwork = Clockwork;
local PLUGIN = PLUGIN;

-- Called when a player crafts a recipe.
function PLUGIN:PlayerCraftedRecipe(player, recipeTable)
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
		local message = recipeTable:OnSuccess(player);

		player:Notify(message or "Success! Crafted the "..recipeTable.name.." recipe!");
	else
		player:Notify("Success! Crafted the "..recipeTable.name.." recipe!");
	end;
end;

-- Called when a player fails to craft a recipe.
function PLUGIN:PlayerFailedToCraftRecipe(player, recipeTable)
	if (recipeTable.OnFailure) then
		local message = recipeTable:OnFailure(player);

		player:Notify(message or "You do not have all of the required materials for this recipe!");
	else
		player:Notify("You do not have all of the required materials for this recipe!");
	end;
end;