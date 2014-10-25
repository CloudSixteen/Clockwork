--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

if (Clockwork and Clockwork.config) then
	ErrorNoHalt("[Clockwork] Clockwork does not currently support AutoRefresh but is being worked on.\n");
	return;
end;

--[[ Include Vercas's serialization library. --]]
include("external/von.lua");
include("external/pon.lua");

--[[
	Include the shared Lua table and
	the Clockwork kernel.
--]]
include("Clockwork.lua");
include("clockwork/framework/cl_kernel.lua");