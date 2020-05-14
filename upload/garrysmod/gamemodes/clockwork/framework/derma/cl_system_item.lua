--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local PANEL = {};

-- A function to set the panel's system table.
function PANEL:SetSystemTable(systemTable)
	self:NoClipping(false);

	self.backgroundButton:SetToolTip(L(systemTable.toolTip));
	self.backgroundButton:SetImage(systemTable.image..".png");
	self.backgroundButton:SetSize(128, 128);
	
	self.titleLabel:SetText(L(systemTable.name));
	self.titleLabel:SizeToContents();
	self.titleLabel.x = (self.backgroundButton:GetWide() / 2) - (self.titleLabel:GetWide() / 2);
	self.titleLabel.y = self.backgroundButton.y + self.backgroundButton:GetTall() + 8;
	
	self.titleLabel:NoClipping(false);
	
	self:SetSize(128, self.titleLabel.y + self.titleLabel:GetTall());
end;

-- A function to set the callback when the item is pressed.
function PANEL:SetOnPressed(callback)
	self.onPressedCallback = callback;
end;

-- Called when the panel is initialized.
function PANEL:Init()
	local informationColor = Clockwork.option:GetColor("information");
	local fontName = Clockwork.fonts:GetSize(Clockwork.option:GetFont("menu_text_tiny"), 22);
	
	self.titleLabel = vgui.Create("DLabel", self);
	self.titleLabel:SetFont(fontName);
	self.titleLabel:SetTextColor(Clockwork.option:GetColor("information"));
	
	self.backgroundButton = Clockwork.kernel:CreateMarkupToolTip(vgui.Create("cwImageButtonBorder", self));
	self.backgroundButton:SetHoverColor(informationColor);
	
	-- Called when the spawn icon is clicked.
	self.backgroundButton.DoClick = function(spawnIcon)
		if (self.onPressedCallback) then
			self.onPressedCallback();
		end;
	end;
end;

-- A function to set the border color of the background button.
function PANEL:SetColor(color)
	self.backgroundButton:SetColor(color);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	return true;
end;

-- Called each frame.
function PANEL:Think()
	
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	
end;
	
vgui.Register("cwSystemItem", PANEL, "DPanel");
