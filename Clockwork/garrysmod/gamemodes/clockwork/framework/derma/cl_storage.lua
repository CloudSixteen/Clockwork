--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local CloseDermaMenus = CloseDermaMenus;
local IsValid = IsValid;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local string = string;
local table = table;
local vgui = vgui;
local math = math;
local gui = gui;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle(Clockwork.storage:GetName());
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
			self:Close(); self:Remove();
			gui.EnableScreenClicker(false);
		Clockwork.kernel:RunCommand("StorageClose");
	end;
	
	self.containerPanel = vgui.Create("cwPanelList", self);
 	self.containerPanel:SetPadding(4);
 	self.containerPanel:SetSpacing(4);
 	self.containerPanel:SizeToContents();
 	self.containerPanel:EnableVerticalScrollbar();	
	
	if (!Clockwork.storage:GetIsOneSided()) then
		self.inventoryPanel = vgui.Create("cwPanelList", self);
		self.inventoryPanel:SetPadding(4);
		self.inventoryPanel:SetSpacing(4);
		self.inventoryPanel:SizeToContents();
		self.inventoryPanel:EnableVerticalScrollbar();
	end;
	
	Clockwork.kernel:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(storagePanel, storageType, usedWeight, weight, usedSpace, space, cash, inventory)
	storagePanel:Clear(true);
		storagePanel.cash = cash;
		storagePanel.weight = weight;
		storagePanel.usedWeight = usedWeight;
		storagePanel.space = space;
		storagePanel.usedSpace = usedSpace;
		storagePanel.inventory = inventory;
		storagePanel.storageType = storageType;
	Clockwork.plugin:Call("PlayerPreRebuildStorage", storagePanel);

	local modelIcon = vgui.Create("DModelPanel", storagePanel);
	modelIcon:SetSize(100, 250);

	local sequence;

	if (storageType == "Container") then
		local ent = Clockwork.storage:GetEntity();

		if (IsValid(ent)) then
			modelIcon:SetModel(ent:GetModel())
			sequence = ent:GetSequence();
		end;
	else
		local player = Clockwork.Client;
		
		modelIcon:SetModel(player:GetModel());
		sequence = player:GetSequence();
	end;

	local bone = modelIcon:GetEntity():LookupBone("ValveBiped.Bip01_Head1")
	local position = Vector(0, 0, 10);

	if (bone) then
		position = modelIcon:GetEntity():GetBonePosition(bone);
	end;

	modelIcon:SetLookAt(position - Vector(0, 0, 15));
	modelIcon:GetEntity():SetSequence(sequence);

	function modelIcon:LayoutEntity(entity) return self:RunAnimation(); end;

	storagePanel:AddItem(modelIcon);
	
	local categories = {};
	local usedWeight = (cash * Clockwork.config:Get("cash_weight"):Get());
	local usedSpace = (cash * Clockwork.config:Get("cash_space"):Get());
	local itemsList = {};
	
	if (Clockwork.storage:GetNoCashWeight()) then
		usedWeight = 0;
	end;

	if (Clockwork.storage:GetNoCashSpace()) then
		usedSpace = 0;
	end;

	for k, v in pairs(storagePanel.inventory) do
		for k2, v2 in pairs(v) do
			if ((storageType == "Container" and Clockwork.storage:CanTakeFrom(v2))
			or (storageType == "Inventory" and Clockwork.storage:CanGiveTo(v2))) then
				local itemCategory = v2("category");
				
				if (itemCategory) then
					itemsList[itemCategory] = itemsList[itemCategory] or {};
					itemsList[itemCategory][#itemsList[itemCategory] + 1] = v2;
					usedWeight = usedWeight + math.max(v2("storageWeight", v2("weight")), 0);
					usedSpace = usedSpace + math.max(v2("storageSpace", v2("space")), 0);
				end;
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
	
	if (!storagePanel.usedWeight) then
		storagePanel.usedWeight = usedWeight;
	end;

	if (!storagePanel.usedSpace) then
		storagePanel.usedSpace = usedSpace;
	end;
	
	Clockwork.plugin:Call(
		"PlayerStorageRebuilt", storagePanel, categories
	);
	
	local numberWang = nil;
	local cashForm = nil;
	local button = nil;
	
	if (Clockwork.config:Get("cash_enabled"):Get() and storagePanel.cash > 0) then
		numberWang = vgui.Create("DNumberWang", storagePanel);
		cashForm = vgui.Create("DForm", storagePanel);
		button = vgui.Create("DButton", storagePanel);
		
		button:SetText(L("StorageTransfer"));
		button.Stretch = true;
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			if (storageType == "Inventory") then
				Clockwork.kernel:RunCommand("StorageGiveCash", numberWang:GetValue());
			else
				Clockwork.kernel:RunCommand("StorageTakeCash", numberWang:GetValue());
			end;
		end;
		
		numberWang.Stretch = true;
		numberWang:SetDecimals(0);
		numberWang:SetMinMax(0, storagePanel.cash);
		numberWang:SetValue(storagePanel.cash);
		numberWang:SizeToContents();
				
		cashForm:SetPadding(5);
		cashForm:SetName(L("Cash"));
		cashForm:AddItem(numberWang);
		cashForm:AddItem(button);
	end;

	local informationForm = vgui.Create("DForm", storagePanel);
		informationForm:SetPadding(5);
		informationForm:SetName(L("Weight"));

		local storageWeight = vgui.Create("cwStorageWeight", storagePanel);
		storageWeight:SetWeight(weight);
		storageWeight:SetUsedWeight(usedWeight);

		informationForm:AddItem(storageWeight);
	storagePanel:AddItem(informationForm);

	if (Clockwork.inventory:UseSpaceSystem() and storagePanel.usedSpace > 0) then
		local informationForm = vgui.Create("DForm", storagePanel);
			informationForm:SetPadding(5);
			informationForm:SetName(L("Space"));

			local storageSpace = vgui.Create("cwStorageSpace", storagePanel);
			storageSpace:SetSpace(space);
			storageSpace:SetUsedSpace(usedSpace);

			informationForm:AddItem(storageSpace);
		storagePanel:AddItem(informationForm);
	end;
	
	if (cashForm) then
		storagePanel:AddItem(cashForm);
	end;
	
	if (#categories > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, storagePanel);
				collapsibleCategory:SetCookieName(storageType..v.category);
			storagePanel:AddItem(collapsibleCategory);
			
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
				CURRENT_ITEM_DATA = {
					itemTable = v2,
					storageType = storagePanel.storageType
				};
				
				categoryList:AddItem(
					vgui.Create("cwStorageItem", categoryList)
				);
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel(self.containerPanel, "Container", nil,
		Clockwork.storage:GetWeight(),
		nil, Clockwork.storage:GetSpace(),
		Clockwork.storage:GetCash(),
		Clockwork.storage:GetInventory()
	);
	
	if (!Clockwork.storage:GetIsOneSided()) then
		local inventory = Clockwork.inventory:GetClient();
		local maxWeight = Clockwork.player:GetMaxWeight();
		local weight = Clockwork.inventory:CalculateWeight(inventory);
		local maxSpace = Clockwork.player:GetMaxSpace();
		local space = Clockwork.inventory:CalculateSpace(inventory);
		local cash = Clockwork.player:GetCash();
		
		self:RebuildPanel(self.inventoryPanel, "Inventory",
			weight, maxWeight, space, maxSpace, cash, inventory
		);
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:SetSize(ScrW() * 0.5, ScrH() * 0.75);
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2));
	
	if (IsValid(self.inventoryPanel)
	and Clockwork.player:GetCash() != self.inventoryPanel.cash) then
		self:Rebuild();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);
	if (!Clockwork.storage:GetIsOneSided()) then
		self.inventoryPanel:StretchToParent(nil, 28, nil, 4);
		self.inventoryPanel:AlignRight(0);
		self.inventoryPanel:SetWide(self:GetWide() / 2);
	end;
	
	self.containerPanel:SetWide(self:GetWide() / 2);
	self.containerPanel:StretchToParent(nil, 28, nil, 4);
	self.containerPanel:AlignLeft(0);
