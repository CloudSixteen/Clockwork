--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local RunConsoleCommand = RunConsoleCommand;
local SysTime = SysTime;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local string = string;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	if (!Clockwork.theme:Call("PreCharacterMenuInit", self)) then
		local smallTextFont = Clockwork.option:GetFont("menu_text_small");
		local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
		local hugeTextFont = Clockwork.option:GetFont("menu_text_huge");
		local scrH = ScrH();
		local scrW = ScrW();
		
		self:SetPos(0, 0);
		self:SetSize(scrW, scrH);
		self:SetDrawOnTop(false);
		self:SetFocusTopLevel(true);
		self:SetPaintBackground(false);
		self:SetMouseInputEnabled(true);
		
		self.titleLabel = vgui.Create("cwLabelButton", self);
		self.titleLabel:SetDisabled(true);
		self.titleLabel:SetFont(hugeTextFont);
		
		self.subLabel = vgui.Create("cwLabelButton", self);
		self.subLabel:SetDisabled(true);
		self.subLabel:SetFont(smallTextFont);
		
		self.authorLabel = vgui.Create("cwLabelButton", self);
		self.authorLabel:SetDisabled(true);
		self.authorLabel:SetFont(tinyTextFont);
		
		self.createButton = vgui.Create("cwLabelButton", self);
		self.createButton:SetFont(smallTextFont);
		self.createButton:FadeIn(0.5);
		self.createButton:SetCallback(function(panel)
			if (table.Count(Clockwork.character:GetAll()) >= Clockwork.player:GetMaximumCharacters()) then
				return Clockwork.character:SetFault({"FaultTooManyCharacters"});
			end;
			
			Clockwork.character:ResetCreationInfo();
			Clockwork.character:OpenNextCreationPanel();
		end);
		self.createButton:SetMouseInputEnabled(true);
		
		self.loadButton = vgui.Create("cwLabelButton", self);
		self.loadButton:SetFont(smallTextFont);
		self.loadButton:FadeIn(0.5);
		self.loadButton:SetCallback(function(panel)
			self:OpenPanel("cwCharacterList", nil, function(panel)
				Clockwork.character:RefreshPanelList();
			end);
		end);
		
		self.loadButton:SetMouseInputEnabled(true);
		
		self.disconnectButton = vgui.Create("cwLabelButton", self);
		self.disconnectButton:SetFont(smallTextFont);
		self.disconnectButton:FadeIn(0.5);
		self.disconnectButton:SetCallback(function(panel)
			if (Clockwork.Client:HasInitialized() and !Clockwork.character:IsMenuReset()) then
				Clockwork.character:SetPanelMainMenu();
				Clockwork.character:SetPanelOpen(false);
			else
				RunConsoleCommand("disconnect");
			end;
		end);
		
		self.disconnectButton:SetMouseInputEnabled(true);
		
		self.previousButton = vgui.Create("cwLabelButton", self);
		self.previousButton:SetFont(tinyTextFont);
		self.previousButton:SetCallback(function(panel)
			if (!Clockwork.character:IsCreationProcessActive()) then
				local activePanel = Clockwork.character:GetActivePanel();
				
				if (activePanel and activePanel.OnPrevious) then
					activePanel:OnPrevious();
				end;
			else
				Clockwork.character:OpenPreviousCreationPanel()
			end;
		end);
		self.previousButton:SetMouseInputEnabled(true);
		
		self.nextButton = vgui.Create("cwLabelButton", self);
		self.nextButton:SetFont(tinyTextFont);
		self.nextButton:SetCallback(function(panel)
			if (!Clockwork.character:IsCreationProcessActive()) then
				local activePanel = Clockwork.character:GetActivePanel();
				
				if (activePanel and activePanel.OnNext) then
					activePanel:OnNext();
				end;
			else
				Clockwork.character:OpenNextCreationPanel()
			end;
		end);
		self.nextButton:SetMouseInputEnabled(true);
		
		self.cancelButton = vgui.Create("cwLabelButton", self);
		self.cancelButton:SetFont(tinyTextFont);
		self.cancelButton:SetCallback(function(panel)
			self:ReturnToMainMenu();
		end);
		self.cancelButton:SetMouseInputEnabled(true);
		
		local modelSize = math.min(ScrW() * 0.5, ScrH() * 0.75);
		
		self.characterModel = vgui.Create("cwCharacterModel", self);
		self.characterModel:SetSize(modelSize, modelSize);
		self.characterModel:SetAlpha(0);
		self.characterModel:SetModel("models/error.mdl");
		self.createTime = SysTime();
		
		Clockwork.theme:Call("PostCharacterMenuInit", self);
		
		self:ResetTextAndPositions();
		
		cvars.AddChangeCallback("cwLang", function()
			self:ResetTextAndPositions();
		end);
	end;
end;

-- A function to reset text and positions.
function PANEL:ResetTextAndPositions()
	local scrH = ScrH();
	local scrW = ScrW();

	self.titleLabel:SetText(string.upper(Schema:GetName()));
	
	self.subLabel:SetText(L(string.upper(Schema:GetDescription())));
	self.subLabel:SizeToContents();
	
	local schemaLogo = Clockwork.option:GetKey("schema_logo");
	
	if (schemaLogo == "") then
		self.titleLabel:SetVisible(true);
		self.titleLabel:SizeToContents();
		self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4);
		self.subLabel:SetPos((scrW / 2) - (self.subLabel:GetWide() / 2), self.titleLabel.y + self.titleLabel:GetTall() + 8);
	else
		self.titleLabel:SetVisible(false);
		self.titleLabel:SetSize(512, 256);
		self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4 - 128);
		self.subLabel:SetPos(self.titleLabel.x + (self.titleLabel:GetWide() / 2) - (self.subLabel:GetWide() / 2), self.titleLabel.y + self.titleLabel:GetTall() + 8);
	end;
	
	self.authorLabel:SetText(L("DevelopedBy", string.upper(Schema:GetAuthor())));
	self.authorLabel:SizeToContents();
	self.authorLabel:SetPos(self.subLabel.x + (self.subLabel:GetWide() - self.authorLabel:GetWide()), self.subLabel.y + self.subLabel:GetTall() + 4);
	
	self.createButton:SetText(L("CharacterMenuNew"));
	self.createButton:SizeToContents();
	self.createButton:SetPos(scrW * 0.25, 16);
	
	self.loadButton:SetText(L("CharacterMenuLoad"));
	self.loadButton:SizeToContents();
	self.loadButton:SetPos(scrW * 0.75, 16);
	
	self.disconnectButton:SetText(L("CharacterMenuLeave"));
	self.disconnectButton:SizeToContents();
	self.disconnectButton:SetPos((scrW / 2) - (self.disconnectButton:GetWide() / 2), 16);
	
	self.previousButton:SetText(L("CharacterMenuPrevious"));
	self.previousButton:SizeToContents();
	self.previousButton:SetPos((scrW * 0.2) - (self.previousButton:GetWide() / 2), scrH * 0.9);
	
	self.nextButton:SetText(L("CharacterMenuNext"));
	self.nextButton:SizeToContents();
	self.nextButton:SetPos((scrW * 0.8) - (self.nextButton:GetWide() / 2), scrH * 0.9);

	self.cancelButton:SetText(L("CharacterMenuCancel"));
	self.cancelButton:SizeToContents();
	self.cancelButton:SetPos((scrW * 0.5) - (self.cancelButton:GetWide() / 2), scrH * 0.9);
end;

-- A function to fade in the model panel.
function PANEL:FadeInModelPanel(model)
	if (ScrH() < 768) then
		return true;
	end;

	local panel = Clockwork.character:GetActivePanel();
	local x, y = ScrW() - self.characterModel:GetWide() - 8, 16;
	
	if (panel) then
		x = panel.x + panel:GetWide() - 16;
		y = (panel.y + (panel:GetTall() / 2)) - (self.characterModel:GetTall() / 2);
	end;
	
	self.characterModel:SetPos(x, y);
	
	if (self.characterModel:FadeIn(0.5)) then
		self:SetModelPanelModel(model);
		return true;
	else
		return false;
	end;
