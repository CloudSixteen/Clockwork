--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

--[[
You don't have to do this, but I think it's nicer.
Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwTrackStats");

cwTrackStats.nextLogTimes = {};

function cwTrackStats:Track(name, data)
	local toSend = {name = name, data = data or {}};
	
	if (SERVER) then
		toSend.data.ip = GetConVarString("ip");
		toSend.data.port = GetConVarString("hostport");
	end;
	
	local encoded = Clockwork.json:Encode(toSend);
	
	http.Post("http://authx.cloudsixteen.com/data/stats/track.php", {encoded = encoded});
end;

function cwTrackStats:CheckLogTime(logId)
	if (not self.nextLogTimes[logId]) then
		local fileData = file.Read("cax/logs/"..logId..".txt", "DATA");
		
		if (fileData) then
			self.nextLogTimes[logId] = tonumber(fileData);
		end;
	end;
	
	local curTime = os.time();

	return (not self.nextLogTimes[logId] or curTime >= nextLogStart);
end;

function cwTrackStats:SetLogTime(logId, delay)
	file.Write("cax/logs/"..logId..".txt", os.time() + delay, "DATA");
	self.nextLogTimes[logId] = os.time() + delay;
end;

--[[ You don't have to do this either, but I prefer to separate the functions. --]]
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");