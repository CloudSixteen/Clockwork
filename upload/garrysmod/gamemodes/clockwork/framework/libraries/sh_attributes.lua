--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tostring = tostring;
local CurTime = CurTime;
local pairs = pairs;
local type = type;
local math = math;

Clockwork.attributes = Clockwork.kernel:NewLibrary("Attributes");

if (SERVER) then
	function Clockwork.attributes:Progress(player, attribute, amount, gradual)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		local attributes = player:GetAttributes();
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (gradual and attributes[attribute]) then
				if (amount > 0) then
					amount = math.max(amount - ((amount / attributeTable.maximum) * attributes[attribute].amount), amount / attributeTable.maximum);
				else
					amount = math.min((amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum);
				end;
			end;
		
			Clockwork.plugin:Call("OnAttributeProgress", player, attribute, amount);
			
			if (attributes[attribute]) then
				if (attributes[attribute].amount == attributeTable.maximum) then
					if (amount > 0) then
						return false, {"YouHaveMaxOfThis", Clockwork.option:GetKey("name_attribute", true)};
					end;
				end;
			else
				attributes[attribute] = {amount = 0, progress = 0};
			end;
			
			local progress = attributes[attribute].progress + amount;
			local remaining = math.max(progress - 100, 0);
			
			if (progress >= 100) then
				attributes[attribute].progress = 0;
				
				player:UpdateAttribute(attribute, 1);
				
				if (remaining > 0) then
					return player:ProgressAttribute(attribute, remaining);
				end;
			elseif (progress < 0) then
				attributes[attribute].progress = 100;
				
				player:UpdateAttribute(attribute, -1);
				
				if (progress < 0) then
					return player:ProgressAttribute(attribute, progress);
				end;
			else
				attributes[attribute].progress = progress;
			end;
			
			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			if (player:HasInitialized()) then
				if (attributes[attribute]) then
					player.cwAttrProgress[attribute] = math.floor(attributes[attribute].progress);
				else
					player.cwAttrProgress[attribute] = 0;
				end;
			end;
		else
			return false, {"NotValidAttribute"};
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to update a player's attribute.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for amount.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Update(player, attribute, amount)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		local attributes = player:GetAttributes();
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (!attributes[attribute]) then
				attributes[attribute] = {amount = 0, progress = 0};
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount and amount > 0) then
					return false, {"YouReachedMaxOfAttribute", Clockwork.option:Translate("name_attribute", true)};
				end;
			end;
			
			attributes[attribute].amount = math.Clamp(attributes[attribute].amount + (amount or 0), 0, attributeTable.maximum);
			
			if (amount and amount > 0) then
				attributes[attribute].progress = 0;
				
				if (player:HasInitialized()) then
					player.cwAttrProgress[attribute] = 0;
					player.cwAttrProgressTime = 0;
				end;
			end;
			
			Clockwork.datastream:Start(player, "AttrUpdate", {
				index = attributeTable.index, amount = attributes[attribute].amount
			});
			
			if (attributes[attribute].amount == 0
			and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			Clockwork.plugin:Call("PlayerAttributeUpdated", player, attributeTable, amount);
			
			return true;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to clear a player's attribute boosts.
		@param {Unknown} Missing description for player.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:ClearBoosts(player)
		Clockwork.datastream:Start(player, "AttrBoostClear", true);
		
		player.cwAttrBoosts = {};
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a boost is active for a player.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for identifier.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for amount.
		@param {Unknown} Missing description for duration.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:IsBoostActive(player, identifier, attribute, amount, duration)
		if (player.cwAttrBoosts) then
			local attributeTable = Clockwork.attribute:FindByID(attribute);
			
			if (attributeTable) then
				attribute = attributeTable.uniqueID;
				
				if (player.cwAttrBoosts[attribute]) then
					local attributeBoost = player.cwAttrBoosts[attribute][identifier];
					
					if (attributeBoost) then
						if (amount and duration) then
							return attributeBoost.amount == amount and attributeBoost.duration == duration;
						elseif (amount) then
							return attributeBoost.amount == amount;
						elseif (duration) then
							return attributeBoost.duration == duration;
						else
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to boost a player's attribute.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for identifier.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for amount.
		@param {Unknown} Missing description for duration.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Boost(player, identifier, attribute, amount, duration)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (amount) then
				if (!identifier) then
					identifier = tostring({});
				end;
				
				if (!player.cwAttrBoosts[attribute]) then
					player.cwAttrBoosts[attribute] = {};
				end;
				
				if (duration) then
					player.cwAttrBoosts[attribute][identifier] = {
						duration = duration,
						endTime = CurTime() + duration,
						default = amount,
						amount = amount,
					};
				else
					player.cwAttrBoosts[attribute][identifier] = {
						amount = amount
					};
				end;
				
				local cwIndex = attributeTable.index;
				local cwAmount = player.cwAttrBoosts[attribute][identifier].amount;
				local cwDuration = player.cwAttrBoosts[attribute][identifier].duration;
				local cwEndTime = player.cwAttrBoosts[attribute][identifier].endTime;
				local cwIdentifier = identifier;
				
				Clockwork.datastream:Start(player, "AttrBoost", {
					index = cwIndex, amount = cwAmount, duration = cwDuration, endTime = cwEndTime, identifier = cwIdentifier
				});
				
				return identifier;
			elseif (identifier) then
				if (self:IsBoostActive(player, identifier, attribute)) then
					if (player.cwAttrBoosts[attribute]) then
						player.cwAttrBoosts[attribute][identifier] = nil;
					end;
					
					Clockwork.datastream:Start(player, "AttrBoostClear", {
						index = attributeTable.index, identifier = identifier
					});
				end;
				
				return true;
			elseif (player.cwAttrBoosts[attribute]) then
				Clockwork.datastream:Start(player, "AttrBoostClear", {
					index = attributeTable.index
				});
				
				player.cwAttrBoosts[attribute] = {};
				
				return true;
			end;
		else
			self:ClearBoosts(player);
			
			return true;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get a player's attribute as a fraction.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for fraction.
		@param {Unknown} Missing description for negative.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Fraction(player, attribute, fraction, negative)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = self:Get(player, attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a player has an attribute.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for boostless.
		@param {Unknown} Missing description for negative.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Get(player, attribute, boostless, negative)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (Clockwork.kernel:HasObjectAccess(player, attributeTable)) then
				local maximum = attributeTable.maximum;
				local default = player:GetAttributes()[attribute];
				local boosts = player.cwAttrBoosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
else
	Clockwork.attributes.stored = Clockwork.attributes.stored or {};
	Clockwork.attributes.boosts = Clockwork.attributes.boosts or {};
	
	--[[
		@codebase Shared
		@details A function to get the attributes panel.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:GetPanel()
		return self.panel;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the local player's attribute as a fraction.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for fraction.
		@param {Unknown} Missing description for negative.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Fraction(attribute, fraction, negative)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = self:Get(attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the local player has an attribute.
		@param {Unknown} Missing description for attribute.
		@param {Unknown} Missing description for boostless.
		@param {Unknown} Missing description for negative.
		@returns {Unknown}
	--]]
	function Clockwork.attributes:Get(attribute, boostless, negative)
		local attributeTable = Clockwork.attribute:FindByID(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (Clockwork.kernel:HasObjectAccess(Clockwork.Client, attributeTable)) then
				local maximum = attributeTable.maximum;
				local default = self.stored[attribute];
				local boosts = self.boosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
	
	Clockwork.datastream:Hook("AttrBoostClear", function(data)
		local index = nil;
		local identifier = nil;
		
		if (type(data) == "table") then
			index = data.index;
			identifier = data.identifier;
		end;
		
		local attributeTable = Clockwork.attribute:FindByID(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (identifier and identifier != "") then
				if (Clockwork.attributes.boosts[attribute]) then
					Clockwork.attributes.boosts[attribute][identifier] = nil;
				end;
			else
				Clockwork.attributes.boosts[attribute] = nil;
			end;
		else
			Clockwork.attributes.boosts = {};
		end;
		
		if (Clockwork.menu:GetOpen()) then
			local panel = Clockwork.attributes:GetPanel();
			
			if (panel and Clockwork.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("AttrBoost", function(data)
		local index = data.index;
		local amount = data.amount;
		local duration = data.duration;
		local endTime = data.endTime;
		local identifier = data.identifier;
		local attributeTable = Clockwork.attribute:FindByID(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (!Clockwork.attributes.boosts[attribute]) then
				Clockwork.attributes.boosts[attribute] = {};
			end;
			
			if (amount and amount == 0) then
				Clockwork.attributes.boosts[attribute][identifier] = nil;
			elseif (duration and duration > 0 and endTime and endTime > 0) then
				Clockwork.attributes.boosts[attribute][identifier] = {
					duration = duration,
					endTime = endTime,
					default = amount,
					amount = amount
				};
			else
				Clockwork.attributes.boosts[attribute][identifier] = {
					default = amount,
					amount = amount
				};
			end;
			
			if (Clockwork.menu:GetOpen()) then
				local panel = Clockwork.attributes:GetPanel();
				
				if (panel and Clockwork.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("AttributeProgress", function(data)
		local index = data.index;
		local amount = data.amount;
		local attributeTable = Clockwork.attribute:FindByID(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (Clockwork.attributes.stored[attribute]) then
				Clockwork.attributes.stored[attribute].progress = amount;
			else
				Clockwork.attributes.stored[attribute] = {amount = 0, progress = amount};
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("AttrUpdate", function(data)
		local index = data.index;
		local amount = data.amount;
		local attributeTable = Clockwork.attribute:FindByID(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (Clockwork.attributes.stored[attribute]) then
				Clockwork.attributes.stored[attribute].amount = amount;
			else
				Clockwork.attributes.stored[attribute] = {amount = amount, progress = 0};
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("AttrClear", function(data)
		Clockwork.attributes.stored = {};
		Clockwork.attributes.boosts = {};
		
		if (Clockwork.menu:GetOpen()) then
			local panel = Clockwork.attributes:GetPanel();
			
			if (panel and Clockwork.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;