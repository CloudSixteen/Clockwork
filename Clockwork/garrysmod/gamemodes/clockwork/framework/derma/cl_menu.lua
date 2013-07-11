--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local SysTime = SysTime;
local IsValid = IsValid;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;
local math = math;

local GRADIENT = surface.GetTextureID("gui/gradient");
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	if (!Clockwork.theme:Call("PreMainMenuInit", self)) then
		local smallTextFont = Clockwork.option:GetFont("menu_text_small");
		local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
		local scrW = ScrW();
		local scrH = ScrH();
		
		self:SetPos(0, 0);
		self:SetSize(scrW, scrH);
		self:SetDrawOnTop(false);
		self:SetPaintBackground(false);
		self:SetMouseInputEnabled(true);
		self:SetKeyboardInputEnabled(true);
		
		self.closeMenuLabel = vgui.Create("cwLabelButton", self);
		self.closeMenuLabel:SetFont(smallTextFont);
		self.closeMenuLabel:SetText("LEAVE MENU");
		self.closeMenuLabel:SetCallback(function(button)
			self:SetOpen(false);
		end);
		self.closeMenuLabel:SetToolTip("Click here to close the menu.");
		self.closeMenuLabel:SizeToContents();
		self.closeMenuLabel:OverrideTextColor(Clockwork.option:GetColor("information"));
		self.closeMenuLabel:SetMouseInputEnabled(true);
		self.closeMenuLabel:SetPos(scrW * 0.05, scrH * 0.1);
		
		self.characterMenuLabel = vgui.Create("cwLabelButton", self);
		self.characterMenuLabel:SetFont(smallTextFont);
		self.characterMenuLabel:SetText("CHARACTERS");
		self.characterMenuLabel:SetCallback(function(button)
			self:SetOpen(false);
			Clockwork.character:SetPanelOpen(true);
		end);
		self.characterMenuLabel:SetToolTip("Click here to view the character menu.");
		self.characterMenuLabel:SizeToContents();
		self.characterMenuLabel:SetMouseInputEnabled(true);
		self.characterMenuLabel:SetPos(scrW * 0.05, self.closeMenuLabel.y + self.closeMenuLabel:GetTall() + 8);
		
		Clockwork.kernel:SetNoticePanel(self);
		
		self.CreateTime = SysTime();
		self.activePanel = nil;
		
		Clockwork.theme:Call("PostMainMenuInit", self);
		self:Rebuild();
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu(bPerformCheck)
	if (bPerformCheck) then
		if (IsValid(self.activePanel) and self.activePanel:IsVisible()) then
			self.activePanel:MakePopup();
		end;
		
		return;
	end;
	
	if (IsValid(self.activePanel) and self.activePanel:IsVisible()) then
		self.activePanel:MakePopup();
		self:FadeOut(0.5, self.activePanel,
			function()
				self.activePanel = nil;
			end
		);
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (!Clockwork.theme:Call("PreMainMenuRebuild", self)) then
		local activePanel = Clockwork.menu:GetActivePanel();
		local bIsVisible = false;
		local width = self.characterMenuLabel:GetWide();
		local scrH = ScrH();
		local scrW = ScrW();
		local oy = self.characterMenuLabel.y + self.characterMenuLabel:GetTall() + 16;
		local ox = ScrW() * 0.05;
		local y = oy;
		local x = ox;
		
		for k, v in pairs(Clockwork.menu:GetItems()) do
			if (IsValid(v.button)) then
				v.button:Remove();
			end;
		end;
		
		Clockwork.menuitems.stored = {};
		Clockwork.plugin:Call("MenuItemsAdd", Clockwork.menuitems);
		Clockwork.plugin:Call("MenuItemsDestroy", Clockwork.menuitems);
		
		table.sort(Clockwork.menuitems.stored, function(a, b)
			return a.text < b.text;
		end);
		
		for k, v in pairs(Clockwork.menuitems.stored) do
			local button, panel = nil, nil;
			
			if (Clockwork.menu.stored[v.panel]) then
				panel = Clockwork.menu.stored[v.panel].panel;
			else
				panel = vgui.Create(v.panel, self);
				panel:SetVisible(false);
				panel:SetSize(Clockwork.menu:GetWidth(), panel:GetTall());
				panel:SetPos(0, 0);
				panel.Name = v.text;
			end;
			
			if (!panel.IsButtonVisible or panel:IsButtonVisible()) then
				button = vgui.Create("cwLabelButton", self);
			end;
			
			if (button) then
				button:SetFont(Clockwork.option:GetFont("menu_text_tiny"));
				button:SetText(string.upper(v.text));
				button:SetAlpha(0);
				button:FadeIn(0.5);
				button:SetToolTip(v.tip);
				button:SetCallback(function(button)
					if (Clockwork.menu:GetActivePanel() != panel) then
						self:OpenPanel(panel);
					end;
				end);
				button:SizeToContents();
				button:SetMouseInputEnabled(true);
				button:SetPos(x, y);
				
				y = y + button:GetTall() + 8;
				bIsVisible = true;
				
				if (button:GetWide() > width) then
					width = button:GetWide();
				end;
			end;
			
			Clockwork.menu.stored[v.panel] = {
				button = button,
				panel = panel
			};
		end;
		
		for k, v in pairs(Clockwork.menu:GetItems()) do
			if (activePanel == v.panel) then
				if (!IsValid(v.button)) then
					self:FadeOut(0.5, activePanel, function()
						self.activePanel = nil;
					end);
				end;
			end;
		end;
		
		Clockwork.theme:Call("PostMainMenuRebuild", self);
	end;
end;

