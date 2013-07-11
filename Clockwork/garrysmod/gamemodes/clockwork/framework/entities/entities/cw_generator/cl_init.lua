--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

include("shared.lua");

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("GeneratorEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;