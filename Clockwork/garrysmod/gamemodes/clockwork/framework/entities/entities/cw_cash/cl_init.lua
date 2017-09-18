--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local amount = self:GetDTInt(0);
	
	y = Clockwork.kernel:DrawInfo(L("Cash"), x, y, colorTargetID, alpha);
	y = Clockwork.kernel:DrawInfo(Clockwork.kernel:FormatCash(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("CashEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;