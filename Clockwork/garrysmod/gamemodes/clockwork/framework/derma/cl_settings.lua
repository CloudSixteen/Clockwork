--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
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
	
	local availableCategories = {};
	local categories = {};
	
	for k, v in pairs(Clockwork.setting.stored) do
		if (!v.Condition or v.Condition()) then
			local category = v.category;
			
			if (!availableCategories[category]) then
				availableCategories[category] = {};
			end;
			
			availableCategories[category][#availableCategories[category] + 1] = v;
		end;
	end;
	
	for k, v in pairs(availableCategories) do
		table.sort(v, function(a, b)
			if (a.class == b.class) then
				return a.text < b.text;
			else
				return a.class < b.class;
			end;
		end);
		
		categories[#categories + 1] = {category = k, settings = v};
	end;
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (table.Count(categories) > 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("These settings are client-side to help you personalise Clockwork.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(categories) do
			local form = vgui.Create("DForm");
				self.panelList:AddItem(form);
			form:SetName(v.category);
			form:SetPadding(4);
			
			for k2, v2 in pairs(v.settings) do
				if (v2.class == "numberSlider") then
					panel = form:NumSlider(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "multiChoice") then
					panel = form:ComboBox(v2.text, v2.conVar);
					panel:SetEditable(false);
					
					for k3, v3 in pairs(v2.options) do
						panel:AddChoice(v3);
					end;
				elseif (v2.class == "numberWang") then
					panel = form:NumberWang(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "textEntry") then
					panel = form:TextEntry(v2.text, v2.conVar);
				elseif (v2.class == "checkBox") then
					panel = form:CheckBox(v2.text, v2.conVar);
				end;
				
				if (IsValid(panel)) then
					if (v2.class == "checkBox") then
						panel.Button:SetToolTip(v2.toolTip);
					else
						panel:SetToolTip(v2.toolTip);
					end;
				end;
			end;
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("You do not have access to any settings!");
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

vgui.Register("cwSettings", PANEL, "EditablePanel");