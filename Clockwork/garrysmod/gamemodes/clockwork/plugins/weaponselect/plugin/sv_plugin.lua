--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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