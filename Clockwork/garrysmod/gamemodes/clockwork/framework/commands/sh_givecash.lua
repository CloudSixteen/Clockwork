--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local NAME_CASH = Clockwork.option:GetKey("name_cash");

local COMMAND = Clockwork.command:New("Give"..string.gsub(NAME_CASH, "%s", ""));
COMMAND.tip = "Give "..string.lower(NAME_CASH).." to the target character.";
COMMAND.text = "<number "..string.gsub(NAME_CASH, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	local cash = math.floor(tonumber((arguments[1] or 0)));
	
	if (target and target:IsPlayer()) then
		if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then			
			if (cash and cash >= 1) then
				if (Clockwork.player:CanAfford(player, cash)) then
					local playerName = player:Name();
					local targetName = target:Name();
					
					if (!Clockwork.player:DoesRecognise(player, target)) then
						targetName = Clockwork.player:GetUnrecognisedName(target, true);
					end;
					
					if (!Clockwork.player:DoesRecognise(target, player)) then
						playerName = Clockwork.player:GetUnrecognisedName(player, true);
					end;
					
					Clockwork.player:GiveCash(player, -cash);
					Clockwork.player:GiveCash(target, cash);
					
					Clockwork.player:Notify(player, "You have given "..Clockwork.kernel:FormatCash(cash, nil, true).." to "..targetName..".");
					Clockwork.player:Notify(target, "You were given "..Clockwork.kernel:FormatCash(cash, nil, true).." by "..playerName..".");
				else
					local amount = cash - player:GetCash();
					Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(amount, nil, true).."!");
				end;
			else
				Clockwork.player:Notify(player, "This is not a valid amount!");
			end;
		else
			Clockwork.player:Notify(player, "This character is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid character!");
	end;
end;

COMMAND:Register();