--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

function cwDelayLOOC:ClockworkConfigChanged(key, data, previousValue, newValue)
	if (key == "looc_interval") then
		for k, v in pairs(cwPlayer.GetAll()) do
			v.cwNextTalkLOOC = nil;
		end;
	end;
end;

function cwDelayLOOC:PlayerCanSayLOOC(player, text)
	local cwConfig = Clockwork.config;
	local interval = cwConfig:Get("looc_interval"):Get();
	local cwPlayer = Clockwork.player;
	local curTime = CurTime();
	
	if (player.cwNextTalkLOOC ~= nil and curTime < player.cwNextTalkLOOC) then
		cwPlayer:Notify(player, {"WaitTalkInLOOC", math.ceil(player.cwNextTalkLOOC - curTime)});
		return false;
	end;
	
	player.cwNextTalkLOOC = curTime + interval;
end;
