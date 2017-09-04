--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.treeNode = vgui.Create("DTree", self);
	self.treeNode:SetPadding(4);
	self.htmlPanel = vgui.Create("HTML", self);
	
	Clockwork.directory.panel = self;
	Clockwork.directory.panel.categoryHistory = {};
	
	self:Rebuild();
end;

-- Called to by the menu to get the width of the panel.
function PANEL:GetMenuWidth()
	return ScrW() * 0.5;
end;

local PAGE_ICON = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAINSURBVBgZBcG/r55zGAfg6/4+z3va01NHlYgzEfE7MdCIGISFgS4Gk8ViYyM2Mdlsko4GSf8Do0FLRCIkghhYJA3aVBtEz3nP89wf11VJvPDepdd390+8Nso5nESBQoq0pfvXm9fzWf19453LF85vASqJlz748vInb517dIw6EyYBIIG49u+xi9/c9MdvR//99MPPZ7+4cP4IZhhTPbwzT2d+vGoaVRRp1rRliVvHq+cfvM3TD82+7mun0o/ceO7NT+/4/KOXjwZU1ekk0840bAZzMQ2mooqh0A72d5x/6sB9D5zYnff3PoYBoWBgFKPKqDKqjCpjKr//dcu9p489dra88cydps30KswACfNEKanSaxhlntjJ8Mv12Paie+vZ+0+oeSwwQ0Iw1xAR1CiFNJkGO4wu3ZMY1AAzBI0qSgmCNJsJUEOtJSMaCTBDLyQ0CknAGOgyTyFFiLI2awMzdEcSQgSAAKVUmAeNkxvWJWCGtVlDmgYQ0GFtgg4pNtOwbBcwQy/Rife/2yrRRVI0qYCEBly8Z+P4qMEMy7JaVw72N568e+iwhrXoECQkfH91kY7jwwXMsBx1L93ZruqrK6uuiAIdSnTIKKPLPFcvay8ww/Hh+ufeznTXu49v95IMoQG3784gYXdTqvRmqn/Wpa/ADFX58MW3L71SVU9ETgEIQQQIOOzub+fhIvwPRDgeVjWDahIAAAAASUVORK5CYII=";

