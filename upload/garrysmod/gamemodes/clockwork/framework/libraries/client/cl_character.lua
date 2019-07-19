--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local Color = Color;
local type = type;
local table = table;
local gui = gui;
local vgui = vgui;

--[[
	@codebase Client
	@details Provides an interface to the client-side character system.
	@field stored A table containing a list of stored characters.
	@field whitelisted A table containing a list of whitelisted factions.
	@field creationPanels A table containing a list of creation panels.
--]]
Clockwork.character = Clockwork.kernel:NewLibrary("Character");
Clockwork.character.stored = Clockwork.character.stored or {};
Clockwork.character.whitelisted = Clockwork.character.whitelisted or {};
Clockwork.character.creationPanels = Clockwork.character.creationPanels or {};

--[[
	@codebase Client
	@details Register a new creation panel.
	@param {String} The friendly name of the creation process.
	@param {String} The name of the VGUI panel to use.
	@param {Function} A callback to get the visibility of the process. Return false to hide.
--]]
function Clockwork.character:RegisterCreationPanel(friendlyName, vguiName, index, Condition)	
	if (index) then
		for k, v in pairs(Clockwork.character.creationPanels) do
			if (v.index >= index) then
				v.index = v.index + 1;
			end;
		end;
	end;

	table.insert(Clockwork.character.creationPanels, index or #Clockwork.character.creationPanels + 1, {
		index = index or #Clockwork.character.creationPanels + 1,
		vguiName = vguiName,
		Condition = Condition,
		friendlyName = friendlyName
	});
end;

--[[
	@codebase Client
	@details Used to remove a character creation panel from use.
--]]
function Clockwork.character:RemoveCreationPanel(name)
	local removed = false;
	local index;

	for k, v in pairs(self.creationPanels) do
		if (name == v.vguiName or name == v.friendlyName) then
			index = v.index;
			removed = true;

			table.remove(self.creationPanels, k);
		end;
	end;

	if (removed == true) then
		for k, v in pairs(Clockwork.character.creationPanels) do
			if (v.index >= index) then
				v.index = v.index - 1;
			end;
		end;
	end;
end;

--[[
	@codebase Client
	@details Get the previous creation panel.
	@returns {Table} The previous creation panel info.
--]]
function Clockwork.character:GetPreviousCreationPanel()
	local info = self:GetCreationInfo();
	local index = info.index - 1;
	
	while (self.creationPanels[index]) do
		local panelInfo = self.creationPanels[index];
		
		if (!panelInfo.Condition
		or panelInfo.Condition(info)) then
			return panelInfo;
		end;
		
		index = index - 1;
	end;
end;

--[[
	@codebase Client
	@details Get the next creation panel.
	@returns {Table} The next creation panel info.
--]]
function Clockwork.character:GetNextCreationPanel()
	local info = self:GetCreationInfo();
	local index = info.index + 1;
	
	while (self.creationPanels[index]) do
		local panelInfo = self.creationPanels[index];
		
		if (!panelInfo.Condition
		or panelInfo.Condition(info)) then
			return panelInfo;
		end;
		
		index = index + 1;
	end;
end;

--[[
	@codebase Client
	@details Reset the active character creation info.
--]]
function Clockwork.character:ResetCreationInfo()
	self:GetPanel().info = {index = 0};
end;

--[[
	@codebase Client
	@details Get the active character creation info.
	@returns {Table} The active character creation info.
--]]
function Clockwork.character:GetCreationInfo()
	return self:GetPanel().info;
end;

