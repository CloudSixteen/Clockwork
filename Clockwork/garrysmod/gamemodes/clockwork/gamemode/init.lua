--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

--[[ Require the CloudAuthX authentication system. --]]
require("cloudauthx");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("external/von.lua");

--[[
	Include Vercas's serialization library
	and the Clockwork kernel. --]]
include("external/von.lua");
include("clockwork/framework/sv_kernel.lua");