end;

-- A function to fade out the model panel.
function PANEL:FadeOutModelPanel()
	self.characterModel:FadeOut(0.5);
end;

-- A function to set the model panel's model.
function PANEL:SetModelPanelModel(model)
	if (self.characterModel.currentModel != model) then
		self.characterModel.currentModel = model;
		self.characterModel:SetModel(model);
	end;
	
	local modelPanel = self.characterModel;
	local weaponModel = Clockwork.plugin:Call("GetModelSelectWeaponModel", model);
	local sequence = Clockwork.plugin:Call("GetModelSelectSequence", modelPanel.Entity, model);
	
	if (weaponModel) then
		self.characterModel:SetWeaponModel(weaponModel);
	else
		self.characterModel:SetWeaponModel(false);
	end;
	
	if (sequence) then
		modelPanel.Entity:ResetSequence(sequence);
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu()
	local panel = Clockwork.character:GetActivePanel();
	
	if (panel) then
	--	if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
			panel:FadeOut(0.5, function()
				Clockwork.character.activePanel = nil;
					panel:Remove();
				self:FadeInTitle();
			end);
--		else
--			Clockwork.character.activePanel = nil;
	--		panel:Remove();
--		end;
	else
		self:FadeInTitle();
	end;
	
	self:FadeOutModelPanel();
	self:FadeOutNavigation();
end;

-- A function to fade out the navigation.
function PANEL:FadeOutNavigation()
	if (!Clockwork.theme:Call("PreCharacterFadeOutNavigation", self)) then
		self.previousButton:FadeOut(0.5);
		self.cancelButton:FadeOut(0.5);
		self.nextButton:FadeOut(0.5);
	end;
end;

-- A function to fade in the navigation.
function PANEL:FadeInNavigation()
	if (!Clockwork.theme:Call("PreCharacterFadeInNavigation", self)) then
		self.previousButton:FadeIn(0.5);
		self.cancelButton:FadeIn(0.5);
		self.nextButton:FadeIn(0.5);
	end;
end;

-- A function to fade out the title.
function PANEL:FadeOutTitle()
	if (!Clockwork.theme:Call("PreCharacterFadeOutTitle", self)) then
		self.subLabel:FadeOut(0.5);
		self.titleLabel:FadeOut(0.5);
		self.authorLabel:FadeOut(0.5);
	end;
end;

-- A function to fade in the title.
function PANEL:FadeInTitle()
	if (!Clockwork.theme:Call("PreCharacterFadeInTitle", self)) then
		self.subLabel:FadeIn(0.5);
		self.titleLabel:FadeIn(0.5);
		self.authorLabel:FadeIn(0.5);
	end;
end;

