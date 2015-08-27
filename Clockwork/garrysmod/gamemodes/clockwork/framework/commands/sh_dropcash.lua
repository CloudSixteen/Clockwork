--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local NAME_CASH = Clockwork.option:GetKey("name_cash");

local COMMAND = Clockwork.command:New("Drop"..string.gsub(NAME_CASH, "%s", ""));
COMMAND.tip = "Drop "..string.lower(NAME_CASH).." at your target position.";
COMMAND.text = "<number "..string.gsub(NAME_CASH, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local cash = tonumber(arguments[1]);
	
	if (cash and cash > 1) then
		cash = math.floor(cash);
		
		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if (Clockwork.player:CanAfford(player, cash)) then
				Clockwork.player:GiveCash(player, -cash, "Dropping "..Clockwork.option:GetKey("name_cash"));
				
				local entity = Clockwork.entity:CreateCash(player, cash, trace.HitPos);
				
				if (IsValid(entity)) then
					Clockwork.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
				end;
			else
				local amount = cash - player:GetCash();
				Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(amount, nil, true).."!");
			end;
		else
			Clockwork.player:Notify(player, "You cannot drop "..string.lower(NAME_CASH).." that far away!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid amount!");
	end;
end;

COMMAND:Register();