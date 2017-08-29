--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

function cwPlayerReport:Report(player)
	local toSend = {
		steamID = player:SteamID64(),
		sessionToken = CloudAuthX:GetToken()
	};
	
	local encoded = Clockwork.json:Encode(toSend);
	
	http.Post("http://authx.cloudsixteen.com/stats/report.php", {encoded = encoded});
end;