--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	@codebase Shared
	@details A library to send Derma String Requests to clients through the server. It can also send simple Derma messages.
--]]
Clockwork.dermaRequest = Clockwork.kernel:NewLibrary("DermaRequest");

local REQUEST_INDEX = 0;
function Clockwork.dermaRequest:GenerateID()
	REQUEST_INDEX = REQUEST_INDEX + 1;
	return os.time() + REQUEST_INDEX;
end

if (SERVER) then

	Clockwork.dermaRequest.hooks = {};

	--[[
		@codebase Server
		@details Requests a string in the form of a Derma Popup on the specified client.
		@param Player Target client
		@param String Title to apply to the Derma popup
		@param String Question to ask in the Derma popup
		@param String Default entry in the text box
		@param Function Callback(answer)
	--]]
	function Clockwork.dermaRequest:RequestString(player, title, question, default, Callback)
		local rID = self:GenerateID();
		Clockwork.datastream:Start(player, "dermaRequest_stringQuery", {id = rID, title = title, question = question, default = default});
		self.hooks[rID] = {Callback = Callback, player = player};
	end

	function Clockwork.dermaRequest:Message(player, message, title, button)
		Clockwork.datastream:Start(player, "dermaRequest_message", {message = message, title = title or nil, button = button or nil});
	end

	function Clockwork.dermaRequest:Validate(player, data)
		if (data.id and data.recv and self.hooks[data.id] and self.hooks[data.id].player == player) then
			return true;
		end
		return false;
	end

	Clockwork.datastream:Hook("dermaRequestCallback", function(player, data)
		if (!Clockwork.dermaRequest:Validate(player, data)) then return; end;
		Clockwork.dermaRequest.hooks[data.id].Callback(data.recv);
		Clockwork.dermaRequest.hooks[data.id] = nil;
	end);

else

	function Clockwork.dermaRequest:Send(id, recv)
		Clockwork.datastream:Start("dermaRequestCallback", {id = id, recv = recv});
	end

	Clockwork.datastream:Hook("dermaRequest_stringQuery", function(data)
		Derma_StringRequest(data.title, data.question, data.default, function(recv)
			Clockwork.dermaRequest:Send(data.id, recv);
		end);
	end);

	Clockwork.datastream:Hook("dermaRequest_message", function(data)
		local title = data.title or nil;
		local button = data.button or nil;
		Derma_Message(data.message, data.title, data.button);
	end);

end