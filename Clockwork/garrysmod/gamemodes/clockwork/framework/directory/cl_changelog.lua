--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;

local CHANGELOG = "";
local REMOVED = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAADGSURBVDjLY/j//z8DJZhh1ADsBhyJkKs44Mv3cI8Ty7+drsyPgLiCaAOOhMuVXyy2+Pl9a+//f9d2/P+6ouj/6WzdP7ucWXKJMmCnC/Pdb0DN/yf5/v9fLvj/f5vi/9ddDv+B4veIMgDk7H9n1/1HBu/rJf6DxIlzgSvz4y9zk///B2r6Ucbw/x0QP8xg/g8Uf0KUAYfDpRpOpqj+flau+P9VJev/uymM//f6svzZ4cpcRXwshMtWAG28D42Fx7g0jyZlCAYAAc7hFvdEsKgAAAAASUVORK5CYII=";
local FIXED = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAACzSURBVDjL7dI9C0FxHMXx8zruG2SSUjKgXwklw2WxSB4yGC2iDFyDpwj1T1LK00jq+hduOt6AwU02w1k/deoLkvhm+APvAVRpoEpBxVEoaoX8SZDbG24AkcWTrZ3D+ubByPBCmEv5HCjfVXPrMNq/0WdpZuaaSI3U50DhomrrG/2WpqdzZWJiE7G2CyB3lPDgTHOmGR/bDHUPRLDk4kJ2ZSA9FSR7CtJQCOQF3rjxL/FHwAu8X+2ABKJChQAAAABJRU5ErkJggg==";
local ADDED = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAC5SURBVDjLY/j//z8DJZhh1ADsBjjsspIC4gb77ZZX7TdbXLVda9Zgs8xEihQDGmZfm/7/0KOD/3ff3/V/6plJ/y3mGjYQbYD9NsurBx4e+D/10tT/nWc6/i+5sui/+RS9q0QbYLfB/OrWO1v+d5/p+t96qvn/3Auz/pt0aRNvgPVyk4appyf+X3xl4f/ZF2b+n3Co579+mSrxXrCcZyhlMV2/wbRP56pRq+ZV3SLlBq1EOanRlEgjAwAXIuIDq5qm/AAAAABJRU5ErkJggg==";
local TIP = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAACtSURBVDjL7dIxCwFxHMbxX8mmDAa67tV4D7wDZTolMlzpn+QoouNlyMZ0Vyc5g1v/JQPdYlJGmb5egbpLNsOzfuqprwDyzeQPfABc08A1FdOSZlLQODlFL2OkARThGGIfLhsIujxtUcmBWVETe3AcQNCGaMG9KTo5MMprTkvYdsCzYD/kWk8D9LMK34ZoDqED6waHaooLL1uMR0vUzRJ9roneVUStymL8S/wR8AaM7e7IrixORwAAAABJRU5ErkJggg==";

