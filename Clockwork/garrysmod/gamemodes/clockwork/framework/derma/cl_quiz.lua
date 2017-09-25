--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local RunConsoleCommand = RunConsoleCommand;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local scrH = ScrH();
	local scrW = ScrW();

	self.createTime = SysTime();
	
	self:SetPos(0, 0);
	self:SetSize(scrW, scrH);
	self:SetPaintBackground(false);
	self:SetMouseInputEnabled(true);
	self:SetKeyboardInputEnabled(true);
	
	self.scrollList = vgui.Create("DScrollPanel", self);
 	self.scrollList:SizeToContents();

	self.panelList = vgui.Create("cwPanelList", self.scrollList);
 	self.panelList:SetPadding(4);
 	self.panelList:SetSpacing(4);
 	self.panelList:SizeToContents();
	
	self.disconnectButton = vgui.Create("cwLabelButton", self);
	self.disconnectButton:SetFont(smallTextFont);
	self.disconnectButton:SetText(L("MenuDisconnect"));
	self.disconnectButton:FadeIn(0.5);
	self.disconnectButton:SetCallback(function(panel)
		RunConsoleCommand("disconnect");
	end);
	self.disconnectButton:SizeToContents();
	self.disconnectButton:SetMouseInputEnabled(true);
	self.disconnectButton:SetPos((scrW * 0.2) - (self.disconnectButton:GetWide() / 2), scrH * 0.9);
	
	self.continueButton = vgui.Create("cwLabelButton", self);
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SetText(L("MenuContinue"));
	self.continueButton:FadeIn(0.5);
	self.continueButton:SetCallback(function(panel)
		Clockwork.datastream:Start("QuizCompleted", true);
	end);
	self.continueButton:SizeToContents();
	self.continueButton:SetMouseInputEnabled(true);
	self.continueButton:SetPos((scrW * 0.8) - (self.continueButton:GetWide() / 2), scrH * 0.9);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	Clockwork.kernel:RegisterBackgroundBlur(self, self.createTime);
	Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
	
	return true;
end;

-- A function to populate the panel.
function PANEL:Populate()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local quizQuestions = Clockwork.quiz:GetQuestions();
	local quizEnabled = Clockwork.quiz:GetEnabled();
	local langTable = Clockwork.lang:GetAll();
	local scrH = ScrH();
	local scrW = ScrW();
	
	self.panelList:Clear(true);
	self.questions = {};
	self.language = CW_CONVAR_LANG:GetString();
	
	self.languageForm = vgui.Create("cwBasicForm");
	self.languageForm:SetAutoSize(true);
	self.languageForm:SetText(L("Language"));
	self.languageForm:SetPadding(8);
	self.languageForm:SetSpacing(4);

	local gmodLang = string.lower(GetConVarString("gmod_language"));

	local panel = vgui.Create("DComboBox", self.languageForm);
	
	for k, v in pairs(langTable) do
		local native = Clockwork.lang:GetNative(k);

		if (native) then
			panel:AddChoice(k.. " ("..native..")", k);
		else
			panel:AddChoice(k, k);
		end;
	end;
	
	if (!self.language or tostring(self.language) == "nil") then
		self.language = Clockwork.lang.default;
	end;
	
	local gmodToCW = Clockwork.lang:GetFromCode(gmodLang);

	if (gmodToCW) then
		RunConsoleCommand("cwLang", gmodToCW);
		panel:SetValue(gmodToCW);
	else
		panel:SetValue(self.language);
	end;

	function panel:OnSelect(index, value, data)
		RunConsoleCommand("cwLang", data);
	end;
	
	self.languageForm:AddItem(panel);
	
	self.panelList:AddItem(self.languageForm);
	
	if (quizEnabled) then
		for k, v in pairs(quizQuestions) do
			self.questions[k] = {k, v};
		end;
		
		table.sort(self.questions, function(a, b)
			return a[2].question < b[2].question;
		end);
		
		self:AddQuestions();
	end;
end;

-- A function to add the quiz questions to the form.
function PANEL:AddQuestions()
	if (!self.questionsForm) then
		self.questionsForm = vgui.Create("cwBasicForm");
		self.questionsForm:SetAutoSize(true);
		self.questionsForm:SetText(L(Clockwork.quiz:GetName()));
		self.questionsForm:SetPadding(8);
		self.questionsForm:SetSpacing(4);
		
		self.panelList:AddItem(self.questionsForm);
	end;
	
	self.questionsForm:Clear(true);
	
	local label = vgui.Create("cwInfoText", self);
		label:SetText(L("MenuQuizHelp"));
		label:SetInfoColor("orange");
	self.questionsForm:AddItem(label);
	
	local colorWhite = Clockwork.option:GetColor("white");
	local fontName = Clockwork.fonts:GetSize(
		Clockwork.option:GetFont("menu_text_tiny"),
		size or 18
	);
	
	for k, v in pairs(self.questions) do
		local panel = vgui.Create("DComboBox", self.questionsForm);
		local question = vgui.Create("DLabel", self.questionsForm);
		local key = v[1];
		
		self.questionsForm:AddItem(question);
		
		question:SetFont(fontName);
		question:SetTextColor(colorWhite);
		question:SetText(L(v[2].question));
		question:SizeToContents();
		
		-- Called when an option is selected.
		function panel:OnSelect(index, value, data)
			Clockwork.datastream:Start("QuizAnswer", {key, index});
		end;
		
		for k2, v2 in pairs(v[2].possibleAnswers) do
			panel:AddChoice(L(v2));
		end;
		
		self.questionsForm:AddItem(panel);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	local scrW = ScrW();
	local scrH = ScrH();
	
	self.panelList:SetSize(scrW * 0.4, math.min(self.panelList.pnlCanvas:GetTall() + 4, ScrH() * 0.75));
	self.panelList:SetPos(0, 0)
	self.scrollList:SetSize(scrW * 0.4, ScrH() * 0.75);
	self.scrollList:SetPos((scrW / 2) - (self.panelList:GetWide() / 2), (scrH / 2) - (self.panelList:GetTall() / 2));
	
	derma.SkinHook("Layout", "Panel", self);
end;

-- Called each frame.
function PANEL:Think()
	local quizEnabled = Clockwork.quiz:GetEnabled();
	local language = CW_CONVAR_LANG:GetString();
	
	if (self.language != language) then
		self.language = language;
		
		if (quizEnabled) then
			self:AddQuestions();
		end;
		
		self.disconnectButton:SetText(L("MenuDisconnect"));
		self.disconnectButton:SizeToContents();

		self.continueButton:SetText(L("MenuContinue"));
		self.continueButton:SizeToContents();

		self.languageForm:SetText(L("Language"));
		self.questionsForm:SetText(L(Clockwork.quiz:GetName()));
	end;

	self:InvalidateLayout(true);
end;

vgui.Register("cwQuiz", PANEL, "DPanel");