-- A function to open a panel.
function PANEL:OpenPanel(vguiName, childData, Callback)
	if (!Clockwork.theme:Call("PreCharacterMenuOpenPanel", self, vguiName, childData, Callback)) then
		local panel = Clockwork.character:GetActivePanel();

		local y  = ScrH() * 0.2;

		if (ScrH() < 768) then
			y = ScrH() * 0.11;
		end;
		
		if (panel) then
			panel:FadeOut(0.5, function()
				panel:Remove(); self.childData = childData;
				
				Clockwork.character.activePanel = vgui.Create(vguiName, self);
				Clockwork.character.activePanel:SetAlpha(0);
				Clockwork.character.activePanel:FadeIn(0.5);
				Clockwork.character.activePanel:MakePopup();
				
				Clockwork.character.activePanel:SetPos(ScrW() * 0.2, y);
				
				if (Callback) then
					Callback(Clockwork.character.activePanel);
				end;
				
				if (childData) then
					Clockwork.character.activePanel.isCreationProcess = true;
					Clockwork.character:FadeInNavigation();
				end;
			end);
		else
			self.childData = childData;
			self:FadeOutTitle();
			
			Clockwork.character.activePanel = vgui.Create(vguiName, self);
			Clockwork.character.activePanel:SetAlpha(0);
			Clockwork.character.activePanel:FadeIn(0.5);
			Clockwork.character.activePanel:MakePopup();
			Clockwork.character.activePanel:SetPos(ScrW() * 0.2, y);
			
			if (Callback) then
				Callback(Clockwork.character.activePanel);
			end;
			
			if (childData) then
				Clockwork.character.activePanel.isCreationProcess = true;
				Clockwork.character:FadeInNavigation();
			end;
		end;
		
		--[[ Fade out the model panel, we probably don't need it now! --]]
		self:FadeOutModelPanel();
		
		Clockwork.theme:Call("PostCharacterMenuOpenPanel", self);
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	if (!Clockwork.theme:Call("PreCharacterMenuPaint", self)) then
		local schemaLogo = Clockwork.option:GetKey("schema_logo");
		local subLabelAlpha = self.subLabel:GetAlpha();
		
		if (schemaLogo != "" and subLabelAlpha > 0) then
			if (!self.logoTextureID) then
				self.logoTextureID = Material(schemaLogo..".png");
			end;
			
			self.logoTextureID:SetFloat("$alpha", subLabelAlpha);
			
			surface.SetDrawColor(255, 255, 255, subLabelAlpha);
			surface.SetMaterial(self.logoTextureID);
			surface.DrawTexturedRect(self.titleLabel.x, self.titleLabel.y - 64, 512, 256);
		end;
		
		local backgroundColor = Clockwork.option:GetColor("background");
		local foregroundColor = Clockwork.option:GetColor("foreground");
		local colorTargetID = Clockwork.option:GetColor("target_id");
		local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
		local colorWhite = Clockwork.option:GetColor("white");
		local scrW, scrH = ScrW(), ScrH();
		local height = (self.createButton.y * 2) + self.createButton:GetTall();
		local x, y = x, 0;
		
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, y, scrW, height, Color(backgroundColor.r, backgroundColor.g, backgroundColor.b, 100));
		
		surface.SetDrawColor(foregroundColor.r, foregroundColor.g, foregroundColor.b, 200);
		surface.DrawRect(0, y + height, scrW, 1);
		
		if (Clockwork.character:IsCreationProcessActive()) then
			local creationPanels = Clockwork.character:GetCreationPanels(true);
			local numCreationPanels = #creationPanels;
			local creationProgress = Clockwork.character:GetCreationProgress();
			local progressHeight = 20;
			local progressY = y + height + 1;
			local boxColor = Color(
				math.min(backgroundColor.r + 50, 255),
				math.min(backgroundColor.g + 50, 255),
				math.min(backgroundColor.b + 50, 255),
				100
			);
			
			Clockwork.kernel:DrawSimpleGradientBox(0, 0, progressY, scrW, progressHeight, boxColor);
			
			for i = 1, numCreationPanels do
				surface.SetDrawColor(foregroundColor.r, foregroundColor.g, foregroundColor.b, 150);
				surface.DrawRect((scrW / numCreationPanels) * i, progressY, 1, progressHeight);
			end;
			
			Clockwork.kernel:DrawSimpleGradientBox(0, 0, progressY, (scrW / 100) * creationProgress, progressHeight, colorTargetID);
			
			if (creationProgress > 0 and creationProgress < 100) then
				surface.SetDrawColor(foregroundColor.r, foregroundColor.g, foregroundColor.b, 200);
				surface.DrawRect((scrW / 100) * creationProgress, progressY, 1, progressHeight);
			end;
			
			for i = 1, numCreationPanels do
				local textX = (scrW / numCreationPanels) * (i - 0.5);
				local textY = progressY + (progressHeight / 2);
				local color = Color(colorWhite.r, colorWhite.g, colorWhite.b, 200);
				
				Clockwork.kernel:DrawSimpleText(L(creationPanels[i].friendlyName), textX, textY - 1, color, 1, 1);
			end;
			
			surface.SetDrawColor(foregroundColor.r, foregroundColor.g, foregroundColor.b, 200);
			surface.DrawRect(0, progressY + progressHeight, scrW, 1);
		end;

		Clockwork.theme:Call("PostCharacterMenuPaint", self);
	end;
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	if (!Clockwork.theme:Call("PreCharacterMenuThink", self)) then
		local characters = table.Count(Clockwork.character:GetAll());
		local bIsLoading = Clockwork.character:IsPanelLoading();
		local schemaLogo = Clockwork.option:GetKey("schema_logo");
		local activePanel = Clockwork.character:GetActivePanel();
		local fault = Clockwork.character:GetFault();
		
		if (Clockwork.plugin:Call("ShouldDrawCharacterBackgroundBlur")) then
			Clockwork.kernel:RegisterBackgroundBlur(self, self.createTime);
		else
			Clockwork.kernel:RemoveBackgroundBlur(self);
		end;
		
		if (self.characterModel) then
			if (!self.characterModel.currentModel
			or self.characterModel.currentModel == "models/error.mdl") then
				self.characterModel:SetAlpha(0);
			end;
		end;
		
		if (!Clockwork.character:IsCreationProcessActive()) then
			if (activePanel) then
				if (activePanel.GetNextDisabled
				and activePanel:GetNextDisabled()) then
					self.nextButton:SetDisabled(true);
				else
					self.nextButton:SetDisabled(false);
				end;
				
				if (activePanel.GetPreviousDisabled
				and activePanel:GetPreviousDisabled()) then
					self.previousButton:SetDisabled(true);
				else
					self.previousButton:SetDisabled(false);
				end;
			end;
		else
			local previousPanelInfo = Clockwork.character:GetPreviousCreationPanel();
			
			if (previousPanelInfo) then
				self.previousButton:SetDisabled(false);
			else
				self.previousButton:SetDisabled(true);
			end;
			
			self.nextButton:SetDisabled(false);
		end;
		
		if (schemaLogo == "") then
			self.titleLabel:SetVisible(true);
		else
			self.titleLabel:SetVisible(false);
		end;
		
		if (characters == 0 or bIsLoading) then
			self.loadButton:SetDisabled(true);
		else
			self.loadButton:SetDisabled(false);
		end;
		
		if (characters >= Clockwork.player:GetMaximumCharacters()
		or Clockwork.character:IsPanelLoading()) then
			self.createButton:SetDisabled(true);
		else
			self.createButton:SetDisabled(false);
		end;
		
		if (Clockwork.Client:HasInitialized() and !Clockwork.character:IsMenuReset()) then
			self.disconnectButton:SetText(L("CharacterMenuCancel"));
			self.disconnectButton:SizeToContents();
		else
			self.disconnectButton:SetText(L("CharacterMenuLeave"));
			self.disconnectButton:SizeToContents();
		end;
		
		if (self.animation) then
			self.animation:Run();
		end;
		
		self:SetSize(ScrW(), ScrH());
		
		Clockwork.theme:Call("PostCharacterMenuThink", self)
	end;
end;

vgui.Register("cwCharacterMenu", PANEL, "DPanel");

--[[
	Add a hook to control clicking outside of the active panel.
--]]

hook.Add("VGUIMousePressed", "Clockwork.character:VGUIMousePressed", function(panel, code)
	local characterPanel = Clockwork.character:GetPanel();
	local activePanel = Clockwork.character:GetActivePanel();
	
	if (Clockwork.character:IsPanelOpen() and activePanel
	and characterPanel == panel) then
		activePanel:MakePopup();
	end;
end);

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.selectedIdx = 1;
	self.characterPanels = {};
	self.isCharacterList = true;
	
	CHAR_LIST = self;
	
	Clockwork.character:FadeInNavigation()
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");
	
	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to clear the panel's panels.
function PANEL:Clear()
	for k, v in pairs(self.characterPanels) do
		v:Remove();
	end;
	
	self.characterPanels = {};
end;

-- A function to add a panel to the panel.
function PANEL:AddPanel(panel)
	self.characterPanels[#self.characterPanels + 1] = panel;
end;

-- Called to get whether the previous button is disabled.
function PANEL:GetPreviousDisabled()
	return (self.characterPanels[self.selectedIdx - 1] == nil);
end;

-- Called to get whether the next button is disabled.
function PANEL:GetNextDisabled()
	return (self.characterPanels[self.selectedIdx + 1] == nil);
end;

-- A function to get the panel's character panels.
function PANEL:GetCharacterPanels()
	return self.characterPanels;
end;

-- A function to get the panel's selected model.
function PANEL:GetSelectedModel()
	return self.characterPanels[self.selectedIdx];
end;

-- A function to manage a panel's targets.
function PANEL:ManageTargets(panel, position, alpha)
	if (!panel.TargetPosition) then
		panel.TargetPosition = position;
	end;
	
	if (!panel.TargetAlpha) then
		panel.TargetAlpha = alpha;
	end;
	
	local interval = 64 * math.EaseInOut(self.easingValue, 0.2, 0.2);
	
	panel.TargetPosition = math.Approach(panel.TargetPosition, position, interval);
	panel.TargetAlpha = math.Approach(panel.TargetAlpha, alpha, interval);
	panel:SetAlpha(panel.TargetAlpha);
	panel:SetPos(panel.TargetPosition, 0);
end;

-- A function to set the panel's selected index.
function PANEL:SetSelectedIdx(index)
	self.selectedIdx = index;
	self.easingValue = 0;
end;

-- Called when the previous button is pressed.
function PANEL:OnPrevious()
	self.selectedIdx = math.max(self.selectedIdx - 1, 1);
	self.easingValue = 0;
	self:MakePopup();
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	self.selectedIdx = math.min(self.selectedIdx + 1, #self.characterPanels);
	self.easingValue = 0;
	self:MakePopup();
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (!self.easingValue) then
		self.easingValue = 0;
	end;
	
	self.easingValue = math.Approach(self.easingValue, 1, FrameTime());
	
	if (self.animation) then self.animation:Run(); end;
	
	while (self.selectedIdx > #self.characterPanels) do
		self.selectedIdx = self.selectedIdx - 1;
	end;
	
	if (self.selectedIdx == 0) then self.selectedIdx = 1; end;
	
	if (self.characterPanels[self.selectedIdx]) then
		local centerPanel = self.characterPanels[self.selectedIdx];
			centerPanel:SetActive(true);
		self:ManageTargets(centerPanel, (self:GetWide() / 2) - (centerPanel:GetWide() / 2), 255);
		
		local rightX = centerPanel.x + centerPanel:GetWide() + 32;
		local leftX = centerPanel.x - 32;
		
		for i = self.selectedIdx - 1, 1, -1 do
			local previousPanel = self.characterPanels[i];
			
			if (previousPanel) then
				previousPanel:SetActive(false);
				
				self:ManageTargets(previousPanel, leftX - previousPanel:GetWide(), (255 / self.selectedIdx) * i);
				
				leftX = previousPanel.x - 32;
			end;
		end;
		
		for k, v in pairs(self.characterPanels) do
			if (k > self.selectedIdx) then
				v:SetActive(false);
				
				self:ManageTargets(v, rightX, (255 / ((#self.characterPanels + 1) - self.selectedIdx)) * ((#self.characterPanels + 1) - k));
				
				rightX = v.x + v:GetWide() + 32;
			end;
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self:SetPos(0, 96);
	self:SetSize(ScrW(), ScrH() - (96 * 2));
end;

vgui.Register("cwCharacterList", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
	local buttonsList = {};
	local colorWhite = Clockwork.option:GetColor("white");
	local buttonX = 20;
	local buttonY = 0;
	local labels = {};
	
	self.customData = self:GetParent().customData;
	self.buttonPanels = {};
	self:SetPaintBackground(false);
	
	Clockwork.plugin:Call("GetCharacterPanelLabels", labels, self.customData);
	
	self.nameLabel = vgui.Create("cwLabelButton", self);
	self.nameLabel:SetDisabled(true);
	self.nameLabel:SetFont(smallTextFont);
	self.nameLabel:SetText(string.upper(self.customData.name));
	self.nameLabel:SizeToContents();
	self.nameLabel:SetPos(0, 80);
	
	self.factionLabel = vgui.Create("cwLabelButton", self);
	self.factionLabel:SetDisabled(true);
	self.factionLabel:SetFont(tinyTextFont);
	self.factionLabel:SetText(string.upper(self.customData.faction));
	self.factionLabel:SizeToContents();
	self.factionLabel:SetPos(0, self.nameLabel.y + self.nameLabel:GetTall() + 4);
	
	local color = Color(255, 255, 255, 255);
	local factionTable = Clockwork.faction:FindByID(self.customData.faction);
	
	if (!factionTable or !factionTable.color) then
		for k, v in pairs(Clockwork.class:GetAll()) do
			if (v.factions and table.HasValue(v.factions, self.customData.faction)) then
				color = v.color;
			end;
		end;
	else	
		color = factionTable.color;
	end;
	
	self.factionLabel:OverrideTextColor(color)
	
	local modelSize = math.min(ScrW() * 0.4, ScrH() * 0.65);
	
	self.characterModel = vgui.Create("cwCharacterModel", self);
	self.characterModel:SetModel(self.customData.model);
	self.characterModel:SetSize(modelSize, modelSize);
	self.characterModel:SetMouseInputEnabled(true);
	
	buttonY = self.factionLabel.y + self.factionLabel:GetTall() + 4;
	
	self.characterModel:SetPos(0, buttonY - (self.characterModel:GetTall() * 0.1));
	
	local modelPanel = self.characterModel;
	local sequence = Clockwork.plugin:Call("GetCharacterPanelSequence", modelPanel.Entity, self.customData.charTable);
	
	if (sequence) then
		modelPanel.Entity:ResetSequence(sequence);
	end;
	
	self.useButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
	self.useButton:SetToolTip(L("UseThisCharacter"));
	self.useButton:SetImage("icon16/tick.png");
	self.useButton:SetSize(16, 16);
	self.useButton:SetPos(0, buttonY);
	self.useButton:SetMouseInputEnabled(true);
	
	self.deleteButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
	self.deleteButton:SetToolTip(L("DeleteThisCharacter"));
	self.deleteButton:SetImage("icon16/cross.png");
	self.deleteButton:SetSize(16, 16);
	self.deleteButton:SetPos(20, buttonY);
	self.deleteButton:SetMouseInputEnabled(true);
	
	Clockwork.plugin:Call("GetCustomCharacterButtons", self.customData.charTable, buttonsList);
	
	for k, v in pairs(buttonsList) do
		local button = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
			buttonX = buttonX + 20;
			button:SetToolTip(v.toolTip);
			button:SetImage(v.image);
			button:SetSize(16, 16);
			button:SetPos(buttonX, buttonY);
			button:SetMouseInputEnabled(true);
		self.buttonPanels[#self.buttonPanels + 1] = button;
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			local function Callback()
				Clockwork.datastream:Start("InteractCharacter", {
					characterID = self.customData.characterID, action = k
				});
			end;
			
			if (!v.OnClick or v.OnClick(Callback) != false) then
				Callback();
			end;
		end;
	end;
	
	-- Called when the button is clicked.
	function self.useButton.DoClick(spawnIcon)
		Clockwork.datastream:Start("InteractCharacter", {
			characterID = self.customData.characterID, action = "use"}
		);
	end;
	
	-- Called when the button is clicked.
	function self.deleteButton.DoClick(spawnIcon)
		Clockwork.kernel:AddMenuFromData(nil, {
			["Yes"] = function()
				Clockwork.datastream:Start("InteractCharacter", {
					characterID = self.customData.characterID, action = "delete"}
				);
			end,
			["No"] = function() end
		});
	end;
	
	local modelPanel = self.characterModel;
	
	-- Called when the character model is clicked.
	function modelPanel.DoClick(modelPanel)
		local activePanel = Clockwork.character:GetActivePanel();
		
		if (activePanel:GetSelectedModel() == self) then
			local options = {};
			local panel = Clockwork.character:GetPanel();
			
			options["Use"] = function()
				Clockwork.datastream:Start("InteractCharacter", {
					characterID = self.customData.characterID, action = "use"}
				);
			end;
			
			options["Delete"] = {};
			options["Delete"]["No"] = function() end;
			options["Delete"]["Yes"] = function()
				Clockwork.datastream:Start("InteractCharacter", {
					characterID = self.customData.characterID, action = "delete"}
				);
			end;
			
			Clockwork.plugin:Call(
				"GetCustomCharacterOptions", self.customData.charTable, options, menu
			);
			
			Clockwork.kernel:AddMenuFromData(nil, options, function(menu, key, value)
				menu:AddOption(T(key), function()
					Clockwork.datastream:Start("InteractCharacter", {
						characterID = self.customData.characterID, action = value}
					);
				end);
			end);
		else
			for k, v in pairs(activePanel:GetCharacterPanels()) do
				if (v == self) then
					activePanel:SetSelectedIdx(k);
				end;
			end;
		end;
	end;
	
	local maxWidth = math.max(buttonX, 200);
	
	if (self.nameLabel:GetWide() > maxWidth) then
		maxWidth = self.nameLabel:GetWide();
	end;
	
	if (self.factionLabel:GetWide() > maxWidth) then
		maxWidth = self.factionLabel:GetWide();
	end;
	
	local labelY = self.characterModel.y + self.characterModel:GetTall() + 4;
	
	for k, v in pairs(labels) do
		local label = vgui.Create("cwLabelButton", self);
		
		label:SetDisabled(true);
		label:SetFont(tinyTextFont);
		label:SetText(string.upper(v.text));
		label:OverrideTextColor(v.color)
		label:SizeToContents();
		label:SetPos((maxWidth / 2) - (label:GetWide()/2), labelY);
		labelY = labelY + label:GetTall() + 4;
	end;
	
	self.characterModel.x = (maxWidth / 2) - (self.characterModel:GetWide() / 2);
	self.nameLabel:SetPos((maxWidth / 2) - (self.nameLabel:GetWide() / 2), self.nameLabel.y);
	self.factionLabel:SetPos((maxWidth / 2) - (self.factionLabel:GetWide() / 2), self.factionLabel.y);
	self:SetSize(maxWidth, ScrH());
	
	local buttonAddX = ((maxWidth / 2) - (buttonX / 2)) - 10;
	
	self.useButton:SetPos(self.useButton.x + buttonAddX, self.useButton.y);
	self.deleteButton:SetPos(self.deleteButton.x + buttonAddX, self.deleteButton.y);
	
	for k, v in pairs(self.buttonPanels) do
		v:SetPos(v.x + buttonAddX, v.y);
	end;
end;

-- A function to set whether the panel is active.
function PANEL:SetActive(isActive)
	if (isActive) then
		self.nameLabel:OverrideTextColor(Clockwork.option:GetColor("information"));
	else
		self.nameLabel:OverrideTextColor(false);
	end;
end;

-- Called each frame.
function PANEL:Think()
	local markupObject = Clockwork.theme:GetMarkupObject();
	local weaponModel = Clockwork.plugin:Call("GetCharacterPanelWeaponModel", self, self.customData.charTable);
	local toolTip = Clockwork.plugin:Call("GetCharacterPanelToolTip", self, self.customData.charTable);
	
	if (tooltip and toolTip != "") then
		details = markupObject:Title(self.customData.name);
		details = markupObject:Add(toolTip);
	end;
	
	markupObject:Title(L("CharTooltipDetailsTitle"));
	markupObject:Add(self.customData.details or L("CharNoDetailsToDisplay"));
	
	if (weaponModel) then
		self.characterModel:SetWeaponModel(weaponModel);
	else
		self.characterModel:SetWeaponModel(false);
	end;
	
	self.characterModel:SetDetails(markupObject:GetText());
end;
	
vgui.Register("cwCharacterPanel", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetPaintBackground(false);
	self:SetAmbientLight(Color(255, 255, 255, 255));
	
	Clockwork.kernel:CreateMarkupToolTip(self);
end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");

	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to set the alpha of the panel.
function PANEL:SetAlpha(alpha)
	local color = self:GetColor();
	
	self:SetColor(Color(color.r, color.g, color.b, alpha));
end;

-- A function to get the alpha of the panel.
function PANEL:GetAlpha(alpha)
	local color = self:GetColor();
	
	return color.a;
end;

-- Called each frame.
function PANEL:Think()
	local entity = self.Entity;
	
	if (self.animation) then
		self.animation:Run();
	end;
	
	if (self.forceX) then
		self.x = self.forceX;
	end;
	
	--entity:ClearPoseParameters();
	--self:InvalidateLayout(true);
end;

-- A function to set the model details.
function PANEL:SetDetails(details)
	self:SetMarkupToolTip(details);
end;

-- A function to set the model weapon.
function PANEL:SetWeaponModel(weaponModel)
	if (!weaponModel and IsValid(self.weaponEntity)) then
		self.weaponEntity:Remove();
		return;
	end;
	
	if (!weaponModel and !IsValid(self.weaponEntity)
	or IsValid(self.weaponEntity) and self.weaponEntity:GetModel() == weaponModel) then
		return;
	end;
	
	if (IsValid(self.weaponEntity)) then
		self.weaponEntity:Remove();
	end;
	
	self.weaponEntity = ClientsideModel(weaponModel, RENDER_GROUP_OPAQUE_ENTITY);
	self.weaponEntity:SetParent(self.Entity);
	self.weaponEntity:AddEffects(EF_BONEMERGE);
end;

PANEL.OnMousePressed = extern_CharModelOnMousePressed;
PANEL.LayoutEntity = extern_CharModelLayoutEntity;
PANEL.Init = extern_CharModelInit;

vgui.Register("cwCharacterModel", PANEL, "DModelPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = Clockwork.option:GetColor("white");
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local font = Clockwork.fonts:GetSize(Clockwork.option:GetFont("info_text_font"), 16);
	
	self:SetSize(self:GetWide(), 32);
	self.totalPoints = 0;
	self.maximumPoints = 0;
	self.attributeTable = nil;
	self.attributePanels = {};
	self:SetPaintBackground(false);
	
	Clockwork.kernel:CreateMarkupToolTip(self);
	
	self.addButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
	self.addButton:SetMaterial("clockwork/increase.png");
	self.addButton:SetSize(32, 32);
	
	-- Called when the button is clicked.
	function self.addButton.DoClick(imageButton)
		self:AddPoint();
	end;
	
	self.removeButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
	self.removeButton:SetMaterial("clockwork/decrease.png");
	self.removeButton:SetSize(32, 32);
	
	-- Called when the button is clicked.
	function self.removeButton.DoClick(imageButton)
		self:RemovePoint();
	end;
	
	self.pointsUsed = vgui.Create("DPanel", self);
	
	Clockwork.kernel:CreateMarkupToolTip(self.pointsUsed);
	
	self.pointsLabel = vgui.Create("DLabel", self);
	self.pointsLabel:SetText("");
	self.pointsLabel:SetFont(font);
	self.pointsLabel:SetTextColor(colorWhite);
	self.pointsLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	Clockwork.kernel:CreateMarkupToolTip(self.pointsLabel);
	
	-- Called when the panel should be painted.
	function self.pointsUsed.Paint(pointsUsed)
		local color = Color(150, 150, 150, 255);
		local width = math.Clamp((pointsUsed:GetWide() / self.attributeTable.maximum) * self.totalPoints, 0, pointsUsed:GetWide());
		
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, pointsUsed:GetWide(), pointsUsed:GetTall(), color);
		
		if (self.totalPoints > 0 and self.totalPoints < self.attributeTable.maximum) then
			Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, width, pointsUsed:GetTall(), colorTargetID);
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.removeButton.x = 0;
	
	if (self.spawnIcon) then
		self.removeButton.x = self.spawnIcon.x + self.spawnIcon:GetWide() + 8;
	end;
	
	self.pointsUsed:SetPos(self.removeButton.x + self.removeButton:GetWide() + 8, 0);
	self.pointsUsed:SetSize(self:GetWide() - self.pointsUsed.x - self.addButton:GetWide() - 8, 32);
	self.pointsLabel:SetText(L(self.attributeTable.name));
	self.pointsLabel:SetPos(self.pointsUsed.x + ((self.pointsUsed:GetWide() / 2) - (self.pointsLabel:GetWide() / 2)), self:GetTall() / 2 - self.pointsLabel:GetTall() / 2);
	self.pointsLabel:SizeToContents();
	
	self.addButton:SetPos(
		self.pointsUsed.x + self.pointsUsed:GetWide() + 8,
		self.pointsUsed.y + (self.pointsUsed:GetTall() / 2) - (self.addButton:GetTall() / 2)
	);
	
	self.removeButton.y = self.addButton.y;
	
	local markupObject = Clockwork.theme:GetMarkupObject();
	local attributeName = L(self.attributeTable.name);
	local attributeMax = self.totalPoints.."/"..self.attributeTable.maximum;
	
	markupObject:Title(attributeName.." ("..attributeMax..")");
	markupObject:Add(L(self.attributeTable.description));
	
	self:SetMarkupToolTip(markupObject:GetText());
	
	self.pointsUsed:SetMarkupToolTip(markupObject:GetText());
	self.pointsLabel:SetMarkupToolTip(markupObject:GetText());
end;

-- A function to add a point.
function PANEL:AddPoint()
	local pointsUsed = self:GetPointsUsed();
	
	if (pointsUsed + 1 <= self.maximumPoints) then
		self.totalPoints = self.totalPoints + 1;
	end;
end;

-- A function to remove a point.
function PANEL:RemovePoint()
	self.totalPoints = math.max(self.totalPoints - 1, 0);
end;

-- A function to get the total points.
function PANEL:GetTotalPoints()	
	return self.totalPoints;
end;

-- A function to get the points used.
function PANEL:GetPointsUsed()
	local pointsUsed = 0;
	
	for k, v in pairs(self.attributePanels) do
		pointsUsed = pointsUsed + v:GetTotalPoints();
	end;
	
	return pointsUsed;
end;

-- A function to get the panel's attribute ID.
function PANEL:GetAttributeID()
	return self.attributeTable.uniqueID;
end;

-- A function to set the panel's attribute panels.
function PANEL:SetAttributePanels(attributePanels)
	self.attributePanels = attributePanels;
end;

-- A function to set the panel's attribute table.
function PANEL:SetAttributeTable(attributeTable)
	self.attributeTable = attributeTable;
	
	if (attributeTable.image) then
		self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
		self.spawnIcon:SetToolTip(L(attributeTable.description));
		self.spawnIcon:SetImage(attributeTable.image..".png");
		self.spawnIcon:SetSize(32, 32);
		self.spawnIcon:SetPos(0, 0);
	end;
end;

-- A function to set the panel's maximum points.
function PANEL:SetMaximumPoints(maximumPoints)
	self.maximumPoints = maximumPoints;
end;
	
vgui.Register("cwCharacterAttribute", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.info = Clockwork.character:GetCreationInfo();
	
	local maximumPoints = Clockwork.config:Get("default_attribute_points"):Get();
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local factionTable = Clockwork.faction:FindByID(self.info.faction);
	local attributes = {};
	
	if (factionTable.attributePointsScale) then
		maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
	end;
	
	if (factionTable.maximumAttributePoints) then
		maximumPoints = factionTable.maximumAttributePoints;
	end;
	
	self.attributesForm = vgui.Create("cwBasicForm");
	self.attributesForm:SetAutoSize(true);
	self.attributesForm:SetText(Clockwork.option:Translate("name_attributes"));
	self.attributesForm:SetPadding(8);
	self.attributesForm:SetSpacing(12);
	
	self.categoryList = vgui.Create("cwPanelList", self);
 	self.categoryList:SetPadding(8);
	self.categoryList:SetSpacing(8);
 	self.categoryList:SizeToContents();
 	self.categoryList:EnableVerticalScrollbar(true);
	
	for k, v in pairs(Clockwork.attribute:GetAll()) do
		attributes[#attributes + 1] = v;
	end;
	
	table.sort(attributes, function(a, b)
		return a.name < b.name;
	end);
	
	self.attributePanels = {};
	self.info.attributes = {};
	self.helpText = self.attributesForm:Help(L("YouCanSpendMorePoints", maximumPoints));
	
	for k, v in pairs(attributes) do
		if (v.isOnCharScreen) then
			local characterAttribute = vgui.Create("cwCharacterAttribute", self.attributesForm);
			
			characterAttribute:SetAttributeTable(v);
			characterAttribute:SetMaximumPoints(maximumPoints);
			characterAttribute:SetAttributePanels(self.attributePanels);
			
			self.attributesForm:AddItem(characterAttribute);
			
			self.attributePanels[#self.attributePanels + 1] = characterAttribute;
		end;
	end;
	
	self.maximumPoints = maximumPoints;
	self.categoryList:AddItem(self.attributesForm);
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	for k, v in pairs(self.attributePanels) do
		self.info.attributes[v:GetAttributeID()] = v:GetTotalPoints();
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");
	
	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.helpText) then
		local pointsLeft = self.maximumPoints;
		
		for k, v in pairs(self.attributePanels) do
			pointsLeft = pointsLeft - v:GetTotalPoints();
		end;
		
		self.helpText:SetText(L("YouCanSpendMorePoints", pointsLeft));
	end;
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.categoryList:StretchToParent(0, 0, 0, 0);
	self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6));
end;

vgui.Register("cwCharacterStageFour", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.info = Clockwork.character:GetCreationInfo();
	
	self.classesForm = vgui.Create("DForm");
	self.classesForm:SetName(L("MenuNameClasses"));
	self.classesForm:SetPadding(4);
	
	self.categoryList = vgui.Create("cwPanelList", self);
 	self.categoryList:SetPadding(8);
	self.categoryList:SetSpacing(8);
 	self.categoryList:SizeToContents();
	
	for k, v in pairs(Clockwork.class:GetAll()) do
		if (v.isOnCharScreen and (v.factions and table.HasValue(v.factions, self.info.faction))) then
			self.classTable = v;
			self.overrideData = {
				information = L("SelectToMakeDefaultClass"),
				Callback = function()
					self.info.class = v.index;
				end
			};
			self.classForm:AddItem(vgui.Create("cwClassesItem", self));
		end;
	end;
	
	self.categoryList:AddItem(self.classForm);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");
	
	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	if (!self.info.class or !Clockwork.class:FindByID(self.info.class)) then
		Clockwork.character:SetFault(L("FaultNeedClass"));
		return false;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.categoryList:StretchToParent(0, 0, 0, 0);
	self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6));
end;

vgui.Register("cwCharacterStageThree", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local panel = Clockwork.character:GetPanel();
	
	self.categoryList = vgui.Create("cwPanelList", self);
 	self.categoryList:SetPadding(8);
	self.categoryList:SetSpacing(8);
 	self.categoryList:SizeToContents();
	
	self.overrideModel = nil;
	self.hasSelectedModel = nil;
	self.hasPhysDesc = (Clockwork.command:FindByID("CharPhysDesc") != nil);
	self.info = Clockwork.character:GetCreationInfo();
	
	if (!Clockwork.faction.stored[self.info.faction].GetModel) then
		self.hasSelectedModel = true;
	end;
	
	local genderModels = Clockwork.faction.stored[self.info.faction].models[string.lower(self.info.gender)];
	
	if (genderModels and #genderModels == 1) then
		self.hasSelectedModel = false;
		self.overrideModel = genderModels[1];
		
		if (!panel:FadeInModelPanel(self.overrideModel)) then
			panel:SetModelPanelModel(self.overrideModel);
		end;
	end;
	
	if (!Clockwork.faction.stored[self.info.faction].GetName) then
		self.nameForm = vgui.Create("cwBasicForm", self);
		self.nameForm:SetAutoSize(true);
		self.nameForm:SetPadding(8);
		self.nameForm:SetSpacing(8);
		self.nameForm:SetText(L("Name"));
		
		if (Clockwork.faction.stored[self.info.faction].useFullName) then
			self.fullNameTextEntry = self.nameForm:TextEntry(L("CharacterMenuFullName"));
			self.fullNameTextEntry:SetAllowNonAsciiCharacters(true);
		else
			self.forenameTextEntry = self.nameForm:TextEntry(L("CharacterMenuForename"));
			self.forenameTextEntry:SetAllowNonAsciiCharacters(true);
			
			self.surnameTextEntry = self.nameForm:TextEntry(L("CharacterMenuSurname"));
			self.surnameTextEntry:SetAllowNonAsciiCharacters(true);
		end;
	end;
	
	if (self.hasSelectedModel or self.hasPhysDesc) then
		if (self.hasPhysDesc) then
			self.physDescForm = vgui.Create("cwBasicForm");
			self.physDescForm:SetAutoSize(true);
			self.physDescForm:SetPadding(8);
			self.physDescForm:SetSpacing(8);
			self.physDescForm:SetText(L("CharacterMenuPhysDesc"));
			self.physDescForm:Help(L("CharacterMenuPhysDescHelp"));
			
			self.physDescTextEntry = self.physDescForm:TextEntry();
			self.physDescTextEntry:SetAllowNonAsciiCharacters(true);
		end;
		
		if (self.hasSelectedModel) then
			self.appearanceForm = vgui.Create("cwBasicForm");
			self.appearanceForm:SetAutoSize(true);
			self.appearanceForm:SetPadding(8);
			self.appearanceForm:SetSpacing(8);
			self.appearanceForm:SetText(L("CharacterMenuAppearance"));
			self.appearanceForm:Help(L("CharacterMenuModelHelp"));
		
			self.modelItemsList = vgui.Create("DPanelList", self);
			self.modelItemsList:SetPadding(4);
			self.modelItemsList:SetSpacing(16);
			self.modelItemsList:SetAutoSize(true);
			self.modelItemsList:EnableHorizontal(true);
			self.modelItemsList:EnableVerticalScrollbar(true);
			
			self.appearanceForm:AddItem(self.modelItemsList);
		end;
	end;
	
	if (self.nameForm) then
		self.categoryList:AddItem(self.nameForm);
	end;
	
	if (self.physDescForm) then
		self.categoryList:AddItem(self.physDescForm);
	end;
	
	if (self.appearanceForm) then
		self.categoryList:AddItem(self.appearanceForm);
	end;
	
	local informationColor = Clockwork.option:GetColor("information");
	local lowerGender = string.lower(self.info.gender);
	local spawnIcon = nil;
	
	for k, v in pairs(Clockwork.faction.stored) do
		if (v.name == self.info.faction) then
			if (self.modelItemsList and v.models[lowerGender]) then
				for k2, v2 in pairs(v.models[lowerGender]) do
					spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
					spawnIcon:SetModel(v2);
					
					-- Called when the spawn icon is clicked.
					function spawnIcon.DoClick(spawnIcon)
						if (self.selectedSpawnIcon) then
							self.selectedSpawnIcon:SetColor(nil);
						end;
						
						spawnIcon:SetColor(informationColor);
						
						if (!panel:FadeInModelPanel(v2)) then
							panel:SetModelPanelModel(v2);
						end;
						
						self.selectedSpawnIcon = spawnIcon;
						self.selectedModel = v2;
					end;
					
					self.modelItemsList:AddItem(spawnIcon);
				end;
			end;
		end;
	end;
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	if (self.overrideModel) then
		self.info.model = self.overrideModel;
	else
		self.info.model = self.selectedModel;
	end;
	
	if (!Clockwork.faction.stored[self.info.faction].GetName) then
		if (IsValid(self.fullNameTextEntry)) then
			local limitCharName = Clockwork.config:Get("max_char_name"):Get();
			self.info.fullName = self.fullNameTextEntry:GetValue();
			
			if (self.info.fullName == "") then
				Clockwork.character:SetFault({"FaultNameInvalid"});
				return false;
			elseif (string.utf8len(self.info.fullName) > limitCharName) then
				Clockwork.character:SetFault({"FaultNameInvalid"});
				return false;
			end;
		else
			self.info.forename = self.forenameTextEntry:GetValue();
			self.info.surname = self.surnameTextEntry:GetValue();
			
			if (self.info.forename == "" or self.info.surname == "") then
				Clockwork.character:SetFault({"FaultNameInvalid"});
				return false;
			end;
			
			if (string.find(self.info.forename, "[%p%s%d]") or string.find(self.info.surname, "[%p%s%d]")) then
				Clockwork.character:SetFault({"FaultNameNoSpecialChars"});
				return false;
			end;
			
			if (!string.find(self.info.forename, "[aeiou]") or !string.find(self.info.surname, "[aeiou]")) then
				Clockwork.character:SetFault({"FaultNameHaveVowel"});
				return false;
			end;
			
			if (string.utf8len(self.info.forename) < 2 or string.utf8len(self.info.surname) < 2) then
				Clockwork.character:SetFault({"FaultNameMinLength"});
				return false;
			end;
			
			if (string.utf8len(self.info.forename) > 16 or string.utf8len(self.info.surname) > 16) then
				Clockwork.character:SetFault({"FaultNameTooLong"});
				return false;
			end;
		end;
	end;
	
	if (self.hasSelectedModel and !self.info.model) then
		Clockwork.character:SetFault({"FaultNeedModel"});
		return false;
	end;
	
	if (self.hasPhysDesc) then
		local minimumPhysDesc = Clockwork.config:Get("minimum_physdesc"):Get();
			self.info.physDesc = self.physDescTextEntry:GetValue();
		if (string.utf8len(self.info.physDesc) < minimumPhysDesc) then
			Clockwork.character:SetFault({"PhysDescMinimumLength", minimumPhysDesc});
			return false;
		end;
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if (self:GetAlpha() == 0 and CW_CONVAR_FADEPANEL:GetInt() == 1 and (!self.animation or !self.animation:Active())) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetVisible(true);
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished) then
				self.animation = nil;
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
		
		Clockwork.option:PlaySound("click_release");
	else
		self:SetVisible(true);
		self:SetAlpha(255);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.categoryList:StretchToParent(0, 0, 0, 0);
	
	self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.5));
end;

vgui.Register("cwCharacterStageTwo", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local factions = {};
	
	for k, v in pairs(Clockwork.faction.stored) do
		if (!v.whitelist or Clockwork.character:IsWhitelisted(v.name)) then
			if (!Clockwork.faction:HasReachedMaximum(k)) then
				factions[#factions + 1] = v.name;
			end;
		end;
	end;
	
	table.sort(factions, function(a, b)
		return a < b;
	end);
	
	self.forcedFaction = nil;
	self.info = Clockwork.character:GetCreationInfo();
	
	self.categoryList = vgui.Create("cwPanelList", self);
 	self.categoryList:SetPadding(8);
	self.categoryList:SetSpacing(8);
 	self.categoryList:SizeToContents();
	
	self.settingsForm = vgui.Create("cwBasicForm");
	self.settingsForm:SetAutoSize(true);
	self.settingsForm:SetText(L("CreateCharacterStage1"));
	self.settingsForm:SetPadding(8);
	self.settingsForm:SetSpacing(8);
	
	if (#factions > 1) then
		self.settingsForm:Help(L("CharacterMenuFactionHelp"));
		self.factionMultiChoice = self.settingsForm:ComboBox(L("CharacterMenuFaction"));
		
		-- Called when an option is selected.
		self.factionMultiChoice.OnSelect = function(multiChoice, index, value, data)
			for k, v in pairs(Clockwork.faction.stored) do
				if (v.name == value) then
					if (IsValid(self.genderMultiChoice)) then
						self.genderMultiChoice:Clear();
					else
						self.genderMultiChoice = self.settingsForm:ComboBox(L("Gender"));
						self.settingsForm:Rebuild();
					end;

					if (v.singleGender) then
						local index = self.genderMultiChoice:AddChoice(L(v.singleGender));
						
						self.genderMultiChoice:ChooseOptionID(index);
					else
						self.genderMultiChoice:AddChoice(L(GENDER_FEMALE));
						self.genderMultiChoice:AddChoice(L(GENDER_MALE));
					end;
					
					Clockwork.CurrentFactionSelected = {self, value};
					
					break;
				end;
			end;
		end;
	elseif (#factions == 1) then
		for k, v in pairs(Clockwork.faction.stored) do
			if (v.name == factions[1]) then
				self.genderMultiChoice = self.settingsForm:ComboBox(L("Gender"));

				if (v.singleGender) then
					local index = self.genderMultiChoice:AddChoice(L(v.singleGender));
					
					self.genderMultiChoice:ChooseOptionID(index);
				else
					self.genderMultiChoice:AddChoice(L(GENDER_FEMALE));
					self.genderMultiChoice:AddChoice(L(GENDER_MALE));
				end;
				
				Clockwork.CurrentFactionSelected = {self, v.name};
				self.forcedFaction = v.name;
				
				break;
			end;
		end;
	end;
	
	if (self.factionMultiChoice) then
		for k, v in pairs(factions) do
			self.factionMultiChoice:AddChoice(v);
		end;
	end;
	
	self.customChoices = {};
	
	Clockwork.plugin:Call("GetPersuasionChoices", self.customChoices);

	if (self.customChoices) then
		self.customPanels = {};
		
		for k2, v2 in pairs(self.customChoices) do
			if (!v2.type or string.lower(v2.type) == "combobox") then
				table.insert(self.customPanels, {v2, self.settingsForm:ComboBox(v2.name)});

				for k3, v3 in ipairs(v2.choices) do
					self.customPanels[#self.customPanels][2]:AddChoice(v3)
				end;
			elseif (string.lower(v2.type) == "textentry") then
				table.insert(self.customPanels, {v2, self.settingsForm:TextEntry(v2.name)});
			end;
		end;
	end;
	
	self.categoryList:AddItem(self.settingsForm);
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	self.info.plugin = {};

	if (self.customPanels) then
		for k, v in pairs(self.customPanels) do
			local value = v[2]:GetValue();

			if (value == "") then
				Clockwork.character:SetFault({"FaultDidNotFillPanel", v[1].name});
				return false;
			elseif (v[1].isNumber) then
				local max = v[1].max;
				local min = v[1].min;

				if (!tonumber(value)) then
					Clockwork.character:SetFault({"FaultDidNotFillPanelWithNumber", v[1].name});
					return false;
				end;

				if (max and max < tonumber(value)) then
					Clockwork.character:SetFault({"FaultTextEntryHigherThan", tostring(max), v[1].name});
					return false;
				end;

				if (min and min > tonumber(value)) then
					Clockwork.character:SetFault({"FaultTextEntryLowerThan", tostring(min), v[1].name});
					return false;
				end;
			end;

			self.info.plugin[v[1].name] = value;
		end;
	end;

	if (IsValid(self.genderMultiChoice)) then
		local faction = self.forcedFaction;
		local gender = self.genderMultiChoice:GetValue();
		
		if (gender == L(GENDER_MALE)) then
			gender = GENDER_MALE;
		else
			gender = GENDER_FEMALE;
		end;
		
		if (!faction and self.factionMultiChoice) then
			faction = self.factionMultiChoice:GetValue();
		end;
		
		for k, v in pairs(Clockwork.faction.stored) do
			if (v.name == faction) then
				if (Clockwork.faction:IsGenderValid(faction, gender)) then
					self.info.faction = faction;
					self.info.gender = gender;
					
					return true;
				end;
			end;
		end;
	end;
	
	Clockwork.character:SetFault({"FaultDidNotChooseFaction"});
	return false;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");
	
	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.categoryList:StretchToParent(0, 0, 0, 0);
	self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6));
end;

vgui.Register("cwCharacterStageOne", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local panel = Clockwork.character:GetPanel();
	
	self.categoryList = vgui.Create("cwPanelList", self);
 	self.categoryList:SetPadding(8);
	self.categoryList:SetSpacing(8);
 	self.categoryList:SizeToContents();
	
	self.maximumPoints = Clockwork.config:Get("max_trait_points"):Get();
	self.selectedTraits = {};
	
	self.info = Clockwork.character:GetCreationInfo();
	self.info.traits = {};
	
	self.traitForm = vgui.Create("cwBasicForm");
	self.traitForm:SetAutoSize(true);
	self.traitForm:SetPadding(8);
	self.traitForm:SetSpacing(8);
	self.traitForm:SetText(L("CharacterMenuTraits"));
	self.helpText = self.traitForm:Help(L("YouCanSpendMorePoints", maximumPoints));
	
	self.traitItemsList = vgui.Create("DPanelList", self);
	self.traitItemsList:SetPadding(4);
	self.traitItemsList:SetSpacing(16);
	self.traitItemsList:SetAutoSize(true);
	self.traitItemsList:EnableHorizontal(true);
	self.traitItemsList:EnableVerticalScrollbar(true);
	
	self.traitForm:AddItem(self.traitItemsList);
	
	self.categoryList:AddItem(self.traitForm);
	
	local informationColor = Clockwork.option:GetColor("information");
	
	for k, v in pairs(Clockwork.trait:GetAll()) do
		local traitTable = v;
		local markupObject = Clockwork.theme:GetMarkupObject();
		
		markupObject:Title(L(v.name));
		markupObject:Add(L(v.description));
		
		if (v.points < 0) then
			markupObject:Add(L("TraitPointsGain", v.points), Clockwork.option:GetColor("trait_gain_color"));
		else
			markupObject:Add(L("TraitPointsLoss", v.points), Clockwork.option:GetColor("trait_loss_color"));
		end;
		
		local traitButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwImageButtonBorder", self));
		
		traitButton:SetHoverColor(informationColor);
		traitButton:SetToolTip(markupObject:GetText());
		traitButton:SetImage(v.image..".png");
		traitButton:SetSize(64, 64);
		
		-- Called when the spawn icon is clicked.
		function traitButton.DoClick(spawnIcon)
			if (table.HasValue(self.selectedTraits, traitTable)) then
				table.RemoveByValue(self.selectedTraits, traitTable);
				table.RemoveByValue(self.info.traits, traitTable.uniqueID);
				
				traitButton:SetColor(nil);
				return;
			end;
			
			if (traitTable.points < self:GetPointsLeft()) then
				traitButton:SetColor(informationColor);
				
				table.insert(self.selectedTraits, traitTable);
				table.insert(self.info.traits, traitTable.uniqueID);
			end;
		end;
		
		self.traitItemsList:AddItem(traitButton);
	end;
end;

-- Called when the next button is pressed.
function PANEL:OnNext()
	
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h) end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	Clockwork.option:PlaySound("rollover");
	
	self:SetVisible(false);
	self:SetAlpha(0);
	
	if (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	Clockwork.option:PlaySound("click_release");
	
	self:SetVisible(true);
	self:SetAlpha(255);
	
	if (Callback) then
		Callback();
	end;
end;

function PANEL:GetPointsLeft()
	local pointsLeft = self.maximumPoints;
	
	for k, v in pairs(self.selectedTraits) do
		pointsLeft = pointsLeft - v.points;
	end;
	
	return pointsLeft;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.helpText) then
		self.helpText:SetText(L("YouCanSpendMorePoints", self:GetPointsLeft()));
	end;
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.categoryList:StretchToParent(0, 0, 0, 0);
	
	self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6));
end;

vgui.Register("cwCharacterStageFive", PANEL, "EditablePanel");

Clockwork.datastream:Hook("CharacterRemove", function(data)
	local characters = Clockwork.character:GetAll();
	local characterID = data;
	
	if (table.Count(characters) == 0) then
		return;
	end;
	
		
	if (!characters[characterID]) then
		return;
	end;
	
	characters[characterID] = nil;
	
	if (!Clockwork.character:IsPanelLoading()) then
		Clockwork.character:RefreshPanelList();
	end;
	
	if (Clockwork.character:GetPanelList()) then
		if (table.Count(characters) == 0) then
			Clockwork.character:GetPanel():ReturnToMainMenu();
		end;
	end;
end);

Clockwork.datastream:Hook("SetWhitelisted", function(data)
	local whitelisted = Clockwork.character:GetWhitelisted();
	
	for k, v in pairs(whitelisted) do
		if (v == data[1]) then
			if (!data[2]) then
				whitelisted[k] = nil;
				
				return;
			end;
		end;
	end;
	
	if (data[2]) then
		whitelisted[#whitelisted + 1] = data[1];
	end;
end);

Clockwork.datastream:Hook("CharacterAdd", function(data)
	Clockwork.character:Add(data.characterID, data);
	
	if (!Clockwork.character:IsPanelLoading()) then
		Clockwork.character:RefreshPanelList();
	end;
end);

Clockwork.datastream:Hook("CharacterMenu", function(data)
	local menuState = data;

	if (menuState == CHARACTER_MENU_LOADED) then
		if (Clockwork.character:GetPanel()) then
			Clockwork.character:SetPanelLoading(false);
			Clockwork.character:RefreshPanelList();
			
			local numCharacters = table.Count(Clockwork.character:GetAll());
			
			if (numCharacters == 0) then
				Clockwork.character:ResetCreationInfo();
				Clockwork.character:OpenNextCreationPanel();
			end;
		end;
	elseif (menuState == CHARACTER_MENU_CLOSE) then
		Clockwork.character:SetPanelOpen(false);
	elseif (menuState == CHARACTER_MENU_OPEN) then
		Clockwork.character:SetPanelOpen(true);
	end;
end);

Clockwork.datastream:Hook("CharacterOpen", function(data)
	Clockwork.character:SetPanelOpen(true);
	
	if (data) then
		Clockwork.character.isMenuReset = true;
	end;
end);

Clockwork.datastream:Hook("CharacterFinish", function(data)
	if (data.wasSuccess) then
		Clockwork.character:SetPanelMainMenu();
		Clockwork.character:SetPanelOpen(false, true);
		Clockwork.character:SetFault(nil);
	else
		Clockwork.character:SetFault(data.fault);
	end;
end);

Clockwork.character:RegisterCreationPanel("CreateCharacterStage1", "cwCharacterStageOne");
Clockwork.character:RegisterCreationPanel("CreateCharacterStage2", "cwCharacterStageTwo");

Clockwork.character:RegisterCreationPanel("CreateCharacterStage3", "cwCharacterStageThree", nil,
	function(info)
		local classTable = Clockwork.class:GetAll();
		
		if (table.Count(classTable) > 0) then
			for k, v in pairs(classTable) do
				if (v.isOnCharScreen and (v.factions
				and table.HasValue(v.factions, info.faction))) then
					return true;
				end;
			end;
		end;
		
		return false;
	end
);

Clockwork.character:RegisterCreationPanel("CreateCharacterStage4", "cwCharacterStageFour", nil, function(info)
		local attributeTable = Clockwork.attribute:GetAll();
		
		if (table.Count(attributeTable) > 0) then
			for k, v in pairs(attributeTable) do
				if (v.isOnCharScreen && (!v.factions or table.HasValue(v.factions, info.faction))) then
					return true;
				end;
			end;
		end;
		
		return false;
	end
);

Clockwork.character:RegisterCreationPanel("CreateCharacterStage5", "cwCharacterStageFive", nil, function(info)
		local maximumPoints = Clockwork.config:Get("max_trait_points"):Get();
		
		if (maximumPoints == 0) then
			return false;
		end;
	
		local traitTable = Clockwork.trait:GetAll();
		
		if (table.Count(traitTable) > 0) then
			for k, v in pairs(traitTable) do
				if (!v.factions or table.HasValue(v.factions, info.faction)) then
					return true;
				end;
			end;
		end;
		
		return false;
	end
);
