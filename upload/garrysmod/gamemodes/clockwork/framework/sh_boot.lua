--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local AddCSLuaFile = AddCSLuaFile;
local IsValid = IsValid;
local pairs = pairs;
local pcall = pcall;
local string = string;
local table = table;
local game = game;

if (!Clockwork) then
	Clockwork = GM;
else
	CurrentGM = Clockwork;
	table.Merge(CurrentGM, GM);
	Clockwork = nil;
	
	Clockwork = GM;
	table.Merge(Clockwork, CurrentGM);
	CurrentGM = nil;
end;

Clockwork.ClockworkFolder = Clockwork.ClockworkFolder or GM.Folder;
Clockwork.SchemaFolder = Clockwork.SchemaFolder or GM.Folder;
Clockwork.KernelVersion = "0.99";
Clockwork.KernelBuild = "beta"
Clockwork.DeveloperVersion = true;
Clockwork.Website = "http://kurozael.com";
Clockwork.Author = "kurozael";
Clockwork.Email = "kurozael@gmail.com";
Clockwork.Name = "Clockwork";

--[[ Check if we are using the right CloudAuthX version. --]]
if (SERVER and CloudAuthX.GetVersion() < 21) then
	for i = 1, 3 do
		Error("[CloudAuthX] This version of Clockwork requires CloudAuthX 16!\n Make sure you have installed the binary files from the Store!\n");
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
AddCSLuaFile("cl_theme.lua");
AddCSLuaFile("sh_kernel.lua");
AddCSLuaFile("sh_enum.lua");
AddCSLuaFile("sh_boot.lua");
include("sh_enum.lua");
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
library, lib = cwLibrary, cwLib;

--[[ These are libraries that we want to load before any others. --]]
Clockwork.kernel:IncludePrefixed("libraries/server/sv_file.lua");

if (SERVER) then CloudAuthX.Authenticate(); end;

Clockwork.kernel:IncludeDirectory("libraries/server", true);
Clockwork.kernel:IncludeDirectory("libraries/client", true);
Clockwork.kernel:IncludeDirectory("libraries/", true);
Clockwork.kernel:IncludePrefixed("cl_theme.lua");
Clockwork.kernel:IncludeDirectory("language/", true);
Clockwork.kernel:IncludeDirectory("directory/", true);
Clockwork.kernel:IncludeDirectory("config/", true);
Clockwork.kernel:IncludePlugins("plugins/", true);
Clockwork.kernel:IncludeDirectory("system/", true);
Clockwork.kernel:IncludeDirectory("items/", true);
Clockwork.kernel:IncludeDirectory("derma/", true);

--[[ The following code is loaded over-the-Cloud. --]]
if (SERVER and Clockwork.LoadPreSchemaExternals) then
	Clockwork:LoadPreSchemaExternals();
end;

--[[ Load the schema and let any plugins know about it. --]]
Clockwork.kernel:IncludeSchema();
Clockwork.plugin:Call("ClockworkSchemaLoaded");

if (SERVER) then
	MsgC(Color(0, 255, 100, 255), "[Clockwork] Successfully loaded "..Schema:GetName().." version "..Clockwork.kernel:GetSchemaGamemodeVersion().." by "..Schema:GetAuthor()..".\n");
end;

--[[ The following code is loaded over-the-Cloud. --]]
if (SERVER and Clockwork.LoadPostSchemaExternals) then
	Clockwork:LoadPostSchemaExternals();
end;	

if (CLIENT) then
	Clockwork.plugin:Call("ClockworkLoadShared", CW_SCRIPT_SHARED);
end;

Clockwork.kernel:IncludeDirectory("commands/", true);

Clockwork.player:AddCharacterData("PhysDesc", NWTYPE_STRING, "");
Clockwork.player:AddCharacterData("Model", NWTYPE_STRING, "");
Clockwork.player:AddCharacterData("Flags", NWTYPE_STRING, "");
Clockwork.player:AddCharacterData("Name", NWTYPE_STRING, "");
Clockwork.player:AddCharacterData("Cash", NWTYPE_NUMBER, 0);
Clockwork.player:AddCharacterData("Key", NWTYPE_NUMBER, 0);

-- Called when the Clockwork shared variables are added.
function Clockwork:ClockworkAddSharedVars(globalVars, playerVars)
	for k, v in pairs(self.player.characterData) do
		playerVars:Add(k, v.nwType, v.playerOnly);
	end;
	
	for k, v in pairs(self.player.playerData) do
		playerVars:Add(k, v.nwType, v.playerOnly);
	end;
	
	playerVars:Number("InvWeight", true);
	playerVars:Number("InvSpace", true);
	playerVars:Number("MaxHP");
	playerVars:Number("MaxAP");
	playerVars:Number("IsDrunk", true);
	playerVars:Number("Wages", true);
	playerVars:Number("ActDuration");
	playerVars:Number("ForceAnim");
	playerVars:Number("IsRagdoll");
	playerVars:Number("Faction");
	playerVars:Number("Gender");
	playerVars:Bool("TargetKnows", true);
	playerVars:Bool("FallenOver", true);
	playerVars:Bool("CharBanned", true);
	playerVars:Bool("IsWepRaised");
	playerVars:Bool("Initialized");
	playerVars:Bool("IsJogMode");
	playerVars:Bool("IsRunMode");
	playerVars:String("Clothes", true);
	playerVars:String("ActName");
	playerVars:String("Icon");
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
