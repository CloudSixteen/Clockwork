--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
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

--[[
	@codebase Client
	@details A function to get the menu's active panel.
	@returns {Unknown}
--]]
function Clockwork.menu:GetActivePanel()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.activePanel;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether a panel is active.
	@param {Unknown} Missing description for panel.
	@returns {Unknown}
--]]
function Clockwork.menu:IsPanelActive(panel)
	return (Clockwork.menu:GetOpen() and self:GetActivePanel() == panel);
end;

--[[
	@codebase Client
	@details A function to get the menu hold time.
	@returns {Unknown}
--]]
function Clockwork.menu:GetHoldTime()
	return self.holdTime;
end;

--[[
	@codebase Client
	@details A function to get the menu's items.
	@returns {Unknown}
--]]
function Clockwork.menu:GetItems()
	return self.stored;
end;

--[[
	@codebase Client
	@details A function to get the menu's width.
	@returns {Unknown}
--]]
function Clockwork.menu:GetWidth()
	return self.width;
end;

--[[
	@codebase Client
	@details A function to get the menu's height.
	@returns {Unknown}
--]]
function Clockwork.menu:GetHeight()
	return self.height;
end;

--[[
	@codebase Client
	@details A function to toggle whether the menu is open.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to set whether the menu is open.
	@param {Unknown} Missing description for bIsOpen.
	@returns {Unknown}
--]]
function Clockwork.menu:SetOpen(bIsOpen)
	local panel = self:GetPanel();
	
	if (panel) then
		panel:SetOpen(bIsOpen);
	end;
end;

--[[
	@codebase Client
	@details A function to get whether the menu is open.
	@returns {Unknown}
--]]
function Clockwork.menu:GetOpen()
	return self.bIsOpen;
end;

--[[
	@codebase Client
	@details A function to get the menu panel.
	@returns {Unknown}
--]]
function Clockwork.menu:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

--[[
	@codebase Client
	@details A function to create the menu.
	@param {Unknown} Missing description for setOpen.
	@returns {Unknown}
--]]
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