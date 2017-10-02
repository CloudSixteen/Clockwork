--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "VictoryBlockBusta";
VICTORY.image = "victories/blockbusta";
VICTORY.reward = 160;
VICTORY.maximum = 10;
VICTORY.description = "VictoryBlockBustaDesc";
VICTORY.unlockTitle = "VictoryBlockBustaTitle";

VIC_BLOCKBUSTER = PhaseFour.victory:Register(VICTORY);