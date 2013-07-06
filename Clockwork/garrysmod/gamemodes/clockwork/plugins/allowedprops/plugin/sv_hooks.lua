--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when Clockwork has loaded all of the entities.
function cwAllowedProps:ClockworkInitPostEntity()
	self:LoadAllowedProps();
end;

-- Called when a player attempts to spawn a prop.
function cwAllowedProps:PlayerSpawnProp(player, model)
	model = Clockwork.kernel:Replace(model, "\\", "/");
	model = Clockwork.kernel:Replace(model, "//", "/");
	model = string.lower(model);
	
	if (!Clockwork.player:IsAdmin(player)) then
		if (!table.HasValue(self.allowedProps, model)) then
			Clockwork.player:Notify(player, "You can only spawn allowed props!");
		
			return false;
		end;
	end;
end;