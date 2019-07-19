--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

-- This is where you might add any functions for your schema.
function Schema:MakeAnnouncement(text)
	Clockwork.player:NotifyAll(text);
end;

--[[-------------------------------------------------------------------------
This function makes a colored text announcement using a color table, in example, you would put:
Schema:NotifyColor(player, Color(255,255,255,255), "I really like foobars!")
---------------------------------------------------------------------------]]
function Schema:NotifyColor(player, color, text)
	Clockwork.chatBox:SendColored(player, color, text);
end;

--[[-------------------------------------------------------------------------
This is where you would define a specific sector of factions being apart of something.
For example, you would do Schema:IsExampleFaction(player:GetFaction()) and if they were apart of FACTION_EXAMPLE it would return true.
This has little use for one faction, but if you want to group up multiple factions without using a table/array this would be a good way.
This is used in:
HL2RP
---------------------------------------------------------------------------]]--
function Schema:IsExampleFaction(faction)
	return faction == FACTION_EXAMPLE;
end;


--[[-------------------------------------------------------------------------
This is used to determine if a player is apart of the 'IsExampleFaction' group or not.
The use of this is a bit redundant.
However it does illustrate an important thing called 'self'.
'self' can be used in a function that refers to something similar, in our case, 'self' means 'Schema'
This is because the function begins with 'Schema:'
This is used in:
HL2RP
---------------------------------------------------------------------------]]--
function Schema:IsExamplePlayer(player)
	if self:IsExampleFaction(player:GetFaction()) then
		return true;
	else
		return false;
	end;
end;

--[[-------------------------------------------------------------------------
This is used to make a player 'cool', in reality it demonstrates the use of character data.
Character data can be used to write data to characters either permanently or temporarily.
This function has two arguments, 'player' and 'level', it also only allows
the use of numbers in it's input.
---------------------------------------------------------------------------]]--
function Schema:MakePlayerCool(player, level)
	if type(level) != "number" then
		player:SetCharacterData("Cool", level);
	end;
end;


--[[-------------------------------------------------------------------------
This function takes the above data assigned and repeats it to everyone.
If they do not have 'Cool' in their data or it's 'equal to' or 'below' 0
It will tell everyone that they're not cool.
If they do have Cool in their Character Data and it's above 0, it'll tell everyone!
---------------------------------------------------------------------------]]--
function Schema:IsPlayerCool(player)
	if (!player:GetCharacterData("Cool") or player:GetCharacterData("Cool") <= 0) then
		self:MakeAnnouncement(player:Name() .. " is not cool!");
	else
		self:MakeAnnouncement(player:Name() .. " is cool! His cool level is " .. player:GetCharacterData("Cool"));
	end;
end;


--[[-------------------------------------------------------------------------
This function is used to determine if someone has a specific item, this has no practical
use if you're just using it one time, but if you're deeply integrating a specific item
in your Schema, like a PDA for a gamemode, it can be pretty useful, as always, it can also
be supplemented by and statements.
---------------------------------------------------------------------------]]--
function Schema:HasExampleItem(player)
	if player:HasItemByID("example") then
	return true;
else
	return false;
	end;
end;
