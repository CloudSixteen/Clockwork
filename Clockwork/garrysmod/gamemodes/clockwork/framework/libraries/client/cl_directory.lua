--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;

if (Clockwork.directory) then return; end;

Clockwork.directory = Clockwork.kernel:NewLibrary("Directory");
Clockwork.directory.friendlyNames = Clockwork.directory.friendlyNames or {};
Clockwork.directory.formatting = Clockwork.directory.formatting or {};
Clockwork.directory.sorting = Clockwork.directory.sorting or {};
Clockwork.directory.matches = Clockwork.directory.matches or {};
Clockwork.directory.stored = Clockwork.directory.stored or {};
Clockwork.directory.tips = Clockwork.directory.tips or {};

--[[ 
	A good idea for the master formatting, is to ensure the existance of default CSS classes.
	You can still customize them for use, though.
--]]
local MASTER_FORMATTING = [[
	<head>
		<style type="text/css">
			@import (http://fonts.googleapis.com/css?family=Quicksand:400,300);
			
			body{font-family:Verdana, Arial, sans-serif;background:#222;}
			.cwContentBox{transition:background 500ms;-o-transition:background 500ms;-moz-transition:background 500ms;-webkit-transition:background;-o-transition-timing-function:ease-out;-moz-transition-timing-function:ease-out;-webkit-transition-timing-function:ease-out;-webkit-transition-duration:500ms;-webkit-user-select:none;background:#222;font-family:Quicksand, Verdana, Arial, sans-serif;margin-bottom:32px;color:#FFF;padding:8px}
			.cwContentTitle{color:#9ed838;font-size:24px;margin:8px 0px 16px 0px;}
			.cwTitleSeperator{text-decoration:none;color:#f1aa2f;}
			.cwTableHeader{text-decoration:none;color:#f1aa2f;}
			.cwTableMain{color:#FFF;}
		</style>
	</head>
	<body>
		[information]
	</body>
]];

--[[ Set up the default formatting for directory pages. --]]
local DEFAULT_FORMATTING = [[
	<div class="cwContentBox">
		<div class="cwContentTitle">
			<img src="[icon]"/>[category]
		</div>
		[information]
	</div>
]];

Clockwork.directory.formatMaster = MASTER_FORMATTING;
Clockwork.directory.formatDefault = {
	noMasterFormatting = false,
	noLineBreaks = false,
	htmlCode = DEFAULT_FORMATTING
};

-- A function to get a category.
function Clockwork.directory:GetCategory(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return v, k;
		end;
	end;
end;

-- A function to add a category match.
function Clockwork.directory:AddCategoryMatch(category, sFind, sReplace)
	if (!self.matches[category]) then
		self.matches[category] = {};
	end;
	
	self.matches[category][sFind] = sReplace;
end;

-- A function to replace a category's matches.
function Clockwork.directory:ReplaceMatches(category, htmlCode)
	if (!self.matches[category]) then return htmlCode; end;
	
	for k, v in pairs(self.matches[category]) do
		htmlCode = Clockwork.kernel:Replace(htmlCode, k, v);
	end;
	
	return htmlCode;
end;

-- A function to set a category tip.
function Clockwork.directory:SetCategoryTip(category, tip)
	self.tips[category] = tip;
end;

-- A function to get a category tip.
function Clockwork.directory:GetCategoryTip(category)
	return self.tips[category];
end;

-- A function to add a category page.
function Clockwork.directory:AddCategoryPage(category, parent, htmlCode, isWebsite)
	self:AddCategory(category, parent);
	self:AddPage(category, htmlCode, isWebsite);
end;

-- A function to set a friendly name.
function Clockwork.directory:SetFriendlyName(category, name)
	self.friendlyNames[category] = name;
end;

-- A function to get a friendly name.
function Clockwork.directory:GetFriendlyName(category)
	return self.friendlyNames[category] or category;
end;

-- A function to set the master formatting.
function Clockwork.directory:SetMasterFormatting(htmlCode)
	self.formatMaster = htmlCode;
end;

-- A function to get the master formatting.
function Clockwork.directory:GetMasterFormatting()
	return self.formatMaster;
end;

-- A function to set category formatting.
function Clockwork.directory:SetCategoryFormatting(category, htmlCode, noLineBreaks, noMasterFormatting)
	self.formatting[category] = {
		noMasterFormatting = (noMasterFormatting == true),
		noLineBreaks = (noLineBreaks == true),
		htmlCode = htmlCode
	};
end;

-- A function to get category formatting.
function Clockwork.directory:GetCategoryFormatting(category)
	return self.formatting[category] or self.formatDefault;
end;

-- A function to set category sorting.
function Clockwork.directory:SetCategorySorting(category, Callback)
	self.sorting[category] = Callback;
end;

-- A function to get category sorting.
function Clockwork.directory:GetCategorySorting(category)
	return self.sorting[category];
end;

-- A function to get whether a category exists.
function Clockwork.directory:CategoryExists(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return true;
		end;
	end;
end;

-- A function to add a category.
function Clockwork.directory:AddCategory(category, parent)
	if (parent) then
		self:AddCategory(parent, false);
	end;
	
	if (!self:CategoryExists(category)) then
		if (parent == false) then parent = nil; end;
		
		self.stored[#self.stored + 1] = {
			category = category,
			pageData = {},
			parent = parent
		};
	elseif (parent != false) then
		for k, v in pairs(self.stored) do
			if (v.category == category) then
				v.parent = parent;
			end;
		end;
	end;
	
	return category, parent;
end;

-- A function to add some code.
function Clockwork.directory:AddCode(category, htmlCode, noLineBreak, sortData, Callback)
	self:AddCategory(category, false);
	
	local categoryTable = self:GetCategory(category);
	local uniqueID = nil;
	local panel = self:GetPanel();
	
	if (categoryTable) then
		categoryTable.pageData[#categoryTable.pageData + 1] = {
			noLineBreak = noLineBreak,
			sortData = sortData,
			Callback = Callback,
			htmlCode = htmlCode
		};
		
		uniqueID = #categoryTable.pageData;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
	
	return uniqueID;
end;

-- A function to remove some code.
function Clockwork.directory:RemoveCode(category, uniqueID, forceRemove)
	local panel = self:GetPanel();
	
	if (category) then
		local categoryTable, categoryKey = self:GetCategory(category);
		
		if (categoryTable) then
			if (uniqueID and !categoryTable.isHTML) then
				if (categoryTable.pageData[uniqueID]) then
					categoryTable.pageData[uniqueID] = nil;
				end;
				
				if (#categoryTable.pageData == 0) then
					self:RemoveCode(category);
				end;
			else
				local removeCategory = true;
				
				if (!forceRemove and !categoryTable.isHTML) then
					for k, v in pairs(self.stored) do
						if (v.parent == category) then
							removeCategory = true;
							
							break;
						end;
					end;
				end;
				
				if (removeCategory) then
					self.stored[categoryKey] = nil;
				end;
			end;
		end;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
end;

-- A function to add a page.
function Clockwork.directory:AddPage(category, htmlCode, isWebsite)
	self:AddCategory(category, false);
	
	local categoryTable = self:GetCategory(category);
	local panel = self:GetPanel();
	
	if (categoryTable) then
		categoryTable.isWebsite = isWebsite;
		categoryTable.pageData = htmlCode;
		categoryTable.isHTML = true;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
end;

-- A function to get the directory panel.
function Clockwork.directory:GetPanel()
	return self.panel;
end;

Clockwork.directory:SetCategorySorting("Commands", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode);
end);

Clockwork.directory:SetCategorySorting("Plugins", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode);
end);

Clockwork.directory:SetCategorySorting("Flags", function(a, b)
	local hasA = Clockwork.player:HasFlags(Clockwork.Client, a.sortData);
	local hasB = Clockwork.player:HasFlags(Clockwork.Client, b.sortData);
	
	if (hasA and hasB) then
		return a.sortData < b.sortData;
	elseif (hasA) then
		return true;
	else
		return false;
	end;
end);

Clockwork.directory:SetCategoryFormatting("Flags", [[
	<div class="cwContentBox">
		<div class="cwContentTitle">
			<img src="[icon]"/>Flags
		</div>
		<table class="cwTableMain">
			<tr>
				<td class="cwTableHeader">Flag</td>
				<td class="cwTableHeader">Details</td>
			</tr>
			[information]
		</table>
	</div>
]], true);

Clockwork.directory:AddCategoryMatch("Commands", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKVSURBVDjLfVNLSFRRGP7umTs+xubpTJQO4bRxoUGRZS1CCCa0oghatkpo4aZN0LJttIhx1UZs0aZ0UxaKgSFC0KZxhnxRaGqjiU7eUZur93n6z5lR0Kxz+e93H+f/vu//zzkK5xz/G+l0+rlt23csy1IJQSjDNE2BL5V/EWSz2SAl9IRCoduVlT4YlATXhZxNOeFwCMPDQ1APS85kMu0iORqN1tfU1OD7/BKEuutyuNwlIg6HyAzDgDo9PW04jlNBISft2hSoadpBy1hf14jIRfJKh/ymiuR4/AQKhQ2pzsXFhUsuQ7yQJiLhIN4OvEFT8xmpLv5JB4JVJD/sSdM0BYpC99JNooitzU08uXdOKo6nP0G4PX7tZsmBsCpUxcRwpBaMMSgUrBziWRBwx0WD8xGJBEPeaQQv94AJB9QTImDweDz7gpVRjsUBtLREcDLZhWOBLJzVdMmBVV4ehSnwqOqeukRRAuGFQAZR308EG5MoLgwhGCAHc68R2vZCFSyiIaIEoZg46pP1l4aC5Q0bTZFlBE9dh6NPoioax46TQ92lJiQ3xkoErFyniNmvf++LhmgAljZPAnlyVERFIA/s6Ciu7JQIvF4VjztPy+WxLBu6bpArF9VWDuGtQXirXbj2JJhbAJgf3DIx0zeHd7k4VOrk09HRD227G4Uw4vf7E7XWFHyY4HUdtxRuvofibGFiUIfXKMJDJaqtD7CyOIJ9Z6G7u/s+kdw433rxcrzQi/qWNpj5Z1DVICZGdAxOxqCxGO0DG9s2xH6Y2TsLqVQqRkuWam+/iiN+P5heAcWzBE9lDFPDv35/GV/tetQ79uJgf/YIyPo6xef+/ldnRSmNVWto/rGAoqabudm1zru93/oOO3h/ANOqi32og/qlAAAAAElFTkSuQmCC");
Clockwork.directory:AddCategoryMatch("Plugins", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHhSURBVDjLpZI9SJVxFMZ/r2YFflw/kcQsiJt5b1ije0tDtbQ3GtFQYwVNFbQ1ujRFa1MUJKQ4VhYqd7K4gopK3UIly+57nnMaXjHjqotnOfDnnOd/nt85SURwkDi02+ODqbsldxUlD0mvHw09ubSXQF1t8512nGJ/Uz/5lnxi0tB+E9QI3D//+EfVqhtppGxUNzCzmf0Ekojg4fS9cBeSoyzHQNuZxNyYXp5ZM5Mk1ZkZT688b6thIBenG/N4OB5B4InciYBCVyGnEBHO+/LH3SFKQuF4OEs/51ndXMXC8Ajqknrcg1O5PGa2h4CJUqVES0OO7sYevv2qoFBmJ/4gF4boaOrg6rPLYWaYiVfDo0my8w5uj12PQleB0vcp5I6HsHAUoqUhR29zH+5B4IxNTvDmxljy3x2YCYUwZVlbzXJh9UKeQY6t2m0Lt94Oh5loPdqK3EkjzZi4MM/Y9Db3MTv/mYWVxaqkw9IOATNR7B5ABHPrZQrtg9sb8XDKa1+QOwsri4zeHD9SAzE1wxBTXz9xtvMc5ZU5lirLSKIz18nJnhOZjb22YKkhd4odg5icpcoyL669TAAujlyIvmPHSWXY1ti1AmZ8mJ3ElP1ips1/YM3H300g+W+51nc95YPEX8fEbdA2ReVYAAAAAElFTkSuQmCC");
Clockwork.directory:AddCategoryMatch("Flags", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAH0SURBVDjLlZPLbxJRGMX5X/xbjBpjjCtXLl2L0YWkaZrhNQwdIA4FZxygC22wltYYSltG1HGGl8nopCMPX9AUKQjacdW4GNPTOywak7ZAF/eRe/M73/nOzXUAcEwaqVTKmUgkGqIoWoIgWP/fTYSTyaSTgAfdbhemaSIej+NcAgRudDod9Pt95PN5RKPR8wnwPG/Z1XVdB8dxin0WDofBsiyCwaA1UYBY/tdqtVAqlRCJRN6FQiE1k8mg2WyCpunxArFY7DKxfFir1VCtVlEoFCBJEhRFQbFYhM/na5wKzq/+4ALprzqxbFUqFWiaBnstl8tQVRWyLMPr9R643W7nCZhZ3uUS+T74jR7Y5c8wDAO5XA4MwxzalklVy+PxNCiKcp4IkbbhzR4K+h9IH02wax3MiAYCgcBfv99/4TS3xxtfepcTCPyKgGl5gCevfyJb/Q3q6Q5uMcb7s3IaTZ6lHY5f70H6YGLp7QDx9T0kSRtr5V9wLbZxw1N/fqbAHIEXsj1saQR+M8BCdg8icbJaHOJBqo3r1KfMuJdyuBZb2NT2R5a5l108JuFl1CHuJ9q4NjceHgncefSN9LoPcYskT9pYIfA9Al+Z3X4xzUdz3H74RbODWlGGeCYPcVf4jksz08HHId6k63USFK7ObuOia3rYHkdyavlR+267GwAAAABJRU5ErkJggg==");

Clockwork.directory:SetCategoryTip("Clockwork", "Contains topics based on the Clockwork framework.");
Clockwork.directory:SetCategoryTip("Commands", "Contains a list of commands and their syntax.");

Clockwork.directory:AddCategoryPage("Credits", "Clockwork", "http://script.cloudsixteen.com/credits/", true);
Clockwork.directory:AddCategory("Plugins", "Clockwork");
Clockwork.directory:AddCategory("Flags", "Clockwork");