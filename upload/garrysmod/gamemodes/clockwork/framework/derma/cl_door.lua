--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;
local gui = gui;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle(Clockwork.door:GetName());
	self:SetSizable(false);
	self:SetDeleteOnClose(false);
	self:SetBackgroundBlur(true);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();
		gui.EnableScreenClicker(false);
	end;
	
	self.settingsPanel = vgui.Create("cwPanelList");
 	self.settingsPanel:SetPadding(4);
 	self.settingsPanel:SetSpacing(4);
 	self.settingsPanel:SizeToContents();
	self.settingsPanel:EnableVerticalScrollbar();
	
	self.playersPanel = vgui.Create("cwPanelList");
 	self.playersPanel:SetPadding(4);
 	self.playersPanel:SetSpacing(4);
 	self.playersPanel:SizeToContents();
	self.playersPanel:EnableVerticalScrollbar();
	
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetPadding(4);
	self.settingsForm:SetName("Settings");
	
	if (Clockwork.door:IsParent()) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("A parent is the main door in a property block.");
			label:SetInfoColor("blue");
		self.settingsPanel:AddItem(label);
	end;
	
	self.settingsPanel:AddItem(self.settingsForm);
	self.textEntry = self.settingsForm:TextEntry("Text to show on the door.");
	self.textEntry:SetAllowNonAsciiCharacters(true);
	
	-- Called when enter has been pressed.
	function self.textEntry.OnEnter(textEntry)
		local text = textEntry:GetValue();
		
		if (!string.find(string.gsub(string.lower(text), "%s", ""), "thisdoorcanbepurchased")) then
			Clockwork.datastream:Start("DoorManagement", { Clockwork.door:GetEntity(), "Text", textEntry:GetValue() });
		end;
	end;
	
	if (Clockwork.door:GetOwner() == Clockwork.Client) then
		if (Clockwork.door:IsParent()) then
			self.comboBox = self.settingsForm:ComboBox("What parent access options to use.");
			self.comboBox:AddChoice("Share access to all children.");
			self.comboBox:AddChoice("Separate access between children.");
			
			if (Clockwork.door:HasSharedAccess()) then
				self.comboBox:SetText("Share access to all children.");
			else
				self.comboBox:SetText("Separate access between children.");
			end;
			
			-- Called when an option is selected.
			self.comboBox.OnSelect = function(multiChoice, index, value, data)
				if (value == "Share access to all children.") then
					Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Share"});
				else
					Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Unshare"});
				end;
			end;
			
			self.parentText = self.settingsForm:ComboBox("What parent text options to use.");
			self.parentText:AddChoice("Share text to all children.");
			self.parentText:AddChoice("Separate text between children.");
			
			if (Clockwork.door:HasSharedText()) then
				self.parentText:SetText("Share text to all children.");
			else
				self.parentText:SetText("Separate text between children.");
			end;
			
			-- Called when an option is selected.
			self.parentText.OnSelect = function(multiChoice, index, value, data)
				if (value == "Share text to all children.") then
					Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Share", "Text"});
				else
					Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Unshare", "Text"});
				end;
			end;
		end;
		
		if (!Clockwork.door:IsUnsellable()) then
			local doorCost = Clockwork.config:Get("door_cost"):Get();
			local doorText = "Sell";
			local button = nil;
			
			if (doorCost > 0) then
				button = self.settingsForm:Button("Sell");
			else
				button = self.settingsForm:Button("Unown");
			end;
			
			-- Called when the button is clicked.
			function button.DoClick(button)
				if (doorCost > 0) then
					Derma_Query("Are you sure that you want to sell this door?", "Sell the door.", "Yes", function()
						Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Sell"});
						
						gui.EnableScreenClicker(false);
						self:Close(); self:Remove();
					end, "No", function()
						gui.EnableScreenClicker(false);
					end);
				else
					Derma_Query("Are you sure that you want to unown this door?", "Unown the door.", "Yes", function()
						Clockwork.datastream:Start("DoorManagement", {Clockwork.door:GetEntity(), "Sell"});
						
						gui.EnableScreenClicker(false);
						self:Close(); self:Remove();
					end, "No", function()
						gui.EnableScreenClicker(false);
					end);
				end;
				
				gui.EnableScreenClicker(true);
			end;
		end;
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:SetPadding(4);
	self.propertySheet:AddSheet("Players", self.playersPanel, "icon16/user.png", nil, nil, "Set up who has access to this door.");
	self.propertySheet:AddSheet("Settings", self.settingsPanel, "icon16/wrench.png", nil, nil, "View the settings for this door.");

	Clockwork.kernel:SetNoticePanel(self);
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.playersPanel:Clear(true);
	
	local accessList = Clockwork.door:GetAccessList();
	local categories = {};
	local owner = Clockwork.door:GetOwner();
	local door = Clockwork.door:GetEntity();
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (Clockwork.Client != v and owner != v) then
				local access = accessList[v] or false;
				
				if (Clockwork.plugin:Call("PlayerShouldShowOnDoorAccessList", v, door, owner)) then
					local name = Clockwork.plugin:Call("GetPlayerDoorAccessName", v, door, owner);
					local index;
					
					if (access == DOOR_ACCESS_COMPLETE) then
						index = 1;
					elseif (access == DOOR_ACCESS_BASIC) then
						index = 2;
					else
						index = 3;
					end;
					
					if (!categories[index]) then
						categories[index] = {};
					end;
					
					categories[index][#categories[index] + 1] = {v, name};
				end;
			end;
		end;
	end;
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", self.playersPanel);
			local panelList = vgui.Create("DPanelList", self.playersPanel);
			
			self.playersPanel:AddItem(collapsibleCategory);
			
			table.sort(v, function(a, b)
				return a[2] < b[2];
			end);
			
			for k2, v2 in pairs(v) do
				local button = vgui.Create("DButton", self.playersPanel);
				local access = false;
				local player = v2[1];
				
				if (k == 1) then
					access = DOOR_ACCESS_COMPLETE;
				elseif (k == 2) then
					access = DOOR_ACCESS_BASIC;
				end;
				
				-- Called when the button is clicked.
				function button.DoClick(button)
					local options;
					
					if (access == DOOR_ACCESS_COMPLETE) then
						options = {
							["Take complete access."] = function()
								Clockwork.datastream:Start("DoorManagement", {door, "Access", player, access});
							end
						};
					elseif (access == DOOR_ACCESS_BASIC) then
						options = {
							["Take basic access."] = function()
								Clockwork.datastream:Start("DoorManagement", {door, "Access", player, access});
							end,
							["Give complete access."] = function()
								Clockwork.datastream:Start("DoorManagement", {door, "Access", player, DOOR_ACCESS_COMPLETE});
							end
						};
					else
						options = {
							["Give basic access."] = function()
								Clockwork.datastream:Start("DoorManagement", {door, "Access", player, DOOR_ACCESS_BASIC});
							end,
							["Give complete access."] = function()
								Clockwork.datastream:Start("DoorManagement", {door, "Access", player, DOOR_ACCESS_COMPLETE});
							end
						};
					end;
					
					if (options) then
						Clockwork.kernel:AddMenuFromData(nil, options);
					end;
				end;
				
				button:SetText(v2[2]);
				
				panelList:AddItem(button);
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetContents(panelList);
			
			if (k == 1) then
				collapsibleCategory:SetLabel("Characters with complete access.");
				collapsibleCategory:SetCookieName("cwDoorComplete");
			elseif (k == 2) then
				collapsibleCategory:SetLabel("Characters with basic access.");
				collapsibleCategory:SetCookieName("cwDoorBasic");
			else
				collapsibleCategory:SetLabel("Characters with no access.");
				collapsibleCategory:SetCookieName("cwDoorZero");
			end;
		end;
	end;
end;
-- Called each frame.
function PANEL:Think()
	local entity = Clockwork.door:GetEntity();
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2));
	
	if (!IsValid(entity) or entity:GetPos():Distance(Clockwork.Client:GetPos()) > 192) then
		self:Close(); self:Remove();
		
		gui.EnableScreenClicker(false);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);

	self.propertySheet:StretchToParent(4, 28, 4, 4);
