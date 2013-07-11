--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("ContFill");
COMMAND.tip = "Fill a container with random items.";
COMMAND.text = "<number Density: 1-5> [string Category]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local scale = tonumber(arguments[1]);
	
	if (scale) then
		scale = math.Clamp(math.Round(scale), 1, 5);
		
		if (IsValid(trace.Entity)) then
			if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
				local model = string.lower(trace.Entity:GetModel());
				
				if (cwStorage.containerList[model]) then
					if (!trace.Entity.inventory) then
						cwStorage.storage[trace.Entity] = trace.Entity;
						
						trace.Entity.inventory = {};
					end;
					
					local containerWeight = cwStorage.containerList[model][1] / (6 - scale);
					local weight = Clockwork.inventory:CalculateWeight(trace.Entity.inventory);
					
					if (!arguments[2] or cwStorage:CategoryExists(arguments[2])) then
						while (weight < containerWeight) do
							local randomItem = cwStorage:GetRandomItem(arguments[2]);
							
							if (randomItem) then
								Clockwork.inventory:AddInstance(
									trace.Entity.inventory, Clockwork.item:CreateInstance(randomItem[1])
								);
								
								weight = weight + randomItem[2];
							end;
						end;
					
						Clockwork.player:Notify(player, "This container has been filled with random items.");
						return;
					else
						Clockwork.player:Notify(player, "That category doesn't exist!"); 
						return;
					end
				end;

				Clockwork.player:Notify(player, "This is not a valid container!");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid scale!");
	end;
end;

COMMAND:Register();