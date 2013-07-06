--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PluginUnload");
COMMAND.tip = "Attempt to unload a plugin.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local plugin = Clockwork.plugin:FindByID(arguments[1]);
	
	if (!plugin) then
		Clockwork.player:Notify(player, "This plugin is not valid!");
		return;
	end;
	
	if (!Clockwork.plugin:IsDisabled(plugin.name)) then
		local bSuccess = Clockwork.plugin:SetUnloaded(plugin.name, true);
		local recipients = {};
		
		if (bSuccess) then
			Clockwork.player:NotifyAll(player:Name().." has unloaded the "..plugin.name.." plugin for the next restart.");
			
			for k, v in pairs(cwPlayer.GetAll()) do
				if (v:HasInitialized()) then
					if (Clockwork.player:HasFlags(v, loadTable.access)
					or Clockwork.player:HasFlags(v, unloadTable.access)) then
						recipients[#recipients + 1] = v;
					end;
				end;
			end;
			
			if (#recipients > 0) then
				Clockwork.datastream:Start(recipients, "AdminMntSet", {plugin.name, true});
			end;
		else
			Clockwork.player:Notify(player, "This plugin could not be unloaded!");
		end;
	else
		Clockwork.player:Notify(player, "This plugin depends on another plugin!");
	end;
end;

COMMAND:Register();