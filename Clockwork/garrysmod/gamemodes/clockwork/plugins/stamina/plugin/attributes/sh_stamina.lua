--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Stamina";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "stam";
	ATTRIBUTE.description = "Affects your overall stamina, e.g: how long you can run for.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_STAMINA = Clockwork.attribute:Register(ATTRIBUTE);