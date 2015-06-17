--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local PLUGIN = PLUGIN

-- Called to sync the ESP data.
Clockwork.datastream:Hook("doorParentESP", function(data)
	PLUGIN.doorHalos = data;
end);

-- Called before halos need to be rendered.
function PLUGIN:PreDrawHalos()
	PLUGIN.doorHalos = PLUGIN.doorHalos or {}

	for k, door in pairs(PLUGIN.doorHalos) do
		if (IsValid(door)) then
			local color = Color(0, 170, 170, 255);

			if (k == "Parent") then
				color = Color(255, 100, 0, 255);
			end;

			halo.Add({door}, color, 1, 1, 1, true, true);
		end;
	end;
end;