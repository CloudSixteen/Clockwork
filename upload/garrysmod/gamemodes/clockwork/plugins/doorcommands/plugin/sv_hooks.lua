--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwDoorCmds:ClockworkInitPostEntity()
	self:LoadParentData();
	self:LoadDoorData();

	if (Clockwork.config:Get("doors_save_state"):Get()) then
		self:LoadDoorStates();
	end;
end;

function cwDoorCmds:PostSaveData()
	if (Clockwork.config:Get("doors_save_state"):Get() and #player.GetAll() > 0) then
		self:SaveDoorStates();
	end;
end;