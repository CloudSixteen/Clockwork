--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
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
		for k, v in pairs(cwStaticEnts.staticEnts) do
			if (target == v) then
				table.remove(cwStaticEnts.staticEnts, k);
				cwStaticEnts:SaveStaticEnts();
					
				Clockwork.player:Notify(player, "You have removed a static entity.");

				return;
			end;
		end;

		Clockwork.player:Notify(player, "This entity is not static.");
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

COMMAND:Register();