--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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
		self:SetSize(scrW, scrH);
		self:SetDrawOnTop(false);
		self:SetPaintBackground(false);
		self:SetMouseInputEnabled(true);
		self:SetKeyboardInputEnabled(true);
				
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
	
	if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
		if (IsValid(self.activePanel) and self.activePanel:IsVisible()) then
			self.activePanel:MakePopup();
			self:FadeOut(0.5, self.activePanel,
				function()
					self.activePanel = nil;
				end
			);
		end;
	else
		self.activePanel:SetVisible(false);
		self.activePanel = nil;
	end;
	
	self:MoveTo(self.tabX, self.tabY, 0.4, 0, 4);
end;

-- A function to rebuild the panel.
function PANEL:Rebuild(change)
	if (!Clockwork.theme:Call("PreMainMenuRebuild", self)) then
		self.tabX = GetConVarNumber("cwTabPosX") or 0;
		self.tabY = GetConVarNumber("cwTabPosY") or 0;
		
		local activePanel = Clockwork.menu:GetActivePanel();		
		local smallTextFont = Clockwork.option:GetFont("menu_text_small");
		local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
		local scrW = ScrW();
		local scrH = ScrH();
		
		if (IsValid(self.closeMenu)) then
			self.closeMenu:Remove();
			self.characterMenu:Remove();
		end;
		
		self.closeMenu = vgui.Create("cwLabelButton", self);
		self.closeMenu:SetFont(smallTextFont);
		self.closeMenu:SetText(CW_CONVAR_CLOSESTRING:GetString() or "CLOSE MENU");
		self.closeMenu:SetCallback(function(button)
			self:SetOpen(false);
		end);
		self.closeMenu:SetToolTip("Click here to close the menu.");
		self.closeMenu:SizeToContents();
		self.closeMenu:SetMouseInputEnabled(true);
		self.closeMenu:SetPos(self.tabX, self.tabY);
		
		self.characterMenu = vgui.Create("cwLabelButton", self);
		self.characterMenu:SetFont(smallTextFont);
		self.characterMenu:SetText(CW_CONVAR_CHARSTRING:GetString() or "CHARACTERS");
		self.characterMenu:SetCallback(function(button)
			self:SetOpen(false);
			Clockwork.character:SetPanelOpen(true);
		end);
		self.characterMenu:SetToolTip("Click here to view the character menu.");
		self.characterMenu:SizeToContents();
		self.characterMenu:SetMouseInputEnabled(true);
		self.characterMenu:SetPos(self.closeMenu.x, self.closeMenu.y + self.closeMenu:GetTall() + 8);	
		
		if (change) then
			self:SetPos(self.tabX, self.tabY);		
		elseif (IsValid(self.activePanel)) then
			local width = self.activePanel:GetWide();			

			self:SetPos(-400, self.tabY);
			self:MoveTo(ScrW() - width - self.tabX - self.closeMenu:GetWide()*1.50, self.tabY, 0.4, 0, 4);
		else			
			self:SetPos(-400, self.tabY);
			self:MoveTo(self.tabX, self.tabY, 0.4, 0, 4);
		end;
	
		local bIsVisible = false;
		local width = self.characterMenu:GetWide();
		local scrH = ScrH();
		local scrW = ScrW();
		local oy = self.characterMenu.y + self.characterMenu:GetTall() + 16;
		local ox = self.closeMenu.x;
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
				panel:SetPos(self.tabX + (scrW - width - (scrW * 0.04)), self.tabY +(scrH * 0.1));
				panel.Name = v.text;
			end;
			
			if (!panel.IsButtonVisible or panel:IsButtonVisible()) then
				button = vgui.Create("cwLabelButton", self);
			end;
		
			if (button) then
				button:SetFont(Clockwork.option:GetFont("menu_text_tiny"));
				button:SetText(string.upper(v.text));
				
				if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
					button:SetAlpha(0);
					button:FadeIn(0.5);
				else
					button:SetAlpha(255);
				end;
				
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
					if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
						self:FadeOut(0.5, activePanel, function()
							self.activePanel = nil;
						end);
					else
						self.activePanel:SetVisible(false);
						self.activePanel = nil;
					end;
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
			if (CW_CONVAR_FADEPANEL:GetInt() == 1) then		
				self:FadeOut(0.5, self.activePanel, function()
					self.activePanel = nil;
					self:OpenPanel(panelToOpen);
				end);
					
				return;
			else
				self.activePanel:SetVisible(false);
				self.activePanel = nil;
				self:OpenPanel(panelToOpen);
			end;
		end;
		
		if (panelToOpen.GetMenuWidth) then
			width = panelToOpen:GetMenuWidth();
		end;
		
		self.activePanel = panelToOpen;
		self.activePanel:SetSize(width, self.activePanel:GetTall());
		self.activePanel:MakePopup();
		self.activePanel:SetPos(ScrW() + 400, scrH * 0.1); 
		
		self.activePanel.GetPanelName = function(panel)
			return panel.Name;
		end;
		
		if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
			self.activePanel:SetPos(scrW - width - (scrW * 0.04), scrH * 0.1);
			self.activePanel:SetAlpha(0);
			self:FadeIn(0.5, self.activePanel, function()
				timer.Simple(FrameTime() * 0.5, function()
					if (IsValid(self.activePanel)) then
						if (self.activePanel.OnSelected) then
							self.activePanel:OnSelected();
						end;
					end;
				end);
			end);
		else		
			self.activePanel:SetAlpha(255);
			self.activePanel:SetVisible(true);
			self.activePanel:MoveTo(scrW - width - (scrW * 0.04), scrH * 0.1, 0.4, 0, 4);
		end;
		
		Clockwork.theme:Call("PostMainMenuOpenPanel", self, panelToOpen);
	end;
