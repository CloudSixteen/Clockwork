--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("TextRemove");

COMMAND.tip = "Remove some text from a surface.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local iRemoved = 0;
	
	for k, v in pairs(cwSurfaceTexts.storedList) do
		if (v.position:Distance(position) <= 256) then
			Clockwork.datastream:Start(nil, "SurfaceTextRemove", v.position);
				cwSurfaceTexts.storedList[k] = nil;
			iRemoved = iRemoved + 1;
		end;
	end;
	
	if (iRemoved > 0) then
		Clockwork.player:Notify(player, {"YouRemovedSurfaceText", iRemoved});
	else
		Clockwork.player:Notify(player, {"NoSurfaceTextsNearPosition"});
	end;
	
	cwSurfaceTexts:SaveSurfaceTexts();
end;

COMMAND:Register();