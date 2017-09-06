--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;

Clockwork.flag = Clockwork.kernel:NewLibrary("Flag");
Clockwork.flag.stored = Clockwork.flag.stored or {};

--[[
	@codebase Shared
	@details A function to add a new flag.
	@param {Unknown} Missing description for flag.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for details.
	@returns {Unknown}
--]]
function Clockwork.flag:Add(flag, name, details)
	if (CLIENT and !self.stored[flag]) then
		Clockwork.directory:AddCode("HelpFlags", [[
			<tr>
				<td class="cwTableContent"><b><font color="red">]]..flag..[[</font></b></td>
				<td class="cwTableContent"><i>]]..details..[[</i></td>
			</tr>
		]], nil, flag, function(htmlCode, sortData)
			if (Clockwork.player:HasFlags(Clockwork.Client, sortData)) then
				return Clockwork.kernel:Replace(Clockwork.kernel:Replace(htmlCode, [[<font color="red">]], [[<font color="green">]]), "</font>", "</font>");
			else
				return htmlCode;
			end;
		end);
	end;
	
	self.stored[flag] = {
		name = name,
		details = details
	};
end;

--[[
	@codebase Shared
	@details A function to get a flag.
	@param {Unknown} Missing description for flag.
	@returns {Unknown}
--]]
function Clockwork.flag:Get(flag)
	return self.stored[flag];
end;

--[[
	@codebase Shared
	@details A function to get the stored flags.
	@returns {Unknown}
--]]
function Clockwork.flag:GetStored()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to get a flag's name.
	@param {Unknown} Missing description for flag.
	@param {Unknown} Missing description for default.
	@returns {Unknown}
--]]
function Clockwork.flag:GetName(flag, default)
	if (self.stored[flag]) then
		return self.stored[flag].name;
	else
		return default;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a flag's details.
	@param {Unknown} Missing description for flag.
	@param {Unknown} Missing description for default.
	@returns {Unknown}
--]]
function Clockwork.flag:GetDescription(flag, default)
	if (self.stored[flag]) then
		return self.stored[flag].details;
	else
		return default;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a flag by it's name.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for default.
	@returns {Unknown}
--]]
function Clockwork.flag:GetFlagByName(name, default)
	local lowerName = string.lower(name);
	
	for k, v in pairs(self.stored) do
		if (string.lower(v.name) == lowerName) then
			return k;
		end;
	end;
	
	return default;
end;

Clockwork.flag:Add("C", "Spawn Vehicles", "Access to spawn vehicles.");
Clockwork.flag:Add("r", "Spawn Ragdolls", "Access to spawn ragdolls.");
Clockwork.flag:Add("c", "Spawn Chairs", "Access to spawn chairs.");
Clockwork.flag:Add("e", "Spawn Props", "Access to spawn props.");
Clockwork.flag:Add("p", "Physics Gun", "Access to the physics gun.");
Clockwork.flag:Add("n", "Spawn NPCs", "Access to spawn NPCs.");
Clockwork.flag:Add("t", "Tool Gun", "Access to the tool gun.");
Clockwork.flag:Add("G", "Give Item", "Access to the give items.");