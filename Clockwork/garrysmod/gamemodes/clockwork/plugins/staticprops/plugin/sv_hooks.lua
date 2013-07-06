--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when Clockwork has loaded all of the entities.
function cwStaticProps:ClockworkInitPostEntity()
	self:LoadStaticProps();
end;

-- Called just after data should be saved.
function cwStaticProps:PostSaveData()
	self:SaveStaticProps();
end;