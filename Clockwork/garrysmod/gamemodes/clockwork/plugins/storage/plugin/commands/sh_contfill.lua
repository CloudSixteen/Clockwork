--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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
					if (!trace.Entity.cwInventory) then
						cwStorage.storage[trace.Entity] = trace.Entity;
						
						trace.Entity.cwInventory = {};
					end;
					
					local containerWeight = cwStorage.containerList[model][1] / (6 - scale);
					local weight = Clockwork.inventory:CalculateWeight(trace.Entity.cwInventory);
					
					if (!arguments[2] or cwStorage:CategoryExists(arguments[2])) then
						while (weight < containerWeight) do
							local randomItem = cwStorage:GetRandomItem(arguments[2]);
							
							if (randomItem) then
								Clockwork.inventory:AddInstance(
									trace.Entity.cwInventory, Clockwork.item:CreateInstance(randomItem[1])
								);
								
								weight = weight + randomItem[2];
							end;
						end;
					
						Clockwork.player:Notify(player, {"ContainerFilledWithRandomItems"});
						return;
					else
						Clockwork.player:Notify(player, {"ContainerCategoryNotExist"}); 
						return;
					end
				end;

				Clockwork.player:Notify(player, {"ContainerNotValid"});
			else
				Clockwork.player:Notify(player, {"ContainerNotValid"});
			end;
		else
			Clockwork.player:Notify(player, {"ContainerNotValid"});
		end;
	else
		Clockwork.player:Notify(player, {"ContainerNotValidScale"});
	end;
end;

COMMAND:Register();