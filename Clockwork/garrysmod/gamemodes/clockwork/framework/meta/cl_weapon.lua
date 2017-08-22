--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local weaponMeta = FindMetaTable("Weapon");

weaponMeta.OldGetPrintName = weaponMeta.OldGetPrintName or weaponMeta.GetPrintName;

-- A function to get a weapon's print name.
function weaponMeta:GetPrintName()
	local itemTable = cwItem:GetByWeapon(self);
	
	if (itemTable) then
		return itemTable("name");
	else
		return self:OldGetPrintName();
	end;
end;