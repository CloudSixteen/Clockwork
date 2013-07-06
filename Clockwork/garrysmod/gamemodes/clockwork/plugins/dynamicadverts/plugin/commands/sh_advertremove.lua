--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AdvertRemove");
COMMAND.tip = "Remove a dynamic advert.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	
	for k, v in pairs(cwDynamicAdverts.storedList) do
		if (v.position:Distance(position) <= 256) then
			Clockwork.datastream:Start(nil, "DynamicAdvertRemove", v.position);
			
			cwDynamicAdverts.storedList[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			Clockwork.player:Notify(player, "You have removed "..removed.." dynamic advert.");
		else
			Clockwork.player:Notify(player, "You have removed "..removed.." dynamic adverts.");
		end;
	else
		Clockwork.player:Notify(player, "There were no dynamic adverts near this position.");
	end;
	
	cwDynamicAdverts:SaveDynamicAdverts();
end;

COMMAND:Register();