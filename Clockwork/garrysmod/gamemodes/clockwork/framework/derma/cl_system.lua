--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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
 	self.panelList:SetPadding(8);
 	self.panelList:StretchToParent(4, 4, 4, 4);
	
	Clockwork.system.panel = self;
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	if (self.system) then
		self.navigationForm = vgui.Create("cwBasicForm", self);
		self.navigationForm:SetPadding(0);
		self.navigationForm:SetName(L("SystemMenuNavigation"));
		self.navigationForm:SetAutoSize(true);
		
		self.panelList:AddItem(self.navigationForm);
		
		local backButton = vgui.Create("cwInfoText", self);
		backButton:SetText(L("SystemMenuBackToNavigation"));
		--systemButton:SetTextToLeft(true);
		backButton:SetButton(true);
		backButton:SetInfoColor("green");
		backButton:SetShowIcon(false);
		
		-- Called when the button is clicked.
		function backButton.DoClick(button)
			self.system = nil;
			self:Rebuild();
		end;
		
		self.navigationForm:AddItem(backButton);
		
		local systemTable = Clockwork.system:FindByID(self.system);
		
		if (systemTable) then
			if (systemTable.doesCreateForm) then
				self.systemForm = vgui.Create("cwBasicForm", self);
				self.systemForm:SetPadding(8);
				self.systemForm:SetName(L(systemTable.name));
				self.systemForm:SetAutoSize(true);
				
				self.panelList:AddItem(self.systemForm);
			end;
			
			systemTable:OnDisplay(self, self.systemForm);
		end;
	else
		self.rootMenuList = vgui.Create("DPanelList", self);
		self.rootMenuList:SetPadding(24);
		self.rootMenuList:SetSpacing(48);
		self.rootMenuList:SetAutoSize(true);
		self.rootMenuList:EnableHorizontal(true);
		
		for k, v in pairs(Clockwork.system:GetAll()) do
			local item = vgui.Create("cwSystemItem", self);
			
			item:SetSystemTable(v);
			
			if (v:HasAccess()) then
				item:SetOnPressed(function()
					self.system = v.name;
					self:Rebuild();
				end);
			else
				item:SetColor(Color(255, 0, 0, 255));
			end;
			
			self.rootMenuList:AddItem(item);
		end;
		
		self.panelList:AddItem(self.rootMenuList);
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
	--self.panelList:StretchToParent(4, 4, 4, 4);
	--self:SetSize(w, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	--DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	return true;
end;

vgui.Register("cwSystem", PANEL, "EditablePanel");