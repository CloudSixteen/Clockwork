local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("ItC");
COMMAND.tip = "Describe a close-range local action or event.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (string.utf8len(text) < 8) then
		Clockwork.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;

	Clockwork.chatBox:AddInTargetRadius(player, "itc", text, player:GetPos(), 
		math.min(Clockwork.config:Get("talk_radius"):Get() / 3, 80));
end;

COMMAND:Register();