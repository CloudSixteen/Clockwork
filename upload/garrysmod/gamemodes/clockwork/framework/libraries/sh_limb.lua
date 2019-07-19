--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Material = Material;
local Color = Color;
local pairs = pairs;
local type = type;
local table = table;
local math = math;

Clockwork.limb = Clockwork.kernel:NewLibrary("Limb");
Clockwork.limb.bones = {
	["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_Pelvis"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
	["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD
};

--[[
	@codebase Shared
	@details A function to convert a bone to a hit group.
	@param {Unknown} Missing description for bone.
	@returns {Unknown}
--]]
function Clockwork.limb:BoneToHitGroup(bone)
	return self.bones[bone] or HITGROUP_CHEST;
end;

--[[
	@codebase Shared
	@details A function to get whether limb damage is active.
	@returns {Unknown}
--]]
function Clockwork.limb:IsActive()
	return Clockwork.config:Get("limb_damage_system"):Get();
end;

if (SERVER) then
	function Clockwork.limb:TakeDamage(player, hitGroup, damage)
		local newDamage = math.ceil(damage);
		local limbData = player:GetCharacterData("LimbData");
		
		if (limbData) then
			limbData[hitGroup] = math.min((limbData[hitGroup] or 0) + newDamage, 100);
			
			Clockwork.datastream:Start(player, "TakeLimbDamage", {
				hitGroup = hitGroup, damage = newDamage
			});
			
			Clockwork.plugin:Call("PlayerLimbTakeDamage", player, hitGroup, newDamage);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to heal a player's body.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for amount.
		@returns {Unknown}
	--]]
	function Clockwork.limb:HealBody(player, amount)
		local limbData = player:GetCharacterData("LimbData");
		
		if (limbData) then
			for k, v in pairs(limbData) do
				self:HealDamage(player, k, amount);
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to heal a player's limb damage.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for amount.
		@returns {Unknown}
	--]]
	function Clockwork.limb:HealDamage(player, hitGroup, amount)
		local newAmount = math.ceil(amount);
		local limbData = player:GetCharacterData("LimbData");
		
		if (limbData and limbData[hitGroup]) then
			limbData[hitGroup] = math.max(limbData[hitGroup] - newAmount, 0);
			
			if (limbData[hitGroup] == 0) then
				limbData[hitGroup] = nil;
			end;
			
			Clockwork.datastream:Start(player, "HealLimbDamage", {
				hitGroup = hitGroup, amount = newAmount
			});
			
			Clockwork.plugin:Call("PlayerLimbDamageHealed", player, hitGroup, newAmount);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to reset a player's limb damage.
		@param {Unknown} Missing description for player.
		@returns {Unknown}
	--]]
	function Clockwork.limb:ResetDamage(player)
		player:SetCharacterData("LimbData", {});
		
		Clockwork.datastream:Start(player, "ResetLimbDamage", true);
		
		Clockwork.plugin:Call("PlayerLimbDamageReset", player);
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether any of a player's limbs are damaged.
		@param {Unknown} Missing description for player.
		@returns {Unknown}
	--]]
	function Clockwork.limb:IsAnyDamaged(player)
		local limbData = player:GetCharacterData("LimbData");
		
		if (limbData and table.Count(limbData) > 0) then
			return true;
		else
			return false;
		end;
	end
	
	--[[
		@codebase Shared
		@details A function to get a player's limb health.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for asFraction.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetHealth(player, hitGroup, asFraction)
		return 100 - self:GetDamage(player, hitGroup, asFraction);
	end;
	
	--[[
		@codebase Shared
		@details A function to get a player's limb damage.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for asFraction.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetDamage(player, hitGroup, asFraction)
		if (!Clockwork.config:Get("limb_damage_system"):Get()) then
			return 0;
		end;
		
		local limbData = player:GetCharacterData("LimbData");
		
		if (type(limbData) == "table") then
			if (limbData and limbData[hitGroup]) then
				if (asFraction) then
					return limbData[hitGroup] / 100;
				else
					return limbData[hitGroup];
				end;
			end;
		end;
		
		return 0;
	end;
else
	Clockwork.limb.bodyTexture = Material("clockwork/limbs/body.png");
	Clockwork.limb.stored = Clockwork.limb.stored or {};
	Clockwork.limb.hitGroups = {
		[HITGROUP_RIGHTARM] = Material("clockwork/limbs/rarm.png"),
		[HITGROUP_RIGHTLEG] = Material("clockwork/limbs/rleg.png"),
		[HITGROUP_LEFTARM] = Material("clockwork/limbs/larm.png"),
		[HITGROUP_LEFTLEG] = Material("clockwork/limbs/lleg.png"),
		[HITGROUP_STOMACH] = Material("clockwork/limbs/stomach.png"),
		[HITGROUP_CHEST] = Material("clockwork/limbs/chest.png"),
		[HITGROUP_HEAD] = Material("clockwork/limbs/head.png")
	};
	Clockwork.limb.names = {
		[HITGROUP_RIGHTARM] = "LimbRightArm",
		[HITGROUP_RIGHTLEG] = "LimbRightLeg",
		[HITGROUP_LEFTARM] = "LimbLeftArm",
		[HITGROUP_LEFTLEG] = "LimbLeftLeg",
		[HITGROUP_STOMACH] = "LimbStomach",
		[HITGROUP_CHEST] = "LimbChest",
		[HITGROUP_HEAD] = "LimbHead"
	};
	
	--[[
		@codebase Shared
		@details A function to get a limb's texture.
		@param {Unknown} Missing description for hitGroup.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetTexture(hitGroup)
		if (hitGroup == "body") then
			return self.bodyTexture;
		else
			return self.hitGroups[hitGroup];
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get a limb's name.
		@param {Unknown} Missing description for hitGroup.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetName(hitGroup)
		return self.names[hitGroup] or "Generic";
	end;
	
	--[[
		@codebase Shared
		@details A function to get a limb color.
		@param {Unknown} Missing description for health.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetColor(health)
		if (health > 75) then
			return Color(166, 243, 76, 255);
		elseif (health > 50) then
			return Color(233, 225, 94, 255);
		elseif (health > 25) then
			return Color(233, 173, 94, 255);
		else
			return Color(222, 57, 57, 255);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the local player's limb health.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for asFraction.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetHealth(hitGroup, asFraction)
		return 100 - self:GetDamage(hitGroup, asFraction);
	end;
	
	--[[
		@codebase Shared
		@details A function to get the local player's limb damage.
		@param {Unknown} Missing description for hitGroup.
		@param {Unknown} Missing description for asFraction.
		@returns {Unknown}
	--]]
	function Clockwork.limb:GetDamage(hitGroup, asFraction)
		if (!Clockwork.config:Get("limb_damage_system"):Get()) then
			return 0;
		end;
		
		if (type(self.stored) == "table") then
			if (self.stored[hitGroup]) then
				if (asFraction) then
					return self.stored[hitGroup] / 100;
				else
					return self.stored[hitGroup];
				end;
			end;
		end;
		
		return 0;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether any of the local player's limbs are damaged.
		@returns {Unknown}
	--]]
	function Clockwork.limb:IsAnyDamaged()
		return table.Count(self.stored) > 0;
	end;
	
	Clockwork.datastream:Hook("ReceiveLimbDamage", function(data)
		Clockwork.limb.stored = data;
		Clockwork.plugin:Call("PlayerLimbDamageReceived");
	end);

	Clockwork.datastream:Hook("ResetLimbDamage", function(data)
		Clockwork.limb.stored = {};
		Clockwork.plugin:Call("PlayerLimbDamageReset");
	end);
	
	Clockwork.datastream:Hook("TakeLimbDamage", function(data)
		local hitGroup = data.hitGroup;
		local damage = data.damage;
		
		Clockwork.limb.stored[hitGroup] = math.min((Clockwork.limb.stored[hitGroup] or 0) + damage, 100);
		Clockwork.plugin:Call("PlayerLimbTakeDamage", hitGroup, damage);
	end);
	
	Clockwork.datastream:Hook("HealLimbDamage", function(data)
		local hitGroup = data.hitGroup;
		local amount = data.amount;
		
		if (Clockwork.limb.stored[hitGroup]) then
			Clockwork.limb.stored[hitGroup] = math.max(Clockwork.limb.stored[hitGroup] - amount, 0);
			
			if (Clockwork.limb.stored[hitGroup] == 100) then
				Clockwork.limb.stored[hitGroup] = nil;
			end;
			
			Clockwork.plugin:Call("PlayerLimbDamageHealed", hitGroup, amount);
		end;
	end);
end;