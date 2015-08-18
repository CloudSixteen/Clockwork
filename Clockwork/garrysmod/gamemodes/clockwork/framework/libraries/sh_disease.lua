--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.disease = Clockwork.kernel:NewLibrary("Disease");
Clockwork.disease.stored = Clockwork.disease.stored or {};
Clockwork.disease.stored.diseases = Clockwork.disease.stored.diseases or {};
Clockwork.disease.stored.conditions = Clockwork.disease.stored.conditions or {};
Clockwork.disease.stored.symptoms = Clockwork.disease.stored.symptoms or {};

-- A function to create a new disease.
function Clockwork.disease:New(uniqueID)
	if (uniqueID) then
		if (!self.stored.diseases[uniqueID]) then
			self.stored.diseases[uniqueID] = {
				conditions = {},
				symptoms = {}
			};
		else
			ErrorNoHalt("Attempting to add already existing disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add nil disease.");
	end;
end;

-- A function to create a new condition.
function Clockwork.disease:NewCondition(uniqueID, callback)
	if (uniqueID) then
		if (!self.stored.conditions[uniqueID]) then
			self.stored.conditions[uniqueID] = callback;
		else
			ErrorNoHalt("Attempting to add already existing condition '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add nil condition.");
	end;
end;

-- A function to create a new symptom.
function Clockwork.disease:NewSymptom(uniqueID, callback)
	if (uniqueID) then
		if (!self.stored.symptoms[uniqueID]) then
			self.stored.symptoms[uniqueID] = callback;
		else
			ErrorNoHalt("Attempting to add already existing symptom '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add nil symptom.");
	end;
end;

-- A function to add a condition to a disease.
function Clockwork.disease:AddCondition(diseaseID, conditionID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			if (conditionID) then
				if (self.stored.conditions[conditionID]) then
					self.stored.diseases[diseaseID].conditions[conditionID] = self.stored.conditions[conditionID];
				else
					ErrorNoHalt("Attempting to add invalid condition '"..conditionID.."' to disease '"..diseaseID.."'.");
				end;
			else
				ErrorNoHalt("Attempting to add nil condition to disease '"..diseaseID.."'.");
			end;
		else
			ErrorNoHalt("Attempting to add condition to invalid disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to add condition to nil disease.");
	end;
end;

-- A function to add a symptom to a disease.
function Clockwork.disease:AddSymptom(diseaseID, symptomID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			if (symptomID) then
				if (self.stored.symptoms[symptomID]) then
					self.stored.diseases[diseaseID].symptomps[symptomID] = self.stored.symptomps[symptomID];
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

-- A function to remove a condition from a disease.
function Clockwork.disease:RemoveCondition(diseaseID, conditionID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			if (conditionID) then
				if (self.stored.conditions[conditionID]) then
					self.stored.diseases[diseaseID].conditions[conditionID] = nil;
				else
					ErrorNoHalt("Attempting to remove invalid condition '"..symptomID.."' from disease '"..diseaseID.."'.");
				end;
			else
				ErrorNoHalt("Attempting to remove nil condition from disease '"..diseaseID.."'.");
			end;
		else
			ErrorNoHalt("Attempting to remove condition from invalid disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to remove condition from nil disease.");
	end;
end;

-- A function to remove a condition from a disease.
function Clockwork.disease:RemoveSymptom(diseaseID, symptomID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			if (symptomID) then
				if (self.stored.symptoms[symptomID]) then
					self.stored.diseases[diseaseID].symptomps[symptomID] = nil;
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

-- A function to delete a disease.
function Clockwork.disease:Delete(uniqueID)
	if (uniqueID) then
		if (self.stored.diseases[uniqueID]) then
			self.stored.diseases[uniqueID] = nil;
		else
			ErrorNoHalt("Attempting to delete invalid disease '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to delete nil disease.");
	end;
end;

-- A function to delete a condition.
function Clockwork.disease:DeleteCondition(uniqueID)
	if (uniqueID) then
		if (self.stored.conditions[uniqueID]) then
			self.stored.conditions[uniqueID] = nil;
		else
			ErrorNoHalt("Attempting to delete invalid condition '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to delete nil condition.");
	end;
end;

-- A function to delete a symptom.
function Clockwork.disease:DeleteSymptom(uniqueID)
	if (uniqueID) then
		if (self.stored.symptoms[uniqueID]) then
			self.stored.symptoms[uniqueID] = nil;
		else
			ErrorNoHalt("Attempting to delete invalid symptom '"..uniqueID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to delete nil symptom.");
	end;
end;

-- A function to get all of a disease's conditions.
function Clockwork.disease:GetConditions(diseaseID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			return self.stored.diseases[diseaseID].conditions;
		else
			ErrorNoHalt("Attempting to get conditions of nonexistant disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to get conditions of nil disease.");
	end
end;

-- A function to get all of a disease's symptomps.
function Clockwork.disease:GetSymptoms(diseaseID)
	if (diseaseID) then
		if (self.stored.diseases[diseaseID]) then
			return self.stored.diseases[diseaseID].symptoms;
		else
			ErrorNoHalt("Attempting to get symptoms of nonexistant disease '"..diseaseID.."'.");
		end;
	else
		ErrorNoHalt("Attempting to get symptoms of nil disease.");
	end
end;

-- A function to get all diseases.
function Clockwork.disease:GetAll()
	return self.stored.diseases;
end;

-- A function to get all conditions.
function Clockwork.disease:GetAllConditions()
	return self.stored.conditions;
end;

-- A function to get all symptoms.
function Clockwork.disease:GetAllSymptoms()
	return self.stored.symptoms;
end;