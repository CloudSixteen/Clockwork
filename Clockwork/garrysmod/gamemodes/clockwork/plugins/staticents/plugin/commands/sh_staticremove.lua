--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticRemove");
COMMAND.tip = "Remove static entities at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (cwStaticEnts:CanStatic(v) != false) then
			for k, v in pairs(cwStaticEnts.staticEnts) do
				if (target == v) then
					cwStaticEnts.staticEnts[k] = nil;
					cwStaticEnts:SaveStaticEnts();
					
					Clockwork.player:Notify(player, "You have removed a static entity.");
					
					return;
				end;
			end;
		else
			Clockwork.player:Notify(player, "This entity is not able to be a static entity!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

COMMAND:Register();