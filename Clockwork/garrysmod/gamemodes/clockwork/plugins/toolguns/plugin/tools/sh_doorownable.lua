--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Category		= "Clockwork tools";
TOOL.Name 			= "Door Set Ownable";
TOOL.UniqueID 		= "doorsetownable";
TOOL.Desc 			= "Add purchasable doors.";
TOOL.HelpText		= "Primary: Set Door Ownable";

TOOL.ClientConVar[ "description" ]		= ""

function TOOL:LeftClick(tr)

	local Clockwork = Clockwork
	
	local description = self:GetClientInfo( "description" )

	if (tr.Entity:GetClass() == "player") then return false end

	if (CLIENT) then return true end

	local ply = self:GetOwner()

	local door = ply:GetEyeTraceNoCursor().Entity;


	if not ply:IsAdmin() then 
		return false
	end

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = description or self:GetClientInfo( "description" )
		};
		
		Clockwork.entity:SetDoorUnownable(data.entity, false);
		Clockwork.entity:SetDoorText(data.entity, false);
		Clockwork.entity:SetDoorName(data.entity, data.name);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(ply, "You have set an ownable door.");
	else
		Clockwork.player:Notify(ply, "This is not a valid door!");
	end;

end



function TOOL.BuildCPanel( CPanel )
	-- HEADER
	CPanel:AddControl( "Header", { Text = "Door Set Ownable", Description	= "Create Ownable Doors" }  )
	
									
	local CVars = {"doorsetownable_description" }

									 
	CPanel:AddControl( "TextBox", { Label = "Door Text",
									 MaxLenth = "20",
									 Command = "doorsetownable_description" } )
end

TOOL:Register();