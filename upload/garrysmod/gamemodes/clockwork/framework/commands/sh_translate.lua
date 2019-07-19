--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("Translate");

COMMAND.tip = "CmdTranslate";
COMMAND.text = "CmdTranslateDesc";
COMMAND.arguments = 3;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.config:Get("translate_api_key"):Get() != "") then
		http.Fetch("https://www.googleapis.com/language/translate/v2/languages?key="..Clockwork.config:Get("translate_api_key"):Get().."&target=en",
			function(body, length, headers, code)
				body = Clockwork.json:Decode(body);
				
				if (body["data"]) then
					local languages = {};
					local source = "";
					local target = "";

					for i = 1, #body["data"]["languages"] do
						languages[string.lower(body["data"]["languages"][i].name)] = string.lower(body["data"]["languages"][i].language);

						if (string.lower(body["data"]["languages"][i].name) == string.lower(arguments[1]) or string.lower(body["data"]["languages"][i].language) == string.lower(arguments[1])) then
							source = string.lower(body["data"]["languages"][i].language);
						end;

						if (string.lower(body["data"]["languages"][i].name) == string.lower(arguments[2]) or string.lower(body["data"]["languages"][i].language) == string.lower(arguments[2])) then
							target = string.lower(body["data"]["languages"][i].language);
						end;
					end;

					if (source != "") then
						if (target != "") then
							http.Fetch("https://www.googleapis.com/language/translate/v2?key="..Clockwork.config:Get("translate_api_key"):Get().."&source="..source.."&target="..v.."&q="..arguments[3],
								function(body, length, headers, code)
									body = Clockwork.json:Decode(body);
										
									if (body["data"]) then
										Clockwork.chatBox:AddInRadius(player, "ic", body["data"]["translations"][1].translatedText, player:GetPos(), Clockwork.config:Get("talk_radius"):Get());
									elseif (body["error"]) then
										local errorsString = body["error"]["errors"][1].reason;

										for i = 2, #body["error"]["errors"] do
											errorsString = ", "..body["error"]["errors"][i].reason;
										end;

										Clockwork.player:Notify(player, "Error(s): "..errorsString);
									end;
								end,

								function(error)
									Clockwork.player:Notify(player, "Error: "..error);
								end
							);
						else
							Clockwork.player:Notify(player, "Invalid target language.");
						end;
					else
						Clockwork.player:Notify(player, "Invalid source language.");
					end;
				elseif (body["error"]) then
					local errorsString = body["error"]["errors"][1].reason;

					for i = 2, #body["error"]["errors"] do
						errorsString = ", "..body["error"]["errors"][i].reason;
					end;

					Clockwork.player:Notify(player, "Error(s): "..errorsString);
				end;
			end,

			function(error)
				Clockwork.player:Notify(player, "Error: "..error);
			end
		);
	else
		Clockwork.player:Notify(player, "There must be a Google Translate API key set for the value of the translate_api_key config to use this feature.");
	end;
end;

--COMMAND:Register();