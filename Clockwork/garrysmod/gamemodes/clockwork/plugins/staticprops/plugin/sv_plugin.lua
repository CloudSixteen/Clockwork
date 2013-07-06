--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to load the static props.
function cwStaticProps:LoadStaticProps()
	self.staticProps = Clockwork.kernel:RestoreSchemaData("plugins/props/"..game.GetMap());
	
	for k, v in pairs(self.staticProps) do
		local entity = ents.Create("prop_physics");
			entity:SetMaterial(v.material);
			entity:SetAngles(v.angles);
			entity:SetColor(v.color);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
		Clockwork.entity:MakeSafe(entity, true, true, true);
		
		self.staticProps[k] = entity;
	end;
end;

-- A function to save the static props.
function cwStaticProps:SaveStaticProps()
	local staticProps = {};
	
	if (type(self.staticProps) == "table") then
		for k, v in pairs(self.staticProps) do
			if (IsValid(v)) then
				staticProps[#staticProps + 1] = {
					model = v:GetModel(),
					color = v:GetColor(),
					angles = v:GetAngles(),
					position = v:GetPos(),
					material = v:GetMaterial()
				};
			end;
		end;
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/props/"..game.GetMap(), staticProps);
end;