--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("GeneratorEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;