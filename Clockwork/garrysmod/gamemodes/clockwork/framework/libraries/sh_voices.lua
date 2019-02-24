--[[ 
    © CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.voices = Clockwork.kernel:NewLibrary("CWVoices");
Clockwork.voices.chatClasses = { "ic", "yell", "whisper" };

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

	if (CLIENT) then
		Clockwork.directory:AddCategory(group, "HelpCommands");
		Clockwork.directory:SetCategorySorting(group, function(a, b)
			return a.sortData < b.sortData;
		end);
	end;
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
		group.voices[#group.voices + 1] = {
			command = command,
			phrase = phrase or "",
			female = female,
			sound = sound,
			menu = menu,
			pitch = pitch,
			volume = volume
		};

		if (CLIENT) then
			Clockwork.directory:AddCode(groupName, [[
				<div class="cwTitleSeperator">
					]] .. string.upper(command) .. [[
				</div>
				<div class="cwContentText">
					<lang>]] .. phrase .. [[</lang>
				</div>
			]], nil, command);
		end;
	else
		ErrorNoHalt("Attempted to add voice for invalid group '"..groupName.."'.\n");
	end;
end;
