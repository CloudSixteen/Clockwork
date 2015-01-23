--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticAdd");
COMMAND.tip = "Add a static entity at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		local class = cwStaticEnts:CanStatic(target)
		if (class == "nope") then
			Clockwork.player:Notify(player, "This entity causes issues when it is static!");
		elseif (class != false) then
			for k, v in pairs(cwStaticEnts.staticEnts) do
				if (target == v) then
					Clockwork.player:Notify(player, "This entity is already static!");				
					return;
				end;
			end;
				
			table.insert(cwStaticEnts.staticEnts, target);			
			Clockwork.player:Notify(player, "You have added a static entity.");		
		else
			Clockwork.player:Notify(player, "You cannot static this entity!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

COMMAND:Register();