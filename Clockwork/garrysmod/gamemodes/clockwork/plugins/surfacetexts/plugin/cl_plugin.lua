--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.datastream:Hook("SurfaceTexts", function(data)
	cwSurfaceTexts.storedList = data;
end);

Clockwork.datastream:Hook("SurfaceTextAdd", function(data)
	cwSurfaceTexts.storedList[#cwSurfaceTexts.storedList + 1] = data;
end);

Clockwork.datastream:Hook("SurfaceTextRemove", function(data)
	for k, v in pairs(cwSurfaceTexts.storedList) do
		if (v.position == data) then
			cwSurfaceTexts.storedList[k] = nil;
		end;
	end;
end);