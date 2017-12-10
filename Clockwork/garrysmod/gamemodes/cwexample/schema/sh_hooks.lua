--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

-- Called when the Clockwork shared variables are added.
function Schema:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("ExampleNumber", true);
	playerVars:String("ExampleString");
	globalVars:Number("ExampleGlobalNumber");
end;