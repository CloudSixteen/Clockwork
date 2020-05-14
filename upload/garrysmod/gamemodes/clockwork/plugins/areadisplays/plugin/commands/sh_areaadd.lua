--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AreaAdd");

COMMAND.tip = "Add an area. Classes are 3D, Scrolling or Cinematic. Use %t in the name to show time.";
COMMAND.text = "<string Name> [number Scale] [bool Expires] [string Class]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 3;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local areaPointData = player.cwAreaData;
	local trace = player:GetEyeTraceNoCursor();
	local name = arguments[1];
	
	if (!areaPointData or areaPointData.name != name) then
		player.cwAreaData = {
			name = name,
			class = (arguments[4] != "" and arguments[4] or "Scrolling"),
			scale = tonumber(arguments[2]),
			minimum = trace.HitPos
		};
		
		if (Clockwork.kernel:ToBool(arguments[3])) then
			player.cwAreaData.doesExpire = true;
		end;
		
		Clockwork.player:Notify(player, {"AreaDisplayMinimum"});
		return;
	elseif (!areaPointData.maximum) then
		areaPointData.maximum = trace.HitPos;
		
		if (areaPointData.class == "3D") then
			Clockwork.player:Notify(player, {"AreaDisplayMaximum"});
			return;
		end;
	end;
	
	local data = {
		name = areaPointData.name,
		scale = areaPointData.scale,
		angles = trace.HitNormal:Angle(),
		expires = areaPointData.doesExpire,
		minimum = areaPointData.minimum,
		maximum = areaPointData.maximum,
		position = trace.HitPos + (trace.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	Clockwork.datastream:Start(nil, "AreaAdd", data);
		cwAreaDisplays.storedList[#cwAreaDisplays.storedList + 1] = data;
		cwAreaDisplays:SaveAreaDisplays();
	Clockwork.player:Notify(player, {"AreaDisplayAdded", data.name});
	
	player.cwAreaData = nil;
end;

COMMAND:Register();