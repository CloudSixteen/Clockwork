--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(2);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	local categories = {};
	local itemsList = {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (v:CanBeOrdered() and Clockwork.kernel:HasObjectAccess(Clockwork.Client, v)) then
			if (Clockwork.plugin:Call("PlayerCanSeeBusinessItem", v)) then
				local itemCategory = v("category");
				itemsList[itemCategory] = itemsList[itemCategory] or {};
				itemsList[itemCategory][#itemsList[itemCategory] + 1] = v;
			end;
		end;
	end;
	
	for k, v in pairs(itemsList) do
		categories[#categories + 1] = {
			itemsList = v,
			category = k
		};
	end;
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (#categories == 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("You do not have access to the "..Clockwork.option:GetKey("name_business", true).." menu!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
		
		Clockwork.plugin:Call("PlayerBusinessRebuilt", self, categories);
	else
		Clockwork.plugin:Call("PlayerBusinessRebuilt", self, categories);
		
		for k, v in pairs(categories) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, self.panelList);
				self.panelList:AddItem(collapsibleCategory);
			
			local categoryList = vgui.Create("DPanelList", collapsibleCategory);
				categoryList:EnableHorizontal(true);
				categoryList:SetAutoSize(true);
				categoryList:SetPadding(4);
				categoryList:SetSpacing(4);
			collapsibleCategory:SetContents(categoryList);
			
			table.sort(v.itemsList, function(a, b)
				local itemTableA = a;
				local itemTableB = b;
				
				if (itemTableA("cost") == itemTableB("cost")) then
					return itemTableA("name") < itemTableB("name");
				else
					return itemTableA("cost") > itemTableB("cost");
				end;
			end);
			
			for k2, v2 in pairs(v.itemsList) do
				self.itemData = {
					itemTable = v2
				};
				
				categoryList:AddItem(vgui.Create("cwBusinessItem", self));
			end;
		end;
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (Clockwork.menu:IsPanelActive(self)) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize(w, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwBusiness", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip = nil;
	
	if (customData.information) then
		if (type(customData.information) == "number") then
			if (customData.information != 0) then
				customData.information = Clockwork.kernel:FormatCash(customData.information);
			else
				customData.information = "Free";
			end;
		end;
	end;
	
	if (customData.description) then
		toolTip = Clockwork.config:Parse(customData.description);
	end;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	self.nameLabel:SetText(customData.name);
	self.nameLabel:SizeToContents();
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	self.infoLabel:SetText(customData.information);
	self.infoLabel:SizeToContents();
	
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	self.spawnIcon:SetColor(customData.spawnIconColor);
	
	if (customData.cooldown) then
		self.spawnIcon:SetCooldown(
			customData.cooldown.expireTime,
			customData.cooldown.textureID
		);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (customData.Callback) then
			customData.Callback();
		end;
	end;
	
	self.spawnIcon:SetModel(customData.model, customData.skin);
	self.spawnIcon:SetToolTip(toolTip);
	self.spawnIcon:SetSize(32, 32);
end;

-- Called each frame.
function PANEL:Think()
	self.infoLabel:SetPos(self.infoLabel.x, 30 - self.infoLabel:GetTall());
end;
	
vgui.Register("cwBusinessCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().itemData;
		self:SetSize(40, 40);
		self.itemTable = itemData.itemTable;
	Clockwork.plugin:Call("PlayerAdjustBusinessItemTable", self.itemTable);
	
	local model, skin = Clockwork.item:GetIconInfo(self.itemTable);
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	
	if (Clockwork.OrderCooldown and CurTime() < Clockwork.OrderCooldown) then
		self.spawnIcon:SetCooldown(Clockwork.OrderCooldown);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		Clockwork.kernel:RunCommand(
			"OrderShipment", self.itemTable("uniqueID")
		);
	end;
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetSize(40, 40);
end;

-- Called each frame.
function PANEL:Think()
	self.spawnIcon:SetMarkupToolTip(Clockwork.item:GetMarkupToolTip(self.itemTable, true));
	self.spawnIcon:SetColor(self.itemTable("color"));
end;
	
vgui.Register("cwBusinessItem", PANEL, "DPanel");