--[[
	© CloudSixteen.com do not share, re-distribute or modify
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
		local class = Clockwork.plugin:Call("CanEntityStatic", target);

		if (class != false) then
			for k, v in pairs(cwStaticEnts.staticEnts) do
				if (target == v) then
					Clockwork.player:Notify(player, {"EntityAlreadyStatic"});

					return;
				end;
			end;
				
			cwStaticEnts:SaveEntity(target);

			Clockwork.player:Notify(player, {"YouAddedStaticEntity"});		
		else
			Clockwork.player:Notify(player, {"CannotStaticEntity"});
		end;
	else
		Clockwork.player:Notify(player, {"LookAtValidEntity"});
	end;
end;

COMMAND:Register();