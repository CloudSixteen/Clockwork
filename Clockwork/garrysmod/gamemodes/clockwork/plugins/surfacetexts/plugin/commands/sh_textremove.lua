--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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
		if (iRemoved == 1) then
			Clockwork.player:Notify(player, "You have removed "..iRemoved.." surface text.");
		else
			Clockwork.player:Notify(player, "You have removed "..iRemoved.." surface texts.");
		end;
	else
		Clockwork.player:Notify(player, "There were no surface texts near this position.");
	end;
	
	cwSurfaceTexts:SaveSurfaceTexts();
end;

COMMAND:Register();