--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
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
 	self.panelList:SetPadding(4);
 	self.panelList:StretchToParent(4, 4, 4, 4);
	
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
			self.navigationForm:SetTall(100);
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
					self.systemForm:SetTall(100);
				self.panelList:AddItem(self.systemForm);
			end;
			
			systemTable:OnDisplay(self, self.systemForm);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("The "..Clockwork.option:GetKey("name_system").." provides you with various Clockwork administrative tools.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local totalY = 0;
		
		for k, v in pairs(Clockwork.system:GetAll()) do
			self.systemCategoryForm = vgui.Create("DForm", self);
				self.systemCategoryForm:SetPadding(4);
				self.systemCategoryForm:SetName(v.name);
				self.systemCategoryForm:SetTall(100);
			self.panelList:AddItem(self.systemCategoryForm);
			
			local tooltip = self.systemCategoryForm:Help(v.toolTip);

			tooltip:SetFont(Clockwork.fonts:GetSize(Clockwork.option:GetFont("menu_text_tiny"), 18));
			tooltip:SetTextColor(Clockwork.option:GetColor("basic_form_color"));
			
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
			
			--self.systemCategoryForm:SetPos(0, totalY);
			
			--totalY = totalY + 100;
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
	--self.panelList:StretchToParent(4, 4, 4, 4);
	--self:SetSize(w, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	--DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	return true;
end;

vgui.Register("cwSystem", PANEL, "EditablePanel");