--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

if (Clockwork and Clockwork.config) then
	ErrorNoHalt("[Clockwork] Clockwork does not currently support AutoRefresh but is being worked on.\n");
	return;
end;

local caxVersion = file.Read("cax.txt", "DATA");
local requireName = "cloudauthx";
if (caxVersion != "" and tonumber(caxVersion)) then
 local fileName = caxVersion;
 
 if (system.IsLinux()) then
 fileName = "gmsv_cloudauthx_"..fileName.."_linux.dll";
 else
 fileName = "gmsv_cloudauthx_"..fileName.."_win32.dll";
 end;
 
 if (file.Exists("lua/bin/"..fileName, "GAME")) then
 requireName = "cloudauthx_"..caxVersion;
 end;
end;
require(requireName);

if (system.IsLinux()) then
	require("mysqloo");
else
	require("tmysql4");
end;

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("external/von.lua");
AddCSLuaFile("external/pon.lua");

--[[
	Include Vercas's serialization library
	and the Clockwork kernel. --]]
include("external/von.lua");
include("external/pon.lua");
include("clockwork/framework/sv_kernel.lua");