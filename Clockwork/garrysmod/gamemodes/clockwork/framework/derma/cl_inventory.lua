--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.inventoryList = vgui.Create("cwPanelList", self);
 	self.inventoryList:SetPadding(2);
 	self.inventoryList:SetSpacing(2);
	
	self.equipmentList = vgui.Create("cwPanelList", self);
 	self.equipmentList:SetPadding(2);
 	self.equipmentList:SetSpacing(2);
	
	self.columnSheet = vgui.Create("DColumnSheet", self);
	self.columnSheet.Navigation:SetWidth(150);
	self.columnSheet:AddSheet(Clockwork.option:GetKey("name_inventory"), self.inventoryList, "icon16/box.png");
	self.columnSheet:AddSheet("Equipment", self.equipmentList, "icon16/shield.png");
	
	Clockwork.inventory.panel = self;
	Clockwork.inventory.panel:Rebuild();
end;

-- Called to by the menu to get the width of the panel.
function PANEL:GetMenuWidth()
	return ScrW() * 0.6;
end;

-- A function to handle unequipping for the panel.
function PANEL:HandleUnequip(itemTable)
	if (itemTable.OnHandleUnequip) then
		itemTable:OnHandleUnequip(
		function(arguments)
			if (arguments) then
				Clockwork.datastream:Start(
					"UnequipItem", {itemTable("uniqueID"), itemTable("itemID"), arguments}
				);
			else
				Clockwork.datastream:Start(
					"UnequipItem", {itemTable("uniqueID"), itemTable("itemID")}
				);
			end;
		end);
	else
		Clockwork.datastream:Start(
			"UnequipItem", {itemTable("uniqueID"), itemTable("itemID")}
		);
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.equipmentList:Clear();
	self.inventoryList:Clear();
	
	local label = vgui.Create("cwInfoText", self);
		label:SetText("To view an item's options, click on its spawn icon.");
		label:SetInfoColor("blue");
	self.inventoryList:AddItem(label);
	
	self.weightForm = vgui.Create("DForm", self);
	self.weightForm:SetPadding(4);
	self.weightForm:SetName("Weight");
	self.weightForm:AddItem(vgui.Create("cwInventoryWeight", self));
	
	if (Clockwork.config:Get("enable_space_system"):Get()) then
		self.spaceForm = vgui.Create("DForm", self);
		self.spaceForm:SetPadding(4);
		self.spaceForm:SetName("Space");
		self.spaceForm:AddItem(vgui.Create("cwInventorySpace", self));
	end

	local itemsList = {inventory = {}, equipment = {}};
	local categories = {inventory = {}, equipment = {}};
	
	for k, v in pairs(Clockwork.Client:GetWeapons()) do
		local itemTable = Clockwork.item:GetByWeapon(v);
		
		if (itemTable and itemTable.HasPlayerEquipped
		and itemTable:HasPlayerEquipped(Clockwork.Client, true)) then
			local itemCategory = itemTable("equippedCategory", itemTable("category"));
			itemsList.equipment[itemCategory] = itemsList.equipment[itemCategory] or {};
			itemsList.equipment[itemCategory][#itemsList.equipment[itemCategory] + 1] = itemTable;
		end;
	end;
	
	for k, v in pairs(Clockwork.inventory:GetClient()) do
		for k2, v2 in pairs(v) do
			local itemCategory = v2("category");
			
			if (v2.HasPlayerEquipped and v2:HasPlayerEquipped(Clockwork.Client, false)) then
				itemCategory = v2("equippedCategory", itemCategory);
				itemsList.equipment[itemCategory] = itemsList.equipment[itemCategory] or {};
				itemsList.equipment[itemCategory][#itemsList.equipment[itemCategory] + 1] = v2;
			else
				itemsList.inventory[itemCategory] = itemsList.inventory[itemCategory] or {};
				itemsList.inventory[itemCategory][#itemsList.inventory[itemCategory] + 1] = v2;
			end;
		end;
	end;
	
	for k, v in pairs(itemsList.equipment) do
		categories.equipment[#categories.equipment + 1] = {
			itemsList = v,
			category = k
		};
	end;
	
	table.sort(categories.equipment, function(a, b)
		return a.category < b.category;
	end);
	
	for k, v in pairs(itemsList.inventory) do
		categories.inventory[#categories.inventory + 1] = {
			itemsList = v,
			category = k
		};
	end;
	
	table.sort(categories.inventory, function(a, b)
		return a.category < b.category;
	end);
	
	Clockwork.plugin:Call("PlayerInventoryRebuilt", self, categories);
	
	if (self.weightForm) then
		self.inventoryList:AddItem(self.weightForm);
	end;

	if (Clockwork.config:Get("enable_space_system"):Get() and self.spaceForm) then
		self.inventoryList:AddItem(self.spaceForm);
	end;

	if (#categories.equipment > 0) then
		for k, v in pairs(categories.equipment) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, self.equipmentList);
				collapsibleCategory:SetCookieName("Equipment"..v.category);
			self.equipmentList:AddItem(collapsibleCategory);
			
			local categoryList = vgui.Create("DPanelList", collapsibleCategory);
				categoryList:EnableHorizontal(true);
				categoryList:SetAutoSize(true);
				categoryList:SetPadding(4);
				categoryList:SetSpacing(4);
			collapsibleCategory:SetContents(categoryList);
			
			table.sort(v.itemsList, function(a, b)
				return a("itemID") < b("itemID");
			end);
			
			for k2, v2 in pairs(v.itemsList) do
				local itemData = {
					itemTable = v2, OnPress = function()
						self:HandleUnequip(v2);
					end
				};
				
				self.itemData = itemData;
				categoryList:AddItem(
					vgui.Create("cwInventoryItem", self)
				);
			end;
		end;
	end;
	
	if (#categories.inventory > 0) then
		for k, v in pairs(categories.inventory) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, self.inventoryList);
				collapsibleCategory:SetCookieName("Inventory"..v.category);
			self.inventoryList:AddItem(collapsibleCategory);
			
			local categoryList = vgui.Create("DPanelList", collapsibleCategory);
				categoryList:EnableHorizontal(true);
				categoryList:SetAutoSize(true);
				categoryList:SetPadding(4);
				categoryList:SetSpacing(4);
			collapsibleCategory:SetContents(categoryList);
			
			table.sort(v.itemsList, function(a, b)
				return a("itemID") < b("itemID");
			end);
			
			for k2, v2 in pairs(v.itemsList) do
				local itemData = {
					itemTable = v2
				};
				
				self.itemData = itemData;
				categoryList:AddItem(
					vgui.Create("cwInventoryItem", self)
				);
			end;
		end;
	end;

	self.inventoryList:InvalidateLayout(true);
	self.equipmentList:InvalidateLayout(true);
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
	self:SetSize(w, ScrH() * 0.75);
	self.columnSheet:StretchToParent(4, 28, 4, 4);
	self.inventoryList:StretchToParent(4, 4, 4, 4);
	self.equipmentList:StretchToParent(4, 4, 4, 4);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	for k, v in pairs(Clockwork.Client:GetWeapons()) do
		local weaponItem = Clockwork.item:GetByWeapon(v);
		if (weaponItem and !v.cwIsWeaponItem) then
			Clockwork.inventory:Rebuild();
			v.cwIsWeaponItem = true;
		end;
	end;
	
	self:InvalidateLayout(true);
end;

vgui.Register("cwInventory", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip = "";
	
	if (customData.information) then
		if (type(customData.information) == "number") then
			customData.information = customData.information.."kg";
		end;
	end;
	
	if (customData.description) then
		toolTip = Clockwork.config:Parse(customData.description);
	end;
	
	if (toolTip == "") then
		toolTip = nil;
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
	
vgui.Register("cwInventoryCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().itemData;
	self:SetSize(40, 40);
	self.itemTable = itemData.itemTable;
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	
	if (!itemData.OnPress) then
		self.spawnIcon.OpenMenu = function(spawnIcon)
			Clockwork.kernel:HandleItemSpawnIconRightClick(self.itemTable, spawnIcon);
		end;
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (itemData.OnPress) then
			itemData.OnPress();
			return;
		end;
		
		Clockwork.kernel:HandleItemSpawnIconClick(self.itemTable, spawnIcon);
	end;
	
	local model, skin = Clockwork.item:GetIconInfo(self.itemTable);
		self.spawnIcon:SetModel(model, skin);
		self.spawnIcon:SetSize(40, 40);
	self.cachedInfo = {model = model, skin = skin};
end;

-- Called each frame.
function PANEL:Think()
	self.spawnIcon:SetMarkupToolTip(Clockwork.item:GetMarkupToolTip(self.itemTable));
	self.spawnIcon:SetColor(self.itemTable("color"));
	
	--[[ Check if the model or skin has changed and update the spawn icon. --]]
	local model, skin = Clockwork.item:GetIconInfo(self.itemTable);
	
	if (model != self.cachedInfo.model or skin != self.cachedInfo.skin) then
		self.spawnIcon:SetModel(model, skin);
		self.cachedInfo.model = model
		self.cachedInfo.skin = skin;
	end;
end;

vgui.Register("cwInventoryItem", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumWeight = Clockwork.player:GetMaxWeight();
	local colorWhite = Clockwork.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	
	self.weight = vgui.Create("DLabel", self);
	self.weight:SetText("N/A");
	self.weight:SetTextColor(colorWhite);
	self.weight:SizeToContents();
	self.weight:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local inventoryWeight = Clockwork.inventory:CalculateWeight(
			Clockwork.inventory:GetClient()
		);
		local maximumWeight = Clockwork.player:GetMaxWeight();
		
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp((spaceUsed:GetWide() / maximumWeight) * inventoryWeight, 0, spaceUsed:GetWide());
		local red = math.Clamp((255 / maximumWeight) * inventoryWeight, 0, 255) ;
		
		if (color) then
			color.r = math.min(color.r - 25, 255);
			color.g = math.min(color.g - 25, 255);
			color.b = math.min(color.b - 25, 255);
		end;
		
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), color);
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), Color(139, 215, 113, 255));
	end;
end;

-- Called each frame.
function PANEL:Think()
	local inventoryWeight = Clockwork.inventory:CalculateWeight(
		Clockwork.inventory:GetClient()
	);
	
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.weight:SetText(inventoryWeight.."/"..Clockwork.player:GetMaxWeight().."kg");
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("cwInventoryWeight", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumSpace = Clockwork.player:GetMaxSpace();
	local colorWhite = Clockwork.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	
	self.space = vgui.Create("DLabel", self);
	self.space:SetText("N/A");
	self.space:SetTextColor(colorWhite);
	self.space:SizeToContents();
	self.space:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local inventorySpace = Clockwork.inventory:CalculateSpace(
			Clockwork.inventory:GetClient()
		);
		local maximumSpace = Clockwork.player:GetMaxSpace();
		
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp((spaceUsed:GetWide() / maximumSpace) * inventorySpace, 0, spaceUsed:GetWide());
		local red = math.Clamp((255 / maximumSpace) * inventorySpace, 0, 255) ;
		
		if (color) then
			color.r = math.min(color.r - 25, 255);
			color.g = math.min(color.g - 25, 255);
			color.b = math.min(color.b - 25, 255);
		end;
		
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), color);
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), Color(139, 215, 113, 255));
	end;
end;

-- Called each frame.
function PANEL:Think()
	local inventorySpace = Clockwork.inventory:CalculateSpace(
		Clockwork.inventory:GetClient()
	);
	
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.space:SetText(inventorySpace.."/"..Clockwork.player:GetMaxSpace().."l");
	self.space:SetPos(self:GetWide() / 2 - self.space:GetWide() / 2, self:GetTall() / 2 - self.space:GetTall() / 2);
	self.space:SizeToContents();
end;
	
vgui.Register("cwInventorySpace", PANEL, "DPanel");