--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharSetDesc");
COMMAND.tip = "Set a character's description permanently.";
COMMAND.text = "<string Name> <string Description>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	local minimumPhysDesc = Clockwork.config:Get("minimum_physdesc"):Get();
	local text = tostring(arguments[2]);
	
	if (string.len(text) < minimumPhysDesc) then
		Clockwork.player:Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
		
		return;
	end;
	
	target:SetCharacterData("PhysDesc", Clockwork.kernel:ModifyPhysDesc(text));
end;

COMMAND:Register();
