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
	
	Clockwork.scoreboard = self;
	Clockwork.scoreboard:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	local availableClasses = {};
	local classes = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			local class = Clockwork.plugin:Call("GetPlayerScoreboardClass", v);
			
			if (class) then
				if (!availableClasses[class]) then
					availableClasses[class] = {};
				end;
				
				if (Clockwork.plugin:Call("PlayerShouldShowOnScoreboard", v)) then
					availableClasses[class][#availableClasses[class] + 1] = v;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return Clockwork.plugin:Call("ScoreboardSortClassPlayers", k, a, b);
		end);
		
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	if (table.Count(classes) > 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText(L("ScoreboardMenuHelp"));
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(classes) do
			local classData = Clockwork.class:FindByID(v.name);
			local classColor = nil;
			
			if (classData) then
				--classColor = classData.color;
			end;
			
			local characterForm = vgui.Create("cwBasicForm", self);
			characterForm:SetPadding(8);
			characterForm:SetSpacing(8);
			characterForm:SetAutoSize(true);
			characterForm:SetText(v.name, Clockwork.option:GetFont("scoreboard_class"), classColor);
			
			local panelList = vgui.Create("DPanelList", self);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			for k2, v2 in pairs(v.players) do
				self.playerData = {
					avatarImage = true,
					steamName = v2:SteamName(),
					faction = v2:GetFaction(),
					player = v2,
					class = cwTeam.GetName(v2:Team()),
					model = v2:GetModel(),
					skin = v2:GetSkin(),
					name = v2:Name()
				};
				
				panelList:AddItem(vgui.Create("cwScoreboardItem", self));
			end;
			
			characterForm:AddItem(panelList);
			
			self.panelList:AddItem(characterForm);
			
			panelList:InvalidateLayout(true);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText(L("ScoreboardMenuNoPlayers"));
			label:SetInfoColor("orange");
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

vgui.Register("cwScoreboard", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	SCOREBOARD_PANEL = true;
	
	self:SetSize(self:GetParent():GetWide(), 52);
	
--	local nameFont = Clockwork.fonts:GetSize(Clockwork.option:GetFont("scoreboard_name"), 20);
--	local descFont = Clockwork.fonts:GetSize(Clockwork.option:GetFont("scoreboard_desc"), 16);
	local nameFont = Clockwork.option:GetFont("scoreboard_name");
	local descFont = Clockwork.option:GetFont("scoreboard_desc");
	local playerData = self:GetParent().playerData;
	local info = {
		doesRecognise = Clockwork.player:DoesRecognise(playerData.player),
		avatarImage = playerData.avatarImage,
		steamName = playerData.steamName,
		faction = playerData.faction,
		player = playerData.player,
		class = playerData.class,
		model = playerData.model,
		skin = playerData.skin,
		name = playerData.name
	};
	
	info.text = Clockwork.plugin:Call("GetPlayerScoreboardText", info.player);
	
	Clockwork.plugin:Call("ScoreboardAdjustPlayerInfo", info);
	
	self.toolTip = info.toolTip;
	self.player = info.player;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(info.name);
	self.nameLabel:SetFont(nameFont);
	self.nameLabel:SetTextColor(Clockwork.option:GetColor("scoreboard_name"));
	self.nameLabel:SizeToContents();

	local class = Clockwork.class:FindByID(self.player:Team());

	if (class and class.color) then
		self.nameLabel:SetColor(class.color);
	end;
	
	self.factionLabel = vgui.Create("DLabel", self); 
	self.factionLabel:SetText(info.faction);
	self.factionLabel:SetFont(descFont);
	self.factionLabel:SetTextColor(Clockwork.option:GetColor("scoreboard_desc"));
	self.factionLabel:SizeToContents();
	
	if (type(info.text) == "string") then
		self.factionLabel:SetText(info.text);
		self.factionLabel:SizeToContents();
	end;
	
	if (info.doesRecognise) then
		self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self));
		self.spawnIcon:SetModel(info.model, info.skin);
		self.spawnIcon:SetSize(40, 40);
	else
		self.spawnIcon = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DImageButton", self));
		self.spawnIcon:SetImage("clockwork/unknown2.png");
		self.spawnIcon:SetSize(40, 40);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local options = {};
		
		Clockwork.plugin:Call("GetPlayerScoreboardOptions", info.player, options);
		Clockwork.kernel:AddMenuFromData(nil, options);
	end;
	
	self.avatarImage = vgui.Create("AvatarImage", self);
	self.avatarImage:SetSize(40, 40);
	
	self.avatarButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("DButton", self.avatarImage));
	self.avatarButton:Dock(FILL);
	self.avatarButton:SetText("");
	self.avatarButton:SetDrawBorder(false);
	self.avatarButton:SetDrawBackground(false);

	if (info.avatarImage) then
		self.avatarButton:SetToolTip(L("PlayerNameAndSteamID", info.steamName, info.player:SteamID()));
		self.avatarButton.DoClick = function(button)
			if (IsValid(info.player)) then
				info.player:ShowProfile();
			end;
		end;

		self.avatarImage:SetPlayer(info.player);
	end;
	
	SCOREBOARD_PANEL = nil;
end;

function PANEL:Paint(width, height)
	local slice = SCOREBOARD_ITEM_SLICED;

	if (not slice) then
		slice = INFOTEXT_SLICED;
	end;

	slice:Draw(0, 0, width, height, nil, Clockwork.option:GetColor("scoreboard_item_background"));
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	if (IsValid(self.player)) then
		if (self.toolTip) then
			self.spawnIcon:SetToolTip(self.toolTip);
		else
			self.spawnIcon:SetToolTip(L("ScoreboardMenuPing", self.player:Ping()));
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.factionLabel:SizeToContents();
	
	self.spawnIcon:SetPos(6, 6);
	self.spawnIcon:SetSize(40, 40);
	self.avatarImage:SetPos(46, 6);
	self.avatarImage:SetSize(40, 40);
	
	self.nameLabel:SetPos(94, 2);
	self.factionLabel:SetPos(94, self.nameLabel.y + self.nameLabel:GetTall() - 2);
end;

vgui.Register("cwScoreboardItem", PANEL, "DPanel");