--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when Clockwork has loaded all of the entities.
function cwAreaDisplays:ClockworkInitPostEntity() self:LoadAreaDisplays(); end;

-- Called when a player's data stream info should be sent.
function cwAreaDisplays:PlayerSendDataStreamInfo(player)
	Clockwork.datastream:Start(player, "AreaDisplays", self.storedList);
end;