--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to load the map scenes.
function cwMapScene:LoadMapScenes()
	local mapScenes = Clockwork.kernel:RestoreSchemaData("plugins/scenes/"..game.GetMap());
	self.storedList = {};
	
	for k, v in pairs(mapScenes) do
		self.storedList[#self.storedList + 1] = v;
	end;
end;

-- A function to save the map scenes.
function cwMapScene:SaveMapScenes()
	local mapScenes = {};
	
	for k, v in pairs(self.storedList) do
		mapScenes[#mapScenes + 1] = v;
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/scenes/"..game.GetMap(), mapScenes);
end;