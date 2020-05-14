--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when a player starts typing.
concommand.Add("cwTypingStart", function(player, command, arguments)
	if (player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER)) then
		if (arguments and arguments[1]) then
			hook.Call("PlayerStartTypingDisplay", Clockwork, player, arguments[1]);
			
			if (arguments[1] == "w") then
				player:SetSharedVar("Typing", TYPING_WHISPER);
			elseif (arguments[1] == "p") then
				player:SetSharedVar("Typing", TYPING_PERFORM);
			elseif (arguments[1] == "n") then
				player:SetSharedVar("Typing", TYPING_NORMAL);
			elseif (arguments[1] == "r") then
				player:SetSharedVar("Typing", TYPING_RADIO);
			elseif (arguments[1] == "y") then
				player:SetSharedVar("Typing", TYPING_YELL);
			elseif (arguments[1] == "o") then
				player:SetSharedVar("Typing", TYPING_OOC);
			end;
		end;
	end;
end);

-- Called when a player finishes typing.
concommand.Add("cwTypingFinish", function(player, command, arguments)
	if (IsValid(player)) then
		if (arguments and arguments[1] and arguments[1] == "1") then
			Clockwork.plugin:Call("PlayerFinishTypingDisplay", player, true);
		else
			Clockwork.plugin:Call("PlayerFinishTypingDisplay", player);
		end;
		
		player:SetSharedVar("Typing", 0);
	end;
end);