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

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetPos(4, 4);
	self:SetSize(self:GetWide() - 8, 32);
	self:SetBackgroundColor(Color(139, 174, 179, 255));
	
	self.icon = vgui.Create("DImage", self);
	self.icon:SetImage("icon16/comment.png");
	self.icon:SizeToContents();
	
	local font = Clockwork.fonts:GetSize(Clockwork.option:GetFont("info_text_font"), 16);
	
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("");
	self.label:SetFont(font);
	self.label:SetTextColor(Clockwork.option:GetColor("white"));
	self.label:SetExpensiveShadow(1, Color(0, 0, 0, 150));
	
	Clockwork.kernel:CreateMarkupToolTip(self);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	if (self.textToLeft) then
		if (self.icon:IsVisible()) then
			self.label:SetPos(self.icon.x + self.icon:GetWide() + 12, h / 2 - self.label:GetTall() / 2);
		else
			self.label:SetPos(8, h / 2 - self.label:GetTall() / 2);
		end;
	else
		self.label:SetPos(w / 2 - self.label:GetWide() / 2, h / 2 - self.label:GetTall() / 2);
	end;
	
	self:UpdateIconPosition();
	
	derma.SkinHook("Layout", "Panel", self);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	if (self:GetPaintBackground()) then
		local width, height = self:GetSize();
		local x, y = 0, 0;
		
		if (self:IsDepressed()) then
			height = height - 2;
			width = width - 2;
			x = x + 1;
			y = y + 1;
		end;
		
		INFOTEXT_SLICED:Draw(x, y, width, height, 8, self:GetBackgroundColor());
		
		if (self:IsButton() and self:IsHovered()) then
			surface.SetDrawColor(255, 255, 255, 50);
			surface.DrawRect(x, y, width, height);
		end;
	end	
	
	return true;
end;

-- A function to set the text to the left.
function PANEL:SetTextToLeft(bValue)
	self.textToLeft = bValue;
end;

-- A function to set the text of the panel.
function PANEL:SetText(text)
	self.label:SetText(text);
	self.label:SizeToContents();
	
	self:UpdateIconPosition();
end;

-- A function to set whether the panel is a button.
function PANEL:SetButton(isButton)
	self.isButton = isButton;
end;

-- A function to get whether the panel is a button.
function PANEL:IsButton()
	return self.isButton;
end;

-- A function to set whether the panel is depressed.
function PANEL:SetDepressed(isDepressed)
	self.isDepressed = isDepressed;
end;

-- A function to get whether the panel is depressed.
function PANEL:IsDepressed()
	return self.isDepressed;
end;

-- A function to set whether the panel is hovered.
function PANEL:SetHovered(isHovered)
	self.isHovered = isHovered;
end;

-- A function to get whether the panel is hovered.
function PANEL:IsHovered()
	return self.isHovered;
end;

-- A function to set the text color of the panel.
function PANEL:SetTextColor(color)
	self.label:SetTextColor(color);
end;

-- Called when the mouse is pressed on the panel.
function PANEL:OnMousePressed(mouseCode)
	if (self:IsButton()) then
		self:SetDepressed(true);
		self:MouseCapture(true);
	end;
end;

-- Called when the mouse is released on the panel.
function PANEL:OnMouseReleased(mouseCode)
	if (self:IsButton() and self:IsDepressed()
	and self:IsHovered()) then
		if (self.DoClick) then
			Clockwork.option:PlaySound("click");
			self:DoClick();
		end;
	end;
	
	self:SetDepressed(false);
	self:MouseCapture(false);
end;

-- Called when the mouse has entered the panel.
function PANEL:OnCursorEntered()
	self:SetHovered(true);
end;

-- Called when the mouse has entered the panel.
function PANEL:OnCursorExited()
	self:SetHovered(false);
end;

-- A function to set whether the icon is shown.
function PANEL:SetShowIcon(showIcon)
	self.icon:SetVisible(showIcon);
end;

-- A function to set the icon.
function PANEL:SetIcon(icon, size)
	if (not size) then
		size = Clockwork.option:GetKey("info_text_icon_size");
	end;
	
	self.icon:SetImage(icon);
	self.icon:SetVisible(true);
	self.icon:SetSize(size, size);
	
	self:UpdateIconPosition();
end;

-- Update the icon position to align with the text.
function PANEL:UpdateIconPosition()
	local size = self.icon:GetWide();
	
	if (not self.textToLeft) then
		self.icon:SetPos(self.label.x - size - 12, 16 - (size / 2));
	else
		self.icon:SetPos(8, 16 - (size / 2));
	end;
end;

-- A function to set the panel's info color.
function PANEL:SetInfoColor(color)
	if (color == "red") then
		self:SetBackgroundColor(Color(179, 46, 49, 255));
		self:SetIcon(Clockwork.option:GetKey("info_text_red_icon"));
	elseif (color == "orange") then
		self:SetBackgroundColor(Color(223, 154, 72, 255));
		self:SetIcon(Clockwork.option:GetKey("info_text_orange_icon"));
	elseif (color == "green") then
		self:SetBackgroundColor(Color(139, 215, 113, 255));
		self:SetIcon(Clockwork.option:GetKey("info_text_green_icon"));
	elseif (color == "blue") then
		self:SetBackgroundColor(Color(139, 174, 179, 255));
		self:SetIcon(Clockwork.option:GetKey("info_text_blue_icon"));
	else
		self:SetShowIcon(false);
		self:SetBackgroundColor(color);
	end;
end;
	
vgui.Register("cwInfoText", PANEL, "DPanel");