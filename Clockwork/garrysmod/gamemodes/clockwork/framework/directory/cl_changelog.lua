--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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

AddVersion("0.88", [[
	A|Clockwork now checks for Schema function overrides and warns against it.
	F|Fixed the Outline library to use the new GMod halo effect and updated any calls to it.
]]);

Clockwork.directory:AddCategoryMatch("Changelog", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAADMSURBVDjLY/z//z8DJYCJgUKAYUBE+440IHYh1gAWLGIzgXgPFINBVFTU/1+/fjH8/v2bAUSD8N69exlBcozIYQCyHUgZAzGIdl1R6bGHVBeEAjW5Qr1QDnOFj4/Pf5jNMHzmzBlUFwA1hQIpkMZ7QKxErCtYoJqVoDaGATXcg/JBBnQAsYmdnR2GC27duoUZBuQAeBhERkZi2IKOYbEAop8/f05lF3h7e/8nZDsy/vz5M5VdYGtr+//nz59Y/QvDf/78QcbUcQHFuREAOJ3Rs6CmnfsAAAAASUVORK5CYII=");
Clockwork.directory:AddCategoryPage("Changelog", nil, CHANGELOG);
Clockwork.directory:SetCategoryTip("Changelog", "Check out the latest revisions to the Clockwork framework.");
Clockwork.directory:AddCategory("Changelog", "Clockwork");