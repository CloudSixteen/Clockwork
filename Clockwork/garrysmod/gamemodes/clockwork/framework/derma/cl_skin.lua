--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local SKIN = {
	DermaVersion = 1,
	PrintName = "Clockwork",
	Author = "kurozael"
}

SKIN.bgColorBright = Color(220, 220, 220, 255);
SKIN.bgColorSleep = Color(70, 70, 70, 255);
SKIN.bgColorDark = Color(50, 50, 50, 255);
SKIN.bgColor = Color(110, 110, 110, 255);

SKIN.frameBorder = Color(50, 50, 50, 255);
SKIN.frameTitle = Color(130, 130, 130, 255);

SKIN.fontCategoryHeader = "TabLarge";
SKIN.fontFormLabel = "TabLarge";
SKIN.fontButton = "Default";
SKIN.fontFrame = "Default";
SKIN.fontTab = "Default";

SKIN.controlColorHighlight = Color(150, 150, 150, 255);
SKIN.controlColorActive = Color(110, 150, 250, 255);
SKIN.controlColorBright = Color(255, 200, 100, 255);
SKIN.controlColorDark = Color(100, 100, 100, 255);
SKIN.controlColor = Color(120, 120, 120, 255);

SKIN.bgAltOne = Color(50, 50, 50, 255);
SKIN.bgAltTwo = Color(55, 55, 55, 255);

SKIN.listviewSelected = Color(100, 170, 220, 255);
SKIN.listviewHover = Color(70, 70, 70, 255);

SKIN.textHighlight = Color(255, 20, 20, 255);
SKIN.textBright = Color(255, 255, 255, 255);
SKIN.textNormal = Color(180, 180, 180, 255);
SKIN.textDark = Color(20, 20, 20, 255);

SKIN.texGradientDown = Material("gui/gradient_down");
SKIN.texGradientUp = Material("gui/gradient_up");

SKIN.comboBoxSelected = Color(100, 170, 220, 255);

SKIN.panelTransback = Color(255, 255, 255, 50);
SKIN.toolTip = Color(255, 245, 175, 255);

SKIN.colCollapsibleCategory = Color(255, 255, 255, 20);
SKIN.colCategoryTextInactive = Color(200, 200, 200, 255);
SKIN.colTabTextInactive = Color(255, 255, 255, 255);
SKIN.colPropertySheet = Color(170, 170, 170, 255);
SKIN.colCategoryText = Color(255, 255, 255, 255);
SKIN.colTabInactive = Color(140, 140, 140, 255);
SKIN.colTabShadow = Color(0, 0, 0, 170);
SKIN.colTabText = Color(255, 255, 255, 255);
SKIN.colTab = Color(170, 170, 170, 255);

SKIN.colTextEntryTextHighlight	= Color(20, 200, 250, 255);
SKIN.colTextEntryTextHighlight	= Color(20, 200, 250, 255);
SKIN.colTextEntryBorder = Color(20, 20, 20, 255);
SKIN.colTextEntryText = Color(20, 20, 20, 255);
SKIN.colNumberWangBG = Color(255, 240, 150, 255);
SKIN.colTextEntryBG = Color(240, 240, 240, 255);
SKIN.colMenuBorder = Color(0, 0, 0, 200);
SKIN.colMenuBG = Color(255, 255, 255, 200);

SKIN.colButtonBorderHighlight = Color(255, 255, 255, 50);
SKIN.colButtonTextDisabled = Color(255, 255, 255, 55);
SKIN.colButtonBorderShadow = Color(0, 0, 0, 100);
SKIN.colButtonBorder = Color(20, 20, 20, 255);
SKIN.colButtonText = Color(255, 255, 255, 255);

-- A function to draw number wang indicator text.
function SKIN:DrawNumberWangIndicatorText(panel, wang, x, y, number, alpha)
	local alpha = math.Clamp(alpha ^ 0.5, 0, 1) * 255;
	local color = self.textDark;
	local dec = (wang:GetDecimals() + 1) * 10;
	
	if (number / dec == math.ceil(number / dec)) then
		color = self.textHighlight;
	end;

	draw.SimpleText(number, "Default", x, y, Color(color.r, color.g, color.b, alpha));
