--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local cwSpawnPoints = cwSpawnPoints;
local spawnPointData;
local cwClass = Clockwork.class;

--Called when the plugin is initialized.
function cwSpawnPoints:Initialize()
	CW_CONVAR_SPAWNPOINTESP = Clockwork.kernel:CreateClientConVar("cwSpawnPointESP", 0, true, true);
	
	Clockwork.setting:AddCheckBox("AdminESP", "ShowSpawnPoints", "cwSpawnPointESP", "ShowSpawnPointsDesc", function()
		return Clockwork.player:IsAdmin(Clockwork.Client);
	end);
end;

local colorWhite = Color(255, 255, 255, 255);
local colorViolet = Color(180, 100, 255, 255);
local spawnColor;

-- Called when the ESP info is needed.
function cwSpawnPoints:GetAdminESPInfo(info)
	if (CW_CONVAR_SPAWNPOINTESP:GetInt() == 1 and spawnPointData) then
		for typeName, spawnPoints in pairs(spawnPointData) do
			spawnColor = colorViolet;

			for k, class in pairs(cwClass:GetAll()) do
				if (class.factions[1] == typeName or typeName == k) then
					spawnColor = class.color;
				end;
			end;

			for k, v in pairs(spawnPoints) do
				table.insert(info, {
					position = v.position,
					text = {
						{
							text = "SpawnPoint",
							color = colorWhite
						},
						{
							text = string.upper(typeName),
							color = spawnColor
						}
					}
				});
			end;
		end;
	end;
end;

-- Called to sync up the ESP data from the server.
Clockwork.datastream:Hook("SpawnPointESPSync", function(data)
	spawnPointData = data;
end);