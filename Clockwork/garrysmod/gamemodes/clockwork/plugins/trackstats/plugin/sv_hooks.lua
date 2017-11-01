--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

--[[
	Track player spawns so that we can calculate
	Daily Active User count and other useful information.
--]]

function cwTrackStats:PlayerInitialSpawn(player) end;

function cwTrackStats:PlayerCharacterCreated(player, character) end;

function cwTrackStats:PlayerCharacterLoaded(player) end;

function cwTrackStats:Think() end;
