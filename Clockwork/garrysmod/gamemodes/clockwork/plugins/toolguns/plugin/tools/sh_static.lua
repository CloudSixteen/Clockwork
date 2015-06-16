--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Category		= "Clockwork tools";
TOOL.Name 			= "Static Prop/Entities";
TOOL.UniqueID 		= "static";
TOOL.Desc 			= "Allows you to save entities permanently on the map.";
TOOL.HelpText		= "Primary: Static Entity | Secondary: Unstatic";

function TOOL:LeftClick(tr)
	local Clockwork = Clockwork
	local player = self:GetOwner()
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if not ply:IsAdmin() then 
		return false
	end

	if (IsValid(target)) then
		if (CLIENT) then return true end
		local class = cwStaticEnts:CanStatic(target)
		if (class == "nope") then
			Clockwork.player:Notify(player, "This entity causes issues when it is static!");
		elseif (class != false) then
			for k, v in pairs(cwStaticEnts.staticEnts) do
				if (target == v) then
					Clockwork.player:Notify(player, "This entity is already static!");				
					return;
				end;
			end;
				
			table.insert(cwStaticEnts.staticEnts, target);
			cwStaticEnts:SaveStaticEnts();

			Clockwork.player:Notify(player, "You have added a static entity.");		
		else
			Clockwork.player:Notify(player, "You cannot static this entity!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end


function TOOL:RightClick( tr )
	local Clockwork = Clockwork
	local player = self:GetOwner()
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if not ply:IsAdmin() then 
		return false
	end
	
	if (IsValid(target)) then
		if (CLIENT) then return true end
		if (cwStaticEnts:CanStatic(target) != false) then
			for k, v in pairs(cwStaticEnts.staticEnts) do
				if (target == v) then
					table.remove(cwStaticEnts.staticEnts, k);
					cwStaticEnts:SaveStaticEnts();
					
					Clockwork.player:Notify(player, "You have removed a static entity.");

					return;
				end;
			end;

			Clockwork.player:Notify(player, "This entity is not static.");
		else
			Clockwork.player:Notify(player, "This entity is not able to be a static entity!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end



function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Text = "Static Entites", Description	= "Allows you to save entities permanently on the map." }  )
	CPanel:AddControl( "Header", { Text = "", Description	= "Updated static plugin by NightAngel." }  )
end

TOOL:Register();