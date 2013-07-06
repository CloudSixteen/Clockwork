--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.Author = "kurozael";
ENT.PrintName = "Salesman";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity is removed.
function ENT:OnRemove()
	if (SERVER and IsValid(self.cwChatBubble)) then
		self.cwChatBubble:Remove();
	end;
end;