end;

vgui.Register("cwDoor", PANEL, "DFrame");

Clockwork.datastream:Hook("PurchaseDoor", function(data)
	local doorCost = Clockwork.config:Get("door_cost"):Get();
	
	if (doorCost > 0) then
		Derma_Query("Do you want to purchase this door for "..Clockwork.kernel:FormatCash(Clockwork.config:Get("door_cost"):Get(), nil, true).."?", "Purchase this door.", "Yes", function()
			Clockwork.datastream:Start("DoorManagement", {data, "Purchase"});
			
			gui.EnableScreenClicker(false);
		end, "No", function()
			gui.EnableScreenClicker(false);
		end);
	else
		Derma_Query("Do you want to own this door?", "Own this door.", "Yes", function()
			Clockwork.datastream:Start("DoorManagement", {data, "Purchase"});
			
			gui.EnableScreenClicker(false);
		end, "No", function()
			gui.EnableScreenClicker(false);
		end);
	end;

	gui.EnableScreenClicker(true);
end);

Clockwork.datastream:Hook("SetSharedAccess", function(data)
	if (Clockwork.door:GetPanel()) then
		Clockwork.door.cwDoorSharedAxs = data;
		
		Clockwork.door:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("SetSharedText", function(data)
	if (Clockwork.door:GetPanel()) then
		Clockwork.door.cwDoorSharedTxt = data;
		
		Clockwork.door:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("DoorAccess", function(data)
	if (Clockwork.door:GetPanel()) then
		local accessList = Clockwork.door:GetAccessList();
		
		if (IsValid(data[1])) then
			if (data[2]) then
				accessList[data[1]] = data[2];
			else
				accessList[data[1]] = nil;
			end;
			
			Clockwork.door:GetPanel():Rebuild();
		end;
	end;
end);

Clockwork.datastream:Hook("DoorManagement", function(data)
	if (Clockwork.door:GetPanel()) then
		Clockwork.door:GetPanel():Remove();
	end;
	
	gui.EnableScreenClicker(true);
	
	Clockwork.door.cwDoorSharedAxs = data.cwDoorSharedAxs;
	Clockwork.door.cwDoorSharedTxt = data.cwDoorSharedTxt;
	Clockwork.door.unsellable = data.unsellable;
	Clockwork.door.accessList = data.accessList;
	Clockwork.door.isParent = data.isParent;
	Clockwork.door.entity = data.entity;
	Clockwork.door.owner = data.owner;
	Clockwork.door.name = Clockwork.entity:GetDoorName(data.entity);
	
	if (Clockwork.door.name == "") then
		Clockwork.door.name = "A door.";
	end;
	
	Clockwork.door.panel = vgui.Create("cwDoor");
	Clockwork.door.panel:MakePopup();
	Clockwork.door.panel:Rebuild();
	
	if (!Clockwork.entity:HasOwner(data.entity) or IsValid(data.owner)) then
		Clockwork.door.panel.textEntry:SetValue(Clockwork.entity:GetDoorText(data.entity));
	end;
end);