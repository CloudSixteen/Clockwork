--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local ScrW = ScrW;
local ScrH = ScrH;
local math = math;
local vgui = vgui;

Clockwork.menu = Clockwork.kernel:NewLibrary("Menu");
Clockwork.menu.width = math.min(ScrW() * 0.7, 768);
Clockwork.menu.height = ScrH() * 0.75;
Clockwork.menu.stored = Clockwork.menu.stored or {};

-- A function to get the menu's active panel.
function Clockwork.menu:GetActivePanel()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.activePanel;
	end;
end;

-- A function to get whether a panel is active.
function Clockwork.menu:IsPanelActive(panel)
	return (Clockwork.menu:GetOpen() and self:GetActivePanel() == panel);
end;

-- A function to get the menu hold time.
function Clockwork.menu:GetHoldTime()
	return self.holdTime;
end;

-- A function to get the menu's items.
function Clockwork.menu:GetItems()
	return self.stored;
end;

-- A function to get the menu's width.
function Clockwork.menu:GetWidth()
	return self.width;
end;

-- A function to get the menu's height.
function Clockwork.menu:GetHeight()
	return self.height;
end;

-- A function to toggle whether the menu is open.
function Clockwork.menu:ToggleOpen()
	local panel = self:GetPanel();
	
	if (panel) then
		if (self:GetOpen()) then
			panel:SetOpen(false);
		else
			panel:SetOpen(true);
		end;
	end;
end;

-- A function to set whether the menu is open.
function Clockwork.menu:SetOpen(bIsOpen)
	local panel = self:GetPanel();
	
	if (panel) then
		panel:SetOpen(bIsOpen);
	end;
end;

-- A function to get whether the menu is open.
function Clockwork.menu:GetOpen()
	return self.bIsOpen;
end;

-- A function to get the menu panel.
function Clockwork.menu:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

-- A function to create the menu.
function Clockwork.menu:Create(setOpen)
	local panel = self:GetPanel();
	
	if (!panel) then
		self.panel = vgui.Create("cwMenu");
		
		if (IsValid(self.panel)) then
			self.panel:SetOpen(setOpen);
			self.panel:MakePopup();
		end;
	end;
end;