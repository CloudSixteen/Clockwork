--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local table = table;

Clockwork.quiz = Clockwork.kernel:NewLibrary("Quiz");
Clockwork.quiz.stored = Clockwork.quiz.stored or {};

--[[
	@codebase Shared
	@details A function to set the quiz name.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.quiz:SetName(name)
	self.name = name;
end;

--[[
	@codebase Shared
	@details A function to get the quiz name.
	@returns {Unknown}
--]]
function Clockwork.quiz:GetName()
	return self.name or "MenuQuizTitle";
end;

--[[
	@codebase Shared
	@details A function to set whether the quiz is enabled.
	@param {Unknown} Missing description for enabled.
	@returns {Unknown}
--]]
function Clockwork.quiz:SetEnabled(enabled)
	self.enabled = enabled;
end;

--[[
	@codebase Shared
	@details A function to get whether the quiz is enabled.
	@returns {Unknown}
--]]
function Clockwork.quiz:GetEnabled()
	return self.enabled;
end;

--[[
	@codebase Shared
	@details A function to get the amount of quiz questions.
	@returns {Unknown}
--]]
function Clockwork.quiz:GetQuestionsAmount()
	return table.Count(self.stored);
end;

--[[
	@codebase Shared
	@details A function to get the quiz questions.
	@returns {Unknown}
--]]
function Clockwork.quiz:GetQuestions()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to get a question.
	@param {Unknown} Missing description for index.
	@returns {Unknown}
--]]
function Clockwork.quiz:GetQuestion(index)
	return self.stored[index];
end;

--[[
	@codebase Shared
	@details A function to get if an answer is correct.
	@param {Unknown} Missing description for index.
	@param {Unknown} Missing description for answer.
	@returns {Unknown}
--]]
function Clockwork.quiz:IsAnswerCorrect(index, answer)
	question = self:GetQuestion(index);
	
	if (question) then
		if (type(question.answer) == "table" and table.HasValue(question.answer, answer)) then
			return true;
		elseif (answer == question.possibleAnswers[question.answer]) then
			return true;
		elseif (question.answer == answer) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to add a new quiz question.
	@param {Unknown} Missing description for question.
	@param {Unknown} Missing description for answer.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.quiz:AddQuestion(question, answer, ...)
	local index = Clockwork.kernel:GetShortCRC(question);
	
	self.stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	};
end;

--[[
	@codebase Shared
	@details A function to remove a quiz question.
	@param {Unknown} Missing description for question.
	@returns {Unknown}
--]]
function Clockwork.quiz:RemoveQuestion(question)
	if (self.stored[question]) then
		self.stored[question] = nil;
	else
		local index = Clockwork.kernel:GetShortCRC(question);
		
		if (self.stored[index]) then
			self.stored[index] = nil;
		end;
	end;
end;

if (CLIENT) then
	function Clockwork.quiz:SetCompleted(completed)
		self.completed = completed;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether the quiz is completed.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:GetCompleted()
		return self.completed;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the quiz panel.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:GetPanel()
		if (IsValid(self.panel)) then
			return self.panel;
		end;
	end;
else
	function Clockwork.quiz:SetCompleted(player, completed)
		if (completed) then
			player:SetData("Quiz", self:GetQuestionsAmount());
		else
			player:SetData("Quiz", nil);
		end;
		
		Clockwork.datastream:Start(player, "QuizCompleted", completed);
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a player has completed the quiz.
		@param {Unknown} Missing description for player.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:GetCompleted(player)
		if (player:GetData("Quiz") == self:GetQuestionsAmount()) then
			return true;
		else
			return player:IsBot();
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to set the quiz percentage.
		@param {Unknown} Missing description for percentage.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:SetPercentage(percentage)
		self.percentage = percentage;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the quiz percentage.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:GetPercentage()
		return self.percentage or 100;
	end;
	
	--[[
		@codebase Shared
		@details A function to call the quiz kick Callback.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for correctAnswers.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:CallKickCallback(player, correctAnswers)
		local kickCallback = self:GetKickCallback();
		
		if (kickCallback) then
			kickCallback(player, correctAnswers);
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get the quiz kick Callback.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:GetKickCallback()
		if (self.kickCallback) then
			return self.kickCallback;
		else
			return function(player, correctAnswers)
				player:Kick("You got too many questions wrong!");
			end;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to set the quiz kick Callback.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.quiz:SetKickCallback(Callback)
		self.kickCallback = Callback;
	end;
end;