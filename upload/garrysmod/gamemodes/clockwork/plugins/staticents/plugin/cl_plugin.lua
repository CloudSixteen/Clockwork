--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local cwStaticEnts = cwStaticEnts;
local Clockwork = Clockwork;

--Called when the plugin is initialized.
function cwStaticEnts:Initialize()
	CW_CONVAR_STATICESP = Clockwork.kernel:CreateClientConVar("cwStaticESP", 0, true, true);
	
	Clockwork.setting:AddCheckBox("AdminESP", "ShowStaticEntities", "cwStaticESP", "ShowStaticEntitiesDesc", function()
		return Clockwork.player:IsAdmin(Clockwork.Client);
	end);
end;

local classTranslate = {
	["gmod_light"] = "Light",
	["prop_physics"] = "Prop",
	["prop_ragdoll"] = "Ragdoll",
	["gmod_lamp"] = "Lamp"
};

-- Called when the ESP info is needed.
function cwStaticEnts:GetAdminESPInfo(info)
	if (self.staticEnts) then
		if (CW_CONVAR_STATICESP:GetInt() == 1) then
			for k, v in ipairs(self.staticEnts) do
				if (IsValid(v) and v:IsValid()) then
					local class = v:GetClass();
					
					if (class != "worldspawn") then
						local translatedClass = classTranslate[class] or class;

						table.insert(info,{
							position = v:GetPos() + Vector(0, 0, 32),
							color = Color(0, 210, 255, 255),
							text = "[Static "..translatedClass.."]"
						});
					end;
				end;
			end;
		end;
	end;
end;

-- Called to sync up the ESP data from the server.
Clockwork.datastream:Hook("StaticESPSync", function(data)
	cwStaticEnts.staticEnts = data;
end)