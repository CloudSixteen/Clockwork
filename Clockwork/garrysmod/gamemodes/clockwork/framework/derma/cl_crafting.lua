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
	local blueprintsList = {};
	
	for k, v in pairs(Clockwork.crafting:GetAll()) do
		local blueprintCategory = v("category");
		
		blueprintsList[blueprintCategory] = blueprintsList[blueprintCategory] or {};
		blueprintsList[blueprintCategory][#blueprintsList[blueprintCategory] + 1] = v;
	end;
	
	for k, v in pairs(blueprintsList) do
		categories[#categories + 1] = {
			blueprintsList = v,
			category = k
		};
	end;
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (#categories == 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("There are no blueprints for the "..Clockwork.option:GetKey("crafting_name").." menu!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
	else
		for k, v in pairs(categories) do
			local collapsibleCategory = Clockwork.kernel:CreateCustomCategoryPanel(v.category, self.panelList);
				self.panelList:AddItem(collapsibleCategory);
			
			local categoryList = vgui.Create("DPanelList", collapsibleCategory);
				categoryList:EnableHorizontal(true);
				categoryList:SetAutoSize(true);
				categoryList:SetPadding(4);
				categoryList:SetSpacing(4);
			collapsibleCategory:SetContents(categoryList);
			
			table.sort(v.blueprintsList, function(a, b)
				local blueprintTableA = a;
				local blueprintTableB = b;
				
				if (blueprintTableA("cost") == blueprintTableB("cost")) then
					return blueprintTableA("name") < blueprintTableB("name");
				else
					return blueprintTableA("cost") > blueprintTableB("cost");
				end;
			end);
			
			for k2, v2 in pairs(v.blueprintsList) do
				self.blueprintData = {
					blueprintTable = v2
				};
				
				categoryList:AddItem(vgui.Create("cwCraftingBlueprint", self));
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

vgui.Register("cwCrafting", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().blueprintData;
		self:SetSize(40, 40);
		self.blueprintTable = itemData.blueprintTable;
	
	local model, skin = Clockwork.crafting:GetIconInfo(self.blueprintTable);
	self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
	
	if (Clockwork.OrderCooldown and CurTime() < Clockwork.OrderCooldown) then
		self.spawnIcon:SetCooldown(Clockwork.OrderCooldown);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		Clockwork.kernel:RunCommand(
			"CraftBlueprint", self.blueprintTable("uniqueID")
		);
	end;
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetSize(40, 40);
end;

-- Called each frame.
function PANEL:Think()
	self.spawnIcon:SetMarkupToolTip(Clockwork.crafting:GetMarkupToolTip(self.blueprintTable, true));
	self.spawnIcon:SetColor(self.blueprintTable("color"));
end;

vgui.Register("cwCraftingBlueprint", PANEL, "DPanel");