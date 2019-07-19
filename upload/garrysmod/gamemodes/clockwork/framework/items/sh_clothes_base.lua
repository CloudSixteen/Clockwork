--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local ITEM = Clockwork.item:New(nil, true);

ITEM.name = "Clothes Base";
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.weight = 2;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.description = "A suitcase full of clothes.";

-- A function to get the model name.
function ITEM:GetModelName(player, group)
	local modelName = nil;
	
	if (!player) then
		player = Clockwork.Client;
	end;
	
	if (group) then
		modelName = string.gsub(string.lower(Clockwork.player:GetDefaultModel(player)), "^.-/.-/", "");
	else
		modelName = string.gsub(string.lower(Clockwork.player:GetDefaultModel(player)), "^.-/.-/.-/", "");
	end;
	
	if (!string.find(modelName, "male") and !string.find(modelName, "female")) then
		if (group) then
			group = "group05/";
		else
			group = "";
		end;
		
		if (SERVER) then
			if (player:GetGender() == GENDER_FEMALE) then
				return group.."female_04.mdl";
			else
				return group.."male_05.mdl";
			end;
		elseif (player:GetGender() == GENDER_FEMALE) then
			return group.."female_04.mdl";
		else
			return group.."male_05.mdl";
		end;
	else
		return modelName;
	end;
end;

-- Called when the item's client side model is needed.
function ITEM:GetClientSideModel()
	local replacement = nil;
	
	if (self.GetReplacement) then
		replacement = self:GetReplacement(Clockwork.Client);
	end;
	
	if (type(replacement) == "string") then
		return replacement;
	elseif (self("replacement")) then
		return self("replacement");
	elseif (self("group")) then
		return "models/humans/"..self("group").."/"..self:GetModelName();
	end;
end;

-- Called when a player changes clothes.
function ITEM:OnChangeClothes(player, isWearing)
	if (isWearing) then
		local replacement = nil;
		
		if (self.GetReplacement) then
			replacement = self:GetReplacement(player);
		end;
		
		if (type(replacement) == "string") then
			player:SetModel(replacement);
		elseif (self("replacement")) then
			player:SetModel(self("replacement"));
		elseif (self("group")) then
			player:SetModel("models/humans/"..self("group").."/"..self:GetModelName(player));
		end;
	else
		Clockwork.player:SetDefaultModel(player);
		Clockwork.player:SetDefaultSkin(player);
	end;
	
	if (self.OnChangedClothes) then
		self:OnChangedClothes(player, isWearing);
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	if (CLIENT) then
		return Clockwork.player:IsWearingItem(self);
	else
		return player:IsWearingItem(self);
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	player:RemoveClothes();
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:IsWearingItem(self)) then
		Clockwork.player:Notify(player, {"CannotDropWhileWearing"});
		return false;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self("whitelist") and !table.HasValue(self("whitelist"), player:GetFaction())) then
		Clockwork.player:Notify(player, {"FactionCannotWearThis"});
		return false;
	end;
	
	if (player:Alive() and !player:IsRagdolled()) then
		if (!self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false) then
			player:SetClothesData(self);
			return true;
		end;
	else
		Clockwork.player:Notify(player, {"CannotActionRightNow"});
	end;
	
	return false;
end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		if (!self:IsInstance()) then return; end;
		
		if (Clockwork.player:IsWearingAccessory(self)) then
			return L("ItemInfoIsWearingYes");
		else
			return L("ItemInfoIsWearingNo");
		end;
	end;
end;

Clockwork.item:Register(ITEM);