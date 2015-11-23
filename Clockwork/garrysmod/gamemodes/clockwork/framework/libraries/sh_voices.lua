--[[ 
    © 2015 CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.voices = Clockwork.kernel:NewLibrary("Voices");
Clockwork.voices.groups = {};

-- A function to add a voice group.
function Clockwork.voices:RegisterGroup(group, bGender, callback)
	if (!bGender) then
		bGender = false;
	end;
	
	self.groups[group] = {
		bGender = bGender,
		IsPlayerMember = callback,
		voices = {};
	};
end;

-- A function to add a voice.
function Clockwork.voices:Add(groupName, command, phrase, sound, female, menu)
	local group = self.groups[groupName];
	
	if (group) then
		group.hasVoices = true;
		group.voices[#group.voices + 1] = {
			command = command,
			phrase = phrase,
			female = female,
			sound = sound,
			menu = menu
		};
	else
		ErrorNoHalt("Attempted to add voice for invalid group '"..groupName.."'.\n");
	end;
end;

function Clockwork.voices:ClockworkInitialized()
	for k, v in pairs(Clockwork.faction:GetAll()) do
		local FACTION = Clockwork.faction:FindByID(v.name);
		
		if (IsValid(FACTION.models.female and FACTION.models.male)) then
			Clockwork.voices:RegisterGroup(v.name, true, function(ply)
				if (ply:GetFaction() == v.name) then
					return true;
				else
					return false;
				end;
			end);
		else
			Clockwork.voices:RegisterGroup(k, false, function(ply)
				if (ply:GetFaction() == v.name) then
					return true;
				else
					return false;
				end;
			end);
		end;
	end;

	Clockwork.plugin:Call("RegisterVoiceGroups", self);
	Clockwork.plugin:Call("RegisterVoices", self);
	Clockwork.plugin:Call("AdjustVoices", self.groups);

	if (CLIENT) then
		for k, v in pairs(Clockwork.voices.groups) do
			if (v.hasVoices) then
				Clockwork.directory:AddCategory(k, "Commands");
				table.sort(v.voices, function(a, b) return a.command < b.command; end);
				for k2, v2 in pairs(v.voices) do
					Clockwork.directory:AddCode(k, [[
						<div class="auraInfoTitle">]]..string.upper(v2.command)..[[</div>
						<div class="auraInfoText">]]..v2.phrase..[[</div>
					]], true);
				end;
			end;
		end;
	end;
end;

Clockwork.plugin:Add("Voices", Clockwork.voices);