--[[
	@codebase Client
	@details Get the creation progress as a percentage.
	@returns Float A percentage of the creation progress.
--]]
function Clockwork.character:GetCreationProgress()
	return (100 / #self:GetCreationPanels(true)) * self:GetCreationInfo().index;
end;

--[[
	@codebase Client
	@details A function to get whether the creation process is active.
	@returns {Unknown}
--]]
function Clockwork.character:IsCreationProcessActive()
	local activePanel = self:GetActivePanel();
	
	if (activePanel and activePanel.isCreationProcess) then
		return true;
	else
		return false;
	end;
end;

--[[
	@codebase Client
	@details A function to open the previous character creation panel.
	@returns {Unknown}
--]]
function Clockwork.character:OpenPreviousCreationPanel()
	local previousPanel = self:GetPreviousCreationPanel();
	local activePanel = self:GetActivePanel();
	local panel = self:GetPanel();
	local info = self:GetCreationInfo();
	
	if (info.index > 0 and activePanel and activePanel.OnPrevious
	and activePanel:OnPrevious() == false) then
		return;
	end;
	
	if (previousPanel) then
		info.index = previousPanel.index;
		panel:OpenPanel(previousPanel.vguiName, info);
	end;
end;

--[[
	@codebase Client
	@details A function to open the next character creation panel.
	@returns {Unknown}
--]]
function Clockwork.character:OpenNextCreationPanel()
	local activePanel = self:GetActivePanel();
	local nextPanel = self:GetNextCreationPanel();
	local panel = self:GetPanel();
	local info = self:GetCreationInfo();
	
	if (info.index > 0 and activePanel and activePanel.OnNext
	and activePanel:OnNext() == false) then
		return;
	end;
	
	if (!nextPanel) then
		Clockwork.plugin:Call(
			"PlayerAdjustCharacterCreationInfo", self:GetActivePanel(), info
		);
		
		Clockwork.datastream:Start("CreateCharacter", info);
	else
		info.index = nextPanel.index;
		panel:OpenPanel(nextPanel.vguiName, info);
	end;
end;

--[[
	@codebase Client
	@details A function to get the creation panels.
	@param {Unknown} Missing description for availableOnly.
	@returns {Unknown}
--]]
function Clockwork.character:GetCreationPanels(availableOnly)
	if (availableOnly) then
		local info = self:GetCreationInfo();
		local availablePanels = {};
		
		for k, v in ipairs(self.creationPanels) do
			if (!v.Condition or v.Condition(info)) then
				table.insert(availablePanels, v);
			end;
		end;
		
		return availablePanels;
	end;

	return self.creationPanels;
end;

--[[
	@codebase Client
	@details A function to get the active panel.
	@returns {Unknown}
--]]
function Clockwork.character:GetActivePanel()
	if (IsValid(self.activePanel)) then
		return self.activePanel;
	end;
end;

--[[
	@codebase Client
	@details A function to set whether the character panel is loading.
	@param {Unknown} Missing description for loading.
	@returns {Unknown}
--]]
function Clockwork.character:SetPanelLoading(loading)
	self.loading = loading;
end;

--[[
	@codebase Client
	@details A function to get whether the character panel is loading.
	@returns {Unknown}
--]]
function Clockwork.character:IsPanelLoading()
	return self.isLoading;
end;

--[[
	@codebase Client
	@details A function to get the character panel list.
	@returns {Unknown}
--]]
function Clockwork.character:GetPanelList()
	local panel = self:GetActivePanel();
	
	if (panel and panel.isCharacterList) then
		return panel;
	end;
end;

--[[
	@codebase Client
	@details A function to get the whitelisted factions.
	@returns {Unknown}
--]]
function Clockwork.character:GetWhitelisted()
	return self.whitelisted;
end;

--[[
	@codebase Client
	@details A function to get whether the local player is whitelisted for a faction.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
function Clockwork.character:IsWhitelisted(faction)
	return table.HasValue(self:GetWhitelisted(), faction);
end;

--[[
	@codebase Client
	@details A function to get the local player's characters.
	@returns {Unknown}
--]]
function Clockwork.character:GetAll()
	return self.stored;
end;

--[[
	@codebase Client
	@details A function to get the character fault.
	@returns {Unknown}
--]]
function Clockwork.character:GetFault()
	return self.fault;
end;

--[[
	@codebase Client
	@details A function to set the character fault.
	@param {Unknown} Missing description for fault.
	@returns {Unknown}
--]]
function Clockwork.character:SetFault(fault)
	if (fault) then
		Clockwork.kernel:AddCinematicText(fault, Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);
	end;
	
	self.fault = fault;
end;

--[[
	@codebase Client
	@details A function to get the character panel.
	@returns {Unknown}
--]]
function Clockwork.character:GetPanel()
	return self.panel;
end;

--[[
	@codebase Client
	@details A function to fade in the navigation.
	@returns {Unknown}
--]]
function Clockwork.character:FadeInNavigation()
	if (IsValid(self.panel)) then
		self.panel:FadeInNavigation();
	end;
end;

--[[
	@codebase Client
	@details A function to refresh the character panel list.
	@returns {Unknown}
--]]
function Clockwork.character:RefreshPanelList()
	local factionScreens = {};
	local factionList = {};
	local panelList = self:GetPanelList();
	
	if (panelList) then
		panelList:Clear();
		
		for k, v in pairs(self:GetAll()) do
			local faction = Clockwork.plugin:Call("GetPlayerCharacterScreenFaction", v);
			if (!factionScreens[faction]) then factionScreens[faction] = {}; end;
			
			factionScreens[faction][#factionScreens[faction] + 1] = v;
		end;
		
		for k, v in pairs(factionScreens) do
			table.sort(v, function(a, b)
				return Clockwork.plugin:Call("CharacterScreenSortFactionCharacters", k, a, b);
			end);
			
			factionList[#factionList + 1] = {name = k, characters = v};
		end;
		
		table.sort(factionList, function(a, b)
			return a.name < b.name;
		end);
		
		for k, v in pairs(factionList) do
			for k2, v2 in pairs(v.characters) do
				panelList.customData = {
					name = v2.name,
					model = v2.model,
					banned = v2.banned,
					faction = v.name,
					details = v2.details,
					charTable = v2,
					characterID = v2.characterID
				};
				
				v2.panel = vgui.Create("cwCharacterPanel", panelList);
				
				if (IsValid(v2.panel)) then
					panelList:AddPanel(v2.panel);
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether the character panel is open.
	@returns {Unknown}
--]]
function Clockwork.character:IsPanelOpen()
	return self.isOpen;
end;

--[[
	@codebase Client
	@details A function to set the character panel to the main menu.
	@returns {Unknown}
--]]
function Clockwork.character:SetPanelMainMenu()
	local panel = self:GetPanel();
	
	if (panel) then
		panel:ReturnToMainMenu();
	end;
end;

--[[
	@codebase Client
	@details A function to set whether the character panel is polling.
	@param {Unknown} Missing description for polling.
	@returns {Unknown}
--]]
function Clockwork.character:SetPanelPolling(polling)
	self.isPolling = polling;
end;

--[[
	@codebase Client
	@details A function to get whether the character panel is polling.
	@returns {Unknown}
--]]
function Clockwork.character:IsPanelPolling()
	return self.isPolling;
end;

--[[
	@codebase Client
	@details A function to get whether the character menu is reset.
	@returns {Unknown}
--]]
function Clockwork.character:IsMenuReset()
	return self.isMenuReset;
end;

--[[
	@codebase Client
	@details A function to set whether the character panel is open.
	@param {Unknown} Missing description for open.
	@param {Unknown} Missing description for bReset.
	@returns {Unknown}
--]]
function Clockwork.character:SetPanelOpen(open, bReset)
	local panel = self:GetPanel();
	
	if (!open) then
		if (!bReset) then
			self.isOpen = false;
		else
			self.isOpen = true;
		end;
		
		if (panel) then
			panel:SetVisible(self:IsPanelOpen());
		end;
	elseif (panel) then
		panel:SetVisible(true);
		panel.createTime = SysTime();
		self.isOpen = true;
	else
		self:SetPanelPolling(true);
	end;
	
	gui.EnableScreenClicker(self:IsPanelOpen());
end;

--[[
	@codebase Client
	@details A function to add a character.
	@param {Unknown} Missing description for characterID.
	@param {Unknown} Missing description for data.
	@returns {Unknown}
--]]
function Clockwork.character:Add(characterID, data)
	self.stored[characterID] = data;
end;