-- A function to show a directory category.
function PANEL:ShowCategory(category)
	if (!category) then
		local masterFormatting = Clockwork.directory:GetMasterFormatting();
		local finalCode = [[
			<div class="cwContentBox">
				<div class="cwContentTitle">
					<img src="]]..PAGE_ICON..[["/><lang>HelpSelectCategory</lang>
				</div>
				<div class="cwContentText">
					<lang>HelpPrivsMessage</lang>
				</div>
			</div>
		]];
		
		if (masterFormatting) then
			finalCode = Clockwork.kernel:Replace(masterFormatting, "[information]", finalCode);
		end;
		
		finalCode = Clockwork.directory:ReplaceMatches(category, finalCode);
		finalCode = Clockwork.kernel:Replace(finalCode, "[category]", Clockwork.option:Translate("name_directory"));
		finalCode = Clockwork.kernel:Replace(finalCode, "{category}", Clockwork.option:Translate("name_directory"):upper());
		finalCode = Clockwork.kernel:ParseData(finalCode);

		self.htmlPanel:SetHTML(finalCode);
	else
		local categoryTable = Clockwork.directory:GetCategory(category);
		
		if (categoryTable) then
			if (!categoryTable.isHTML) then
				local newPageData = {};
				
				for k, v in pairs(categoryTable.pageData) do
					newPageData[#newPageData + 1] = v;
				end;
				
				local sorting = Clockwork.directory:GetCategorySorting(category);
				
				if (sorting) then
					table.sort(newPageData, sorting);
				end;
				
				if (table.Count(newPageData) > 0) then
					local masterFormatting = Clockwork.directory:GetMasterFormatting();
					local formatting = Clockwork.directory:GetCategoryFormatting(category);
					local firstKey = true;
					local finalCode = "";
				
					for k, v in pairs(newPageData) do
						local htmlCode = v.htmlCode;
						
						if (type(v.Callback) == "function") then
							htmlCode = v.Callback(htmlCode, v.sortData);
						end;
						
						if (htmlCode and htmlCode != "") then
							if (!firstKey) then
								if ((!formatting or !formatting.noLineBreaks)
								and !v.noLineBreak) then
									finalCode = finalCode.."<br>"..htmlCode;
								else
									finalCode = finalCode..htmlCode;
								end;
							else
								finalCode = htmlCode;
							end;
							
							firstKey = false;
						end;
					end;
					
					if (formatting) then
						finalCode = Clockwork.kernel:Replace(formatting.htmlCode, "[information]", finalCode);
					end;
					
					if (masterFormatting) then
						finalCode = Clockwork.kernel:Replace(masterFormatting, "[information]", finalCode);
					end;
					
					finalCode = Clockwork.directory:ReplaceMatches(category, finalCode);
					finalCode = Clockwork.kernel:Replace(finalCode, "[category]", L(category));
					finalCode = Clockwork.kernel:Replace(finalCode, "{category}", string.upper(L(category)));
					finalCode = Clockwork.kernel:ParseData(finalCode);
					
					self.htmlPanel:SetHTML(finalCode);
				end;
			elseif (!categoryTable.isWebsite) then
				local masterFormatting = Clockwork.directory:GetMasterFormatting();
				local formatting = Clockwork.directory:GetCategoryFormatting(category);
				local finalCode = categoryTable.pageData;
				
				if (formatting) then
					finalCode = Clockwork.kernel:Replace(formatting.htmlCode, "[information]", finalCode);
				end;
				
				if (masterFormatting) then
					finalCode = Clockwork.kernel:Replace(masterFormatting, "[information]", finalCode);
				end;
				
				finalCode = Clockwork.directory:ReplaceMatches(category, finalCode);
				finalCode = Clockwork.kernel:Replace(finalCode, "[category]", L(category));
				finalCode = Clockwork.kernel:Replace(finalCode, "{category}", string.upper(L(category)));
				finalCode = Clockwork.kernel:ParseData(finalCode);
				
				self.htmlPanel:SetHTML(finalCode);
			else
				self.htmlPanel:OpenURL(categoryTable.pageData);
			end;
		end;
	end;
end;

-- A function to clear the nodes.
function PANEL:ClearNodes()
	if (self.treeNode.Items) then
		for k, v in pairs(self.treeNode.Items) do
			if (IsValid(v)) then
				v:Remove();
			end;
		end;
	end;
	
	self.treeNode.m_pSelectedItem = nil;
	self.treeNode.Items = {};
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (!CW_REBUILDING_DIRECTORY) then
		self:ClearNodes();
		
		CW_REBUILDING_DIRECTORY = true;
			Clockwork.plugin:Call("ClockworkDirectoryRebuilt", self);
		CW_REBUILDING_DIRECTORY = nil;
		
		Clockwork.kernel:ValidateTableKeys(Clockwork.directory.stored);
		
		table.sort(Clockwork.directory.stored, function(a, b)
			return a.category < b.category;
		end);
		
		local nodeTable = {};
		
		for k, v in pairs(Clockwork.directory.stored) do
			if (!v.parent) then
				nodeTable[v.category] = self.treeNode:AddNode(L(v.category));
			end;
		end;
		
		for k, v in pairs(Clockwork.directory.stored) do
			if (v.parent and nodeTable[v.parent]) then
				nodeTable[v.category] = nodeTable[v.parent]:AddNode(L(v.category));
			elseif (!nodeTable[v.category]) then
				nodeTable[v.category] = self.treeNode:AddNode(L(v.category));
			end;
			
			if (!nodeTable[v.category].Initialized) then
				local friendlyName = Clockwork.directory:GetFriendlyName(v.category);
				local tip = Clockwork.directory:GetCategoryTip(v.category);
				
				if (tip) then
					nodeTable[v.category]:SetToolTip(L(tip));
				end;
				
				nodeTable[v.category].Initialized = true;
				nodeTable[v.category]:SetText(L(friendlyName));
				nodeTable[v.category].DoClick = function(node)
					for k2, v2 in pairs(Clockwork.directory.stored) do
						if (v2.category == v.category and (v2.isWebsite
						or v2.isHTML or #v2.pageData > 0)) then
							self.currentCategory = v.category;
							self:ShowCategory(self.currentCategory);
							
							break;
						end;
					end;
				end;
			end;
		end;
		
		self:ShowCategory(self.currentCategory);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self:SetSize(w, ScrH() * 0.75);
	self.treeNode:SetPos(4, 4);
	self.treeNode:SetSize(w * 0.25, h - 8);
	self.htmlPanel:SetPos((w * 0.25) + 8, 4);
	self.htmlPanel:SetSize((w * 0.75) - 16, h - 8);
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	DERMA_SLICED_BG:Draw(0, 0, w, h, 8, COLOR_WHITE);
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwDirectory", PANEL, "EditablePanel");