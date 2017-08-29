--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the bars are needed.
function cwStamina:GetBars(bars)
	local stamina = Clockwork.Client:GetSharedVar("Stamina");
	
	if (!self.stamina) then
		self.stamina = stamina;
	else
		self.stamina = math.Approach(self.stamina, stamina, 1);
	end;
	
	if (self.stamina < 95) then
		bars:Add("STAMINA", Color(100, 175, 100, 255), "", self.stamina, 100, self.stamina < 10);
	end;
end;