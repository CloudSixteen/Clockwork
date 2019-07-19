--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

if (CLIENT) then
	local SYSTEM = Clockwork.system:New("ManageConfig");
	
	SYSTEM.image = "clockwork/system/config";
	SYSTEM.toolTip = "ManageConfigHelp";
	SYSTEM.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local commandTable = Clockwork.command:FindByID("CfgSetVar");
		
		if (commandTable and Clockwork.player:HasFlags(Clockwork.Client, commandTable.access)) then
			return true;
		else
			return false;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		self.adminValues = nil;
		
		self.infoText = vgui.Create("cwInfoText", systemPanel);
		self.infoText:SetText(L("ConfigMenuHelp"));
		self.infoText:SetInfoColor("blue");
		self.infoText:DockMargin(0, 0, 0, 8);
		
		systemPanel.panelList:AddItem(self.infoText);
		
		self.configForm = vgui.Create("cwBasicForm", systemPanel);
		self.configForm:SetText(L("ConfigMenuTitle"));
		self.configForm:SetPadding(8);
		self.configForm:SetSpacing(8);
		self.configForm:SetAutoSize(true);
		
		systemPanel.panelList:AddItem(self.configForm);

		self.editForm = vgui.Create("cwBasicForm", systemPanel);
		self.editForm:SetText("");
		self.editForm:SetPadding(8);
		self.editForm:SetVisible(false);
		self.editForm:SetSpacing(8);
		self.editForm:SetAutoSize(true);
		
		systemPanel.panelList:AddItem(self.editForm);
		
		if (!self.activeKey) then
			Clockwork.datastream:Start("SystemCfgKeys", true);
		end;

		self.listView = vgui.Create("DListView");
		self.listView:AddColumn(L("ConfigMenuListName"));
		self.listView:AddColumn(L("ConfigMenuListKey"));
		self.listView:AddColumn(L("ConfigMenuListAddedBy"));
		self.listView:SetMultiSelect(false);
		self.listView:SetTall(256);
		self:PopulateComboBox();
			
		function self.listView.OnRowSelected(parent, lineID, line)
			Clockwork.datastream:Start("SystemCfgValue", line.key);
		end;
			
		self.configForm:AddItem(self.listView);
	end;

	function SYSTEM:PopulateConfigBox()
		self.editForm:Clear(true);

		if (self.activeKey) then
			self.adminValues = Clockwork.config:GetFromSystem(self.activeKey.key);
			self.infoText:SetText(L("ConfigMenuStartToEdit"));
		end;

		if (self.editForm and !self.editForm:IsVisible()) then
			self.editForm:SetVisible(true);
		end;

		if (self.adminValues) then
			for k, v in pairs(string.Explode("\n", L(self.adminValues.help))) do
				self.editForm:Help(v);
			end;
			
			self.editForm:SetText(L(self.adminValues.name));
			
			if (self.activeKey.value != nil) then
				local mapEntry = self.editForm:TextEntry(L("ConfigMenuMapText"));
				local valueType = type(self.activeKey.value);
				
				if (valueType == "string") then
					local textEntry = self.editForm:TextEntry(L("ConfigMenuValueText"));
					local okayButton = self:AddOkayButton(self.editForm);
					
					textEntry:SetValue(self.activeKey.value);
					
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						Clockwork.datastream:Start("SystemCfgSet", {
							key = self.activeKey.key,
							value = textEntry:GetValue(),
							useMap = mapEntry:GetValue()
						});
					end;
				elseif (valueType == "number") then
					local numSlider = self.editForm:NumSlider(L("ConfigMenuValueText"), nil, self.adminValues.minimum, self.adminValues.maximum, self.adminValues.decimals);
					numSlider:SetValue(self.activeKey.value);
						
					local okayButton = self:AddOkayButton(self.editForm);
					
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						Clockwork.datastream:Start("SystemCfgSet", {
							key = self.activeKey.key,
							value = numSlider:GetValue(),
							useMap = mapEntry:GetValue()
						});
					end;
				elseif (valueType == "boolean") then
					local checkBox = self.editForm:CheckBox(L("ConfigMenuOnText"));
					checkBox:SetValue(self.activeKey.value);
					
					local okayButton = self:AddOkayButton(self.editForm);
					
					-- Called when the button is clicked.
					function okayButton.DoClick(okayButton)
						Clockwork.datastream:Start("SystemCfgSet", {
							key = self.activeKey.key,
							value = checkBox:GetChecked(),
							useMap = mapEntry:GetValue()
						});
					end;
				end;
			end;
		end;
	end;
	
	-- A function to add an okay button to a form.
	function SYSTEM:AddOkayButton(form)
		local okayButton = vgui.Create("cwInfoText", self);
		
		okayButton:SetText(L("ConfigMenuOkayText"));
		okayButton:SetButton(true);
		okayButton:SetInfoColor("green");
		okayButton:SetShowIcon(false);
		
		form:AddItem(okayButton);
		
		return okayButton;
	end;
	
	-- A function to populate the system's combo box.
	function SYSTEM:PopulateComboBox()
		self.listView:Clear(true);
	
		if (self.configKeys) then
			local defaultConfigItem = nil;
			
			for k, v in pairs(self.configKeys) do
				local adminValues = Clockwork.config:GetFromSystem(v);
				
				if (adminValues) then
					local comboBoxItem = self.listView:AddLine(L(adminValues.name), v, L(adminValues.category));
					
					comboBoxItem:SetToolTip(L(adminValues.help));
					comboBoxItem.key = v;
					
					if (self.activeKey and self.activeKey.key == v) then
						defaultConfigItem = comboBoxItem;
					end;
				end;
			end;
			
			if (defaultConfigItem) then
				self.listView:SelectItem(defaultConfigItem, true);
			end;
			
			self.listView:SortByColumn(1);
		end;
	end;

	SYSTEM:Register();
	
	Clockwork.datastream:Hook("SystemCfgKeys", function(data)
		local systemTable = Clockwork.system:FindByID("ManageConfig");
		
		if (systemTable) then
			systemTable.configKeys = data;
			systemTable:PopulateComboBox();
		end;
	end);
	
	Clockwork.datastream:Hook("SystemCfgValue", function(data)
		local systemTable = Clockwork.system:FindByID("ManageConfig");
		
		if (systemTable) then
			systemTable.activeKey = { key = data[1], value = data[2] };
			systemTable:PopulateConfigBox();
		end;
	end);
