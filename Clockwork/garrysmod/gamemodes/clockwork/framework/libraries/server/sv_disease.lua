--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.disease = Clockwork.kernel:NewLibrary("Disease");
Clockwork.disease.stored = Clockwork.disease.stored or {};
Clockwork.disease.stored.diseases = Clockwork.disease.stored.diseases or {};
Clockwork.disease.stored.symptoms = Clockwork.disease.stored.symptoms or {};

--[[
	@codebase Server
	@details A function to create a new disease.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.disease:New(uniqueID)
	if (uniqueID) then
		if (!self:IsValid(uniqueID)) then
			self.stored.diseases[uniqueID] = {};
		else
			ErrorNoHalt("Attempting to add already existing disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add nil disease.");
	end;
end;

--[[
	@codebase Server
	@details A function to delete a disease.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.disease:Delete(uniqueID)
	if (uniqueID) then
		if (self:IsValid(uniqueID)) then
			self.stored.diseases[uniqueID] = nil;
		else
			ErrorNoHalt("Attempting to delete invalid disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to delete nil disease.");
	end;
end;

--[[
	@codebase Server
	@details A function to create a new symptom.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for callback.
	@returns {Unknown}
--]]
function Clockwork.disease:NewSymptom(uniqueID, callback)
	if (uniqueID) then
		if (!self:IsValidSymptom(uniqueID)) then
			self.stored.symptoms[uniqueID] = callback;
		else
			ErrorNoHalt("Attempting to add already existing symptom '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add nil symptom.");
	end;
end;

--[[
	@codebase Server
	@details A function to add a symptom to a disease.
	@param {Unknown} Missing description for diseaseID.
	@param {Unknown} Missing description for symptomID.
	@returns {Unknown}
--]]
function Clockwork.disease:AddSymptom(diseaseID, symptomID)
	if (diseaseID) then
		if (self:IsValid(diseaseID)) then
			if (symptomID) then
				if (self:IsValidSymptom(symptomID)) then
					if (!table.HasValue(self.stored.diseases[diseaseID], symptomID)) then
						table.insert(self.stored.diseases[diseaseID], symptomID);
					end;
				else
					ErrorNoHalt("Attempting to add invalid symptom '"..symptomID.."' to disease '"..diseaseID.."'.");
				end;
			else
				ErrorNoHalt("Attempting to add nil symptom to disease '"..diseaseID.."'.");
			end;
		else
			ErrorNoHalt("Attempting to add symptom to invalid disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add symptom to nil disease.");
	end;
end;

--[[
	@codebase Server
	@details A function to remove a condition from a disease.
	@param {Unknown} Missing description for diseaseID.
	@param {Unknown} Missing description for symptomID.
	@returns {Unknown}
--]]
function Clockwork.disease:RemoveSymptom(diseaseID, symptomID)
	if (diseaseID) then
		if (self:IsValid(diseaseID)) then
			if (symptomID) then
				if (self:IsValidSymptom(symptomID)) then
					table.RemoveByValue(self.stored.diseases[diseaseID], symptomID);
				else
					ErrorNoHalt("Attempting to remove invalid symptom '"..symptomID.."' from disease '"..diseaseID.."'.");
				end;
			else
				ErrorNoHalt("Attempting to remove nil symptom from disease '"..diseaseID.."'.");
			end;
		else
			ErrorNoHalt("Attempting to remove symptom from invalid disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to remove symptom from nil disease.");
	end;
end;

--[[
	@codebase Server
	@details A function to delete a symptom.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.disease:DeleteSymptom(uniqueID)
	if (uniqueID) then
		if (self:IsValidSymptom(uniqueID)) then
			self.stored.symptoms[uniqueID] = nil;

			for k, v in pairs(Clockwork.disease:GetAll()) do
				table.RemoveByValue(v, uniqueID);
			end;
		else
			ErrorNoHalt("Attempting to delete invalid symptom '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to delete nil symptom.");
	end;
end;

--[[
	@codebase Server
	@details A function to get all of a disease's symptomps.
	@param {Unknown} Missing description for diseaseID.
	@returns {Unknown}
--]]
function Clockwork.disease:GetSymptoms(diseaseID)
	if (diseaseID) then
		if (self:IsValid(diseaseID)) then
			local symptoms = {};

			for k, v in pairs(self.stored.diseases[diseaseID]) do
				symptoms[v] = self.stored.symptoms[v];
			end;

			return symptoms;
		else
			ErrorNoHalt("Attempting to get symptoms of nonexistant disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to get symptoms of nil disease.");
	end
end;

--[[
	@codebase Server
	@details A function to get if a disease is valid.
	@param {Unknown} Missing description for diseaseID.
	@returns {Unknown}
--]]
function Clockwork.disease:IsValid(diseaseID)
	if (self.stored.diseases[diseaseID]) then
		return true;
	else
		return false;
	end;
end;

--[[
	@codebase Server
	@details A function to get if a disease is valid.
	@param {Unknown} Missing description for symptomID.
	@returns {Unknown}
--]]
function Clockwork.disease:IsValidSymptom(symptomID)
	if (self.stored.symptoms[symptomID]) then
		return true;
	else
		return false;
	end;
end;

--[[
	@codebase Server
	@details A function to get all diseases.
	@returns {Unknown}
--]]
function Clockwork.disease:GetAll()
	return self.stored.diseases;
end;

--[[
	@codebase Server
	@details A function to get all symptoms.
	@returns {Unknown}
--]]
function Clockwork.disease:GetAllSymptoms()
	return self.stored.symptoms;
end;