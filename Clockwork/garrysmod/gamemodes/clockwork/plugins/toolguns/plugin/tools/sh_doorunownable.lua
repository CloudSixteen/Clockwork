--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Category		= "Clockwork tools";
TOOL.Name 			= "Door Set Unownable";
TOOL.UniqueID 		= "doorsetunownable";
TOOL.Desc 			= "Disable owning of door but with text.";
TOOL.HelpText		= "Primary: Set Door Unownable";

TOOL.ClientConVar[ "description" ]	= "";
TOOL.ClientConVar[ "doorname" ]		= "";

function TOOL:LeftClick(tr)
	if (CLIENT) then return true end

	local Clockwork = Clockwork
	local ply = self:GetOwner()
	local doorname = self:GetClientInfo( "doorname" )
	local description = self:GetClientInfo( "description" )
	local door = ply:GetEyeTraceNoCursor().Entity;
	
	if (!ply:IsAdmin()) then 
		return false;
	end;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = description or self:GetClientInfo( "description" ),
			name = doorname or self:GetClientInfo( "doorname" )
		};
		
		Clockwork.entity:SetDoorName(data.entity, data.name);
		Clockwork.entity:SetDoorText(data.entity, data.text);
		Clockwork.entity:SetDoorUnownable(data.entity, true);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(ply, "You have set an unownable door.");
	else
		Clockwork.player:Notify(ply, "This is not a valid door!");
	end;
end;



function TOOL.BuildCPanel( CPanel )
	-- HEADER
	CPanel:AddControl( "Header", { Text = "Door Set Unownable", Description	= "Disable owning of door but with text." }  )
									
	local CVars = {"doorunownable_description" }
									 
	CPanel:AddControl( "TextBox", { 
		Label = "Door Description",
		MaxLenth = "20",
		Command = "doorsetunownable_description"
	})

	CPanel:AddControl( "TextBox", { 
		Label = "Door Name",
		MaxLenth = "20",
		Command = "doorsetunownable_doorname"
	})
end;

TOOL:Register();