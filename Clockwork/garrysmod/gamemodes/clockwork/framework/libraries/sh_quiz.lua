--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local table = table;

Clockwork.quiz = Clockwork.kernel:NewLibrary("Quiz");
Clockwork.quiz.stored = Clockwork.quiz.stored or {};

-- A function to set the quiz name.
function Clockwork.quiz:SetName(name)
	self.name = name;
end;

-- A function to get the quiz name.
function Clockwork.quiz:GetName()
	return self.name or "Questions";
end;

-- A function to set whether the quiz is enabled.
function Clockwork.quiz:SetEnabled(enabled)
	self.enabled = enabled;
end;

-- A function to get whether the quiz is enabled.
function Clockwork.quiz:GetEnabled()
	return self.enabled;
end;

-- A function to get the amount of quiz questions.
function Clockwork.quiz:GetQuestionsAmount()
	return table.Count(self.stored);
end;

-- A function to get the quiz questions.
function Clockwork.quiz:GetQuestions()
	return self.stored;
end;

-- A function to get a question.
function Clockwork.quiz:GetQuestion(index)
	return self.stored[index];
end;

-- A function to get if an answer is correct.
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

-- A function to add a new quiz question.
function Clockwork.quiz:AddQuestion(question, answer, ...)
	local index = Clockwork.kernel:GetShortCRC(question);
	
	self.stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	};
end;

-- A function to remove a quiz question.
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
	
	-- A function to get whether the quiz is completed.
	function Clockwork.quiz:GetCompleted()
		return self.completed;
	end;
	
	-- A function to get the quiz panel.
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
	
	-- A function to get whether a player has completed the quiz.
	function Clockwork.quiz:GetCompleted(player)
		if (player:GetData("Quiz") == self:GetQuestionsAmount()) then
			return true;
		else
			return player:IsBot();
		end;
	end;
	
	-- A function to set the quiz percentage.
	function Clockwork.quiz:SetPercentage(percentage)
		self.percentage = percentage;
	end;
	
	-- A function to get the quiz percentage.
	function Clockwork.quiz:GetPercentage()
		return self.percentage or 100;
	end;
	
	-- A function to call the quiz kick Callback.
	function Clockwork.quiz:CallKickCallback(player, correctAnswers)
		local kickCallback = self:GetKickCallback();
		
		if (kickCallback) then
			kickCallback(player, correctAnswers);
		end;
	end;
	
	-- A function to get the quiz kick Callback.
	function Clockwork.quiz:GetKickCallback()
		if (self.kickCallback) then
			return self.kickCallback;
		else
			return function(player, correctAnswers)
				player:Kick("You got too many questions wrong!");
			end;
		end;
	end;
	
	-- A function to set the quiz kick Callback.
	function Clockwork.quiz:SetKickCallback(Callback)
		self.kickCallback = Callback;
	end;
end;