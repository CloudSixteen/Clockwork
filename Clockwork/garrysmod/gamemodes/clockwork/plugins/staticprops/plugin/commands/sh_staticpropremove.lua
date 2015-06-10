--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticPropRemove");
COMMAND.tip = "Remove static props at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (Clockwork.entity:IsPhysicsEntity(target)) then
			for k, v in pairs(cwStaticProps.staticProps) do
				if (target == v) then
					cwStaticProps.staticProps[k] = nil;
					cwStaticProps:SaveStaticProps();
					
					Clockwork.player:Notify(player, "You have removed a static prop.");
					
					return;
				end;
			end;
		else
			Clockwork.player:Notify(player, "This entity is not a physics entity!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

COMMAND:Register();