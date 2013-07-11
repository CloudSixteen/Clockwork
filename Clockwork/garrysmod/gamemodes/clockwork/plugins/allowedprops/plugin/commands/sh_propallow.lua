--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("PropAllow");
COMMAND.tip = "Add a prop to the allowed list.";
COMMAND.text = "[string Model]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local model = nil;
	
	if (arguments[1]) then
		model = string.lower(arguments[1]);
	elseif (trace.Entity:GetClass() == "prop_physics") then
		model = string.lower(trace.Entity:GetModel());
	else
		Clockwork.player:Notify(player, "This is not a valid prop!");
	end;
	
	if (model and !table.HasValue(cwAllowedProps.allowedProps, model)) then
		cwAllowedProps.allowedProps[#cwAllowedProps.allowedProps + 1] = model;
		
		Clockwork.player:Notify(player, "You have added "..model.." to the allowed list.");
	else
		Clockwork.player:Notify(player, "That prop is already on the allowed list.");
	end;
	
	cwAllowedProps:SaveAllowedProps();
end;

COMMAND:Register();