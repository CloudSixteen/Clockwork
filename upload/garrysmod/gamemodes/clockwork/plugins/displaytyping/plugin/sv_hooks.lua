--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when a player's typing display has started.
function PLUGIN:PlayerStartTypingDisplay(player, code)
	if (!player:IsNoClipping()) then
		if (code == "n" or code == "y" or code == "w" or code == "r") then
			if (!player.typingBeep) then
				local rankName, rank = player:GetFactionRank();
				local faction = Clockwork.faction:FindByID(player:GetFaction());
				local soundName = rank and rank.startChatNoise or faction and faction.startChatNoise;

				if (soundName) then
					player.typingBeep = true;

					player:EmitSound(soundName);
				end;
			end;
		end;
	end;
end;

-- Called when a player's typing display has finished.
function PLUGIN:PlayerFinishTypingDisplay(player, textTyped)
	if (textTyped) then
		if (player.typingBeep) then
			local rankName, rank = player:GetFactionRank();
			local faction = Clockwork.faction:FindByID(player:GetFaction());

			if (rank and rank.endChatNoise) then
				player:EmitSound(rank.endChatNoise);
			elseif (faction and faction.endChatNoise) then
				player:EmitSound(faction.endChatNoise);
			end;
		end;
	end;
	
	player.typingBeep = nil;
end;
