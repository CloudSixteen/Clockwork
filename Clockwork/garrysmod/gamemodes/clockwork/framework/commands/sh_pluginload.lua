--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PluginLoad");
COMMAND.tip = "Attempt to load a plugin.";
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
	
	local unloadTable = Clockwork.command:FindByID("PluginLoad");
	local loadTable = Clockwork.command:FindByID("PluginLoad");
	
	if (!Clockwork.plugin:IsDisabled(plugin.name)) then
		local bSuccess = Clockwork.plugin:SetUnloaded(plugin.name, false);
		local recipients = {};
		
		if (bSuccess) then
			Clockwork.player:NotifyAll(player:Name().." has loaded the "..plugin.name.." plugin for the next restart.");
			
			for k, v in pairs(cwPlayer.GetAll()) do
				if (v:HasInitialized()) then
					if (Clockwork.player:HasFlags(v, loadTable.access)
					or Clockwork.player:HasFlags(v, unloadTable.access)) then
						recipients[#recipients + 1] = v;
					end;
				end;
			end;
			
			if (#recipients > 0) then
				Clockwork.datastream:Start(recipients, "SystemPluginSet", {plugin.name, false});
			end;
		else
			Clockwork.player:Notify(player, "This plugin could not be loaded!");
		end;
	else
		Clockwork.player:Notify(player, "This plugin depends on another plugin!");
	end;
end;

COMMAND:Register();