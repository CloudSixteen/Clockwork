--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.config:Add("mysql_xsc_table", "messages", nil, nil, true, true, true);
Clockwork.config:Add("cross_server_chat_enabled", false, true);
Clockwork.config:Add("cross_server_chat_name", "", true);

-- A function to query the messages.
function cwXCS:QueryChat()
	local curTime = CurTime();
	local serverName = Clockwork.config:Get("cross_server_chat_name"):Get();
	
	if (Clockwork.config:Get("cross_server_chat_enabled"):Get() and name != "") then
		local messagesTable = Clockwork.config:Get("mysql_xsc_table"):Get();

		if (self.currentKey) then
			local queryObj = Clockwork.database:Select(messagesTable);
				queryObj:AddColumn("_Key");
				queryObj:AddColumn("_PlayerName");
				queryObj:AddColumn("_Text");
				queryObj:AddColumn("_Color");
				queryObj:AddWhere("_Key > ?", self.currentKey);
				queryObj:AddWhere("_ServerName <> ?", serverName);
				queryObj:SetCallback(function(result)
					if (Clockwork.database:IsResult(result)) then
						for k, v in pairs(result)do
							if (v._PlayerName and v._Text and v._Color) then
								local color = Clockwork.json:Decode(v._Color);

								Clockwork.datastream:Start(nil, "CrossServerChat", {name = v._PlayerName, text = v._Text, color = color});

								print("[XSC] "..v._PlayerName..": "..v._Text);
							end;
						end;

						self.currentKey = result[#result]._Key;
					end;
				end);
				queryObj:SetOrder("_Key", "ASC");
			queryObj:Pull();
		else
			local queryObj = Clockwork.database:Select(messagesTable);
				queryObj:AddColumn("_Key");
				queryObj:AddWhere("_ServerName <> ?", serverName);
				queryObj:SetCallback(function(result)
					if (Clockwork.database:IsResult(result)) then
						self.currentKey = result[#result]._Key;
					else
						self.currentKey = 0;
					end;
				end);
				queryObj:SetOrder("_Key", "ASC");
			queryObj:Pull();
		end;
	end;
	
	self.cwNextQueryChat = curTime + 1;
end;