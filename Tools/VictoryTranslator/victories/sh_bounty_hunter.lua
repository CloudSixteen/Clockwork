--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "VictoryBountyHunter";
VICTORY.image = "victories/bountyhunter";
VICTORY.reward = 240;
VICTORY.maximum = 10;
VICTORY.description = "VictoryBountyHunterDesc";
VICTORY.unlockTitle = "VictoryBountyHunterTitle";

VIC_BOUNTYHUNTER = PhaseFour.victory:Register(VICTORY);