--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]
	

local PLUGIN = PLUGIN;

local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Door Parenting Manager";
TOOL.UniqueID 		= "doorparent";
TOOL.Category			= "Clockwork";
TOOL.Desc 			= "Manage parent doors.";
TOOL.HelpText		= "Primary: Set Parent/Child | Reload: Clear Active Parent | Secondary: Remove Door Parent";

TOOL.ClientConVar[ "description" ]		= ""

function TOOL:LeftClick(tr)
	if (CLIENT) then return true; end

	local player = self:GetOwner();
	local Clockwork = Clockwork;

	PLUGIN.infoTable = PLUGIN.infoTable or {};

	if (!player:IsAdmin()) then 
		return false;
	end;

	local door = player:GetEyeTraceNoCursor().Entity;

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (IsValid(player.cwParentDoor)) then
			if (door == player.cwParentDoor) then
				Clockwork.player:Notify(player, "You cannot parent a door to itself!");
			else
				if (cwDoorCmds.parentData[door] == player.cwParentDoor) then
					Clockwork.player:Notify(player, "This door is already parented to the active parent door!.");
				else
					cwDoorCmds.parentData[door] = player.cwParentDoor;
					cwDoorCmds:SaveParentData();

					table.insert(PLUGIN.infoTable, door)

					Clockwork.entity:SetDoorParent(door, player.cwParentDoor);
					Clockwork.player:Notify(player, "You have added this as a child to the active parent door.");
				end;
			end;
		else
			player.cwParentDoor = door;
			PLUGIN.infoTable.Parent = door;

			for k, parent in pairs(cwDoorCmds.parentData) do
				if (parent == door) then
					table.insert(PLUGIN.infoTable, k);
				end;
			end;

			Clockwork.player:Notify(player, "You have set the active parent door to this. The parent has been highlighted orange, and its children blue.");
		end;		
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;

	Clockwork.datastream:Start(player, "doorParentESP", PLUGIN.infoTable);
end;

function TOOL:Reload(tr)
	if (CLIENT) then return false; end;

	local player = self:GetOwner()
	local Clockwork = Clockwork

	PLUGIN.infoTable = PLUGIN.infoTable or {};

	if (!player:IsAdmin()) then 
		return false;
	end;

	if (IsValid(player.cwParentDoor)) then
		player.cwParentDoor = nil;
		PLUGIN.infoTable = {};

		Clockwork.player:Notify(player, "You have cleared your active parent door.");
		Clockwork.datastream:Start(player, "doorParentESP", PLUGIN.infoTable);
	else
		Clockwork.player:Notify(player, "You do not have an active parent door.");
	end;
end;

function TOOL:RightClick(tr)
	if (CLIENT) then return true; end;

	local Clockwork = Clockwork;
	local player = self:GetOwner();

	PLUGIN.infoTable = PLUGIN.infoTable or {};

	if (!player:IsAdmin()) then 
		return false;
	end

	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (cwDoorCmds.parentData[door]) then
			if (cwDoorCmds.parentData[door] == player.cwParentDoor) then
				for k, v in pairs(PLUGIN.infoTable) do
					if (v == door) then
						table.remove(PLUGIN.infoTable, k)
					end;
				end;
			end;

			cwDoorCmds.parentData[door] = nil;
			cwDoorCmds:SaveParentData();
			
			Clockwork.entity:SetDoorParent(door, false);
			Clockwork.player:Notify(player, "You have unparented this door.");

			Clockwork.datastream:Start(player, "doorParentESP", PLUGIN.infoTable);
		else
			Clockwork.player:Notify(player, "This door has no parent!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;	
end

function TOOL.BuildCPanel( CPanel )
	-- HEADER
	CPanel:AddControl("Header", {Text = "Door Parenting", Description	= "Manage Parent Doors" });
	CPanel:AddControl("Header", { 
		Text = "Help", 
		Description	= "Door parenting lets you create a parent door, and once the player purchases that door, they will have access to the door's 'children'. Thus eliminating the need to setownable doors. How To use Door Parenting\n \n1. First Choose a parent door using Left Click. This is usually the 'front' door.\n\n2. Now Left Click any doors within the property.\n\n3. Now You may make the front door 'ownable'. You can also do unownable to set text on the other doors.\n\n*Make sure you unset the parent door once you are done." 
	});
end


local plugin = Clockwork.plugin:FindByID("Door Commands");
	
if (plugin) then
	if (Clockwork.plugin:IsDisabled(plugin.name) or Clockwork.plugin:IsUnloaded(plugin.name)) then
		
	else
		TOOL:Register();
	end	
end