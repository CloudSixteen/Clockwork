--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

if (CLIENT) then
	local SYSTEM = Clockwork.system:New("ManagePlugins");
	
	SYSTEM.toolTip = "ManagePluginsHelp";
	SYSTEM.image = "clockwork/system/plugins";
	SYSTEM.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local unloadTable = Clockwork.command:FindByID("PluginUnload");
		local loadTable = Clockwork.command:FindByID("PluginLoad");
		
		if (loadTable and unloadTable) then
			if (Clockwork.player:HasFlags(Clockwork.Client, loadTable.access)
			or Clockwork.player:HasFlags(Clockwork.Client, unloadTable.access)) then
				return true;
			end;
		end;
		
		return false;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		self.pluginButtons = {};
		
		local donePlugins = {};
		local categories = {};
		local mainPlugins = {};
		
		for k, v in pairs(Clockwork.plugin:GetStored()) do
			if (v != Schema) then
				local category = v.author;
				
				if (string.find(category, "<font")) then
					category = L("InvalidPluginAuthor");
				end;
			
				categories[category] = categories[category] or {};
				categories[category][#categories[category] + 1] = v;
			end;
		end;
		
		for k, v in pairs(categories) do
			table.sort(v, function(a, b)
				return a.name < b.name;
			end);
			
			mainPlugins[#mainPlugins + 1] = {
				category = k,
				plugins = v
			};
		end;
		
		table.sort(mainPlugins, function(a, b)
			return a.category < b.category;
		end);
		
		Clockwork.datastream:Start("SystemPluginGet", true);
		
		if (#mainPlugins > 0) then
			local label = vgui.Create("cwInfoText", systemPanel);
			label:SetText(L("SystemPluginsHelpText"));
			label:SetInfoColor("blue");
			label:DockMargin(0, 0, 0, 8);
			
			systemPanel.panelList:AddItem(label);
			
			for k, v in pairs(mainPlugins) do
				local pluginForm = vgui.Create("cwBasicForm", systemPanel);
				local panelList = vgui.Create("DPanelList", systemPanel);
				
				for k2, v2 in pairs(v.plugins) do
					self.pluginButtons[v2.name] = vgui.Create("cwInfoText", systemPanel);
					self.pluginButtons[v2.name]:SetText(L(v2.name));
					self.pluginButtons[v2.name]:SetButton(true);
					self.pluginButtons[v2.name]:SetToolTip(L(v2.description));
					
					panelList:AddItem(self.pluginButtons[v2.name]);
					
					if (Clockwork.plugin:IsDisabled(v2.name)) then
						self.pluginButtons[v2.name]:SetInfoColor("orange");
						self.pluginButtons[v2.name]:SetButton(false);
					elseif (Clockwork.plugin:IsUnloaded(v2.name)) then
						self.pluginButtons[v2.name]:SetInfoColor("red");
					else
						self.pluginButtons[v2.name]:SetInfoColor("green");
					end;
					
					-- Called when the button is clicked.
					self.pluginButtons[v2.name].DoClick = function(button)
						if (!Clockwork.plugin:IsDisabled(v2.name)) then
							if (Clockwork.plugin:IsUnloaded(v2.name)) then
								Clockwork.datastream:Start("SystemPluginSet", {v2.name, false});
							else
								Clockwork.datastream:Start("SystemPluginSet", {v2.name, true});
							end;
						end;
					end;
				end;
				
				systemPanel.panelList:AddItem(pluginForm);
				
				panelList:SetAutoSize(true);
				panelList:SetPadding(8);
				panelList:SetSpacing(4);
				
				pluginForm:SetText(v.category);
				pluginForm:AddItem(panelList);
				pluginForm:SetPadding(8);
				pluginForm:SetAutoSize(true);
			end;
		else
			local label = vgui.Create("cwInfoText", systemPanel);
			label:SetText(L("SystemPluginsNoneInstalled"));
			label:SetInfoColor("red");
			
			systemPanel.panelList:AddItem(label);
		end;
	end;
	
	-- A function to update the plugin buttons.
	function SYSTEM:UpdatePluginButtons()
		for k, v in pairs(self.pluginButtons) do
			if (Clockwork.plugin:IsDisabled(k)) then
				v:SetInfoColor("orange");
				v:SetButton(false);
			elseif (Clockwork.plugin:IsUnloaded(k)) then
				v:SetInfoColor("red");
				v:SetButton(true);
			else
				v:SetInfoColor("green");
				v:SetButton(true);
			end;
		end;
	end;

	SYSTEM:Register();
	
	Clockwork.datastream:Hook("SystemPluginGet", function(data)
		local systemTable = Clockwork.system:FindByID("ManagePlugins");
		local unloaded = data;
		
		for k, v in pairs(Clockwork.plugin:GetStored()) do
			if (unloaded[v.folderName]) then
				Clockwork.plugin:SetUnloaded(v.name, true);
			else
				Clockwork.plugin:SetUnloaded(v.name, false);
			end;
		end;
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:UpdatePluginButtons();
		end;
	end);
	
	Clockwork.datastream:Hook("SystemPluginSet", function(data)
		local systemTable = Clockwork.system:FindByID("ManagePlugins");
		local plugin = Clockwork.plugin:FindByID(data[1]);
		
		if (plugin) then
			Clockwork.plugin:SetUnloaded(plugin.name, (data[2] == true));
		end;
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:UpdatePluginButtons();
		end;
	end);
else
	Clockwork.datastream:Hook("SystemPluginGet", function(player, data)
		Clockwork.datastream:Start(player, "SystemPluginGet", Clockwork.plugin:GetUnloaded());
	end);
	
	Clockwork.datastream:Hook("SystemPluginSet", function(player, data)
		local unloadTable = Clockwork.command:FindByID("PluginLoad");
		local loadTable = Clockwork.command:FindByID("PluginLoad");
		
		if (data[2] == true and (!loadTable or !Clockwork.player:HasFlags(player, loadTable.access))) then
			return;
		elseif (data[2] == false and (!unloadTable or !Clockwork.player:HasFlags(player, unloadTable.access))) then
			return;
		elseif (type(data[2]) != "boolean") then
			return;
		end;
		
		local plugin = Clockwork.plugin:FindByID(data[1]);
		
		if (not plugin) then
			Clockwork.player:Notify(player, {"PluginNotValid"});
			return;
		end;
		
		if (!Clockwork.plugin:IsDisabled(plugin.name)) then
			local wasSuccess = Clockwork.plugin:SetUnloaded(plugin.name, data[2]);
			local recipients = {};
			
			if (wasSuccess) then
				if (data[2]) then
					Clockwork.player:NotifyAll({"PlayerUnloadedPlugin", player:Name(), plugin.name});
				else
					Clockwork.player:NotifyAll({"PlayerLoadedPlugin", player:Name(), plugin.name});
				end;
				
				for k, v in pairs(cwPlayer.GetAll()) do
					if (v:HasInitialized()) then
						if (Clockwork.player:HasFlags(v, loadTable.access)
						or Clockwork.player:HasFlags(v, unloadTable.access)) then
							recipients[#recipients + 1] = v;
						end;
					end;
				end;
				
				if (#recipients > 0) then
					Clockwork.datastream:Start(recipients, "SystemPluginSet", {plugin.name, data[2]});
				end;
			elseif (data[2]) then
				Clockwork.player:Notify(player, {"PluginCouldNotBeUnloaded"});
			else
				Clockwork.player:Notify(player, {"PluginCouldNotBeLoaded"});
			end;
		else
			Clockwork.player:Notify(player, {"PluginDependsOnAnother"});
		end;
	end);
end;