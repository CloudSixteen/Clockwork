--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticWhitelistView");

COMMAND.tip = "View the static whitelist.";
COMMAND.access = "a";
COMMAND.alias = {"SWView"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local whitelist = cwStaticEnts.whitelist;
	local defaultList = {
		"prop_physics",
		"gmod_",
		"prop_ragdoll",
		"edit_"
	};

	table.Merge(whitelist, defaultList);
	
	Clockwork.player:Notify(player, {"StaticWhitelistView", table.concat(whitelist, ", ")});
end;

COMMAND:Register();