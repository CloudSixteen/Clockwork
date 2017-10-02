--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "VictoryConfederacy";
VICTORY.image = "victories/confederacy";
VICTORY.reward = 400;
VICTORY.maximum = 20;
VICTORY.description = "VictoryConfederacyDesc";
VICTORY.unlockTitle = "VictoryConfederacyTitle";

VIC_CONFEDERACY = PhaseFour.victory:Register(VICTORY);