end;

-- A function to draw a generic background.
function SKIN:DrawGenericBackground(x, y, w, h, color)
	Clockwork.kernel:DrawSimpleGradientBox(2, x, y, w, h, color);
end;

-- A function to draw a button border.
function SKIN:DrawButtonBorder(x, y, w, h, depressed)
	if (!depressed) then
		surface.SetDrawColor(self.colButtonBorderHighlight);
		surface.DrawRect(x + 1, y + 1, w - 2, 1);
		surface.DrawRect(x + 1, y + 1, 1, h - 2);
		surface.DrawRect(x + 2, y + 2, 1, 1);
		surface.SetDrawColor(self.colButtonBorderShadow);
		surface.DrawRect(w - 2, y + 2, 1, h - 2);
		surface.DrawRect(x + 2, h - 2, w - 2, 1);
	else
		local color = self.colButtonBorderShadow
		
		for i = 1, 5 do
			surface.SetDrawColor(color.r, color.g, color.b, (255 - i * (255 / 5)));
			surface.DrawOutlinedRect(i, i, w - i, h - i);
		end;
	end;

	surface.SetDrawColor(self.colButtonBorder);
	surface.DrawOutlinedRect(x, y, w, h);
end;

-- A function to draw a disabled button border.
function SKIN:DrawDisabledButtonBorder(x, y, w, h, depressed)
	surface.SetDrawColor(0, 0, 0, 150);
	surface.DrawOutlinedRect(x, y, w, h);
end;


-- Called when a frame is painted.
function SKIN:PaintFrame(panel)
	self:DrawGenericBackground(0, 0, panel:GetWide(), panel:GetTall(), self.frameBorder);
	self:DrawGenericBackground(1, 1, panel:GetWide() - 2, panel:GetTall() - 2, self.frameTitle);
	draw.RoundedBoxEx(4, 2, 21, panel:GetWide() - 4, panel:GetTall() - 23, self.bgColor, false, false, true, true);
end;

-- Called when a frame is layed out.
function SKIN:LayoutFrame(panel)
	panel.lblTitle:SetFont(self.fontFrame);
	panel.btnClose:SetPos(panel:GetWide() - 22, 4);
	panel.btnClose:SetSize(18, 18);
	panel.lblTitle:SetPos(8, 2);
	panel.lblTitle:SetSize(panel:GetWide() - 25, 20);
end;

-- Called when a button is painted.
function SKIN:PaintButton(panel)
	local w, h = panel:GetSize();

	if (panel.m_bBackground) then
		local color = self.controlColor;

		if (panel:GetDisabled()) then
			color = self.controlColorDark;
		elseif (panel.Depressed or panel:GetSelected()) then
			color = self.controlColorActive;
		elseif (panel.Hovered) then
			color = self.controlColorHighlight;
		end;

		self:DrawGenericBackground(0, 0, w, h, Color(0, 0, 0, 230));
		self:DrawGenericBackground(1, 1, w - 2, h - 2, Color(color.r + 30, color.g + 30, color.b + 30));
		self:DrawGenericBackground(2, 2, w - 4, h - 4, color);
		self:DrawGenericBackground(3, h * 0.5, w - 6, h - h * 0.5 - 2, Color(0, 0, 0, 40));
	end;
end;

-- Called when a button is painted over.
function SKIN:PaintOverButton(panel) end;

-- Called when a button is schemed.
function SKIN:SchemeButton(panel)
	panel:SetFont(self.fontButton);
	
	if (panel:GetDisabled()) then
		panel:SetTextColor(self.colButtonTextDisabled);
	else
		panel:SetTextColor(self.colButtonText);
	end;
	
	DLabel.ApplySchemeSettings(panel);
