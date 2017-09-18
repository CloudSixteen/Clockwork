--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharSetDesc");

COMMAND.tip = "CmdCharSetDesc";
COMMAND.text = "CmdCharSetDescDesc";
COMMAND.access = "o";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local minimumPhysDesc = Clockwork.config:Get("minimum_physdesc"):Get();
	local text = arguments[2];
	
	if (target) then
		if (text and text != "") then
			if (string.utf8len(text) < minimumPhysDesc) then
				Clockwork.player:Notify(player, {"PhysDescMinimumLength", minimumPhysDesc});
				return;
			end;

			local physDesc = Clockwork.kernel:ModifyPhysDesc(text);
			
			target:SetCharacterData("PhysDesc", physDesc);

			Clockwork.player:Notify(player, {"PlayersPhysDescChangedTo", target:Name(), physDesc});
		else
			Clockwork.dermaRequest:RequestString(player, {"PhysDescChangeTitle"}, {"PhysDescChangeOtherDesc"}, target:GetSharedVar("PhysDesc"), function(result)
				player:RunClockworkCmd(self.name, target:Name(), result);
			end)
		end;
	else
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
	end;
end;

COMMAND:Register();
