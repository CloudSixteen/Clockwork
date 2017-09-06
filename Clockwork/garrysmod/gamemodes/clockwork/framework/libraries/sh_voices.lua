--[[ 
    © CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.voices = Clockwork.kernel:NewLibrary("CWVoices");

local groups = {};

--[[
	@codebase Shared
	@details A function to get the local stored voice groups.
	@returns {Unknown}
--]]
function Clockwork.voices:GetAll()
	return groups;
end;

--[[
	@codebase Shared
	@details A function to get a certain group by ID.
	@param {Unknown} Missing description for id.
	@returns {Unknown}
--]]
function Clockwork.voices:FindByID(id)
	return groups[id];
end;

--[[
	@codebase Shared
	@details A function to get the voices of a certain group by ID.
	@param {Unknown} Missing description for id.
	@returns {Unknown}
--]]
function Clockwork.voices:GetVoices(id)
	return groups[id].voices;
end;

--[[
	@codebase Shared
	@details A function to add a voice group.
	@param {Unknown} Missing description for group.
	@param {Unknown} Missing description for gender.
	@param {Unknown} Missing description for callback.
	@returns {Unknown}
--]]
function Clockwork.voices:RegisterGroup(group, gender, callback)
	if (!gender) then
		gender = false;
	end;
	
	groups[group] = {
		gender = gender,
		IsPlayerMember = callback,
		voices = {};
	};
end;

--[[
	@codebase Shared
	@details A function to add a voice.
	@param {Unknown} Missing description for groupName.
	@param {Unknown} Missing description for command.
	@param {Unknown} Missing description for phrase.
	@param {Unknown} Missing description for sound.
	@param {Unknown} Missing description for female.
	@param {Unknown} Missing description for menu.
	@param {Unknown} Missing description for pitch.
	@param {Unknown} Missing description for volume.
	@returns {Unknown}
--]]
function Clockwork.voices:Add(groupName, command, phrase, sound, female, menu, pitch, volume)
	local group = groups[groupName];
	
	if (group) then
		group.hasVoices = true;
		group.voices[#group.voices + 1] = {
			command = command,
			phrase = phrase,
			female = female,
			sound = sound,
			menu = menu,
			pitch = pitch,
			volume = volume
		};
	else
		ErrorNoHalt("Attempted to add voice for invalid group '"..groupName.."'.\n");
	end;
end;

--[[
	@codebase Shared
	@details Called when the framework initializes.
	@returns {Unknown}
--]]
function Clockwork.voices:ClockworkInitialized()
	for k, v in pairs(Clockwork.faction:GetAll()) do
		local FACTION = Clockwork.faction:FindByID(v.name);
		
		if (IsValid(FACTION.models.female and FACTION.models.male)) then
			self:RegisterGroup(v.name, true, function(ply)
				if (ply:GetFaction() == v.name) then
					return true;
				else
					return false;
				end;
			end);
		else
			self:RegisterGroup(k, false, function(ply)
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
	Clockwork.plugin:Call("AdjustVoices", groups);

	if (CLIENT) then
		for k, v in pairs(groups) do
			if (v.hasVoices) then
				Clockwork.directory:AddCategory(k, "HelpCommands");

				table.sort(v.voices, function(a, b) return a.command < b.command; end);

				for k2, v2 in pairs(v.voices) do
					if (!v2.phrase) then
						v2.phrase = "";
					end;

					Clockwork.directory:AddCode(k, [[
						<div class="cwTitleSeperator">
							]]..string.upper(v2.name)..[[
						</div>
						<div class="cwContentText">
							<lang>]]..v2.phrase..[[</lang>
						</div>
					]]);
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details Called when chat box info should be adjusted.
	@param {Unknown} Missing description for info.
	@returns {Unknown}
--]]
function Clockwork.voices:ChatBoxAdjustInfo(info)
	if (info.class == "ic" or info.class == "yell" or info.class == "whisper") then
		if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
			info.text = string.upper(string.sub(info.text, 1, 1))..string.sub(info.text, 2);
			
			for k, v in pairs(groups) do
				if (v.IsPlayerMember(info.speaker)) then
					for k2, v2 in pairs(v.voices) do
						if (string.lower(info.text) == string.lower(v2.command)) then
							local voice = {
								global = false,
								volume = v2.volume or 80,
								sound = v2.sound,
								pitch = v2.pitch
							};
							
							if (v.gender) then
								if (v2.female and info.speaker:QueryCharacter("Gender") == GENDER_FEMALE) then
									voice.sound = string.Replace(voice.sound, "/male", "/female");
								end;
							end;
							
							if (info.class == "whisper") then
								voice.volume = voice.volume * 0.75;
							elseif (info.class == "yell") then
								voice.volume = voice.volume * 1.25;
							end;
							
							info.voice = voice;

							if (v2.phrase == nil or v2.phrase == "") then
								info.visible = false;
								
								if (SERVER) then
									Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerSays", info.speaker:Name(), info.text});
								end;
							else
								info.text = v2.phrase;
							end;
						
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details Called when a chat box message has been added.
	@param {Unknown} Missing description for info.
	@returns {Unknown}
--]]
function Clockwork.voices:ChatBoxMessageAdded(info)
	if (info.voice) then
		if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
			info.speaker:EmitSound(info.voice.sound, info.voice.volume, info.voice.pitch);
		end;
		
		if (info.voice.global) then
			for k, v in pairs(info.listeners) do
				if (v != info.speaker) then
					Clockwork.player:PlaySound(v, info.voice.sound);
				end;
			end;
		end;
	end;
end;

Clockwork.plugin:Add("Voices", Clockwork.voices);