end;

-- Called when a panel is painted.
function SKIN:PaintPanel(panel)
	if (panel.m_bPaintBackground) then
		local w, h = panel:GetSize();
		
		self:DrawGenericBackground(0, 0, w, h, panel.m_bgColor or self.panelTransback);
	end;
end;

-- Called when a sys button is painted.
function SKIN:PaintSysButton(panel)
	self:PaintButton(panel);
	self:PaintOverButton(panel);
end;

-- Called when a sys button is schemed.
function SKIN:SchemeSysButton(panel)
	panel:SetFont("Marlett"); DLabel.ApplySchemeSettings(panel);
end;

-- Called when an image button is painted.
function SKIN:PaintImageButton(panel)
	self:PaintButton(panel);
end;

-- Called when an image button is painted over.
function SKIN:PaintOverImageButton(panel)
	self:PaintOverButton(panel);
end;

-- Called when an image button is layed out.
function SKIN:LayoutImageButton(panel)
	if (panel.m_bBorder) then
		panel.m_Image:SetPos(1, 1);
		panel.m_Image:SetSize(panel:GetWide() - 2, panel:GetTall() - 2);
	else
		panel.m_Image:SetPos(0, 0);
		panel.m_Image:SetSize(panel:GetWide(), panel:GetTall());
	end;
end;

-- Called when a panel list is painted.
function SKIN:PaintPanelList(panel)
	if (panel.m_bBackground) then
		self:DrawGenericBackground(0, 0, panel:GetWide(), panel:GetTall(), self.bgColorDark);
	end;
end;

-- Called when a vertical scrollbar is painted.
function SKIN:PaintVScrollBar(panel)
	surface.SetDrawColor(self.bgColorSleep);
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
end;

-- Called when a vertical scrollbar is layed out.
function SKIN:LayoutVScrollBar(panel)
	local wide = panel:GetWide();
	local scroll = panel:GetScroll() / panel.CanvasSize;
	local barSize = math.max(panel:BarScale() * (panel:GetTall() - (wide * 2)), 10)
	local track = (panel:GetTall() - (wide * 2) - barSize) + 1;
	
	scroll = scroll * track;
	
	panel.btnGrip:SetPos(0, wide + scroll);
	panel.btnGrip:SetSize(wide, barSize);
	panel.btnUp:SetPos(0, 0, wide, wide);
	panel.btnUp:SetSize(wide, wide);
	
	panel.btnDown:SetPos(0, panel:GetTall() - wide, wide, wide);
	panel.btnDown:SetSize(wide, wide);
end;

-- Called when a scroll bar grip is painted.
function SKIN:PaintScrollBarGrip(panel)
	local w, h = panel:GetSize();
	local color = self.controlColor;
	
	if (panel.Depressed) then
		color = self.controlColorActive;
	elseif (panel.Hovered) then
		color = self.controlColorHighlight;
	end;
 
	self:DrawGenericBackground(0, 0, w, h, Color(0, 0, 0, 230));
	self:DrawGenericBackground(1, 1, w - 2, h - 2, Color(color.r + 30, color.g + 30, color.b + 30));
	self:DrawGenericBackground(2, 2, w - 4, h - 4, color);
	self:DrawGenericBackground(3, h * 0.5, w - 6, h - h * 0.5 - 2, Color(0, 0, 0, 25));
end;

-- Called when a menu is painted.
function SKIN:PaintMenu(panel)
	surface.SetDrawColor(self.colMenuBG);
	panel:DrawFilledRect(0, 0, w, h);
end;

-- Called when a menu is painted over.
function SKIN:PaintOverMenu(panel)
	surface.SetDrawColor(self.colMenuBorder);
	panel:DrawOutlinedRect(0, 0, w, h);
end;

-- Called when a menu is layed out.
function SKIN:LayoutMenu(panel) end;

