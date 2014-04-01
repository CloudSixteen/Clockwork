--[[ 
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local AddCSLuaFile = AddCSLuaFile;
local IsValid = IsValid;
local pairs = pairs;
local pcall = pcall;
local string = string;
local table = table;
local game = game;

Clockwork = Clockwork or GM;
Clockwork.ClockworkFolder = Clockwork.ClockworkFolder or GM.Folder;
Clockwork.SchemaFolder = Clockwork.SchemaFolder or GM.Folder;
Clockwork.KernelVersion = "0.91";
Clockwork.Website = "http://kurozael.com";
Clockwork.Author = "kurozael";
Clockwork.Email = "kurozael@gmail.com";
Clockwork.Name = "Clockwork";

--[[ Check if we are using the right CloudAX version. --]]
if (SERVER and CloudAuthX.GetVersion() < 5) then
	for i = 1, 3 do
		Error("[CloudAuthX] Clockwork requires an updated CloudAuthX .dll!\n");
	end;
end;

--[[
	Do not edit this function. Editing this function will cause
	the schema to not function, and CloudAuthX will not
	auth you.
--]]
function Clockwork:GetGameDescription()
	local schemaName = self.kernel:GetSchemaGamemodeName();
	return "CW: "..schemaName;
end;

AddCSLuaFile("cl_kernel.lua");
AddCSLuaFile("sh_kernel.lua");
AddCSLuaFile("sh_fixes.lua");
AddCSLuaFile("sh_enum.lua");
AddCSLuaFile("sh_boot.lua");
include("sh_enum.lua");
include("sh_fixes.lua");
include("sh_kernel.lua");

if (CLIENT) then
	if (CW_SCRIPT_SHARED) then
		CW_SCRIPT_SHARED = Clockwork.kernel:Deserialize(CW_SCRIPT_SHARED);
	else
		CW_SCRIPT_SHARED = {};
	end;
	
	if (CW_SCRIPT_SHARED.clientCode) then
		RunString(CW_SCRIPT_SHARED.clientCode);
	end;
end;

if (CW_SCRIPT_SHARED.schemaFolder) then
	Clockwork.SchemaFolder = CW_SCRIPT_SHARED.schemaFolder;
end;

if (!game.GetWorld) then
	game.GetWorld = function() return Entity(0); end;
end;

--[[ These are aliases to avoid variable name conflicts. --]]
cwPlayer, cwTeam, cwFile = player, team, file;
_player, _team, _file = player, team, file;

--[[ These are libraries that we want to load before any others. --]]
Clockwork.kernel:IncludePrefixed("libraries/sv_file.lua");

if (SERVER) then CloudAuthX.Authenticate(); end;

Clockwork.kernel:IncludeDirectory("libraries/", true);
Clockwork.kernel:IncludeDirectory("directory/", true);
Clockwork.kernel:IncludeDirectory("config/", true);
Clockwork.kernel:IncludePlugins("plugins/", true);
Clockwork.kernel:IncludeDirectory("system/", true);
Clockwork.kernel:IncludeDirectory("items/", true);
Clockwork.kernel:IncludeDirectory("derma/", true);

--[[ The following code is loaded by CloudAuthX. --]]
if (SERVER) then include("sv_cloudax.lua"); end;

--[[ The following code is loaded over-the-Cloud. --]]
if (SERVER and Clockwork.LoadPreSchemaExternals) then
	Clockwork:LoadPreSchemaExternals();
end;

--[[ Load the schema and let any plugins know about it. --]]
Clockwork.kernel:IncludeSchema();
Clockwork.plugin:Call("ClockworkSchemaLoaded");

--[[ The following code is loaded over-the-Cloud. --]]
if (SERVER and Clockwork.LoadPostSchemaExternals) then
	Clockwork:LoadPostSchemaExternals();
end;

if (CLIENT) then
	Clockwork.plugin:Call("ClockworkLoadShared", CW_SCRIPT_SHARED);
end;

Clockwork.kernel:IncludeDirectory("commands/", true);

-- Called when the Clockwork shared variables are added.
function Clockwork:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("InvWeight", true);
	playerVars:Number("MaxHP", true);
	playerVars:Number("MaxAP", true);
	playerVars:Number("IsDrunk", true);
	playerVars:Number("Wages", true);
	playerVars:Number("Cash", true);
	playerVars:Number("ActDuration");
	playerVars:Number("ForceAnim");
	playerVars:Number("IsRagdoll");
	playerVars:Number("Faction");
	playerVars:Number("Gender");
	playerVars:Number("Key");
	playerVars:Bool("TargetKnows", true);
	playerVars:Bool("FallenOver", true);
	playerVars:Bool("CharBanned", true);
	playerVars:Bool("IsWepRaised");
	playerVars:Bool("Initialized");
	playerVars:Bool("IsJogMode");
	playerVars:Bool("IsRunMode");
	playerVars:String("PhysDesc");
	playerVars:String("Clothes", true);
	playerVars:String("Model", true);
	playerVars:String("ActName");
	playerVars:String("Flags");
	playerVars:String("Name");
	playerVars:Entity("Ragdoll");
	playerVars:Float("StartActTime");
	globalVars:String("NoMySQL");
	globalVars:String("Date");
	globalVars:Number("Minute");
	globalVars:Number("Hour");
	globalVars:Number("Day");
end;

Clockwork.plugin:Call("ClockworkAddSharedVars",
	Clockwork.kernel:GetSharedVars():Global(true),
	Clockwork.kernel:GetSharedVars():Player(true)
);

Clockwork.plugin:IncludeEffects("Clockwork/framework");
Clockwork.plugin:IncludeWeapons("Clockwork/framework");
Clockwork.plugin:IncludeEntities("Clockwork/framework");

if (SERVER) then CloudAuthX.Initialize(); end;
