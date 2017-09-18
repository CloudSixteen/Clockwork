--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PluginUnload");

COMMAND.tip = "CmdPluginUnload";
COMMAND.text = "CmdPluginUnloadDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local plugin = Clockwork.plugin:FindByID(arguments[1]);
	
	if (!plugin) then
		Clockwork.player:Notify(player, {"PluginNotValid"});
		return;
	end;
	
	local unloadTable = Clockwork.command:FindByID("PluginLoad");
	local loadTable = Clockwork.command:FindByID("PluginLoad");
	
	if (!Clockwork.plugin:IsDisabled(plugin.name)) then
		local wasSuccess = Clockwork.plugin:SetUnloaded(plugin.name, true);
		local recipients = {};
		
		if (wasSuccess) then
			Clockwork.player:NotifyAll({"PlayerUnloadedPlugin", player:Name(), plugin.name});
			
			for k, v in pairs(cwPlayer.GetAll()) do
				if (v:HasInitialized()) then
					if (Clockwork.player:HasFlags(v, loadTable.access)
					or Clockwork.player:HasFlags(v, unloadTable.access)) then
						recipients[#recipients + 1] = v;
					end;
				end;
			end;
			
			if (#recipients > 0) then
				Clockwork.datastream:Start(recipients, "SystemPluginSet", {plugin.name, true});
			end;
		else
			Clockwork.player:Notify(player, {"PluginCouldNotBeUnloaded"});
		end;
	else
		Clockwork.player:Notify(player, {"PluginDependsOnAnother"});
	end;
end;

COMMAND:Register();