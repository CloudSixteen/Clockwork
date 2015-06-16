--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Category		= "Clockwork tools";
TOOL.Name 			= "Door Parenting Manager";
TOOL.UniqueID 		= "doorparent";
TOOL.Desc 			= "Manage parent doors.";
TOOL.HelpText		= "Primary: Set Parent | Reload: Clear Parent | Secondary: Set Child";

TOOL.ClientConVar[ "description" ]		= ""

function TOOL:LeftClick(tr)

	local Ply = self:GetOwner()
	local Clockwork = Clockwork

	if not Ply:IsAdmin() then 
		return false
	end
	local door = Ply:GetEyeTraceNoCursor().Entity;
	if (CLIENT) then return true end

	-- Clear parent, cus people are lazy
		--cwDoorCmds.parentData[door] = nil;
		--cwDoorCmds:SaveParentData();

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
			
			player.cwParentDoor = door;
			door:SetMaterial("pp/copy");
			Clockwork.player:Notify(Ply, "You have set the active parent door to this. This door is highlighted in white for you.");
	else
		Clockwork.player:Notify(Ply, "This is not a valid door!");
	end;
end

function TOOL:Reload(tr)

	local ply = self:GetOwner()
	local Clockwork = Clockwork

	if not ply:IsAdmin() then 
		return false
	end	

	if (tr.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end

	local Ply = self:GetOwner()
	local door = Ply:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		cwDoorCmds.parentData[door] = nil;
		cwDoorCmds:SaveParentData();
		
		Clockwork.entity:SetDoorParent(door, false);
		door:SetMaterial("");
		Clockwork.player:Notify(ply, "You have unparented this door.");

	
	else
		Clockwork.player:Notify(ply, "This is not a valid door!");
	end;
	
end

function TOOL:RightClick(tr)

	local Clockwork = Clockwork
	local Ply = self:GetOwner()
	


	if not Ply:IsAdmin() then 
		return false
	end

	local door = Ply:GetEyeTraceNoCursor().Entity;

	if (CLIENT) then return true end

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
			if (IsValid(player.cwParentDoor)) then
			cwDoorCmds.parentData[door] = player.cwParentDoor;
			cwDoorCmds:SaveParentData();
			
			Clockwork.entity:SetDoorParent(door, player.cwParentDoor);
				Clockwork.player:Notify(Ply, "You have added this as a child to the active parent door.");
			else
				Clockwork.player:Notify(Ply, "You have not selected a valid parent door!");
			end;
		else
			Clockwork.player:Notify(Ply, "This is not a valid door!");
	end;

end

function TOOL.BuildCPanel( CPanel )
	-- HEADER
	CPanel:AddControl( "Header", { Text = "Door Parenting", Description	= "Manage Parent Doors" }  )
	CPanel:AddControl( "Header", { 
									Text = "Help", 
									Description	= "Door parenting lets you create a parent door, and once the player purchases that door, they will have access to the door's 'children'. Thus eliminating the need to setownable doors. How To use Door Parenting\n \n1. First Choose a parent door using Left Click. This is usually the 'front' door.\n\n2. Now Right Click any doors within the property.\n\n3. Now You may make the front door 'ownable'. You can also do unownable to set text on the other doors.\n\n*Make sure you unset the parent door once you are done." 

								})
end

TOOL:Register();