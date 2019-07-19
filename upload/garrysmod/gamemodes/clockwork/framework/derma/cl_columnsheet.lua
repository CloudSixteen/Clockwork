--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local derma = derma;
local vgui = vgui;

local PANEL = {};

-- A function to add a new sheet.
function PANEL:AddSheet(label, panel, material)
	if (!IsValid(panel)) then
		return;
	end;
	
	local newSheet = {};
	
	if (self.ButtonOnly) then
		newSheet.Button = vgui.Create("DImageButton", self.Navigation);
		newSheet.Button:Dock(TOP);
		newSheet.Button:DockMargin(0, 1, 0, 0);
	else
		newSheet.Button = vgui.Create("cwIconButton", self.Navigation);
		
		local size = Clockwork.fonts:GetSize(Clockwork.option:GetFont("menu_text_tiny"), 20);
	
		newSheet.Button:SetTall(32);
		newSheet.Button:Dock(TOP);
		newSheet.Button:DockMargin(0, 0, 0, 8);
		newSheet.Button:SetFont(size);
		
		function newSheet.Button:Paint(width, height)
			SLICED_COLUMNSHEET_BUTTON:Draw(0, 0, width, height, 8, Color(255, 255, 255, 150));
		end;
	end;
	
	newSheet.Button:SetImage(material);
	newSheet.Button.Target = panel;
	newSheet.Button:SetText(label);
	newSheet.Button.DoClick = function()
		self:SetActiveButton(newSheet.Button)
	end;
	
	newSheet.Panel = panel;
	newSheet.Panel:SetParent(self.Content);
	newSheet.Panel:SetVisible(false);
	
	if (self.ButtonOnly) then
		newSheet.Button:SizeToContents();
	end;
	
	newSheet.Button:SetColor(Clockwork.option:GetColor("columnsheet_text_normal"));
	newSheet.Button:SetExpensiveShadow(1, Clockwork.option:GetColor("columnsheet_shadow_normal"));
	
	table.insert(self.Items, newSheet)
	
	if (!IsValid(self.ActiveButton)) then
		self:SetActiveButton(newSheet.Button);
	end;
end;

-- A function to set the active button.
function PANEL:SetActiveButton(active)
	if (self.ActiveButton == active) then
		return;
	end;
	
	if (self.ActiveButton && self.ActiveButton.Target) then	
		self.ActiveButton.Target:SetVisible(false)
		self.ActiveButton:SetSelected(false)
		self.ActiveButton:SetColor(Clockwork.option:GetColor("columnsheet_text_normal"));
		self.ActiveButton:SetExpensiveShadow(1, Clockwork.option:GetColor("columnsheet_shadow_normal"));
	end

	self.ActiveButton = active;
	
	active.Target:SetVisible(true);
	active:SetSelected(true);
	active:SetColor(Clockwork.option:GetColor("columnsheet_text_active"));
	active:SetExpensiveShadow(1, Clockwork.option:GetColor("columnsheet_shadow_active"));
	
	self.Content:InvalidateLayout();
end
	
vgui.Register("cwColumnSheet", PANEL, "DColumnSheet");