end;

-- A function to make a panel fade out.
function PANEL:FadeOut(speed, panel, Callback)
	local height = Clockwork.menu:GetHeight();
	local width = Clockwork.menu:GetWidth();
	local scrW = ScrW();
	local scrH = ScrH();
	
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
			local height = Clockwork.menu:GetHeight();
			local width = Clockwork.menu:GetWidth();
			local scrW = ScrW();
			local scrH = ScrH();
			
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
	
	local x, y = self.tabX - GetConVarNumber("cwBackX"), self.tabY - GetConVarNumber("cwBackY");
	local w, h = GetConVarNumber("cwBackW"), GetConVarNumber("cwBackH");
	local scrW, scrH = ScrW(), ScrH();
	
	if (CW_CONVAR_SHOWGRADIENT:GetInt() == 1) then
		Clockwork.kernel:DrawSimpleGradientBox(
			0, x, y, w, h, Color(GetConVarNumber("cwBackColorR"), GetConVarNumber("cwBackColorG"), GetConVarNumber("cwBackColorB"), GetConVarNumber("cwBackColorA"))
		);
	elseif (CW_CONVAR_SHOWMATERIAL:GetInt() == 1) then
		local material = Material(CW_CONVAR_MATERIAL:GetString());	
		
		surface.SetDrawColor(GetConVarNumber("cwBackColorR"), GetConVarNumber("cwBackColorG"), GetConVarNumber("cwBackColorB"), GetConVarNumber("cwBackColorA"));
		surface.SetMaterial(material);
		surface.DrawTexturedRect(x, y, w, h);
	end;

	return true;
end;

-- Called every fame.
function PANEL:Think()
	if (!Clockwork.theme:Call("PreMainMenuThink", self)) then
		self:SetVisible(Clockwork.menu:GetOpen());
		self:SetSize(ScrW(), ScrH());
		self:SetPos(0,0);
	
		if (self.tabX != GetConVarNumber("cwTabPosX") or self.tabY != GetConVarNumber("cwTabPosY")) then
			self.tabX = GetConVarNumber("cwTabPosX");
			self.tabY = GetConVarNumber("cwTabPosY");
			self:Rebuild(true);
		end;
		
		if (self.closeMenu:GetText() and self.closeMenu:GetText() != CW_CONVAR_CLOSESTRING:GetString()) then
			self.closeMenu:SetText(CW_CONVAR_CLOSESTRING:GetString());
		end;
		
		if (self.characterMenu:GetText() and self.characterMenu:GetText() != CW_CONVAR_CHARSTRING:GetString()) then
			self.characterMenu:SetText(CW_CONVAR_CHARSTRING:GetString());
		end;
		
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
		
		self.closeMenu:OverrideTextColor(informationColor);
		
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