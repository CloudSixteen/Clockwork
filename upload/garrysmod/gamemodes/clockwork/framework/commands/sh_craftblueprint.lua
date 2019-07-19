--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CraftBlueprint");

COMMAND.tip = "CmdCraftBlueprint";
COMMAND.text = "CmdCraftBlueprintDesc";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local blueprintTable = Clockwork.crafting:FindByID(arguments[1]);
	
	if (!blueprintTable) then
		return false;
	end;
	
	Clockwork.crafting:Craft(player, blueprintTable);
end;

COMMAND:Register();