--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local TOOL = Clockwork.tool:New();

TOOL.Name = "Static Add/Remove";
TOOL.UniqueID = "static";
TOOL.Category = "Clockwork";
TOOL.Desc = "Allows you to save entities permanently on the map.";
TOOL.HelpText = "Primary: Static Entity | Secondary: Unstatic Entity";
TOOL.leftClickCMD = "StaticAdd";
TOOL.rightClickCMD = "StaticRemove";

function TOOL.BuildCPanel(CPanel )
	CPanel:AddControl("Header", {Text = "Static Add/Remove", Description = L("StaticToolAddDesc")});
end

TOOL:Register();