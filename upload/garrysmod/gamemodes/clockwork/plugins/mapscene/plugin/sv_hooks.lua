--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when a player's data stream info should be sent.
function cwMapScene:PlayerSendDataStreamInfo(player)
	if (#self.storedList > 0) then
		player.cwMapScene = self.storedList[math.random(1, #self.storedList)];
		
		if (player.cwMapScene) then
			Clockwork.datastream:Start(player, "MapScene", player.cwMapScene);
		end;
	end;
end;

-- Called when a player's visibility should be set up.
function cwMapScene:SetupPlayerVisibility(player)
	if (player.cwMapScene) then
		AddOriginToPVS(player.cwMapScene.position);
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function cwMapScene:ClockworkInitPostEntity()
	cwMapScene:LoadMapScenes();
end;