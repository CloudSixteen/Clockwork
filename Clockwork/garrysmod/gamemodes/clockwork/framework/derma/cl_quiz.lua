--[[
	� 2012 CloudSixteen.com do not share, re-distribute or modify
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
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	
	self.disconnectButton = vgui.Create("cwLabelButton", self);
	self.disconnectButton:SetFont(smallTextFont);
	self.disconnectButton:SetText("DISCONNECT");
	self.disconnectButton:FadeIn(0.5);
	self.disconnectButton:SetCallback(function(panel)
		RunConsoleCommand("disconnect");
	end);
	self.disconnectButton:SizeToContents();
	self.disconnectButton:SetMouseInputEnabled(true);
	self.disconnectButton:SetPos((scrW * 0.2) - (self.disconnectButton:GetWide() / 2), scrH * 0.9);
		
	self.continueButton = vgui.Create("cwLabelButton", self);
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SetText("CONTINUE");
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
	
	DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	
	return true;
end;

-- A function to populate the panel.
function PANEL:Populate()
	local smallTextFont = Clockwork.option:GetFont("menu_text_small");
	local quizQuestions = Clockwork.quiz:GetQuestions();
	local questions = {};
	local scrH = ScrH();
	local scrW = ScrW();
	
	self.questionsForm = vgui.Create("DForm");
	self.questionsForm:SetName(Clockwork.quiz:GetName());
	self.questionsForm:SetPadding(4);
	
	self.panelList:Clear(true);
	
	local label = vgui.Create("cwInfoText", self);
		label:SetText("If any answers are incorrect, you may be kicked from the server.");
		label:SetInfoColor("orange");
	self.panelList:AddItem(label);

	self.panelList:AddItem(self.questionsForm);
	
	for k, v in pairs(quizQuestions) do
		questions[k] = {k, v};
	end;
	
	table.sort(questions, function(a, b)
		return a[2].question < b[2].question;
	end);
	
	for k, v in pairs(questions) do
		local panel = vgui.Create("DComboBox", self.questionsForm);
		local question = vgui.Create("DLabel", self.questionsForm);
		local key = v[1];
			
		self.questionsForm:AddItem(question);
			
		question:SetText(v[2].question);
		question:SetDark(true);
		question:SizeToContents();
			
		-- Called when an option is selected.
		function panel:OnSelect(index, value, data)
			Clockwork.datastream:Start("QuizAnswer", {key, index});
		end;
			
		for k2, v2 in pairs(v[2].possibleAnswers) do
			panel:AddChoice(v2);
		end;
		
		self.questionsForm:AddItem(panel);
	end;

	local langText = vgui.Create("DLabel", self.questionsForm);
	local panel = vgui.Create("DComboBox", self.questionsForm);

	question:SetText(L("Language")..":");
	question:SetDark(true);
	question:SizeToContents();

	function panel:OnSelect(index, value, data)
		Clockwork.Client:SetData("Language", index);
	end;

	for k, v in pairs(Clockwork.lang:GetAll()) do
		panel;AddChoice(k);
	end;

	self.questionsForm:AddItem(panel);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	local scrW = ScrW();
	local scrH = ScrH();
	
	self.panelList:SetSize(scrW * 0.5, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
	self.panelList:SetPos((scrW / 2) - (self.panelList:GetWide() / 2), (scrH / 2) - (self.panelList:GetTall() / 2));
	self.scrollList:SetPos((scrW / 2) - (self.panelList:GetWide() / 2), (scrH / 2) - (self.panelList:GetTall() / 2));
	self.scrollList:SetSize(scrW * 0.5, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
	
	derma.SkinHook("Layout", "Panel", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwQuiz", PANEL, "DPanel");