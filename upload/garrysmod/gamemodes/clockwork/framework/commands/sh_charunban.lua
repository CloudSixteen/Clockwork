--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharUnban");

COMMAND.tip = "CmdCharUnban";
COMMAND.text = "CmdCharUnbanDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local charName = string.lower(arguments[1]);
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (string.lower(v:Name()) == charName) then
				Clockwork.player:NotifyAll({"PlayerUnbannedPlayer", player:Name(), arguments[1]});
				Clockwork.player:SetBanned(player, false);
				
				return;
			else
				for k2, v2 in pairs(v:GetCharacters()) do
					if (string.lower(v2.name) == charName) then
						Clockwork.player:NotifyAll({"PlayerUnbannedPlayer", player:Name(), arguments[1]});
						
						v2.data["CharBanned"] = false;
						
						return;
					end;
				end;
			end;
		end;
	end;
	
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local charName = arguments[1];
	
	local queryObj = Clockwork.database:Select(charactersTable);
		queryObj:SetCallback(function(result)
			if (Clockwork.database:IsResult(result)) then
				local queryObj = Clockwork.database:Update(charactersTable);
					queryObj:Replace("_Data", "\"CharBanned\":true", "\"CharBanned\":false");
					queryObj:AddWhere("_Name = ?", charName);
				queryObj:Push();
				
				Clockwork.player:NotifyAll({"PlayerUnbannedPlayer", player:Name(), arguments[1]});
			else
				Clockwork.player:Notify(player, {"NotValidCharacter", charName});
			end;
		end);
		queryObj:AddWhere("_Name = ?", charName);
	queryObj:Pull();
end;

COMMAND:Register();