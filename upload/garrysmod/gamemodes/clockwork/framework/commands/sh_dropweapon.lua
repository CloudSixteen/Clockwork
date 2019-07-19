--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("DropWeapon");

COMMAND.tip = "CmdDropWeapon";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER);

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon)) then
		local class = weapon:GetClass();
		local itemTable = Clockwork.item:GetByWeapon(weapon);
		
		if (!itemTable) then
			Clockwork.player:Notify(player, {"ThisNotValidWeapon"});
			return;
		end;
		
		if (Clockwork.plugin:Call("PlayerCanDropWeapon", player, itemTable, weapon)) then
			local trace = player:GetEyeTraceNoCursor();
			
			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = Clockwork.entity:CreateItem(player, itemTable, trace.HitPos);
				
				if (IsValid(entity)) then
					Clockwork.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
					
					player:TakeItem(itemTable, true);
					player:StripWeapon(class);
					player:SelectWeapon("cw_hands");
					
					Clockwork.plugin:Call("PlayerDropWeapon", player, itemTable, entity, weapon);
				end;
			else
				Clockwork.player:Notify(player, {"CannotDropWeaponFar"});
			end;
		end;
	else
		Clockwork.player:Notify(player, {"ThisNotValidWeapon"});
	end;
end;

COMMAND:Register();