--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.config:Add("weapon_selection_multi", false);

Clockwork.datastream:Hook("SelectWeapon", function(player, data)
	local weaponClass = data;

	if (type(weaponClass) == "string") then
		if (player:HasWeapon(weaponClass)) then
			player:SelectWeapon(weaponClass);
		end;
	end;
end);