-- Called when a menu option is painted.
function SKIN:PaintMenuOption(panel)
	if (panel.m_bBackground and panel.Hovered) then
		local color = nil;

		if (panel.Depressed) then
			color = self.controlColorBright;
		else
			color = self.controlColorActive;
		end;

		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
	end;
end;

-- Called when a menu option is layed out.
function SKIN:LayoutMenuOption(panel)
	panel:SizeToContents();
	panel:SetWide(panel:GetWide() + 30);
	panel:SetSize(math.max(panel:GetParent():GetWide(), panel:GetWide()), 18);
	
	if (panel.SubMenuArrow) then
		panel.SubMenuArrow:SetSize(panel:GetTall(), panel:GetTall());
		panel.SubMenuArrow:CenterVertical();
		panel.SubMenuArrow:AlignRight();
	end;
end;

-- Called when a menu option is schemed.
function SKIN:SchemeMenuOption(panel)
	panel:SetFGColor(40, 40, 40, 255);
end;

-- Called when a text entry is painted.
function SKIN:PaintTextEntry(panel)
	if (panel.m_bBackground) then
		surface.SetDrawColor(self.colTextEntryBG);
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
	end;
	
	panel:DrawTextEntryText(panel.m_colText, panel.m_colHighlight, panel.m_colCursor);
	
	if (panel.m_bBorder) then
		surface.SetDrawColor(self.colTextEntryBorder);
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall());
	end;
end;

-- Called when a text entry is schemed.
function SKIN:SchemeTextEntry(panel)
	panel:SetTextColor(self.colTextEntryText);
	panel:SetHighlightColor(self.colTextEntryTextHighlight);
	panel:SetCursorColor(Color(0, 0, 100, 255));
end;

-- Called when a label is painted.
function SKIN:PaintLabel(panel)
	return false;
end;

-- Called when a label is schemed.
function SKIN:SchemeLabel(panel)
	local color = nil

	if (panel.Hovered and panel:GetTextColorHovered()) then
		color = panel:GetTextColorHovered();
	else
		color = panel:GetTextColor();
	end;
	
	if (color) then
		panel:SetFGColor(color.r, color.g, color.b, color.a);
	else
		panel:SetFGColor(200, 200, 200, 255);
	end;
end;

-- Called when a label is layed out.
function SKIN:LayoutLabel(panel)
	panel:ApplySchemeSettings();
	
	if (panel.m_bAutoStretchVertical) then
		panel:SizeToContentsY();
	end;
end;

-- Called when a category header is painted.
function SKIN:PaintCategoryHeader(panel) end;

-- Called when a category header is schemed.
function SKIN:SchemeCategoryHeader(panel)
	panel:SetTextInset(5);
	panel:SetFont(self.fontCategoryHeader);
	
	if (panel:GetParent():GetExpanded()) then
		panel:SetTextColor(self.colCategoryText);
	else
		panel:SetTextColor(self.colCategoryTextInactive);
	end;
end;

-- Called when a collapsible category is painted.
function SKIN:PaintCollapsibleCategory(panel)
	self:DrawGenericBackground(0, 0, panel:GetWide(), panel:GetTall(), self.colCollapsibleCategory);
end;

-- Called when a tab is painted.
function SKIN:PaintTab(panel)
	if (panel:GetPropertySheet():GetActiveTab() == panel) then
		self:DrawGenericBackground(0, 0, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow);
		self:DrawGenericBackground(1, 1, panel:GetWide() - 2, panel:GetTall() + 8, self.colTab);
	else
		self:DrawGenericBackground(0, 1, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow);
		self:DrawGenericBackground(1, 2, panel:GetWide() - 2, panel:GetTall() + 8, self.colTabInactive);
	end;
end;

