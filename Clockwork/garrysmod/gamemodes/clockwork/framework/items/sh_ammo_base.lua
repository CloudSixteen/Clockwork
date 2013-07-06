--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Ammo Base";
ITEM.useText = "Load";
ITEM.useSound = false;
ITEM.category = "Ammunition";
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 0;
ITEM.roundsText = "Rounds";
ITEM.customFunctions = {"Split"};
ITEM:AddData("Rounds", -1, true);

-- A function to get the item's weight.
function ITEM:GetItemWeight()
	return (self.weight / self.ammoAmount) * self:GetData("Rounds");
end;

ITEM:AddQueryProxy("weight", ITEM:GetItemWeight());
ITEM:AddQueryProxy("ammoCount", "Rounds", true);

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local secondaryAmmoClass = self("secondaryAmmoClass");
	local primaryAmmoClass = self("primaryAmmoClass");
	local ammoAmount = self("ammoAmount");
	local ammoClass = self("ammoClass");
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = Clockwork.item:GetByWeapon(v);
		
		if (itemTable and (itemTable.primaryAmmoClass == ammoClass
		or itemTable.secondaryAmmoClass == ammoClass)) then
			player:GiveAmmo(ammoAmount, ammoClass);
			
			return;
		end;
	end;
	
	Clockwork.player:Notify(
		player, "You need to equip a weapon that uses this ammunition!"
	);
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnInstantiated()
		self:SetData("Rounds", self.ammoCount);
	end;
	
	-- Called when a custom function was called.
	function ITEM:OnCustomFunction(player, funcName)
		if (funcName == "Split") then
			
		end;
	end;
else
	function ITEM:GetClientSideInfo()
		return Clockwork.kernel:AddMarkupLine(
			"", self("roundsText")..": "..self:GetData("Rounds")
		);
	end;
end;

Clockwork.item:Register(ITEM);