--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmenuName = Clockwork.salesmenu:GetName();
	
	self:SetTitle(salesmenuName);
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		
		Clockwork.datastream:Start("SalesmanDone", Clockwork.salesmenu.entity);
			Clockwork.salesmenu.buyInShipments = nil;
			Clockwork.salesmenu.priceScale = nil;
			Clockwork.salesmenu.factions = nil;
			Clockwork.salesmenu.buyRate = nil;
			Clockwork.salesmenu.classes = nil;
			Clockwork.salesmenu.entity = nil;
			Clockwork.salesmenu.stock = nil;
			Clockwork.salesmenu.sells = nil;
			Clockwork.salesmenu.cash = nil;
			Clockwork.salesmenu.text = nil;
			Clockwork.salesmenu.buys = nil;
			Clockwork.salesmenu.name = nil;
		gui.EnableScreenClicker(false);
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:SetPadding(4);
	
	if (table.Count(Clockwork.salesmenu:GetSells()) > 0) then
		self.sellsPanel = vgui.Create("cwPanelList");
		self.sellsPanel:SetPadding(4);
		self.sellsPanel:SetSpacing(4);
		self.sellsPanel:SizeToContents();
		self.sellsPanel:EnableVerticalScrollbar();
		
		self.propertySheet:AddSheet("Sells", self.sellsPanel, "icon16/box.png", nil, nil, "View items that "..salesmenuName.." sells.");
	end;
	
	if (table.Count(Clockwork.salesmenu:GetBuys()) > 0) then
		self.buysPanel = vgui.Create("cwPanelList");
		self.buysPanel:SetPadding(4);
		self.buysPanel:SetSpacing(4);
		self.buysPanel:SizeToContents();
		self.buysPanel:EnableVerticalScrollbar();
		
		self.propertySheet:AddSheet("Buys", self.buysPanel, "icon16/add.png", nil, nil, "View items that "..salesmenuName.." buys.");
	end;

	Clockwork.kernel:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(typeName, panelList, inventory)
	panelList:Clear(true);
	panelList.inventory = inventory;
	
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		local totalCash = Clockwork.salesmenu:GetCash();
		
		if (totalCash > -1) then
			local cashForm = vgui.Create("DForm", panelList);
				cashForm:SetName(L("Cash"));
				cashForm:SetPadding(4);
			panelList:AddItem(cashForm);
			
			cashForm:Help(
				Clockwork.salesmenu:GetName().." has "..Clockwork.kernel:FormatCash(totalCash, nil, true).." to their name."
			);
		end;
	end;
	
	local categories = {};
	local items = {};
	
	for k, v in pairs(panelList.inventory) do
		if (typeName == "Sells") then
			local itemTable = Clockwork.item:FindByID(k);
			
			if (itemTable) then
				local itemCategory = itemTable("category");
				
				if (itemCategory) then
					items[itemCategory] = items[itemCategory] or {};
					items[itemCategory][#items[itemCategory] + 1] = {k, v};
				end;
			end;
		else
			local itemsList = Clockwork.inventory:GetItemsByID(
				Clockwork.inventory:GetClient(), k
			);
			
			if (itemsList) then
				for k2, v2 in pairs(itemsList) do
					local itemCategory = v2("category");
					
					if (itemCategory) then
						items[itemCategory] = items[itemCategory] or {};
						items[itemCategory][#items[itemCategory] + 1] = v2;
					end;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(items) do
		categories[#categories + 1] = {
			category = k,
			items = v
		};
	end;
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, panelList);
				collapsibleCategory:SetCookieName("Salesmenu"..typeName..v.category);
			panelList:AddItem(collapsibleCategory);
			
			local categoryList = vgui.Create("DPanelList", collapsibleCategory);
				categoryList:EnableHorizontal(true);
				categoryList:SetAutoSize(true);
				categoryList:SetPadding(4);
				categoryList:SetSpacing(4);
			collapsibleCategory:SetContents(categoryList);
			
			if (typeName == "Sells") then
				table.sort(v.items, function(a, b)
					local itemTableA = Clockwork.item:FindByID(a[1]);
					local itemTableB = Clockwork.item:FindByID(b[1]);
					
					if (itemTableA.cost == itemTableB.cost) then
						return itemTableA.name < itemTableB.name;
					else
						return itemTableA.cost > itemTableB.cost;
					end;
				end);
				
				for k2, v2 in pairs(v.items) do
					CURRENT_ITEM_DATA = {
						itemTable = Clockwork.item:FindByID(v2[1]),
						typeName = typeName
					};
					
					categoryList:AddItem(
						vgui.Create("cwSalesmenuItem", categoryList)
					);
				end;
			else
				table.sort(v.items, function(a, b)
					if (a.cost == b.cost) then
						return a.name < b.name;
					else
						return a.cost > b.cost;
					end;
				end);
				
				for k2, v2 in pairs(v.items) do
					CURRENT_ITEM_DATA = {
						itemTable = v2,
						typeName = typeName
					};
					
					categoryList:AddItem(
						vgui.Create("cwSalesmenuItem", categoryList)
					);
				end;
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (IsValid(self.sellsPanel)) then
		self:RebuildPanel("Sells", self.sellsPanel, Clockwork.salesmenu:GetSells());
	end;
	
	if (IsValid(self.buysPanel)) then
		self:RebuildPanel("Buys", self.buysPanel, Clockwork.salesmenu:GetBuys());
	end;
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2));
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);

	self.propertySheet:StretchToParent(4, 28, 4, 4);
