--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when Clockwork has loaded all of the entities.
function cwDoorCmds:ClockworkInitPostEntity()
	self:LoadParentData();
	self:LoadDoorData();
end;