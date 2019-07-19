--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local ITEM = Clockwork.item:New("weapon_base", true);

ITEM.name = "Grenade Base";
ITEM.isThrowableWeapon = true;

-- Called when a player equips the item.
function ITEM:OnEquip(player)
	Clockwork.player:GiveSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player holsters the item.
function ITEM:OnHolster(player, bForced)
	Clockwork.player:TakeSpawnAmmo(player, "grenade", 1);
end;

-- Called when a player attempts to drop the weapon.
function ITEM:CanDropWeapon(player, attacker, bNoMsg)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self("weaponClass"));
		player:TakeItem(self, true);
		
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to holster the weapon.
function ITEM:CanHolsterWeapon(player, forceHolster, bNoMsg)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self("weaponClass"));
		
		return false;
	else
		return true;
	end;
end;

Clockwork.item:Register(ITEM);