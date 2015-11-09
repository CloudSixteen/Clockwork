--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticAreaAdd");
COMMAND.tip = "Add static ents in a certain radius around yourself.";
COMMAND.text = "<number Radius> [bool PropsOnly]";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local radius = tonumber(arguments[1]);

	if (radius) then
		local radiusEnts = ents.FindInSphere(player:GetPos(), radius);
		local staticCount = 0;
		local propsOnly = Clockwork.kernel:ToBool(arguments[2]);

		for k, entity in pairs(radiusEnts) do
			local class = Clockwork.plugin:Call("CanEntityStatic", target);
			local canStatic = true;
			
			if (!propsOnly and class != false or propsOnly and class == "props_physics") then
				for k2, v2 in pairs(cwStaticEnts.staticEnts) do
					if (entity == v2) then
						canStatic = false;
					end;

					if (canStatic) then
						table.insert(cwStaticEnts.staticEnts, entity);
						staticCount = staticCount + 1;
					end;
				end;
			end;
		end;

		if (staticCount > 0) then
			cwStaticEnts:SaveStaticEnts();
		end;

		Clockwork.player:Notify(player, "You have staticed "..staticCount.." entities within "..radius.." units around you.");
	else
		Clockwork.player:Notify(player, "You must enter a number for the radius!");
	end;
end;

COMMAND:Register();