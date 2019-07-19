--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local GROUP_SUPER = 1;
local GROUP_ADMIN = 2;
local GROUP_OPER = 3;
local GROUP_USER = 4;

if (CLIENT) then
	local SYSTEM = Clockwork.system:New("ManageGroups");
	
	SYSTEM.image = "clockwork/system/groups";
	SYSTEM.toolTip = "ManageGroupsHelp";
	SYSTEM.groupType = GROUP_USER;
	SYSTEM.groupPage = 1;
	SYSTEM.groupPlayers = nil;
	SYSTEM.doesCreateForm = false;

	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		if (!Clockwork.config:Get("use_own_group_system"):Get()) then
			local commandTable = Clockwork.command:FindByID("PlySetGroup");
			
			if (commandTable and Clockwork.player:HasFlags(Clockwork.Client, commandTable.access)) then
				return true;
			end;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		if (self.groupType == GROUP_USER) then
			local label = vgui.Create("cwInfoText", systemPanel);
			label:SetText(L("ManageGroupsSelectingGroup"));
			label:SetInfoColor("blue");
			label:DockMargin(0, 0, 0, 8);
			
			systemPanel.panelList:AddItem(label);
			
			local userGroupsForm = vgui.Create("cwBasicForm", systemPanel);
			userGroupsForm:SetText(L("ManageGroupsUserGroups"));
			userGroupsForm:SetPadding(8);
			userGroupsForm:SetAutoSize(true);
			
			systemPanel.panelList:AddItem(userGroupsForm);
			
			local userGroups = {
				L("ManageGroupsSuperAdmins"),
				L("ManageGroupsAdmins"),
				L("ManageGroupsOperators")
			};
			
			for k, v in pairs(userGroups) do
				local groupButton = vgui.Create("DButton", systemPanel);
				groupButton:SetToolTip(L("ManageGroupsManageWithin", v));
				groupButton:SetText(v);
				groupButton:SetWide(systemPanel:GetParent():GetWide());
			
				-- Called when the button is clicked.
				function groupButton.DoClick(button)
					self.groupPlayers = nil;
					self.groupType = k;
					self:Rebuild();
				end;
				
				userGroupsForm:AddItem(groupButton);
			end;
		else
			local backButton = vgui.Create("DButton", systemPanel);
				backButton:SetText(L("ManageGroupsBackToGroups"));
				backButton:SetWide(systemPanel:GetParent():GetWide());
				
				-- Called when the button is clicked.
				function backButton.DoClick(button)
					self.groupType = GROUP_USER;
					self:Rebuild();
				end;
			systemPanel.navigationForm:AddItem(backButton);
			
			if (!self.noRefresh) then
				Clockwork.datastream:Start("SystemGroupGet", {self.groupType, self.groupPage});
			else
				self.noRefresh = nil;
			end;
			
			if (self.groupPlayers) then
				if (#self.groupPlayers > 0) then
					for k, v in pairs(self.groupPlayers) do
						local label = vgui.Create("cwInfoText", systemPanel);
							label:SetText(v.steamName);
							label:SetButton(true);
							label:SetToolTip(L("ManageGroupsSteamIDInfo", v.steamID));
							label:SetInfoColor("blue");
						systemPanel.panelList:AddItem(label);
						
						-- Called when the button is clicked.
						function label.DoClick(button)
							local commandTable = Clockwork.command:FindByID("PlyDemote");
							
							if (commandTable and Clockwork.player:HasFlags(Clockwork.Client, commandTable.access)) then
								Derma_Query(L("ManageGroupsDemoteText", v.steamName), L("ManageGroupsDemoteTitle"), L("Yes"), function()
									Clockwork.datastream:Start("SystemGroupDemote", {v.steamID, v.steamName, self.groupType});
								end, "No", function() end);
							end;
						end;
					end;
					
					if (self.pageCount > 1) then
						local pageForm = vgui.Create("cwBasicForm", systemPanel);
						pageForm:SetText(L("PageCount", self.groupPage, self.pageCount));
						pageForm:SetPadding(8);
						pageForm:SetAutoSize(true);
						
						systemPanel.panelList:AddItem(pageForm);
						
						if (self.isNext) then
							local nextButton = pageForm:Button("Next");
							
							-- Called when the button is clicked.
							function nextButton.DoClick(button)
								Clockwork.datastream:Start("SystemGroupGet", {self.groupType, self.groupPage + 1});
							end;
						end;
						
						if (self.isBack) then
							local backButton = pageForm:Button("Back");
							
							-- Called when the button is clicked.
							function backButton.DoClick(button)
								Clockwork.datastream:Start("SystemGroupGet", {self.groupType, self.groupPage - 1});
							end;
						end;
					end;
				else
					local label = vgui.Create("cwInfoText", systemPanel);
						label:SetText(L("ManageGroupsNoUsers"));
						label:SetInfoColor("orange");
					systemPanel.panelList:AddItem(label);
				end;
			else
				local label = vgui.Create("cwInfoText", systemPanel);
					label:SetText(L("ManageGroupsGettingUsers"));
					label:SetInfoColor("blue");
				systemPanel.panelList:AddItem(label);
			end;
		end;
	end;

	SYSTEM:Register();
	
	Clockwork.datastream:Hook("SystemGroupRebuild", function(data)
		local systemTable = Clockwork.system:FindByID("ManageGroups");
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:Rebuild();
		end;
	end);
	
	Clockwork.datastream:Hook("SystemGroupGet", function(data)
		if (type(data) == "table") then
			local systemTable = Clockwork.system:FindByID("ManageGroups");
			
			if (systemTable) then
				systemTable.groupPlayers = data.players;
				systemTable.groupPage = data.page;
				systemTable.pageCount = data.pageCount;
				systemTable.noRefresh = true;
				systemTable.isBack = data.isBack;
				systemTable.isNext = data.isNext;
				systemTable:Rebuild();
			end;
		else
			local systemTable = Clockwork.system:FindByID("ManageGroups");
			
			if (systemTable) then
				systemTable.groupPlayers = {};
				systemTable.groupPage = 1;
				systemTable.noRefresh = true;
					
				if (systemTable:IsActive()) then
					systemTable:Rebuild();
				end;
			end;
		end;
	end);
else
	Clockwork.datastream:Hook("SystemGroupDemote", function(player, data)
		local commandTable = Clockwork.command:FindByID("PlyDemote");
		
		if (commandTable and type(data) == "table"
		and Clockwork.player:HasFlags(player, commandTable.access)) then
			local target = Clockwork.player:FindByID(data[1]);
			
			if (target) then
				Clockwork.player:RunClockworkCommand(player, "PlyDemote", data[1]);
				
				timer.Simple(1, function()
					if (IsValid(player)) then
						Clockwork.datastream:Start(player, "SystemGroupRebuild", true);
					end;
				end);
			else
				local schemaFolder = Clockwork.kernel:GetSchemaFolder();
				local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
				local cwUserGroup = "user";
				
				if (data[3] == GROUP_SUPER) then
					cwUserGroup = "superadmin";
				elseif (data[3] == GROUP_ADMIN) then
					cwUserGroup = "admin";
				elseif (data[3] == GROUP_OPER) then
					cwUserGroup = "operator";
				end;
				
				local queryObj = Clockwork.database:Update(playersTable);
					queryObj:SetValue("_UserGroup", "user");
					queryObj:AddWhere("_Schema = ?", schemaFolder);
					queryObj:AddWhere("_SteamID = ?", data[1]);
					queryObj:SetCallback(function(result)
						Clockwork.datastream:Start(player, "SystemGroupRebuild", true);
					end);
				queryObj:Push();
				
				Clockwork.player:NotifyAll({"PlayerDemotedUserToGroup", player:Name(), data[2], cwUserGroup, "user"});
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("SystemGroupGet", function(player, data)
		if (type(data) != "table") then
			return;
		end;
		
		local groupType = tonumber(data[1]);
		local groupPage = tonumber(data[2]);
		
		if (groupPage) then
			local groupPlayers = {};
			local sendPlayers = {};
			local finishIndex = groupPage * 8;
			local startIndex = finishIndex - 7;
			local groupName = "user";
			local pageCount = 0;
			
			if (groupType == GROUP_SUPER) then
				groupName = "superadmin";
			elseif (groupType == GROUP_ADMIN) then
				groupName = "admin";
			elseif (groupType == GROUP_OPER) then
				groupName = "operator";
			end;
			
			local schemaFolder = Clockwork.kernel:GetSchemaFolder();
			local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
			local queryObj = Clockwork.database:Select(playersTable);
				queryObj:SetCallback(function(result)
					if (Clockwork.database:IsResult(result)) then
						for k, v in pairs(result) do
							groupPlayers[#groupPlayers + 1] = {
								steamName = v._SteamName,
								steamID = v._SteamID
							};
						end;
					end;
					
					table.sort(groupPlayers, function(a, b)
						return a.steamName < b.steamName;
					end);
					
					pageCount = math.ceil(#groupPlayers / 8);
					
					for k, v in pairs(groupPlayers) do
						if (k >= startIndex and k <= finishIndex) then
							sendPlayers[#sendPlayers + 1] = v;
						end;
					end;
					
					if (#sendPlayers > 0) then
						Clockwork.datastream:Start(player, "SystemGroupGet", {
							pageCount = pageCount,
							players = sendPlayers,
							isNext = (groupPlayers[finishIndex + 1] != nil),
							isBack = (groupPlayers[startIndex - 1] != nil),
							page = groupPage
						});
					else
						Clockwork.datastream:Start(player, "SystemGroupGet", false);
					end;
				end);
				
				queryObj:AddWhere("_Schema = ?", schemaFolder);
				queryObj:AddWhere("_UserGroup = ?", groupName);
			queryObj:Pull();
		end;
	end);
end;