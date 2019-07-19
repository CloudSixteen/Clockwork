--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Door Parenting Manager";
TOOL.UniqueID 		= "doorparent";
TOOL.Category		= "Clockwork";
TOOL.Desc 			= "Manage parent doors.";
TOOL.HelpText		= "Primary: Set Parent/Child | Reload: Clear Active Parent | Secondary: Remove Door Parent";
TOOL.rightClickCMD	= "DoorUnparent";
TOOL.reloadCMD		= "DoorResetParent";
TOOL.reloadFire		= false;

TOOL.ClientConVar[ "description" ]	= ""

function TOOL:LeftClick(tr)
	if (CLIENT) then return true; end

	local player = self:GetOwner();
	local door = tr.Entity;

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (IsValid(player.cwParentDoor)) then
			player:RunClockworkCmd("DoorSetChild");
		else
			player:RunClockworkCmd("DoorSetParent");
		end;		
	else
		Clockwork.player:Notify(player, {"ThisIsNotAValidDoor"});
	end;
end;

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Text = L("DoorToolNameText"), Description = L("DoorToolNameDesc")});
	CPanel:AddControl("Header", {Text = L("DoorToolHelpText"), Description	= L("DoorToolHelpDesc")});
end;

TOOL:Register();