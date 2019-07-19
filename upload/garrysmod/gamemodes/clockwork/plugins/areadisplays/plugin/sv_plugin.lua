--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.datastream:Hook("EnteredArea", function(player, data)
	if (data[1] and data[2] and data[3]) then
		hook.Call("PlayerEnteredArea", Clockwork, player, data[1], data[2], data[3]);
	end;
end);

-- A function to load the area names.
function cwAreaDisplays:LoadAreaDisplays()
	self.storedList = Clockwork.kernel:RestoreSchemaData("plugins/areas/"..game.GetMap());
end;

-- A function to save the area names.
function cwAreaDisplays:SaveAreaDisplays()
	Clockwork.kernel:SaveSchemaData("plugins/areas/"..game.GetMap(), self.storedList);
end;