--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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
 	self.panelList:SetPadding(8);
 	self.panelList:SetSpacing(8);
	self.panelList:StretchToParent(4, 4, 4, 4);
	self.panelList:HideBackground();
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
			label:SetText(L("SettingsMenuHelp"));
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(categories) do
			local form = vgui.Create("cwBasicForm", self);
			
			form:SetPadding(8);
			form:SetSpacing(8);
			form:SetAutoSize(true);
			form:SetText(L(v.category), nil, "basic_form_highlight", 25);
			
			for k2, v2 in pairs(v.settings) do
				if (v2.class == "numberSlider") then
					panel = form:NumSlider(L(v2.text), v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "multiChoice") then
					local conVar = GetConVar(v2.conVar);
					
					panel = form:ComboBox(v2.text, v2.conVar);
					panel:SetValue(conVar:GetString());
					
					for k3, v3 in pairs(v2.options) do
						panel:AddChoice(v3);
					end;
				elseif (v2.class == "numberWang") then
					panel = form:NumberWang(L(v2.text), v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "textEntry") then
					panel = form:TextEntry(L(v2.text), v2.conVar);
				elseif (v2.class == "checkBox") then
					panel = form:CheckBox(L(v2.text), v2.conVar);
				elseif (v2.class == "colorMixer") then
					local mixer = vgui.Create("DColorMixer");
					local label = vgui.Create("DLabel");
					
					label:SetText(L(v2.text));
					label:SetFont(Clockwork.fonts:GetSize(Clockwork.option:GetFont("menu_text_tiny"), 16));
					label:SetTextColor(Clockwork.option:GetColor("basic_form_color"));
					mixer:SetPalette(true);
					mixer:SetAlphaBar(true);
					mixer:SetWangs(true);
					mixer:SetConVarR(v2.conVar.."R");
					mixer:SetConVarG(v2.conVar.."G");
					mixer:SetConVarB(v2.conVar.."B");
					mixer:SetConVarA(v2.conVar.."A");
					
					panel = mixer;

					form:AddItem(label);
					form:AddItem(mixer);
				end;
				
				if (IsValid(panel)) then
					if (v2.class == "checkBox") then
						panel.Button:SetToolTip(L(v2.toolTip));
					else
						panel:SetToolTip(L(v2.toolTip));
					end;
				end;
			end;
			
			self.panelList:AddItem(form);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText(L("SettingsMenuNoAccess"));
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
function PANEL:PerformLayout(w, h) end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	
	return true;
end;

vgui.Register("cwSettings", PANEL, "EditablePanel");
