--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("TextAdd");

COMMAND.tip = "Add some text to a surface.";
COMMAND.text = "<markup Text> [number Scale]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	local fScale = tonumber(arguments[2]);
	
	if (fScale) then
		fScale = fScale * 0.25;
	end;
	
	local data = {
		text = arguments[1],
		scale = fScale,
		angles = traceLine.HitNormal:Angle(),
		position = traceLine.HitPos + (traceLine.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	Clockwork.datastream:Start(nil, "SurfaceTextAdd", data);
	
	cwSurfaceTexts.storedList[#cwSurfaceTexts.storedList + 1] = data;
	cwSurfaceTexts:SaveSurfaceTexts();
	
	Clockwork.player:Notify(player, {"YouAddedSurfaceText"});
end;

COMMAND:Register();