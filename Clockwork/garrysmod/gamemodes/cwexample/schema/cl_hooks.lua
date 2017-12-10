--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

-- Called when the cinematic intro info is needed.
function Schema:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self:GetAuthor()..".",
		title = Clockwork.config:Get("intro_text_big"):Get(),
		text = Clockwork.config:Get("intro_text_small"):Get()
	};
end;