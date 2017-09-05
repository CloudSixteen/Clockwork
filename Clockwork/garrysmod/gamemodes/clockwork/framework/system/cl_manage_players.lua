--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local SYSTEM = Clockwork.system:New("ManagePlayers");

SYSTEM.toolTip = "ManagePlayersHelp";
SYSTEM.image = "clockwork/system/players";
SYSTEM.doesCreateForm = false;

-- Called to get whether the local player has access to the system.
function SYSTEM:HasAccess()
	return Clockwork.player:IsAdmin(Clockwork.Client);
end;

-- Called when the system should be displayed.
function SYSTEM:OnDisplay(systemPanel, systemForm)
	local availableClasses = {};
	local classes = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			local class = Clockwork.plugin:Call("GetPlayerScoreboardClass", v);
			
			if (class) then
				if (!availableClasses[class]) then
					availableClasses[class] = {};
				end;
				
				availableClasses[class][#availableClasses[class] + 1] = v;
			end;
		end;
	end;
	
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return Clockwork.plugin:Call("ScoreboardSortClassPlayers", k, a, b);
		end);
		
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	if (table.Count(classes) > 0) then
		local label = vgui.Create("cwInfoText", systemPanel);
			label:SetText(L("ManagePlayersCommands"));
			label:SetInfoColor("blue");
			label:DockMargin(0, 0, 0, 8);
		systemPanel.panelList:AddItem(label);
		
		for k, v in pairs(classes) do
			local characterForm = vgui.Create("cwBasicForm", systemPanel);
			local panelList = vgui.Create("DPanelList", systemPanel);
			
			for k2, v2 in pairs(v.players) do
				local label = vgui.Create("cwInfoText", systemPanel);
					label:SetText(v2:Name());
					label:SetButton(true);
					label:SetToolTip(L("PlayerNameAndSteamID", v2:SteamName(), v2:SteamID()));
					label:SetInfoColor(cwTeam.GetColor(v2:Team()));
				panelList:AddItem(label);
				
				-- Called when the button is clicked.
				function label.DoClick(button)
					if (IsValid(v2)) then
						local options = {};
							Clockwork.plugin:Call("GetPlayerScoreboardOptions", v2, options);
						Clockwork.kernel:AddMenuFromData(nil, options);
					end;
				end;
			end;
			
			systemPanel.panelList:AddItem(characterForm);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(8);
			panelList:SetSpacing(4);
			
			characterForm:SetText(v.name);
			characterForm:AddItem(panelList);
			characterForm:SetPadding(8); 
			characterForm:SetAutoSize(true);
		end;
	else
		local label = vgui.Create("cwInfoText", systemPanel);
		label:SetText(L("ManagePlayersNoPlayers"));
		label:SetInfoColor("orange");
		
		systemPanel.panelList:AddItem(label);
	end;
end;

SYSTEM:Register();