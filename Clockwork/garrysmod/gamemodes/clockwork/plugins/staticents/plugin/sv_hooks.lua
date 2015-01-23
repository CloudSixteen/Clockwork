--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwStaticEnts:ClockworkInitPostEntity()
	self:LoadStaticEnts();
end;

-- Called just after data should be saved.
function cwStaticEnts:PostSaveData()
	self:SaveStaticEnts();
end;