-- Called when a tab is schemed.
function SKIN:SchemeTab(panel)
	panel:SetFont(self.fontTab);

	local extraInset = 10;

	if (panel.Image) then
		extraInset = extraInset + panel.Image:GetWide();
	end;
	
	panel:SetTextInset(extraInset);
	panel:SizeToContents();
	panel:SetSize(panel:GetWide() + 10, panel:GetTall() + 8);
	
	local active = (panel:GetPropertySheet():GetActiveTab() == panel);
	
	if (active) then
		panel:SetTextColor(self.colTabText);
	else
		panel:SetTextColor(self.colTabTextInactive);
	end;
	
	panel.BaseClass.ApplySchemeSettings(panel);
end;

-- Called when a tab is layed out.
function SKIN:LayoutTab(panel)
	panel:SetTall(22);

	if (panel.Image) then
		local active = (panel:GetPropertySheet():GetActiveTab() == panel);
		local diff = panel:GetTall() - panel.Image:GetTall();
		
		panel.Image:SetPos(7, diff * 0.6);

		if (!active) then
			panel.Image:SetImageColor(Color(170, 170, 170, 155));
		else
			panel.Image:SetImageColor(Color(255, 255, 255, 255));
		end;
	end;
end;

-- Called when a property sheet is painted.
function SKIN:PaintPropertySheet(panel)
	local activeTab = panel:GetActiveTab();
	local offset = 0;
	
	if (activeTab) then
		offset = activeTab:GetTall();
	end;
	
	self:DrawGenericBackground(0, offset, panel:GetWide(), panel:GetTall() - offset, self.colPropertySheet);
end;

-- Called when a list view is painted.
function SKIN:PaintListView(panel)
	if (panel.m_bBackground) then
		surface.SetDrawColor(50, 50, 50, 255);
		panel:DrawFilledRect();
	end;
end;
	
-- Called when a list view line is painted.
function SKIN:PaintListViewLine(panel)
	local color = nil;
	
	if (panel:IsSelected()) then
		color = self.listviewSelected;
	elseif (panel.Hovered) then
		color = self.listviewHover;
	elseif (panel.m_bAlt) then
		color = self.bgAltTwo;
	else
		return;
	end;
 
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall());
end;


-- Called when a list view label is schemed.
function SKIN:SchemeListViewLabel(panel)
	panel:SetTextInset(3);
	panel:SetTextColor(Color(255, 255, 255, 255));

end;

-- Called when a form is painted.
function SKIN:PaintForm(panel)
	local color = self.bgColorSleep;

	self:DrawGenericBackground(0, 9, panel:GetWide(), panel:GetTall() - 9, self.bgColor);
end;

-- Called when a form is schemed.
function SKIN:SchemeForm(panel)
	panel.Label:SetFont(self.fontFormLabel);
	panel.Label:SetTextColor(Color(255, 255, 255, 255));
end;

-- Called when a form is layed out.
function SKIN:LayoutForm(panel) end;

-- Called when a multi choice is layed out.
function SKIN:LayoutMultiChoice(panel)
	panel.TextEntry:SetSize(panel:GetWide(), panel:GetTall());
	
	panel.DropButton:SetSize(panel:GetTall(), panel:GetTall());
	panel.DropButton:SetPos(panel:GetWide() - panel:GetTall(), 0);
	panel.DropButton:SetZPos(1);
	
	panel.DropButton:SetDrawBackground(false);
	panel.DropButton:SetDrawBorder(false);
	
	panel.DropButton:SetTextColor(Color(30, 100, 200, 255));
end;

