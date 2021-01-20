--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local startTime = os.clock();

if (Clockwork and Clockwork.kernel) then
	MsgC(Color(0, 255, 100, 255), "[Clockwork] Change has been detected! Auto-refreshing...\n");
else
	MsgC(Color(0, 255, 100, 255), "[Clockwork] The framework is initializing...\n");
end;

CLOUDAUTHX_VERSION = -1;

require("cwutil");

if (system.IsLinux()) then
	require("mysqloo");
else
	require("tmysql4");
end;

AddCSLuaFile("external/utf8.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("external/von.lua");

--[[ Include Vercas's serialization library and the Clockwork kernel. --]]
include("external/utf8.lua");
include("external/von.lua");
include("clockwork/framework/sv_cax_patch.lua");
include("clockwork/framework/sv_kernel.lua");

if (Clockwork and cwBootComplete) then
	MsgC(Color(0, 255, 100, 255), "[Clockwork] Auto-refresh handled server-side in "..math.Round(os.clock() - startTime, 3).. " second(s)!\n");
else
	local version = Clockwork.kernel:GetVersionBuild();
	
	MsgC(Color(0, 255, 100, 255), "[Clockwork] Successfully loaded Clockwork version "..version.." in "..math.Round(os.clock() - startTime, 3).. " second(s).\n");
end;

cwBootComplete = true;