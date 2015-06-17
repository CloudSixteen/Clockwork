--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Category		= "Clockwork tools";
TOOL.Name 			= "Door Lock/Unlock";
TOOL.UniqueID 		= "keys";
TOOL.Desc 			= "Lock and Unlock all those doors!";
TOOL.HelpText		= "Primary: Lock | Secondary: Unlock";

function TOOL:LeftClick(tr)
	local Clockwork = Clockwork
	local ply = self:GetOwner()
	
	if not ply:IsAdmin() then 
		return false
	end
	
	if (tr.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end

	local Ply = self:GetOwner()
	local door = Ply:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Lock", "", 0);
	else
		Clockwork.player:Notify(Ply, "This is not a valid door!");
	end;
end

function TOOL:RightClick( tr )
	local Clockwork = Clockwork
	local ply = self:GetOwner()

	if not ply:IsAdmin() then 
		return false
	end
	
	if (tr.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end

	local Ply = self:GetOwner()
	local door = Ply:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Unlock", "", 0);
	else
		Clockwork.player:Notify(Ply, "This is not a valid door!");
	end;
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Text = "Door Lock/Unlock", Description	= "Open or Lock doors." }  )
end

TOOL:Register();