else
	Clockwork.datastream:Hook("SystemCfgSet", function(player, data)
		local commandTable = Clockwork.command:FindByID("CfgSetVar");
		
		if (commandTable and Clockwork.player:HasFlags(player, commandTable.access)) then
			local configObject = Clockwork.config:Get(data.key);
			
			if (configObject:IsValid()) then
				local keyPrefix = "";
				local useMap = data.useMap;
				
				if (useMap == "") then
					useMap = nil;
				end;
				
				if (useMap) then
					useMap = string.lower(Clockwork.kernel:Replace(useMap, ".bsp", ""));
					keyPrefix = useMap.."'s ";
					
					if (!file.Exists("maps/"..useMap..".bsp", "GAME")) then
						Clockwork.player:Notify(player, {"MapNameIsNotValid", useMap});
						
						return;
					end;
				end;
				
				if (!configObject("isStatic")) then
					value = configObject:Set(data.value, useMap);
					
					if (value != nil) then
						local printValue = tostring(value);
						
						if (configObject("isPrivate")) then
							if (configObject("needsRestart")) then
								Clockwork.player:NotifyAll({"PlayerSetConfigRestart", player:Name(), keyPrefix..data.key, string.rep("*", string.utf8len(printValue))});
							else
								Clockwork.player:NotifyAll({"PlayerSetConfig", player:Name(), keyPrefix..data.key, string.rep("*", string.utf8len(printValue))});
							end;
						elseif (configObject("needsRestart")) then
							Clockwork.player:NotifyAll({"PlayerSetConfigRestart", player:Name(), keyPrefix..data.key, printValue});
						else
							Clockwork.player:NotifyAll({"PlayerSetConfig", player:Name(), keyPrefix..data.key, printValue});
						end;
						
						Clockwork.datastream:Start(player, "SystemCfgValue", {data.key, configObject:Get()});
					else
						Clockwork.player:Notify(player, {"UnableToBeSet", data.key});
					end;
				else
					Clockwork.player:Notify(player, {"ConfigKeyIsStatic", data.key});
				end;
			else
				Clockwork.player:Notify(player, {"ConfigKeyIsNotValid", data.key});
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("SystemCfgKeys", function(player, data)
		local configKeys = {};
		
		for k, v in pairs(Clockwork.config:GetStored()) do
			if (!v.isStatic) then
				configKeys[#configKeys + 1] = k;
			end;
		end;
		
		table.sort(configKeys, function(a, b)
			return a < b;
		end);
		
		Clockwork.datastream:Start(player, "SystemCfgKeys", configKeys);
	end);
	
	Clockwork.datastream:Hook("SystemCfgValue", function(player, data)
		local configObject = Clockwork.config:Get(data);
		
		if (configObject:IsValid()) then
			if (type(configObject:Get()) == "string" and configObject("isPrivate")) then
				Clockwork.datastream:Start(player, "SystemCfgValue", {data, "****"});
			else
				Clockwork.datastream:Start(player, "SystemCfgValue", {
					data, configObject:GetNext(configObject:Get())
				});
			end;
		end;
	end);
end;