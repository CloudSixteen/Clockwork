--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.SharedVars = Clockwork.kernel:NewLibrary("SharedVars");
Clockwork.SharedVars.player = Clockwork.SharedVars.player or {vars = {}};
Clockwork.SharedVars.global = Clockwork.SharedVars.global or {vars = {}};

--[[
	@codebase Shared
	@details A function to get the global shared variables.
	@param {Table} The global shared variable object.
--]]
function Clockwork.SharedVars:Global(getVars)
	if (!getVars) then
		return self.global.vars;
	else
		return self.global;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the player shared variables.
	@param {Table} The player shared variable object.
--]]
function Clockwork.SharedVars:Player(getVars)
	if (!getVars) then
		return self.player.vars;
	else
		return self.player;
	end;
end;

--[[
	@codebase Shared
	@details A function to add a player shared variable.
	@param {String} A unique identifier.
	@param {String} The shared variable class.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Add(name, class, playerOnly)
	self.vars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;

--[[
	@codebase Shared
	@details A function to add a player shared string.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:String(name, playerOnly)
	self:Add(name, NWTYPE_STRING, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared entity.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Entity(name, playerOnly)
	self:Add(name, NWTYPE_ENTITY, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared vector.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Vector(name, playerOnly)
	self:Add(name, NWTYPE_VECTOR, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared number.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Number(name, playerOnly)
	self:Add(name, NWTYPE_NUMBER, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared angle.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Angle(name, playerOnly)
	self:Add(name, NWTYPE_ANGLE, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared float.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Float(name, playerOnly)
	self:Add(name, NWTYPE_FLOAT, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a player shared bool.
	@param {String} A unique identifier.
	@param {Bool} Whether or not the shared variable is global.
--]]
function Clockwork.SharedVars.player:Bool(name, playerOnly)
	self:Add(name, NWTYPE_BOOL, playerOnly);
end;

--[[
	@codebase Shared
	@details A function to add a global shared variable.
	@param {String} A unique identifier.
	@param {String} The shared variable class.
--]]
function Clockwork.SharedVars.global:Add(name, class)
	self.vars[name] = {
		class = class,
		name = name
	};
end;

--[[
	@codebase Shared
	@details A function to add a global shared string.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:String(name)
	self:Add(name, NWTYPE_STRING);
end;

--[[
	@codebase Shared
	@details A function to add a global shared entity.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Entity(name)
	self:Add(name, NWTYPE_ENTITY);
end;

--[[
	@codebase Shared
	@details A function to add a global shared vector.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Vector(name)
	self:Add(name, NWTYPE_VECTOR);
end;

--[[
	@codebase Shared
	@details A function to add a global shared number.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Number(name)
	self:Add(name, NWTYPE_NUMBER);
end;

--[[
	@codebase Shared
	@details A function to add a global shared angle.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Angle(name)
	self:Add(name, NWTYPE_ANGLE);
end;

--[[
	@codebase Shared
	@details A function to add a global shared float.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Float(name)
	self:Add(name, NWTYPE_FLOAT);
end;

--[[
	@codebase Shared
	@details A function to add a global shared bool.
	@param {String} A unique identifier.
--]]
function Clockwork.SharedVars.global:Bool(name)
	self:Add(name, NWTYPE_BOOL);
end;