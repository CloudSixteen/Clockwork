--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local pairs = pairs;
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
	
	Clockwork.system.panel = self;
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	if (self.system) then
		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);
	
		local backButton = vgui.Create("DButton", self);
			backButton:SetText("Back to Navigation");
			backButton:SetWide(self:GetParent():GetWide());
			
			-- Called when the button is clicked.
			function backButton.DoClick(button)
				self.system = nil;
				self:Rebuild();
			end;
		self.navigationForm:AddItem(backButton);
		
		local systemTable = Clockwork.system:FindByID(self.system);
		
		if (systemTable) then
			if (systemTable.doesCreateForm) then
				self.systemForm = vgui.Create("DForm", self);
					self.systemForm:SetPadding(4);
					self.systemForm:SetName(systemTable.name);
				self.panelList:AddItem(self.systemForm);
			end;
			
			systemTable:OnDisplay(self, self.systemForm);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("The "..Clockwork.option:GetKey("name_system").." provides you with various tools.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(Clockwork.system:GetAll()) do
			self.systemCategoryForm = vgui.Create("DForm", self);
				self.systemCategoryForm:SetPadding(4);
				self.systemCategoryForm:SetName(v.name);
			self.panelList:AddItem(self.systemCategoryForm);
			
			self.systemCategoryForm:Help(v.toolTip);
			
			local systemButton = vgui.Create("cwInfoText", systemPanel);
				systemButton:SetText("Open");
				systemButton:SetTextToLeft(true);
				
				if (v:HasAccess()) then
					systemButton:SetButton(true);
					systemButton:SetInfoColor("green");
					systemButton:SetToolTip("Click here to open this System panel.");
					
					-- Called when the button is clicked.
					function systemButton.DoClick(button)
						self.system = v.name;
						self:Rebuild();
					end;
				else
					systemButton:SetInfoColor("red");
					systemButton:SetToolTip("You do not have access to this System panel.");
				end;
				
				systemButton:SetShowIcon(false);
			self.systemCategoryForm:AddItem(systemButton);
		end;
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs(Clockwork.system:GetAll()) do
		if (v:HasAccess()) then
			return true;
		end;
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

vgui.Register("cwSystem", PANEL, "EditablePanel");