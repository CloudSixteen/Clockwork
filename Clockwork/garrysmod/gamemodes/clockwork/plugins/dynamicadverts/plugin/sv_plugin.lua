--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to load the dynamic adverts.
function cwDynamicAdverts:LoadDynamicAdverts()
	self.storedList = Clockwork.kernel:RestoreSchemaData("plugins/adverts/"..game.GetMap());
end;

-- A function to save the dynamic adverts.
function cwDynamicAdverts:SaveDynamicAdverts()
	Clockwork.kernel:SaveSchemaData("plugins/adverts/"..game.GetMap(), self.storedList);
end;