end;

vgui.Register("cwStorage", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA;
	
	self:SetSize(56, 56);
	self.itemTable = itemData.itemTable;
	self.storageType = itemData.storageType;
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (!self.nextCanClick or CurTime() >= self.nextCanClick) then
			if (self.storageType == "Inventory") then
				Clockwork.kernel:RunCommand("StorageGiveItem", self.itemTable("uniqueID"), self.itemTable("itemID"));
			else
				Clockwork.kernel:RunCommand("StorageTakeItem", self.itemTable("uniqueID"), self.itemTable("itemID"));
			end;
			
			self.nextCanClick = CurTime() + 1;
		end;
	end;
	
	local model, skin = Clockwork.item:GetIconInfo(self.itemTable);
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetSize(56, 56);
	
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

vgui.Register("cwStorageItem", PANEL, "DPanel");

local PANEL = {};

function PANEL:SetWeight(weight)
	self.weight = weight;
end;

function PANEL:GetWeight()
	return self.weight or 0
end;

function PANEL:SetUsedWeight(usedWeight)
	self.usedWeight = usedWeight;
end;

function PANEL:GetUsedWeight()
	return self.usedWeight or 0;
end;

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = Clockwork.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	self.panel = self:GetParent();
	
	self.weightLabel = vgui.Create("DLabel", self);
	self.weightLabel:SetText("N/A");
	self.weightLabel:SetTextColor(colorWhite);
	self.weightLabel:SizeToContents();
	self.weightLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = math.floor(self:GetWeight());
		local usedWeight = math.floor(self:GetUsedWeight());
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp((spaceUsed:GetWide() / maximumWeight) * usedWeight, 0, spaceUsed:GetWide());
		local red = math.Clamp((255 / maximumWeight) * usedWeight, 0, 255) ;
		
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
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.weightLabel:SetText(math.floor(self:GetUsedWeight()).."/"..math.floor(self:GetWeight()).."kg");
	self.weightLabel:SetPos(self:GetWide() / 2 - self.weightLabel:GetWide() / 2, self:GetTall() / 2 - self.weightLabel:GetTall() / 2);
	self.weightLabel:SizeToContents();
end;
	
vgui.Register("cwStorageWeight", PANEL, "DPanel");

local PANEL = {};

function PANEL:SetSpace(space)
	self.maxSpace = space;
end;

function PANEL:GetSpace()
	return self.maxSpace or 0
end;

function PANEL:SetUsedSpace(usedSpace)
	self.usedSpace = usedSpace;
end;

function PANEL:GetUsedSpace()
	return self.usedSpace or 0;
end;

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = Clockwork.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	self.panel = self:GetParent();
	
	self.space = vgui.Create("DLabel", self);
	self.space:SetText("N/A");
	self.space:SetTextColor(colorWhite);
	self.space:SizeToContents();
	self.space:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumSpace = math.floor(self:GetSpace());
		local usedSpace = math.floor(self:GetUsedSpace());
		
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp((spaceUsed:GetWide() / maximumSpace) * usedSpace, 0, spaceUsed:GetWide());
		local red = math.Clamp((255 / maximumSpace) * usedSpace, 0, 255) ;
		
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
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.space:SetText(math.floor(self:GetUsedSpace()).."/"..math.floor(self:GetSpace()).."l");
	self.space:SetPos(self:GetWide() / 2 - self.space:GetWide() / 2, self:GetTall() / 2 - self.space:GetTall() / 2);
	self.space:SizeToContents();
end;
	
vgui.Register("cwStorageSpace", PANEL, "DPanel");

Clockwork.datastream:Hook("StorageStart", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		CloseDermaMenus();
		Clockwork.storage.panel:Close();
		Clockwork.storage.panel:Remove();
	end;
	
	gui.EnableScreenClicker(true);
	
	Clockwork.storage.noCashWeight = data.noCashWeight;
	Clockwork.storage.noCashSpace = data.noCashSpace;
	Clockwork.storage.isOneSided = data.isOneSided;
	Clockwork.storage.inventory = {};
	Clockwork.storage.weight = Clockwork.config:Get("default_inv_weight"):Get();
	Clockwork.storage.space = Clockwork.config:Get("default_inv_space"):Get();
	Clockwork.storage.entity = data.entity;
	Clockwork.storage.name = data.name;
	Clockwork.storage.cash = 0;
	
	Clockwork.storage.panel = vgui.Create("cwStorage");
	Clockwork.storage.panel:Rebuild();
	Clockwork.storage.panel:MakePopup();
	
	Clockwork.kernel:RegisterBackgroundBlur(Clockwork.storage:GetPanel(), SysTime());
end);

Clockwork.datastream:Hook("StorageCash", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		Clockwork.storage.cash = data;
		Clockwork.storage:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("StorageWeight", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		Clockwork.storage.weight = data;
		Clockwork.storage:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("StorageSpace", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		Clockwork.storage.space = data;
		Clockwork.storage:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("StorageClose", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		Clockwork.kernel:RemoveBackgroundBlur(Clockwork.storage:GetPanel());
	
		CloseDermaMenus();
		
		Clockwork.storage:GetPanel():Close();
		Clockwork.storage:GetPanel():Remove();
		
		gui.EnableScreenClicker(false);
		
		Clockwork.storage.inventory = nil;
		Clockwork.storage.weight = nil;
		Clockwork.storage.space = nil;
		Clockwork.storage.entity = nil;
		Clockwork.storage.name = nil;
	end;
end);

Clockwork.datastream:Hook("StorageTake", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		Clockwork.inventory:RemoveUniqueID(
			Clockwork.storage.inventory, data.uniqueID, data.itemID
		);
		
		Clockwork.storage:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("StorageGive", function(data)
	if (Clockwork.storage:IsStorageOpen()) then
		local itemTable = Clockwork.item:FindByID(data.index);
		
		if (itemTable) then
			for k, v in pairs(data.itemList) do
				Clockwork.inventory:AddInstance(
					Clockwork.storage.inventory,
					Clockwork.item:CreateInstance(data.index, v.itemID, v.data)
				);
			end;
			
			Clockwork.storage:GetPanel():Rebuild();
		end;
	end;
end);