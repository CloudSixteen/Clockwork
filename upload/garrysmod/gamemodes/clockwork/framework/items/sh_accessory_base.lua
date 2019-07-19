--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local ITEM = Clockwork.item:New(nil, true);

ITEM.name = "Accessory Base";
ITEM.model = "models/gibs/hgibs.mdl";
ITEM.weight = 1;
ITEM.useText = "Wear";
ITEM.category = "Accessories";
ITEM.description = "An accessory you can wear.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentOffsetAngles = Angle(270, 270, 0);

ITEM.attachmentOffsetVector = Vector(0, 3, 3);

-- Called when a player wears the accessory.
function ITEM:OnWearAccessory(player, isWearing)
	if (isWearing) then
	else
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	if (CLIENT) then
		return Clockwork.player:IsWearingAccessory(self);
	else
		return player:IsWearingAccessory(self);
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	player:RemoveAccessory(self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:IsWearingAccessory(self)) then
		Clockwork.player:Notify(player, {"CannotDropWhileWearing"});
		return false;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		if (!self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false) then
			player:WearAccessory(self);
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