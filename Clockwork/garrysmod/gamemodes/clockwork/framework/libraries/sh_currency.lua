--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local string = string;

Clockwork.currency = Clockwork.kernel:NewLibrary("Currency");
Clockwork.currency.stored = Clockwork.currency.stored or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

function CLASS_TABLE:__call(parameter, failSafe)
	return self:Query(parameter, failSafe);
end;

function CLASS_TABLE:Create(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name;
		object.data = {};
	return object;
end;

function CLASS_TABLE:Query(key, failSafe)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return failSafe;
	end;
end;

function CLASS_TABLE:SetData(key, value)
	if (self.data) then
		self.data[key] = value;
	end;
	
	Clockwork.currency.stored[key] = self;
end;

function CLASS_TABLE:GetModel()
	return self("model", "models/props_c17/briefcase001a.mdl");
end;

function CLASS_TABLE:SetModel(model)
	self:SetData("model", model);
end;

function CLASS_TABLE:GetDefault()
	return self("default", 0);
end;

function CLASS_TABLE:SetDefault(amount)
	self:SetData("default", amount);
end;

--[[
	@codebase Shared
	@details A function to add a currency.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for model.
	@param {Unknown} Missing description for defaultValue.
	@returns {Unknown}
--]]
function Clockwork.currency:Add(name, model, defaultValue)
	local key = string.lower(string.gsub(name, "%s", "_"));

	if (!self.stored[key]) then
		local currencyObject = CLASS_TABLE:Create(name);
		
		if (model != nil) then
			currencyObject:SetModel(model);
		end;
		
		if (defaultValue != 0) then
			currencyObject:SetDefault(defaultValue);
		end;
		
		if (currencyObject.data) then
			self.stored[key] = currencyObject;
		end;
		
		return currencyObject;
	end;
end;

--[[
	@codebase Shared
	@details A function to get a currency table.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.currency:Get(name)
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		local key = string.lower(string.gsub(name, "%s", "_"));

		if (!self.stored[key]) then
			return self:Add(name);
		else
			return self.stored[key];
		end;
	else
		return {};
	end;
end;

--[[
	@codebase Shared
	@details A function to get all of the stored currencies.
	@returns {Unknown}
--]]
function Clockwork.currency:GetAll()
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		return self.stored;
	else
		return {};
	end;
end;