--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Roll");

COMMAND.tip = "CmdRoll";
COMMAND.text = "CmdRollDesc";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local number = math.Clamp(math.floor(tonumber(arguments[1]) or 100), 0, 1000000000);
	local roll = math.random(0, number)
	
	Clockwork.chatBox:AddInRadius(player, "roll", {"PlayerRoll", roll, number}, player:GetPos(), Clockwork.config:Get("talk_radius"):Get());
	
	Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerRoll", player:Name(), roll, number});
end;

COMMAND:Register();