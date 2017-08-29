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

local weaponMeta = FindMetaTable("Weapon");

weaponMeta.OldGetPrintName = weaponMeta.OldGetPrintName or weaponMeta.GetPrintName;

-- A function to get a weapon's print name.
function weaponMeta:GetPrintName()
	local itemTable = cwItem:GetByWeapon(self);
	
	if (itemTable) then
		return L(itemTable("name"));
	else
		return self:OldGetPrintName();
	end;
end;