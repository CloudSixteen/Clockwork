--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[ Require the CloudAuthX authentication system. --]]
require("cloudauthx");

if (system.IsLinux()) then
	require("mysqloo");
end;

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("external/von.lua");
AddCSLuaFile("external/pon.lua");

--[[
	Include Vercas's serialization library, Penguin's Object Notation and the Clockwork kernel. 
--]]
include("external/von.lua");
include("external/pon.lua");
include("clockwork/framework/sv_kernel.lua");