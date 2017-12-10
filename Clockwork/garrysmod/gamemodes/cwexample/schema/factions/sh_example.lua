--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

local FACTION = Clockwork.faction:New("Example Faction");

FACTION.isWhitelisted = false; -- Do we need to be whitelisted to select this faction?
FACTION.useFullName = true; -- Do we allow players to enter a full name, otherwise it only lets them select a first and second.
FACTION.material = "path/to/material"; -- The path to the faction material (shown on the creation screen).
FACTION.models = {
	female = {"models/path/to/model.mdl"},
	male = {"models/path/to/model.mdl"}
};

FACTION_EXAMPLE = FACTION:Register();