--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "VictoryDrunkard";
VICTORY.image = "victories/drunkard";
VICTORY.reward = 80;
VICTORY.maximum = 10;
VICTORY.description = "VictoryDrunkardDesc";
VICTORY.unlockTitle = "VictoryDrunkardTitle";

VIC_DRUNKARD = PhaseFour.victory:Register(VICTORY);