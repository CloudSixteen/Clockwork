--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("ContSetMessage");

COMMAND.tip = "Set a container's message.";
COMMAND.text = "<string Message>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			trace.Entity.cwMessage = arguments[1];
			
			Clockwork.player:Notify(player, {"YouSetContainerMessage"});
		else
			Clockwork.player:Notify(player, {"ContainerNotValid"});
		end;
	else
		Clockwork.player:Notify(player, {"ContainerNotValid"});
	end;
end;

COMMAND:Register();