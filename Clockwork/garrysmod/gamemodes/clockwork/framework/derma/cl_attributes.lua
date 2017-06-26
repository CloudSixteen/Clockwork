--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local surface = surface;
local table = table;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(8);
 	self.panelList:SetSpacing(8);
	self.panelList:StretchToParent(4, 4, 4, 4);
	self.panelList:HideBackground();
	
	Clockwork.attributes.panel = self;
	Clockwork.attributes.panel.boosts = {};
	Clockwork.attributes.panel.progress = {};
	Clockwork.attributes.panel.attributes = {};
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	local miscellaneous = {};
	local categories = {};
	local attributes = {};
	
	for k, v in pairs(Clockwork.attribute:GetAll()) do
		if (Clockwork.kernel:HasObjectAccess(Clockwork.Client, v)) then
			if (v.category) then
				local category = v.category;
				
				attributes[category] = attributes[category] or {};
				attributes[category][#attributes[category] + 1] = {k, v.name};
			else
				miscellaneous[#miscellaneous + 1] = {k, v.name};
			end;
		end;
	end;
	
	for k, v in pairs(attributes) do
		categories[#categories + 1] = {
			attributes = v,
			category = k
		};
	end;
	
	table.sort(miscellaneous, function(a, b)
		return a[2] < b[2];
	end);
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (#categories > 0 or #miscellaneous > 0) then
		local attributeName = string.lower(Clockwork.option:GetKey("name_attribute"));
		
		--[[
		local label = vgui.Create("cwInfoText", self);
			label:SetText("The top bar represents the points and the bottom represents progress.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local label = vgui.Create("cwInfoText", self);
			label:SetText("A green bar means that the "..attributeName.." has been boosted.");
			label:SetInfoColor("green");
			label:SetShowIcon(false);
		self.panelList:AddItem(label);
		
		local label = vgui.Create("cwInfoText", self);
			label:SetText("A red bar means that the "..attributeName.." has been hindered.");
			label:SetInfoColor("red");
			label:SetShowIcon(false);
		self.panelList:AddItem(label);
		--]]
		
		for k, v in pairs(miscellaneous) do
			local categoryForm = vgui.Create("cwBasicForm", self);
			categoryForm:SetPadding(0);
			categoryForm:SetSpacing(0);
			categoryForm:SetAutoSize(true);
			categoryForm:SetText(v[2], nil, nil, 18);
			
			self.currentAttribute = v[1];
			
			categoryForm:AddItem(
				vgui.Create("cwAttributesItem", self)
			);
			
			self.panelList:AddItem(categoryForm);
		end;
		
		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("cwBasicForm", self);
			categoryForm:SetPadding(0);
			categoryForm:SetSpacing(8);
			categoryForm:SetAutoSize(true);
			categoryForm:SetText(v.category, nil, "basic_form_highlight", 25);
			
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.attributes, function(a, b)
				return a[2] < b[2];
			end);
			
			for k2, v2 in pairs(v.attributes) do
				local attributeForm = vgui.Create("cwBasicForm", self);
				attributeForm:SetPadding(0);
				attributeForm:SetSpacing(4);
				attributeForm:SetAutoSize(true);
				attributeForm:SetText(v2[2], nil, nil, 18);
				
				self.currentAttribute = v2[1];
				
				attributeForm:AddItem(
					vgui.Create("cwAttributesItem", self)
				);
				
				panelList:AddItem(attributeForm);
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(8);
			
			categoryForm:AddItem(panelList);
			
			self.panelList:AddItem(categoryForm);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("You do not have access to any "..Clockwork.option:GetKey("name_attributes", true).."!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
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
	--self.panelList:StretchToParent(4, 4, 4, 4);
	--self:SetSize(w, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	
	return true;
end;

vgui.Register("cwAttributes", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.attribute = Clockwork.attribute:FindByID(
		self:GetParent().currentAttribute
	);

	self:SetBackgroundColor(Color(80, 70, 60, 255));
	self:SetToolTip(self.attribute.description);
	self:SetSize(self:GetParent():GetWide() - 8, 32);
	
	self.baseBar = vgui.Create("DPanel", self);
	self.baseBar:SetSize(self:GetWide() - 4, 20);
	
	self.progressBar = vgui.Create("DPanel", self);
	self.progressBar:SetSize(self:GetWide() - 4, 8);
	
	self.percentageText = vgui.Create("DLabel", self);
	self.percentageText:SetText("0%");
	self.percentageText:SetTextColor(Clockwork.option:GetColor("white"));
	self.percentageText:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	self.percentageText:SizeToContents();
	self.percentageText:SetPos(
		self:GetWide() - self.percentageText:GetWide() - 16,
		self.baseBar.y + (self.baseBar:GetTall() / 2) - (self.percentageText:GetTall() / 2)
	);
	
	-- Called when the panel should be painted.
	function self.baseBar.Paint(baseBar)
		local hinderColor = Clockwork.option:GetColor("attribute_hinder_color");
		local boostColor = Clockwork.option:GetColor("attribute_boost_color");
		local attributes = Clockwork.attributes.panel.attributes;
		local mainColor = Clockwork.option:GetColor("attribute_main_color");
		local frameTime = FrameTime() * 10;
		local uniqueID = self.attribute.uniqueID;
		local curTime = CurTime();
		local default = Clockwork.attributes.stored[uniqueID];
		local boosts = Clockwork.attributes.panel.boosts;
		local boost = 0;
		
		if (!boosts[uniqueID]) then
			boosts[uniqueID] = 0;
		end;
		
		if (!attributes[uniqueID]) then
			if (default) then
				attributes[uniqueID] = default.amount;
			else
				attributes[uniqueID] = 0;
			end;
		end;
		
		if (default) then
			attributes[uniqueID] = math.Approach(
				attributes[uniqueID], default.amount, frameTime
			);
		else
			attributes[uniqueID] = math.Approach(attributes[uniqueID], 0, frameTime);
		end;
		
		if (Clockwork.attributes.boosts[uniqueID]) then
			for k, v in pairs(Clockwork.attributes.boosts[uniqueID]) do
				boost = boost + v.amount;
			end;
		end;
		
		if (boost > self.attribute.maximum) then
			boost = self.attribute.maximum;
		elseif (boost < -self.attribute.maximum) then
			boost = -self.attribute.maximum;
		end;
		
		boosts[uniqueID] = math.Approach(boosts[uniqueID], boost, frameTime);
		
		local color = Clockwork.option:GetColor("attribute_base_color");
		local width = (baseBar:GetWide() / self.attribute.maximum) * attributes[uniqueID];
		local boostData = {
			negative = boosts[uniqueID] < 0,
			boost = math.abs(boosts[uniqueID]),
			width = math.ceil((baseBar:GetWide() / self.attribute.maximum) * math.abs(boosts[uniqueID]))
		};
		local barLineWidth = width;
		
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(0, 0, baseBar:GetWide(), baseBar:GetTall());
		self:SetPercentageText(self.attribute.maximum, attributes[uniqueID], boosts[uniqueID]);
		
		if (boostData.negative) then
			if (attributes[uniqueID] - boostData.boost >= 0) then
				boostData.width = math.min(boostData.width, width);
				barLineWidth = math.max(width - boostData.width, 0);
				
				surface.SetDrawColor(Clockwork.kernel:UnpackColor(mainColor));
				surface.DrawRect(0, 0, barLineWidth, baseBar:GetTall());
				
				local hinderX = math.max(width - boostData.width, 0);
					surface.SetDrawColor(Clockwork.kernel:UnpackColor(hinderColor));
					surface.DrawRect(hinderX, 0, boostData.width, baseBar:GetTall());
				surface.SetDrawColor(255, 255, 255, 255);
				
				if (boostData.width > 4 and hinderX + boostData.width < baseBar:GetWide() - 2) then
					surface.DrawRect(hinderX + boostData.width, 0, 1, baseBar:GetTall());
				end;
			else
				surface.SetDrawColor(Clockwork.kernel:UnpackColor(hinderColor));
				surface.DrawRect(0, 0, boostData.width, baseBar:GetTall());
				
				if (boostData.width > 4 and boostData.width < baseBar:GetWide() - 2) then
					surface.DrawRect(boostData.width, 0, 1, baseBar:GetTall());
				end;
			end;
		else
			surface.SetDrawColor(Clockwork.kernel:UnpackColor(mainColor));
			surface.DrawRect(0, 0, width, baseBar:GetTall());
			
			local boostWidth = math.min(boostData.width, baseBar:GetWide());
			surface.SetDrawColor(Clockwork.kernel:UnpackColor(boostColor));
			surface.DrawRect(width, 0, boostWidth, baseBar:GetTall());
			
			if (boostData.width > 4 and boostWidth < baseBar:GetWide() - 2) then
				surface.SetDrawColor(255, 255, 255, 255);
				surface.DrawRect(width + boostWidth, 0, 1, baseBar:GetTall());
			end;
		end;
		
		if (barLineWidth > 4 and barLineWidth < baseBar:GetWide() - 2) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect(barLineWidth, 0, 1, baseBar:GetTall());
		end;
		
		surface.SetDrawColor(255, 255, 255, 255);
		surface.DrawRect(0, baseBar:GetTall() - 1, baseBar:GetWide(), 1);
	end;
	
	-- Called when the panel should be painted.
	function self.progressBar.Paint(progressBar)
		local progressColor = Clockwork.option:GetColor("attribute_progress_color");
		local uniqueID = self.attribute.uniqueID;
		local progress = Clockwork.attributes.panel.progress;
		local default = Clockwork.attributes.stored[uniqueID];
		
		if (!progress[uniqueID]) then
			if (default) then
				progress[uniqueID] = default.progress;
			else
				progress[uniqueID] = 0;
			end;
		end;
		
		if (default) then
			progress[uniqueID] = math.Approach(progress[uniqueID], default.progress, 1);
		else
			progress[uniqueID] = math.Approach(progress[uniqueID], 0, FrameTime() * 2);
		end;
		
		local width = math.ceil((progressBar:GetWide() / 100) * progress[uniqueID]);
		local color = Color(100, 100, 100, 255);
		
		surface.SetDrawColor(Clockwork.kernel:UnpackColor(color));
		surface.DrawRect(0, 0, progressBar:GetWide(), progressBar:GetTall(), color);
		surface.SetDrawColor(Clockwork.kernel:UnpackColor(progressColor));
		surface.DrawRect(0, 0, width, progressBar:GetTall(), progressColor);
		
		if (width > 4 and width < progressBar:GetWide() - 2) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect(width, 0, 1, progressBar:GetTall());
		end;
	end;
	
	if (self.attribute.image) then
		self.spawnIcon = vgui.Create("DImageButton", self);
		self.spawnIcon:SetToolTip(self.attribute.description);
		self.spawnIcon:SetImage(self.attribute.image..".png");
		self.spawnIcon:SetSize(32, 32);
		
		self.baseBar:SetPos(32, 2);
		self.progressBar:SetPos(32, 22);
	else
		self.baseBar:SetPos(2, 2);
		self.progressBar:SetPos(2, 22);
	end;
end;

-- A function to set the panel's percentage text.
function PANEL:SetPercentageText(maximum, default, boost)
	local percentage = math.Clamp(math.Round((100 / maximum) * (default + boost)), -100, 100);
	
	self.percentageText:SetText(percentage.."%");
	self.percentageText:SizeToContents();
	self.percentageText:SetPos(
		self:GetWide() - self.percentageText:GetWide() - 16,
		self.baseBar.y + (self.baseBar:GetTall() / 2) - (self.percentageText:GetTall() / 2)
	);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	local x, y = 0, 0;
	
	Clockwork.kernel:DrawSimpleGradientBox(4, x, y, w, h, self:GetBackgroundColor());
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	if (self.spawnIcon) then
		self.progressBar:SetSize(self:GetWide() - 34, 8);
		self.baseBar:SetSize(self:GetWide() - 34, 20);
		self.spawnIcon:SetPos(1, 1);
		self.spawnIcon:SetSize(30, 30);
	else
		self.progressBar:SetSize(self:GetWide() - 4, 8);
		self.baseBar:SetSize(self:GetWide() - 4, 20);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	if (self.spawnIcon) then
		self.spawnIcon:SetPos(1, 1);
		self.spawnIcon:SetSize(30, 30);
	end;
end;
	
vgui.Register("cwAttributesItem", PANEL, "DPanel");