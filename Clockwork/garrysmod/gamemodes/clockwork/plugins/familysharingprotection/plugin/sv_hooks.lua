local PLUGIN = PLUGIN;
local Clockwork = Clockwork;
local apiURL = "http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&steamid=%s&appid_playing=4000&format=json";

-- Called when a player attempts to connect to the server.
function PLUGIN:CheckPassword(steamID, ipAddress, svPassword, clPassword, name)
	local apiKey = Clockwork.config:Get("steam_api_key"):Get();

	if (apiKey != "") then
		local response = Clockwork.json:Decode(CloudAuthX.WebPost(string.format(apiURL, apiKey, steamID), ""));

		if (response) then
			local lenderSteamID = response["response"]["lender_steamid"];

			if (lenderSteamID != "0") then
				local bCanJoin, reason = Clockwork:CheckPassword(lenderSteamID, ipAddress);

				if (bCanJoin == false) then
					return false, reason;
				end;
			end;
		end;
	end;
end;