-- Called when a number wang indicator is painted.
function SKIN:PaintNumberWangIndicator(panel)
	if (panel.m_bTop) then
		surface.SetMaterial(self.texGradientUp);
	else
		surface.SetMaterial(self.texGradientDown);
	end;
	
	surface.SetDrawColor(self.colNumberWangBG);
	surface.DrawTexturedRect(0, 0, panel:GetWide(), panel:GetTall());
	
	local wang = panel:GetWang();
	local curNum = math.floor(wang:GetFloatValue());

	local increment = wang:GetTall();
	local insetY = 5;
	local insetX = 3;
	local offset = (curNum - wang:GetFloatValue()) * increment;
	local numInc = 1;
	
	if (panel.m_bTop) then
		local minimum = wang:GetMin();
		local startPos = panel:GetTall() + offset;
		local endPos = increment *  - 1;

		curNum = curNum + numInc;
		
		for y = startPos, increment *  - 1, endPos do
			curNum = curNum - numInc;
			
			if (curNum < minimum) then
				break
			end;
			
			self:DrawNumberWangIndicatorText(panel, wang, insetX, y + insetY, curNum, y / panel:GetTall());
		end;
	else
		local maximum = wang:GetMax();

		for y = offset - increment, panel:GetTall(), increment do
			self:DrawNumberWangIndicatorText(panel, wang, insetX, y + insetY, curNum, 1 - ((y + increment) / panel:GetTall()));
			curNum = curNum + numInc;
			
			if (curNum > maximum) then
				break
			end;
		end;
	end;
end;

-- Called when a number wang indicator is layed out.
function SKIN:LayoutNumberWangIndicator(panel)
	panel.Height = 200;

	local wang = panel:GetWang();
	local x, y = wang:LocalToScreen(0, wang:GetTall());
	
	if (panel.m_bTop) then
		y = y - panel.Height - wang:GetTall();
	end;
	
	panel:SetPos(x, y);
	panel:SetSize(wang:GetWide() - wang.Wanger:GetWide(), panel.Height);
end;

-- Called when a checkbox is painted.
function SKIN:PaintCheckBox(panel)
	local w, h = panel:GetSize()

	surface.SetDrawColor(255, 255, 255, 255);
	surface.DrawRect(1, 1, w - 2, h - 2);
	surface.SetDrawColor(30, 30, 30, 255);
	surface.DrawRect(1, 0, w - 2, 1);
	surface.DrawRect(1, h - 1, w - 2, 1);
	surface.DrawRect(0, 1, 1, h - 2);
	surface.DrawRect(w - 1, 1, 1, h - 2);
	surface.DrawRect(1, 1, 1, 1);
	surface.DrawRect(w - 2, 1, 1, 1);
	surface.DrawRect(1, h - 2, 1, 1);
	surface.DrawRect(w - 2, h - 2, 1, 1);
end;

-- Called when a checkbox is schemed.
function SKIN:SchemeCheckBox(panel)
	panel:SetTextColor(Color(0, 0, 0, 255));
	DSysButton.ApplySchemeSettings(panel);
end;

-- Called when a slider is painted.
function SKIN:PaintSlider(panel) end;

-- Called when a num slider is painted.
function SKIN:PaintNumSlider(panel)
	local w, h = panel:GetSize()
	
	self:DrawGenericBackground(0, 0, w, h, Color(255, 255, 255, 20));
	
	surface.SetDrawColor(0, 0, 0, 200);
	surface.DrawRect(3, h / 2, w - 6, 1);
end;

-- Called when a combobox item is painted.
function SKIN:PaintComboBoxItem(panel)
	if (panel:GetSelected()) then
		local color = self.comboBoxSelected;
			surface.SetDrawColor(color.r, color.g, color.b, color.a);
		panel:DrawFilledRect();
	end;
end;

-- Called when a combo box item is schemed.
function SKIN:SchemeComboBoxItem(panel)
	panel:SetTextColor(Color(0, 0, 0, 255));
end;

-- Called when a combobox item is painted.
function SKIN:PaintComboBox(panel)
	surface.SetDrawColor(255, 255, 255, 255);
	panel:DrawFilledRect();
 
	surface.SetDrawColor(0, 0, 0, 255);
	panel:DrawOutlinedRect();
end;

-- Called when a bevel is painted.
function SKIN:PaintBevel(panel)
	local w, h = panel:GetSize();

	surface.SetDrawColor(255, 255, 255, 255);
	surface.DrawOutlinedRect(0, 0, w - 1, h - 1);
	
	surface.SetDrawColor(0, 0, 0, 255);
	surface.DrawOutlinedRect(1, 1, w - 1, h - 1);
end;