local function AddVersion(version, changeLog)
	local explodedChanges = string.Explode("\n", changeLog);
	local tChanges = {};
	
	for k, v in pairs(explodedChanges) do
		local tValue = string.Explode("|", (string.gsub(v, "\t", "")));
		
		if (tValue[1] and tValue[2]) then
			if (tValue[1] == "A") then
				tValue[1] = ADDED;
			elseif (tValue[1] == "F") then
				tValue[1] = FIXED;
			elseif (tValue[1] == "R") then
				tValue[1] = REMOVED;
			elseif (tValue[1] == "T") then
				tValue[1] = TIP;
			end;
			
			tChanges[#tChanges + 1] = tValue;
		end;
	end;
	
	CHANGELOG = CHANGELOG..[[
		<div class="cwTitleSeperator">]]..version..[[</div>
	]];
	
	for k, v in pairs(tChanges) do
		local text = v[2];
		local icon = v[1];
		
		CHANGELOG = CHANGELOG..[[
			<div class="cwContentText">
				<img src="]]..icon..[[" style="vertical-align:text-bottom;"/>
				]]..text..[[
			</div>
		]];
	end;
end;

AddVersion("0.92", [[
	A|Added support for intro sound configuration and reduced line count.
	A|Now using PON + made datastreams faster.
	A|Added new ESP system for extra information on players and entities.
	A|Added Clockwork.player:AddCharacterData and Clockwork.player:AddPlayerData.
	A|Added Linux binaries. This is a big deal. You can now run Clockwork on your Linux server.
	A|Added a config option to disable black intro bars.
	A|Added two config options to use different types of server rates.
	A|Added console versions of common admin commands (such as "setgroup", "demote" etc). Use "cwc COMMAND ARGUMENTS" in console.
	A|Added a way to allow icons to be set for notifications.
	A|Added CharSetFlags and CharCheckFlags commands, as well as a SetFlags function.
	A|Added the ending to the vocoder speech for MPF and Overwatch (::>)
	A|Added a config option to disable/enable alt jogging.
	A|Clockwork will try to use SQLLite if the default SQL file is not touched.
	A|Clockwork will try to use MySQLOO if it is installed and loaded.
	A|Added MeC, MeL, ItC and ItL commands to account for distances when using the Me and It commands.
	A|Added a config option to the stamina plugin which allows you to change the stamina regeneration rate.
	A|Added a built-in crafting / recipe system.
	F|Fixed bug where weapons didn't raise correctly.
	F|Changed Clockwork intro music to old OpenAura one.
	F|Fixed the config option for crosshairs.
	F|Changed log files so they are named in order of year-month-day so they sort correctly.	
	F|Fixed the file.Exists function.
	F|Fixed the CharSetDesc command.	
	F|Fixed issue preventing salesmen and storage from working.
]]);


AddVersion("0.91", [[
	A|Added GiveCash from the player library to the player meta table.
	A|Added \n to a few ErrorNoHalt calls that were missing it.
	A|Extended item options capabilities.
	A|Added cl_imagebutton.lua
	A|Added material computation to DrawScreenBlurs().
	F|Headbob has been clamped from 0 to 1.
	F|Changed schema hook override warning to be clearer.
]]);

AddVersion("0.90", [[
	A|A new config option (observer_reset) was added to prevent a player's position being reset when exiting observer mode.
	A|Added the Derma Request library which can be used to prompt a client.		
	A|Added two functions to give and take a table of item instances from a player object.
	A|Added sh_charsetdesc.lua for operators to set a character's physical description.
	A|Added itemTable:EntityHandleMenuOption for cw_item entities (allows more code to be moved into item files).
	A|Added a 'space' system similiar to the 'weight' system, miscellaneous fixes and changes.
	A|Added a check to inventory:AddInstance to prevent erroring.
	A|A player's targetname is now set to their faction (for use with mapping.)
	A|Added size multiplier options to the chatbox to allow different sized messages. Whispering and yelling uses this feature.
	A|Added the Clockwork.fonts library for ease in creation and grabbing of different sized fonts that use the same settings.
	F|Optimized client-side vignette drawing. Only performing raycast once every second.
	F|Loading and unloading of plugins is now fully functional.
	F|Progress bars will now use ScissorRect for an improved graphical aesthetic.
	F|Change /Roll to allow the player to specify the range of values.
	F|Stamina will no longer deplete if you are not on the ground.
	F|Fixed a bug where hook errors would not be reported correctly.
	F|Fixed the PluginLoad/PluginUnload commands.		
]]);

AddVersion("0.88", [[
	A|Clockwork now checks for Schema function overrides and warns against it.
	F|Fixed the Outline library to use the new GMod halo effect and updated any calls to it.
]]);

Clockwork.directory:AddCategoryMatch("Changelog", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAADMSURBVDjLY/z//z8DJYCJgUKAYUBE+440IHYh1gAWLGIzgXgPFINBVFTU/1+/fjH8/v2bAUSD8N69exlBcozIYQCyHUgZAzGIdl1R6bGHVBeEAjW5Qr1QDnOFj4/Pf5jNMHzmzBlUFwA1hQIpkMZ7QKxErCtYoJqVoDaGATXcg/JBBnQAsYmdnR2GC27duoUZBuQAeBhERkZi2IKOYbEAop8/f05lF3h7e/8nZDsy/vz5M5VdYGtr+//nz59Y/QvDf/78QcbUcQHFuREAOJ3Rs6CmnfsAAAAASUVORK5CYII=");
Clockwork.directory:AddCategoryPage("Changelog", nil, CHANGELOG);
Clockwork.directory:SetCategoryTip("Changelog", "Check out the latest revisions to the Clockwork framework.");
Clockwork.directory:AddCategory("Changelog", "Clockwork");