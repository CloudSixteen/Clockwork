--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local entityMeta = FindMetaTable("Entity");

entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		cwPlugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	cwPlugin:Call("EntityFireBullets", self, bulletInfo);
	return self:ClockworkFireBullets(bulletInfo);
end;

