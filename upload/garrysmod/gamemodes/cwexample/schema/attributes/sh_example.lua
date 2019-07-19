--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

local ATTRIBUTE = Clockwork.attribute:New();

ATTRIBUTE.name = "AttributeExample";
ATTRIBUTE.image = "path/to/material";
ATTRIBUTE.maximum = 75; -- The maximum amount of this attribute that a player can reach.
ATTRIBUTE.uniqueID = "exp"; -- A unique ID, this must be different for every attribute.
ATTRIBUTE.description = "AttributeExampleDesc"; -- A short description of the attribute.
ATTRIBUTE.isOnCharScreen = true; -- Is this attribute selectable on the character screen?

ATB_EXAMPLE = Clockwork.attribute:Register(ATTRIBUTE);