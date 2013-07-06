--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.datastream:Hook("MapScene", function(data)
	cwMapScene.curStored = data;
end);