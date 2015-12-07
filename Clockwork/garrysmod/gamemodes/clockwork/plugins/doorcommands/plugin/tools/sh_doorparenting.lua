--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
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
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

function TOOL.BuildCPanel( CPanel )
	-- HEADER
	CPanel:AddControl("Header", {Text = "Door Parenting", Description	= "Manage Parent Doors" });
	CPanel:AddControl("Header", { 
		Text = "Help", 
		Description	= "Door parenting lets you create a parent door, and once the player purchases that door, they will have access to the door's 'children'. Thus eliminating the need to setownable doors. How To use Door Parenting\n \n1. First Choose a parent door using Left Click. This is usually the 'front' door.\n\n2. Now Left Click any doors within the property.\n\n3. Now You may make the front door 'ownable'. You can also do unownable to set text on the other doors.\n\n*Make sure you unset the parent door once you are done." 
	});
end;

TOOL:Register();