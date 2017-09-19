--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("SetCash");

COMMAND.tip = "CmdSetCash";
COMMAND.text = "CmdSetCashDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	local cash = math.floor(tonumber((arguments[2] or 0)));
	
	if (target) then
		if (cash and cash >= 1) then
			local playerName = player:Name();
			local targetName = target:Name();
			local giveCash = cash - target:GetCash();
			
			Clockwork.player:GiveCash(target, giveCash);
			
			Clockwork.player:Notify(player, {"YouSetPlayersCash", targetName, {"Cash"}, Clockwork.kernel:FormatCash(cash, nil, true)});
			Clockwork.player:Notify(target, {"YourCashSetBy", {"Cash"}, Clockwork.kernel:FormatCash(cash, nil, true), playerName});
		else
			Clockwork.player:Notify(player, {"NotValidAmount"});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();