end;

vgui.Register("cwSalesmenu", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA;
	
	self:SetSize(40, 40);
	self.itemTable = itemData.itemTable;
	self.typeName = itemData.typeName;
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	self.spawnIcon:SetColor(self.itemTable("color"));
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local entity = Clockwork.salesmenu:GetEntity();
		
		if (IsValid(entity)) then
			Clockwork.datastream:Start("Salesmenu", {
				tradeType = self.typeName,
				uniqueID = self.itemTable("uniqueID"),
				itemID = self.itemTable("itemID"),
				entity = entity
			});
		end;
	end;
	
	local model, skin = Clockwork.item:GetIconInfo(self.itemTable);
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetSize(40, 40);
end;

-- Called each frame.
function PANEL:Think()
	local function DisplayCallback(displayInfo)
		local priceScale = 1;
		local amount = 0;
		
		if (self.typeName == "Sells") then
			if (Clockwork.salesmenu:BuyInShipments()) then
				amount = self.itemTable("batch");
			else
				amount = 1;
			end;
			
			priceScale = Clockwork.salesmenu:GetPriceScale();
		elseif (self.typeName == "Buys") then
			priceScale = Clockwork.salesmenu:GetBuyRate() / 100;
		end;
		
		if (Clockwork.config:Get("cash_enabled"):Get()) then
			if (self.itemTable("cost") != 0) then
				displayInfo.weight = Clockwork.kernel:FormatCash(
					(self.itemTable("cost") * priceScale) * math.max(amount, 1)
				);
			else
				displayInfo.weight = L("Priceless");
			end;
			
			local overrideCash = Clockwork.salesmenu.sells[self.itemTable("uniqueID")];
			
			if (self.typeName == "Buys") then
				overrideCash = Clockwork.salesmenu.buys[self.itemTable("uniqueID")];
			end;
			
			if (type(overrideCash) == "number") then
				displayInfo.weight = Clockwork.kernel:FormatCash(overrideCash * math.max(amount, 1));
			end;
		end;
		
		if (self.typeName == "Sells") then
			if (amount > 1) then
				displayInfo.name = L("AmountOfThing", amount, L(self.itemTable("name")));
			else
				displayInfo.name = L(self.itemTable("name"));
			end;
		end;
		
		local stockLeft = Clockwork.salesmenu.stock[self.itemTable("uniqueID")];
		
		if (self.typeName == "Sells" and stockLeft) then
			displayInfo.itemTitle = "["..stockLeft.."] ["..displayInfo.name..", "..displayInfo.weight.."]";
		end;
	end;
	
	self.spawnIcon:SetMarkupToolTip(Clockwork.item:GetMarkupToolTip(self.itemTable, true, DisplayCallback));
	self.spawnIcon:SetColor(self.itemTable("color"));
end;

vgui.Register("cwSalesmenuItem", PANEL, "DPanel");