-- Called when a tree is painted.
function SKIN:PaintTree(panel)
	if (panel.m_bBackground) then
		surface.SetDrawColor(self.bgColorBright.r, self.bgColorBright.g, self.bgColorBright.b, self.bgColorBright.a);
		panel:DrawFilledRect();
	end;
end;

-- Called when a tiny button is painted.
function SKIN:PaintTinyButton(panel)
	if (panel.m_bBackground) then
		surface.SetDrawColor(255, 255, 255, 255);
		panel:DrawFilledRect();
	end;
	
	if (panel.m_bBorder) then
		surface.SetDrawColor(0, 0, 0, 255);
		panel:DrawOutlinedRect();
	end;
end;

-- Called when a tiny button is schemed.
function SKIN:SchemeTinyButton(panel)
	panel:SetFont("Default");
		if (panel:GetDisabled()) then
			panel:SetTextColor(Color(0, 0, 0, 50));
		else
			panel:SetTextColor(Color(0, 0, 0, 255));
		end;
		
		DLabel.ApplySchemeSettings(panel);
	panel:SetFont("DefaultSmall");
end;

-- Called when a tree node button is painted.
function SKIN:PaintTreeNodeButton(panel)
	if (panel.m_bSelected) then
		surface.SetDrawColor(50, 200, 255, 150);
		panel:DrawFilledRect();
	elseif (panel.Hovered) then
		surface.SetDrawColor(255, 255, 255, 100);
		panel:DrawFilledRect();
	end;
end;

-- Called when a tree node button is schemed.
function SKIN:SchemeTreeNodeButton(panel)
	DLabel.ApplySchemeSettings(panel);
end;

-- Called when a tooltip is painted.
function SKIN:PaintTooltip(panel)
	local w, h = panel:GetSize();
	
	DisableClipping(true);
		for i = 1, 4 do
			local borderSize = i * 2;
			local bgColor = Color(0, 0, 0, (255 / i) * 0.3);

			self:DrawGenericBackground(borderSize, borderSize, w, h, bgColor);
			panel:DrawArrow(borderSize, borderSize);
			self:DrawGenericBackground(-borderSize, borderSize, w, h, bgColor);
			panel:DrawArrow(-borderSize, borderSize);
			self:DrawGenericBackground(borderSize, -borderSize, w, h, bgColor);
			panel:DrawArrow(borderSize, -borderSize);
			self:DrawGenericBackground(-borderSize, -borderSize, w, h, bgColor);
			panel:DrawArrow(-borderSize, -borderSize);
		end;

		draw.RoundedBox(4, 0, 0, w, h, self.toolTip);
		panel:DrawArrow(0, 0);
		
		panel.Contents:SetTextColor(Color(0, 0, 0, 255));
		panel.Contents:SetExpensiveShadow(1, Color(255, 255, 255, 255));
	DisableClipping(false);
end;

-- Called when a voice notify is painted.
function SKIN:PaintVoiceNotify(panel)
	local w, h = panel:GetSize();
	
	self:DrawGenericBackground(0, 0, w, h, panel.Color);
	self:DrawGenericBackground(1, 1, w - 2, h - 2, Color(60, 60, 60, 240));
end;

-- Called when a voice notify is schemed.
function SKIN:SchemeVoiceNotify(panel)
	panel.LabelName:SetFont("TabLarge");
	panel.LabelName:SetContentAlignment(4);
	panel.LabelName:SetColor(color_white);
	panel:InvalidateLayout();
end;

-- Called when a voice notify is layed out.
function SKIN:LayoutVoiceNotify(panel)
	panel:SetSize(200, 40);
	panel.Avatar:SetPos(4, 4);
	panel.Avatar:SetSize(32, 32);
	panel.LabelName:SetPos(44, 0);
	panel.LabelName:SizeToContents();
	panel.LabelName:CenterVertical();
end;

derma.DefineSkin("Clockwork", "Made for the Clockwork framework.", SKIN);