-- A function to open a panel.
function PANEL:OpenPanel(panelToOpen)
	if (!Clockwork.theme:Call("PreMainMenuOpenPanel", self, panelToOpen)) then
		local height = Clockwork.menu:GetHeight();
		local width = Clockwork.menu:GetWidth();
		local scrW = ScrW();
		local scrH = ScrH();
		
		if (IsValid(self.activePanel)) then
			self:FadeOut(0.5, self.activePanel, function()
				self.activePanel = nil;
				self:OpenPanel(panelToOpen);
			end);
			
			return;
		end;
		
		if (panelToOpen.GetMenuWidth) then
			width = panelToOpen:GetMenuWidth();
		end;
		
		self.activePanel = panelToOpen;
		self.activePanel:SetAlpha(0);
		self.activePanel:SetSize(width, self.activePanel:GetTall());
		self.activePanel:MakePopup();
		self.activePanel:SetPos(scrW - width - (scrW * 0.05), scrH * 0.1);
		self.activePanel.GetPanelName = function(panel)
			return panel.Name;
		end;
		
		self:FadeIn(0.5, self.activePanel, function()
			timer.Simple(FrameTime() * 0.5, function()
				if (IsValid(self.activePanel)) then
					if (self.activePanel.OnSelected) then
						self.activePanel:OnSelected();
					end;
				end;
			end);
		end);
		
		Clockwork.theme:Call("PostMainMenuOpenPanel", self, panelToOpen);
	end;
end;

-- A function to make a panel fade out.
function PANEL:FadeOut(speed, panel, Callback)
	if (panel:GetAlpha() > 0 and (!self.fadeOutAnimation or !self.fadeOutAnimation:Active())) then
		self.fadeOutAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			panel:SetAlpha(255 - (delta * 255));
			
			if (animation.Finished) then
				self.fadeOutAnimation = nil;
				panel:SetVisible(false);
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Start(speed);
		end;
		
		Clockwork.option:PlaySound("rollover");
	else
		panel:SetVisible(false);
		panel:SetAlpha(0);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- A function to make a panel fade in.
function PANEL:FadeIn(speed, panel, Callback)
	if (panel:GetAlpha() == 0 and (!self.fadeInAnimation or !self.fadeInAnimation:Active())) then
		self.fadeInAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			panel:SetVisible(true);
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished) then
				self.fadeInAnimation = nil;
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.fadeInAnimation) then
			self.fadeInAnimation:Start(speed);
		end;
		
		Clockwork.option:PlaySound("click_release");
	else
		panel:SetVisible(true);
		panel:SetAlpha(255);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	if (!Clockwork.theme:Call("PreMainMenuPaint", self)) then
		derma.SkinHook("Paint", "Panel", self);
		Clockwork.theme:Call("PostMainMenuPaint", self);
	end;
	
	local scrW, scrH = ScrW(), ScrH();
	Clockwork.kernel:DrawGradient(
		GRADIENT_RIGHT, 0, 0, scrW * 0.2, scrH, Color(100, 100, 100, 150)
	);
	
	return true;
end;

-- Called every fame.
function PANEL:Think()
	if (!Clockwork.theme:Call("PreMainMenuThink", self)) then
		if (Clockwork.plugin:Call("ShouldDrawMenuBackgroundBlur")) then
			Clockwork.kernel:RegisterBackgroundBlur(self, self.CreateTime);
		else
			Clockwork.kernel:RemoveBackgroundBlur(self);
		end;
		
		self:SetVisible(Clockwork.menu:GetOpen());
		self:SetSize(ScrW(), ScrH());
		
		Clockwork.menu.height = ScrH() * 0.75;
		Clockwork.menu.width = math.min(ScrW() * 0.7, 768);
		
		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Run();
		end;
		
		if (self.fadeInAnimation) then
			self.fadeInAnimation:Run();
		end;
		
		Clockwork.theme:Call("PostMainMenuThink", self);
		
		local activePanel = Clockwork.menu:GetActivePanel();
		local informationColor = Clockwork.option:GetColor("information");
		
		for k, v in pairs(Clockwork.menu:GetItems()) do
			if (IsValid(v.button)) then
				if (v.panel == activePanel) then
					v.button:OverrideTextColor(informationColor);
				else
					v.button:OverrideTextColor(false);
				end;
			end;
		end;
	end;
end;

-- A function to set whether the panel is open.
function PANEL:SetOpen(bIsOpen)
	self:SetVisible(bIsOpen);
	self:ReturnToMainMenu(true);
	
	Clockwork.menu.bIsOpen = bIsOpen;
	gui.EnableScreenClicker(bIsOpen);
	
	if (bIsOpen) then
		self:Rebuild();
		self.CreateTime = SysTime();
		
		Clockwork.kernel:SetNoticePanel(self);
		Clockwork.plugin:Call("MenuOpened");
	else
		Clockwork.plugin:Call("MenuClosed");
	end;
end;

vgui.Register("cwMenu", PANEL, "DPanel");

hook.Add("VGUIMousePressed", "Clockwork.menu:VGUIMousePressed", function(panel, code)
	local activePanel = Clockwork.menu:GetActivePanel();
	local menuPanel = Clockwork.menu:GetPanel();
	
	if (Clockwork.menu:GetOpen() and activePanel and menuPanel == panel) then
		menuPanel:ReturnToMainMenu();
	end;
end);

Clockwork.datastream:Hook("MenuOpen", function(data)
	local panel = Clockwork.menu:GetPanel();
	
	if (panel) then
		Clockwork.menu:SetOpen(data);
	else
		Clockwork.menu:Create(data);
	end;
end);