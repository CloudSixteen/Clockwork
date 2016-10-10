--[[
© 2013 CloudSixteen.com do not share, re-distribute or modify
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
	local libconfig = Clockwork.config;
	local interval = libconfig:Get("looc_interval"):Get();
	local libplayer = Clockwork.player;
	local curTime = CurTime();
	
	if (player.cwNextTalkLOOC ~= nil and curTime < player.cwNextTalkLOOC) then
		libplayer:Notify(player, "You cannot cannot talk in LOOC for another "..math.ceil(player.cwNextTalkLOOC - curTime).." second(s)!");
		return false;
	end;
	
	player.cwNextTalkLOOC = curTime + interval;
end;
