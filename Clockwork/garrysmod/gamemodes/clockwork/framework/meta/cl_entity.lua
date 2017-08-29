--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local cwDatastream = Clockwork.datastream;
local cwCharacter = Clockwork.character;
local cwCommand = Clockwork.command;
local cwSetting = Clockwork.setting;
local cwFaction = Clockwork.faction;
local cwChatBox = Clockwork.chatBox;
local cwEntity = Clockwork.entity;
local cwOption = Clockwork.option;
local cwConfig = Clockwork.config;
local cwKernel = Clockwork.kernel;
local cwPlugin = Clockwork.plugin;
local cwTheme = Clockwork.theme;
local cwEvent = Clockwork.event;
local cwPly = Clockwork.player;
local cwMenu = Clockwork.menu;
local cwQuiz = Clockwork.quiz;
local cwItem = Clockwork.item;
local cwLimb = Clockwork.limb;

local entityMeta = FindMetaTable("Entity");

entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets;

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		cwPlugin:Call("PlayerAdjustBulletInfo", self, bulletInfo);
	end;
	
	cwPlugin:Call("EntityFireBullets", self, bulletInfo);
	
	return self:ClockworkFireBullets(bulletInfo);
end;

