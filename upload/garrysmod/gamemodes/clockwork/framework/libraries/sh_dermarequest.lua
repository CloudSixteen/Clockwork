--[[ 
    © CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html
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
end;

if (SERVER) then
	Clockwork.dermaRequest.hooks = Clockwork.dermaRequest.hooks or {};

	--[[
		@codebase Server
		@details Requests a string in the form of a derma popup on the specified client.
		@param {Player} The player to send the request to.
		@param {String} A title string to apply to the derma popup.
		@param {String} The question to ask in the derma popup.
		@param {String} An optional default string for the answer.
		@param {Function} A callback function. It passes the answer as an argument.
	--]]
	function Clockwork.dermaRequest:RequestString(player, title, question, default, Callback)
		local id = self:GenerateID();
		
		Clockwork.datastream:Start(player, "dermaRequest_stringQuery", {id = id, title = title, question = question, default = default});
		
		self.hooks[id] = {Callback = Callback, player = player};
	end;

	--[[
		@codebase Server
		@details Requests a confirmation from a player. When called, it displays a question box with a Confirm and Cancel button.
		@param {Player} The player to send the request to.
		@param {String} A title string to apply to the derma popup.
		@param {String} The question to ask in the derma popup.
		@param {Function} A callback function. It passes the answer as an argument.
	--]]
	function Clockwork.dermaRequest:RequestConfirmation(player, title, question, Callback)
		local id = self:GenerateID();
		
		Clockwork.datastream:Start(player, "dermaRequest_confirmQuery", {id = id, title = title, question = question});
		
		self.hooks[id] = {Callback = Callback, player = player};
	end;

	--[[
		@codebase Server
		@details Sends a derma popup message to a specific player.
		@param {Player} The player to send the request to.
		@param {String} The message to send to the player.
		@param {String} A title string to apply to the derma popup (Optional).
		@param {String} An optional button text override (Optional).
	--]]
	function Clockwork.dermaRequest:Message(player, message, title, button)
		Clockwork.datastream:Start(player, "dermaRequest_message", {message = message, title = title or nil, button = button or nil});
	end;

	--[[
		@codebase Shared
		@details An internal function to validate a return
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.dermaRequest:Validate(player, data)
		if (data.id and data.recv and self.hooks[data.id] and self.hooks[data.id].player == player) then
			return true;
		end;
		
		return false;
	end;

	Clockwork.datastream:Hook("dermaRequestCallback", function(player, data)
		if (!Clockwork.dermaRequest:Validate(player, data)) then return; end;
		Clockwork.dermaRequest.hooks[data.id].Callback(data.recv);
		Clockwork.dermaRequest.hooks[data.id] = nil;
	end);

else

	function Clockwork.dermaRequest:Send(id, recv)
		Clockwork.datastream:Start("dermaRequestCallback", {id = id, recv = recv});
	end;

	Clockwork.datastream:Hook("dermaRequest_stringQuery", function(data)
		Derma_StringRequest(T(data.title), T(data.question), data.default, function(recv)
			Clockwork.dermaRequest:Send(data.id, recv);
		end);
	end);

	Clockwork.datastream:Hook("dermaRequest_confirmQuery", function(data)
		Derma_Query(T(data.question), T(data.title), 
			"Confirm", function() Clockwork.dermaRequest:Send(data.id, true) end,
			"Cancel", function() Clockwork.dermaRequest:Send(data.id, false); end);
	end);

	Clockwork.datastream:Hook("dermaRequest_message", function(data)
		local title = data.title or nil;
		local button = data.button or nil;
		
		Derma_Message(T(data.message), T(data.title), T(data.button));
	end);

end