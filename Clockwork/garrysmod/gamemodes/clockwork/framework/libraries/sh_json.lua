--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

Clockwork.json = Clockwork.kernel:NewLibrary("Json");

function Clockwork.json:Encode(tableToEncode)
	return util.TableToJSON(tableToEncode);
end;

function Clockwork.json:Decode(stringToDecode)
	return util.JSONToTable(stringToDecode);
end;