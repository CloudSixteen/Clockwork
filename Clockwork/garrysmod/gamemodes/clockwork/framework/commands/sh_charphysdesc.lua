--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharPhysDesc");
COMMAND.tip = "Change your character's physical description.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1]) then
		local minimumPhysDesc = Clockwork.config:Get("minimum_physdesc"):Get();
		local text = table.concat(arguments, " ");
		
		if (string.len(text) < minimumPhysDesc) then
			Clockwork.player:Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
			
			return;
		end;
		
		player:SetCharacterData("PhysDesc", Clockwork.kernel:ModifyPhysDesc(text));
	else
		Clockwork.datastream:Start(player, "PhysDesc", true);
	end;
end;

COMMAND:Register();