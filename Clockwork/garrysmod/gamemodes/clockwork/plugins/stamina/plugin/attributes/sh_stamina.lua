--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Stamina";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "stam";
	ATTRIBUTE.description = "Affects your overall stamina, e.g: how long you can run for.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_STAMINA = Clockwork.attribute:Register(ATTRIBUTE);