--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DropCash");

COMMAND.tip = "CmdDropCash";
COMMAND.text = "CmdDropCashDesc";
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
				Clockwork.player:GiveCash(player, -cash, {"CashDroppingCash", {"Cash"}});
				
				local entity = Clockwork.entity:CreateCash(player, cash, trace.HitPos);
				
				if (IsValid(entity)) then
					Clockwork.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
				end;
			else
				local amount = cash - player:GetCash();
				
				player:NotifyMissingCash(amount);
			end;
		else
			Clockwork.player:Notify(player, {"CannotDropNameFar", {"Cash"}});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidAmount"});
	end;
end;

COMMAND:Register();