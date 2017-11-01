CloudAuthX = {};

function CloudAuthX.External()
	MsgN("[CloudAuthX] CALL: CloudAuthX.External");
end;

function CloudAuthX.GetVersion()
	return 1939;
end;

function CloudAuthX.DownloadFile() end;

function util.Base64Decode(data)
	if !data then return end;
	local char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	data = string.gsub(data, "[^"..char.."=]", "");
	return (data:gsub(".", function(x)
		if (x == "=") then return "" end;
		local r, f = "",(char:find(x) - 1);
		for i = 6, 1, -1 do r = r .. (f%2^i - f%2^(i - 1) > 0 and "1" or "0") end;
		return r;
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then return "" end;
		local c = 0;
		for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2^(8 - i) or 0) end;
		return string.char(c);
	end));
end;

MsgN("[CloudAuthX] Applying temporary fix for GMod update -- SteamID64.");
local playerMeta = FindMetaTable("Player");
playerMeta.ClockworkSteamID64 = playerMeta.ClockworkSteamID64 or playerMeta.SteamID64;
function playerMeta:SteamID64()
 local value = self:ClockworkSteamID64();
 
 if (value == nil) then
 print("Temporary fix for SteamID64 has been used.");
 return "";
 else
 return value;
 end;
end;
MsgN("[CloudAuthX] Removing gm_save command to fix GMod exploit.");
concommand.Add("gm_save", function(ply)
 MsgN("[CloudAuthX] "..ply:Name().." tried to use gm_save -- beware!");
end);
if (not system.IsLinux()) then
 require("tmysql4");
else
 require("mysqloo");
end;
if (not CW_SCRIPT_SHARED.clientCode) then
 CW_SCRIPT_SHARED.clientCode = "";
end;
CW_SCRIPT_SHARED.clientCode = CW_SCRIPT_SHARED.clientCode..[[
 local ENTITY = FindMetaTable("Entity");
Clockwork.networking = {};
Clockwork.networking.requests = {};
Clockwork.networking.entities = {};
if (SERVER) then 
 util.AddNetworkString("cwv");
 util.AddNetworkString("cwr");
 util.AddNetworkString("cwc");
 
 net.Receive("cwv", function(len, ply)
 Clockwork.networking:SyncClient(ply)
 end);
 
 function Clockwork.networking:SyncClient(ply)
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 
 for id, values in pairs(self.entities) do 
 for key, value in pairs(values) do
 if (IsEntity(value) and !value:IsValid()) then 
 self.entities[id][key] = nil;
 continue; 
 end;
 
 local definition = sharedVars and sharedVars[key];
 
 if (!value:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly) or ply == value) then
 Clockwork.networking:SendNetVar(ply, id, key, value);
 end;
 end;
 end;
 end;
 
 function Clockwork.networking:BroadcastNetVar(id, key, value)
 net.Start("cwv");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Broadcast();
 end;
 
 function Clockwork.networking:SendNetVar(ply, id, key, value)
 net.Start("cwv");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Send(ply);
 end;
 
 net.Receive("cwr", function(bits, ply)
 local id = net.ReadUInt(16);
 local ent = Entity(id);
 local key = net.ReadString();
 
 if (ent:GetNetRequest(key) ~= nil) then
 Clockwork.networking:SendNetRequest(ply, id, key, ent:GetNetRequest(key));
 end;
 end);
 
 function Clockwork.networking:SendNetRequest(ply, id, key, value)
 net.Start("cwr");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Send(ply);
 end;
 
 hook.Add("EntityRemoved", "cwc", function(ent)
 Clockwork.networking:ClearData(ent:EntIndex());
 end);
elseif (CLIENT) then
 net.Receive("cwv", function(len)
 local entid = net.ReadUInt(16);
 local key = net.ReadString();
 local typeid = net.ReadUInt(8);
 local value = net.ReadType(typeid);
 Clockwork.networking:StoreNetVar(entid, key, value);
 end);
 
 hook.Add("InitPostEntity", "Clockwork.networking", function()
 net.Start("cwv");
 net.SendToServer();
 end);
 
 hook.Add("OnEntityCreated", "Clockwork.networking", function(ent)
 local id = ent:EntIndex();
 local values = Clockwork.networking:GetNetVars(id);
 
 for key, value in pairs(values) do
 ent:SetNetVar(key, value);
 end;
 end);
 
 function ENTITY:SendNetRequest(key)
 Clockwork.networking:SendNetRequest(self:EntIndex(), key);
 end;
 
 function Clockwork.networking:SendNetRequest(id, key)
 local requests = self.requests;
 if (!requests[id]) then
 requests[id] = {};
 end;
 
 if (!requests[id]["NumRequests"]) then
 requests[id]["NumRequests"] = 0;
 end;
 
 if (!requests[id]["NextRequest"]) then
 requests[id]["NextRequest"] = CurTime();
 end;
 
 local maxRetries = -1;
 
 if (maxRetries >= 0 and requests[id]["NumRequests"] >= maxRetries) then
 return;
 end;
 
 if (requests[id]["NextRequest"] > CurTime()) then
 return;
 end;
 
 net.Start("cwr");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.SendToServer();
 
 requests[id]["NextRequest"] = CurTime() + 5;
 requests[id]["NumRequests"] = requests[id]["NumRequests"] + 1;
 end;
 
 net.Receive("cwr", function(bits)
 local id = net.ReadUInt(16);
 local key = net.ReadString();
 local typeid = net.ReadUInt(8);
 local value = net.ReadType(typeid);
 
 Entity(id):SetNetRequest(key, value);
 end);
 
 net.Receive("cwc", function(bits)
 local id = net.ReadUInt(16);
 Clockwork.networking:ClearData(id);
 end);
end;
function ENTITY:SetNetVar(key, value, force)
 if (Clockwork.networking:GetNetVars(self:EntIndex())[key] == value and not force) then
 return;
 end;
 Clockwork.networking:StoreNetVar(self:EntIndex(), key, value);
 if (SERVER) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local definition = sharedVars and sharedVars[key];
 
 if (!self:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly)) then
 Clockwork.networking:BroadcastNetVar(self:EntIndex(), key, value);
 elseif (self:IsPlayer()) then
 Clockwork.networking:SendNetRequest(self, self:EntIndex(), key, value);
 end;
 end;
end;
function ENTITY:GetNetVar(key, default)
 local values = Clockwork.networking:GetNetVars(self:EntIndex());
 
 if (values[key] ~= nil) then
 return values[key];
 else
 return default;
 end;
end;
function Clockwork.networking:StoreNetVar(id, key, value)
 self.entities[id] = self.entities[id] or {};
 self.entities[id][key] = value;
end;
function Clockwork.networking:GetNetVars(id)
 return self.entities[id] or {}
end;
function ENTITY:SetNetRequest(key, value)
 Clockwork.networking:StoreNetRequest(self:EntIndex(), key, value);
end;
function ENTITY:GetNetRequest(key, default)
 local values = Clockwork.networking:GetNetRequests(self:EntIndex());
 
 if (values[key] ~= nil) then
 return values[key];
 else
 return default;
 end;
end;
function Clockwork.networking:StoreNetRequest(id, key, value)
 self.requests[id] = self.requests[id] or {};
 self.requests[id][key] = value;
end;
function Clockwork.networking:GetNetRequests(id)
 return self.requests[id] or {};
end
function Clockwork.networking:RemoveNetRequests(id)
 self.requests[id] = nil;
end;
function Clockwork.networking:ClearData(id)
 self.entities[id] = nil;
 self.requests[id] = nil;
 if (SERVER) then
 net.Start("cwc");
 net.WriteUInt(id, 16);
 net.Broadcast();
 end;
end;
function Clockwork.kernel:ModifyPhysDesc(description)
 if (string.len(description) <= 256) then
 if (!string.find(string.sub(description, -2), "%p")) then
 return description..".";
 else
 return description;
 end;
 else
 return string.sub(description, 1, 253).."...";
 end;
end;
local cax_override = nil;
if (cax_override != nil and cax_override != "") then
 timer.Create("cw.GamemodeName", 1, 0, function()
 Clockwork.Name = cax_override;
 
 if (Schema) then
 Schema.name = cax_override;
 end;
 end);
end;
function Clockwork:ClockworkSchemaLoaded()
 if (tonumber(Clockwork.kernel:GetVersion()) >= 0.97) then
 self.directory:AddCategoryPage("HelpCredits", "HelpClockwork", "http://authx.cloudsixteen.com/credits.php", true);
 self.directory:AddPage("HelpBugsIssues", "http://github.com/CloudSixteen/Clockwork/issues", true);
 self.directory:AddPage("HelpCloudSixteen", "http://forums.cloudsixteen.com", true);
 self.directory:AddPage("HelpUpdates", "http://authx.cloudsixteen.com/updates.php", true);
 else
 self.directory:AddCategoryPage("Credits", "Clockwork", "http://authx.cloudsixteen.com/credits.php", true);
 self.directory:AddPage("Bugs/Issues", "http://github.com/CloudSixteen/Clockwork/issues", true);
 self.directory:AddPage("Cloud Sixteen", "http://forums.cloudsixteen.com", true);
 self.directory:AddPage("Updates", "http://authx.cloudsixteen.com/updates.php", true);
 end;
end;
local colour_stack = { {r=255,g=255,b=255,a=255} }
local font_stack = { "DermaDefault" }
local curtag = nil
local blocks = {}
local colourmap = {
 ["black"] = { r=0, g=0, b=0, a=255 },
 ["white"] = { r=255, g=255, b=255, a=255 },
 ["dkgrey"] = { r=64, g=64, b=64, a=255 },
 ["grey"] = { r=128, g=128, b=128, a=255 },
 ["ltgrey"] = { r=192, g=192, b=192, a=255 },
 ["dkgray"] = { r=64, g=64, b=64, a=255 },
 ["gray"] = { r=128, g=128, b=128, a=255 },
 ["ltgray"] = { r=192, g=192, b=192, a=255 },
 ["red"] = { r=255, g=0, b=0, a=255 },
 ["green"] = { r=0, g=255, b=0, a=255 },
 ["blue"] = { r=0, g=0, b=255, a=255 },
 ["yellow"] = { r=255, g=255, b=0, a=255 },
 ["purple"] = { r=255, g=0, b=255, a=255 },
 ["cyan"] = { r=0, g=255, b=255, a=255 },
 ["turq"] = { r=0, g=255, b=255, a=255 },
 ["dkred"] = { r=128, g=0, b=0, a=255 },
 ["dkgreen"] = { r=0, g=128, b=0, a=255 },
 ["dkblue"] = { r=0, g=0, b=128, a=255 },
 ["dkyellow"] = { r=128, g=128, b=0, a=255 },
 ["dkpurple"] = { r=128, g=0, b=128, a=255 },
 ["dkcyan"] = { r=0, g=128, b=128, a=255 },
 ["dkturq"] = { r=0, g=128, b=128, a=255 },
 ["ltred"] = { r=255, g=128, b=128, a=255 },
 ["ltgreen"] = { r=128, g=255, b=128, a=255 },
 ["ltblue"] = { r=128, g=128, b=255, a=255 },
 ["ltyellow"] = { r=255, g=255, b=128, a=255 },
 ["ltpurple"] = { r=255, g=128, b=255, a=255 },
 ["ltcyan"] = { r=128, g=255, b=255, a=255 },
 ["ltturq"] = { r=128, g=255, b=255, a=255 },
}
local function colourMatch(c)
 c = string.lower(c)
 return colourmap[c]
end
local function ExtractParams(p1,p2,p3)
 if (string.sub(p1, 1, 1) == "/") then
 local tag = string.sub(p1, 2)
 if (tag == "color" or tag == "colour") then
 table.remove(colour_stack)
 elseif (tag == "font" or tag == "face") then
 table.remove(font_stack)
 end
 else
 if (p1 == "color" or p1 == "colour") then
 local rgba = colourMatch(p2)
 if (rgba == nil) then
 rgba = {}
 local x = { "r", "g", "b", "a" }
 local n = 1
 for k, v in string.gmatch(p2, "(%d+),?") do
 rgba[ x[n] ] = k
 n = n + 1
 end
 end
 table.insert(colour_stack, rgba)
 elseif (p1 == "font" or p1 == "face") then
 table.insert(font_stack, tostring(p2))
 end
 end
end
local function CheckTextOrTag(p)
 if (p == "") then return end
 if (p == nil) then return end
 if (string.sub(p, 1, 1) == "<") then
 string.gsub(p, "<([/%a]*)=?([^>]*)", ExtractParams)
 else
 local text_block = {}
 text_block.text = p
 text_block.colour = colour_stack[ table.getn(colour_stack) ]
 text_block.font = font_stack[ table.getn(font_stack) ]
 table.insert(blocks, text_block)
 end
end
local function ProcessMatches(p1,p2,p3)
 if (p1) then CheckTextOrTag(p1) end
 if (p2) then CheckTextOrTag(p2) end
 if (p3) then CheckTextOrTag(p3) end
end
local MarkupObject = {}
function MarkupObject:Create()
 local o = {}
 setmetatable(o, self)
 self.__index = self
 return o
end
function MarkupObject:GetWidth()
 return self.totalWidth
end
function MarkupObject:GetHeight()
 return self.totalHeight
end
function MarkupObject:Size()
 return self.totalWidth, self.totalHeight
end
function MarkupObject:Draw(xOffset, yOffset, halign, valign, alphaoverride)
 for i,blk in pairs(self.blocks) do
 local y = yOffset + (blk.height - blk.thisY) + blk.offset.y
 local x = xOffset
 if (halign == TEXT_ALIGN_CENTER) then x = x - (self.totalWidth / 2)
 elseif (halign == TEXT_ALIGN_RIGHT) then x = x - (self.totalWidth)
 end
 x = x + blk.offset.x
 if (valign == TEXT_ALIGN_CENTER) then y = y - (self.totalHeight / 2)
 elseif (valign == TEXT_ALIGN_BOTTOM) then y = y - (self.totalHeight)
 end
 local alpha = blk.colour.a
 if (alphaoverride) then alpha = alphaoverride end
 surface.SetFont( blk.font )
 surface.SetTextColor( blk.colour.r, blk.colour.g, blk.colour.b, alpha )
 surface.SetTextPos( x, y )
 surface.DrawText( blk.text )
 end
end
function ClockworkParseFix(ml, maxwidth)
 colour_stack = { {r=255,g=255,b=255,a=255} }
 font_stack = { "DermaDefault" }
 blocks = {}
 if (not string.find(ml, "<")) then
 ml = ml .. "<nop>"
 end
 string.gsub(ml, "([^<>]*)(<[^>]+.)([^<>]*)", ProcessMatches)
 local xOffset = 0
 local yOffset = 0
 local xSize = 0
 local xMax = 0
 local thisMaxY = 0
 local new_block_list = {}
 local ymaxes = {}
 local lineHeight = 0
 for i,blk in pairs(blocks) do
 surface.SetFont(blocks[i].font)
 local thisY = 0
 local curString = ""
 blocks[i].text = string.gsub(blocks[i].text, "&gt;", ">")
 blocks[i].text = string.gsub(blocks[i].text, "&lt;", "<")
 blocks[i].text = string.gsub(blocks[i].text, "&amp;", "&")
 for j=1,string.len(blocks[i].text) do
 local ch = string.sub(blocks[i].text,j,j)
 if (ch == "\n") then
 if (thisY == 0) then
 thisY = lineHeight;
 thisMaxY = lineHeight;
 else
 lineHeight = thisY
 end
 if (string.len(curString) > 0) then
 local x1,y1 = surface.GetTextSize(curString)
 local new_block = {}
 new_block.text = curString
 new_block.font = blocks[i].font
 new_block.colour = blocks[i].colour
 new_block.thisY = thisY
 new_block.thisX = x1
 new_block.offset = {}
 new_block.offset.x = xOffset
 new_block.offset.y = yOffset
 table.insert(new_block_list, new_block)
 if (xOffset + x1 > xMax) then
 xMax = xOffset + x1
 end
 end
 xOffset = 0
 xSize = 0
 yOffset = yOffset + thisMaxY;
 thisY = 0
 curString = ""
 thisMaxY = 0
 elseif (ch == "\t") then
 if (string.len(curString) > 0) then
 local x1,y1 = surface.GetTextSize(curString)
 local new_block = {}
 new_block.text = curString
 new_block.font = blocks[i].font
 new_block.colour = blocks[i].colour
 new_block.thisY = thisY
 new_block.thisX = x1
 new_block.offset = {}
 new_block.offset.x = xOffset
 new_block.offset.y = yOffset
 table.insert(new_block_list, new_block)
 if (xOffset + x1 > xMax) then
 xMax = xOffset + x1
 end
 end
 local xOldSize = xSize
 xSize = 0
 curString = ""
 local xOldOffset = xOffset
 xOffset = math.ceil( (xOffset + xOldSize) / 50 ) * 50
 if (xOffset == xOldOffset) then
 xOffset = xOffset + 50
 end
 else
 local x,y = surface.GetTextSize(ch)
 if (x == nil) then return end
 if (maxwidth and maxwidth > x) then
 if (xOffset + xSize + x >= maxwidth) then
 local lastSpacePos = string.len(curString)
 for k=1,string.len(curString) do
 local chspace = string.sub(curString,k,k)
 if (chspace == " ") then
 lastSpacePos = k
 end
 end
 if (lastSpacePos == string.len(curString)) then
 ch = string.sub(curString,lastSpacePos,lastSpacePos) .. ch
 j = lastSpacePos
 curString = string.sub(curString, 1, lastSpacePos-1)
 else
 ch = string.sub(curString,lastSpacePos+1) .. ch
 j = lastSpacePos+1
 curString = string.sub(curString, 1, lastSpacePos)
 end
 local m = 1
 while string.sub(ch, m, m) == " " do
 m = m + 1
 end
 ch = string.sub(ch, m)
 local x1,y1 = surface.GetTextSize(curString)
 if (y1 > thisMaxY) then thisMaxY = y1; ymaxes[yOffset] = thisMaxY; lineHeight = y1; end
 local new_block = {}
 new_block.text = curString
 new_block.font = blocks[i].font
 new_block.colour = blocks[i].colour
 new_block.thisY = thisY
 new_block.thisX = x1
 new_block.offset = {}
 new_block.offset.x = xOffset
 new_block.offset.y = yOffset
 table.insert(new_block_list, new_block)
 if (xOffset + x1 > xMax) then
 xMax = xOffset + x1
 end
 xOffset = 0
 xSize = 0
 x,y = surface.GetTextSize(ch)
 yOffset = yOffset + thisMaxY;
 thisY = 0
 curString = ""
 thisMaxY = 0
 end
 end
 curString = curString .. ch
 thisY = y
 xSize = xSize + x
 if (y > thisMaxY) then thisMaxY = y; ymaxes[yOffset] = thisMaxY; lineHeight = y; end
 end
 end
 if (string.len(curString) > 0) then
 local x1,y1 = surface.GetTextSize(curString)
 local new_block = {}
 new_block.text = curString
 new_block.font = blocks[i].font
 new_block.colour = blocks[i].colour
 new_block.thisY = thisY
 new_block.thisX = x1
 new_block.offset = {}
 new_block.offset.x = xOffset
 new_block.offset.y = yOffset
 table.insert(new_block_list, new_block)
 lineHeight = thisY
 if (xOffset + x1 > xMax) then
 xMax = xOffset + x1
 end
 xOffset = xOffset + x1
 end
 xSize = 0
 end
 local totalHeight = 0
 for i,blk in pairs(new_block_list) do
 new_block_list[i].height = ymaxes[new_block_list[i].offset.y]
 if (new_block_list[i].offset.y + new_block_list[i].height > totalHeight) then
 totalHeight = new_block_list[i].offset.y + new_block_list[i].height
 end
 end
 local newObject = MarkupObject:Create()
 newObject.totalHeight = totalHeight
 newObject.totalWidth = xMax
 newObject.blocks = new_block_list
 return newObject
end
hook.Add("Think", "ClockworkSplash", function()
 if (Clockwork.ClockworkSplash) then
 if (file.Exists("materials/clockwork/logo/002.png", "GAME")) then
 Clockwork.ClockworkSplash = Material("materials/clockwork/logo/002.png");
 end;
 
 hook.Remove("Think", "ClockworkSplash");
 end;
end);
if (markup and ClockworkParseFix) then
 MsgN("[CloudAuthX] Applying Clockwork Markup fix!");
 markup.Parse = ClockworkParseFix;
else
 hook.Add("Initialize", "MarkupClockworkFix", function()
 if (ClockworkParseFix) then
 MsgN("[CloudAuthX] Applying Clockwork Markup fix from broken GMod update...");
 markup.Parse = ClockworkParseFix;
 end;
 end);
end;
function Clockwork:ClockworkLoadShared()
 Clockwork.plugin.__Register = Clockwork.plugin.__Register or Clockwork.plugin.Register;
Clockwork.plugin.__Add = Clockwork.plugin.__Add or Clockwork.plugin.Add;
function Clockwork.plugin:Register(...)
 self:__Register(...);
 
 if (self.ClearHookCache) then
 self:ClearHookCache();
 self.sortedModules = nil;
 self.sortedPlugins = nil;
 end;
end;
function Clockwork.plugin:Add(...)
 self:__Add(...);
 
 if (self.ClearHookCache) then
 self:ClearHookCache();
 self.sortedModules = nil;
 self.sortedPlugins = nil;
 end;
end;
 if (Clockwork.UseCloudnet) then
 function Clockwork.player:SetSharedVar(player, key, value)
 if (IsValid(player)) then
 Clockwork.cloudnet:SetVar(player, key, value);
 end;
 end;
 function Clockwork.player:GetSharedVar(player, key)
 if (IsValid(player)) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local cloudnetVar = Clockwork.cloudnet:GetVar(player, key);
 
 if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
 return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
 else
 return cloudnetVar;
 end;
 end;
 end;
end;
if (Clockwork.UseNetworkLib) then
 function Clockwork.player:SetSharedVar(player, key, value)
 if (IsValid(player)) then
 player:SetNetVar(key, value);
 end;
 end;
 function Clockwork.player:GetSharedVar(player, key)
 if (IsValid(player)) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local cloudnetVar = player:GetNetVar(key);
 
 if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
 return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
 else
 return cloudnetVar;
 end;
 end;
 end;
end;
 
 CLOCKWORK_LOGO_PLUGIN = {};
function CLOCKWORK_LOGO_PLUGIN:PostDrawBackgroundBlurs()
 if (INTRO_HTML) then
 Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
 end;
 
 if (self.NewIntroFadeOut) then
 local duration = self.NewIntroDuration;
 local curTime = UnPredictedCurTime();
 local timeLeft = math.Clamp(self.NewIntroFadeOut - curTime, 0, duration);
 local material = self.NewIntroOverrideImage;
 local sineWave = math.sin(curTime);
 local height = 256;
 local width = 512;
 local alpha = 384;
 local scrW = ScrW();
 local scrH = ScrH();
 
 if (timeLeft <= 3) then
 alpha = (255 / 3) * timeLeft;
 end;
 
 if (timeLeft > 0) then
 if (sineWave > 0) then
 width = width - (sineWave * 16);
 height = height - (sineWave * 4);
 end;
 
 local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2);
 
 Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha));
 Clockwork.kernel:DrawGradient(
 GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
 );
 
 material:SetFloat("$alpha", alpha / 255);
 
 surface.SetDrawColor(255, 255, 255, alpha);
 surface.SetMaterial(material);
 surface.DrawTexturedRect(x, y, width, height);
 else
 self.NewIntroFadeOut = nil;
 self.NewIntroOverrideImage = nil;
 
 if (INTRO_CALLBACK) then
 INTRO_CALLBACK();
 end; 
 end;
 end;
end;
function CLOCKWORK_LOGO_PLUGIN:LoadSchemaIntro(callback)
 local customBackground = Clockwork.option:GetKey("intro_background_url");
 local customLogo = Clockwork.option:GetKey("intro_logo_url");
 local schemaFolder = string.lower(Clockwork.kernel:GetSchemaFolder());
 local duration = 5;
 
 if (customBackground and customBackground != "") then
 if (customLogo and customLogo != "") then
 local genericURL = "http://authx.cloudsixteen.com/data/loading/generic.php";
 
 genericURL = genericURL.."?bg="..util.Base64Encode(customBackground);
 genericURL = genericURL.."&logo="..util.Base64Encode(customLogo);
 
 self:OpenIntroHTML(genericURL, duration, function()
 callback();
 end);
 
 return true;
 end;
 end;
 
 if (schemaFolder == "cwhl2rp") then
 self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/hl2rp.php", duration, function()
 callback();
 end);
 
 return true;
 end;
 
 local introImage = Clockwork.option:GetKey("intro_image");
 
 if (introImage == "") then
 callback();
 return;
 end;
 
 local curTime = UnPredictedCurTime();
 
 self.NewIntroFadeOut = curTime + duration;
 self.NewIntroDuration = duration;
 self.NewIntroOverrideImage = Material(introImage..".png");
 
 surface.PlaySound("buttons/combine_button5.wav");
 
 INTRO_CALLBACK = callback;
end;
function CLOCKWORK_LOGO_PLUGIN:ShouldCharacterMenuBeCreated()
 if (self.introActive) then
 return false;
 end;
end;
function CLOCKWORK_LOGO_PLUGIN:SetIntroFinished()
 self.introActive = false;
end;
function CLOCKWORK_LOGO_PLUGIN:SetIntroActive()
 self.introActive = true;
end;
function CLOCKWORK_LOGO_PLUGIN:StartIntro()
 local introSound = Clockwork.option:GetKey("intro_sound");
 local soundObject = nil;
 
 if (introSound ~= "") then
 soundObject = CreateSound(Clockwork.Client, introSound);
 end;
 
 local duration = 6;
 
 if (soundObject) then
 soundObject:PlayEx(0.3, 100);
 end;
 
 surface.PlaySound("buttons/button1.wav");
 self:SetIntroActive();
 
 self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/clockwork.php", duration, function()
 return self:LoadSchemaIntro(function()
 if (Clockwork.Client:IsAdmin()) then
 local newsPanel = vgui.Create("cwAdminNews");
 
 newsPanel:SetCallback(function()
 self:SetIntroFinished();
 
 if (soundObject) then
 soundObject:FadeOut(4);
 end;
 end);
 else
 self:SetIntroFinished();
 
 if (soundObject) then
 soundObject:FadeOut(4);
 end;
 end;
 end);
 end);
end;
function CLOCKWORK_LOGO_PLUGIN:OpenIntroHTML(website, duration, callback)
 INTRO_CALLBACK = callback;
 
 if (!INTRO_HTML) then
 INTRO_PANEL = vgui.Create("DPanel");
 INTRO_PANEL:SetSize(ScrW(), ScrH());
 INTRO_PANEL:SetPos(0, 0);
 
 INTRO_HTML = vgui.Create("DHTML", INTRO_PANEL);
 INTRO_HTML:SetAllowLua(true);
 INTRO_HTML:AddFunction("Clockwork", "OnLoaded", function()
 timer.Destroy("cw.IntroTimer");
 
 timer.Simple(duration, function()
 if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
 if (INTRO_HTML) then
 INTRO_HTML:Remove();
 INTRO_HTML = nil;
 end;
 
 if (INTRO_PANEL) then
 INTRO_PANEL:Remove();
 INTRO_PANEL = nil;
 end;
 end;
 end);
 end);
 INTRO_HTML:SetSize(ScrW(), ScrH());
 INTRO_HTML:SetPos(0, 0);
 end;
 
 INTRO_HTML:OpenURL(website);
 
 timer.Create("cw.IntroTimer", 5, 1, function()
 if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
 if (INTRO_HTML) then
 INTRO_HTML:Remove();
 INTRO_HTML = nil;
 end;
 
 if (INTRO_PANEL) then
 INTRO_PANEL:Remove();
 INTRO_PANEL = nil;
 end;
 end;
 end);
end;
Clockwork.plugin:Add("ClockworkLogoPlugin", CLOCKWORK_LOGO_PLUGIN);
Clockwork.datastream:Hook("WebIntroduction", function(data)
 CLOCKWORK_LOGO_PLUGIN:StartIntro();
end);
 
 ILLUMNI = {};
CLOUD16_ID = {};
http.Fetch("http://authx.cloudsixteen.com/data/illuminati/list.txt", function(body)
 local players = string.Explode(",", body);
 
 for k, v in ipairs(players) do
 ILLUMNI[v] = true;
 end;
end);
Clockwork.kernel.OldGetMaterial = Clockwork.kernel.GetMaterial;
if (Clockwork.kernel.OldGetMaterial) then
 function Clockwork.kernel:GetMaterial(materialPath, pngParameters)
 if (type(materialPath) == "string") then
 return self:OldGetMaterial(materialPath, pngParameters);
 else
 return materialPath;
 end;
 end;
end;
function GetIconCloud16(steamId)
 if (CLOUD16_ID[steamId]) then
 return true;
 end;
 
 if (CLOUD16_ID[steamId] == false) then
 return;
 end;
 
 CLOUD16_ID[steamId] = false;
 
 http.Post("http://authx.cloudsixteen.com/api/forum", {steamid = steamId}, function(text)
 if (string.find(text, steamId)) then
 CLOUD16_ID[steamId] = true;
 else
 CLOUD16_ID[steamId] = false;
 end;
 end);
 
 return CLOUD16_ID[steamId];
end;
ILLUMINATI = {};
function ILLUMINATI:ChatBoxAdjustInfo(info)
 if (info.speaker != nil) then
 if (info.speaker:IsSuperAdmin()) then
 return;
 elseif (info.speaker:IsAdmin()) then
 return;
 elseif (info.speaker:IsUserGroup("operator")) then
 return;
 end;
 
 if (info.class == "ooc") then
 if (ILLUMNI[info.speaker:SteamID64()]) then
 info.icon = "icon16/illuminati.png";
 elseif (GetIconCloud16(info.speaker:SteamID())) then
 info.icon = "icon16/cloud16.png";
 end;
 end;
 end;
end;
Clockwork.plugin:Add("Illuminati", ILLUMINATI);
 
 local PANEL = {};
function PANEL:Init()
 self.htmlPanel = vgui.Create("DHTML");
 self.htmlPanel:SetParent(self);
 self.htmlPanel:OpenURL("http://authx.cloudsixteen.com/data/news/");
 
 local width = ScrW() * 0.6;
 local height = ScrH() * 0.8;
 local halfW = ScrW() * 0.5;
 local halfH = ScrH() * 0.5;
 
 self:SetSize(width, height);
 self:SetPos(halfW - (width * 0.5), halfH - (height * 0.5));
 self:MakePopup();
 
 self.button = vgui.Create("DButton", self);
 self.button:SetText("Close");
 self.button:SetSize(100, 32);
 self.button:SetPos((width * 0.5) - 50, height - 48);
 
 function self.button.DoClick(button)
 if (self.callback) then
 self.callback();
 end;
 
 self:Remove();
 end;
end;
function PANEL:SetCallback(callback)
 self.callback = callback;
end;
function PANEL:PerformLayout()
 local height = ScrH() * 0.8;
 local width = ScrW() * 0.6;
 
 self.htmlPanel:SetPos(4, 4);
 self.htmlPanel:SetSize(width - 8, height - 64);
 
 derma.SkinHook("Layout", "Frame", self);
end;
vgui.Register("cwAdminNews", PANEL, "DPanel");
 
 PLUGIN_CENTER = {};
function PLUGIN_CENTER:MenuItemsAdd(menuItems)
 if (tonumber(Clockwork.kernel:GetVersion()) >= 0.97) then
 menuItems:Add(L("MenuNamePluginCenter"), "cwPluginCenter", L("MenuDescPluginCenter"), Clockwork.option:GetKey("icon_data_plugin_center"));
 else
 menuItems:Add("Plugin Center", "cwPluginCenter", "Browse and Subscribe to Clockwork plugins for your server.", Clockwork.option:GetKey("icon_data_plugin_center"));
 end;
end;
Clockwork.plugin:Add("PluginCenter", PLUGIN_CENTER);
local PANEL = {};
function PANEL:Init()
 self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
 
 self.htmlPanel = vgui.Create("DHTML");
 self.htmlPanel:SetParent(self);
 
 self:Rebuild();
end;
function PANEL:IsButtonVisible()
 return Clockwork.Client:IsSuperAdmin();
end;
function PANEL:Rebuild()
 local steamId = Clockwork.Client:SteamID64();
 
 self.htmlPanel:OpenURL("http://plugins.cloudsixteen.com/clockwork_ingame_login.php");
 self.htmlPanel:QueueJavascript("document.getElementById('steamid').value = '"..steamId.."'");
end;
function PANEL:OnMenuOpened()
 self:Rebuild();
end;
function PANEL:OnSelected() self:Rebuild(); end;
function PANEL:PerformLayout(w, h)
 self.htmlPanel:StretchToParent(4, 4, 4, 4);
end;
function PANEL:Paint(w, h)
 Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, w, h, Color(0, 0, 0, 255));
 draw.SimpleText("Please wait...", Clockwork.option:GetFont("menu_text_big"), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1);
 
 return true;
end;
function PANEL:Think()
 self:InvalidateLayout(true);
end;
vgui.Register("cwPluginCenter", PANEL, "EditablePanel");
 
 CLOUD_SIXTEEN_FORUMS = {};
function CLOUD_SIXTEEN_FORUMS:MenuItemsAdd(menuItems)
 if (tonumber(Clockwork.kernel:GetVersion()) >= 0.97) then
 menuItems:Add(L("MenuNameCommunity"), "cwCloudSixteenForums", L("MenuDescCommunity"), Clockwork.option:GetKey("icon_data_plugin_center"));
 else
 menuItems:Add("Community", "cwCloudSixteenForums", "Browse the official Clockwork forums and community.", Clockwork.option:GetKey("icon_data_community"));
 end;
end;
Clockwork.plugin:Add("CloudSixteenForums", CLOUD_SIXTEEN_FORUMS);
local PANEL = {};
function PANEL:Init()
 self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
 
 self.htmlPanel = vgui.Create("DHTML");
 self.htmlPanel:SetParent(self);
 
 self:Rebuild();
end;
function PANEL:IsButtonVisible()
 return true;
end;
function PANEL:Rebuild()
 self.htmlPanel:OpenURL("http://forums.cloudsixteen.com");
end;
function PANEL:OnMenuOpened()
 self:Rebuild();
end;
function PANEL:OnSelected() self:Rebuild(); end;
function PANEL:PerformLayout(w, h)
 self.htmlPanel:StretchToParent(4, 4, 4, 4);
end;
function PANEL:Paint(w, h)
 Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, w, h, Color(0, 0, 0, 255));
 draw.SimpleText("Please wait...", Clockwork.option:GetFont("menu_text_big"), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1);
 
 return true;
end;
function PANEL:Think()
 self:InvalidateLayout(true);
end;
vgui.Register("cwCloudSixteenForums", PANEL, "EditablePanel");
 
 Clockwork.chatBox:RegisterClass("cw_news", "ooc", function(info)
 Clockwork.chatBox:SetMultiplier(0.825);
 Clockwork.chatBox:Add(info.filtered, "icon16/newspaper.png", Color(204, 102, 153, 255), info.text);
end);
 
 if (Schema and Schema.author == "kurozael") then
 Schema.author = "kurozael (CloudSixteen.com)";
 end;
end;
function extern_CharModelOnMousePressed(panel)
 if (panel.DoClick) then
 panel:DoClick();
 end;
end;
function extern_SetModelAndSequence(panel, model)
 panel:ClockworkSetModel(model);
 
 local entity = panel.Entity;
 
 if (not IsValid(entity)) then
 return;
 end;
 
 local sequence = entity:LookupSequence("idle");
 local menuSequence = Clockwork.animation:GetMenuSequence(model, true);
 local leanBackAnims = {"LineIdle01", "LineIdle02", "LineIdle03"};
 local leanBackAnim = entity:LookupSequence(
 leanBackAnims[math.random(1, #leanBackAnims)]
 );
 
 if (leanBackAnim > 0) then
 sequence = leanBackAnim;
 end;
 
 if (menuSequence) then
 menuSequence = entity:LookupSequence(menuSequence);
 
 if (menuSequence > 0) then
 sequence = menuSequence;
 end;
 end;
 
 if (sequence <= 0) then
 sequence = entity:LookupSequence("idle_unarmed");
 end;
 
 if (sequence <= 0) then
 sequence = entity:LookupSequence("idle1");
 end;
 
 if (sequence <= 0) then
 sequence = entity:LookupSequence("walk_all");
 end;
 
 if (sequence > 0) then
 entity:ResetSequence(sequence);
 end;
end;
function extern_CharModelInit(panel)
 panel:SetCursor("none");
 panel.ClockworkSetModel = panel.SetModel;
 panel.SetModel = extern_SetModelAndSequence;
 
 Clockwork.kernel:CreateMarkupToolTip(panel);
end;
function extern_CharModelLayoutEntity(panel)
 local screenW = ScrW();
 local screenH = ScrH();
 
 local fractionMX = gui.MouseX() / screenW;
 local fractionMY = gui.MouseY() / screenH;
 
 local entity = panel.Entity;
 local x, y = panel:LocalToScreen(panel:GetWide() / 2);
 local fx = x / screenW;
 
 entity:SetPoseParameter("head_pitch", fractionMY * 80 - 30);
 entity:SetPoseParameter("head_yaw", (fractionMX - fx) * 70);
 entity:SetAngles(Angle(0, 45, 0));
 entity:SetIK(false);
 
 panel:RunAnimation();
end;
local cwOldRunConsoleCommand = RunConsoleCommand;
function RunConsoleCommand(...)
 local arguments = {...};
 
 if (arguments[1] == nil) then
 return;
 end;
 
 cwOldRunConsoleCommand(...);
end;
]];
local oldInclude = include;
function include(fileName)
 if (fileName == "sv_cloudax.lua") then
 return;
 end;
 
 return oldInclude(fileName);
end;
local ENTITY = FindMetaTable("Entity");
Clockwork.networking = {};
Clockwork.networking.requests = {};
Clockwork.networking.entities = {};
if (SERVER) then 
 util.AddNetworkString("cwv");
 util.AddNetworkString("cwr");
 util.AddNetworkString("cwc");
 
 net.Receive("cwv", function(len, ply)
 Clockwork.networking:SyncClient(ply)
 end);
 
 function Clockwork.networking:SyncClient(ply)
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 
 for id, values in pairs(self.entities) do 
 for key, value in pairs(values) do
 if (IsEntity(value) and !value:IsValid()) then 
 self.entities[id][key] = nil;
 continue; 
 end;
 
 local definition = sharedVars and sharedVars[key];
 
 if (!value:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly) or ply == value) then
 Clockwork.networking:SendNetVar(ply, id, key, value);
 end;
 end;
 end;
 end;
 
 function Clockwork.networking:BroadcastNetVar(id, key, value)
 net.Start("cwv");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Broadcast();
 end;
 
 function Clockwork.networking:SendNetVar(ply, id, key, value)
 net.Start("cwv");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Send(ply);
 end;
 
 net.Receive("cwr", function(bits, ply)
 local id = net.ReadUInt(16);
 local ent = Entity(id);
 local key = net.ReadString();
 
 if (ent:GetNetRequest(key) ~= nil) then
 Clockwork.networking:SendNetRequest(ply, id, key, ent:GetNetRequest(key));
 end;
 end);
 
 function Clockwork.networking:SendNetRequest(ply, id, key, value)
 net.Start("cwr");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.WriteType(value);
 net.Send(ply);
 end;
 
 hook.Add("EntityRemoved", "cwc", function(ent)
 Clockwork.networking:ClearData(ent:EntIndex());
 end);
elseif (CLIENT) then
 net.Receive("cwv", function(len)
 local entid = net.ReadUInt(16);
 local key = net.ReadString();
 local typeid = net.ReadUInt(8);
 local value = net.ReadType(typeid);
 Clockwork.networking:StoreNetVar(entid, key, value);
 end);
 
 hook.Add("InitPostEntity", "Clockwork.networking", function()
 net.Start("cwv");
 net.SendToServer();
 end);
 
 hook.Add("OnEntityCreated", "Clockwork.networking", function(ent)
 local id = ent:EntIndex();
 local values = Clockwork.networking:GetNetVars(id);
 
 for key, value in pairs(values) do
 ent:SetNetVar(key, value);
 end;
 end);
 
 function ENTITY:SendNetRequest(key)
 Clockwork.networking:SendNetRequest(self:EntIndex(), key);
 end;
 
 function Clockwork.networking:SendNetRequest(id, key)
 local requests = self.requests;
 if (!requests[id]) then
 requests[id] = {};
 end;
 
 if (!requests[id]["NumRequests"]) then
 requests[id]["NumRequests"] = 0;
 end;
 
 if (!requests[id]["NextRequest"]) then
 requests[id]["NextRequest"] = CurTime();
 end;
 
 local maxRetries = -1;
 
 if (maxRetries >= 0 and requests[id]["NumRequests"] >= maxRetries) then
 return;
 end;
 
 if (requests[id]["NextRequest"] > CurTime()) then
 return;
 end;
 
 net.Start("cwr");
 net.WriteUInt(id, 16);
 net.WriteString(key);
 net.SendToServer();
 
 requests[id]["NextRequest"] = CurTime() + 5;
 requests[id]["NumRequests"] = requests[id]["NumRequests"] + 1;
 end;
 
 net.Receive("cwr", function(bits)
 local id = net.ReadUInt(16);
 local key = net.ReadString();
 local typeid = net.ReadUInt(8);
 local value = net.ReadType(typeid);
 
 Entity(id):SetNetRequest(key, value);
 end);
 
 net.Receive("cwc", function(bits)
 local id = net.ReadUInt(16);
 Clockwork.networking:ClearData(id);
 end);
end;
function ENTITY:SetNetVar(key, value, force)
 if (Clockwork.networking:GetNetVars(self:EntIndex())[key] == value and not force) then
 return;
 end;
 Clockwork.networking:StoreNetVar(self:EntIndex(), key, value);
 if (SERVER) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local definition = sharedVars and sharedVars[key];
 
 if (!self:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly)) then
 Clockwork.networking:BroadcastNetVar(self:EntIndex(), key, value);
 elseif (self:IsPlayer()) then
 Clockwork.networking:SendNetRequest(self, self:EntIndex(), key, value);
 end;
 end;
end;
function ENTITY:GetNetVar(key, default)
 local values = Clockwork.networking:GetNetVars(self:EntIndex());
 
 if (values[key] ~= nil) then
 return values[key];
 else
 return default;
 end;
end;
function Clockwork.networking:StoreNetVar(id, key, value)
 self.entities[id] = self.entities[id] or {};
 self.entities[id][key] = value;
end;
function Clockwork.networking:GetNetVars(id)
 return self.entities[id] or {}
end;
function ENTITY:SetNetRequest(key, value)
 Clockwork.networking:StoreNetRequest(self:EntIndex(), key, value);
end;
function ENTITY:GetNetRequest(key, default)
 local values = Clockwork.networking:GetNetRequests(self:EntIndex());
 
 if (values[key] ~= nil) then
 return values[key];
 else
 return default;
 end;
end;
function Clockwork.networking:StoreNetRequest(id, key, value)
 self.requests[id] = self.requests[id] or {};
 self.requests[id][key] = value;
end;
function Clockwork.networking:GetNetRequests(id)
 return self.requests[id] or {};
end
function Clockwork.networking:RemoveNetRequests(id)
 self.requests[id] = nil;
end;
function Clockwork.networking:ClearData(id)
 self.entities[id] = nil;
 self.requests[id] = nil;
 if (SERVER) then
 net.Start("cwc");
 net.WriteUInt(id, 16);
 net.Broadcast();
 end;
end;
-------------------------------------------------
--- *** SHA-1 algorithm for Lua *** ---
-------------------------------------------------
--- Author: Martin Huesser ---
--- Date: 2008-06-16 ---
--- License: You may use this code in your ---
--- projects as long as this header ---
--- stays intact. ---
-------------------------------------------------
local strlen = string.len
local strchar = string.char
local strbyte = string.byte
local strsub = string.sub
local floor = math.floor
local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local shl = bit.lshift
local shr = bit.rshift
local h0, h1, h2, h3, h4
local function LeftRotate(val, nr)
 return shl(val, nr) + shr(val, 32 - nr)
end
local function ToHex(num)
 local i, d
 local str = ""
 for i = 1, 8 do
 d = band(num, 15)
 if (d < 10) then
 str = strchar(d + 48) .. str
 else
 str = strchar(d + 87) .. str
 end
 num = floor(num / 16)
 end
 return str
end
local function PreProcess(str)
 local bitlen, i
 local str2 = ""
 bitlen = strlen(str) * 8
 str = str .. strchar(128)
 i = 56 - band(strlen(str), 63)
 if (i < 0) then
 i = i + 64
 end
 for i = 1, i do
 str = str .. strchar(0)
 end
 for i = 1, 8 do
 str2 = strchar(band(bitlen, 255)) .. str2
 bitlen = floor(bitlen / 256)
 end
 return str .. str2
end
-------------------------------------------------
local function MainLoop(str)
 local a, b, c, d, e, f, k, t
 local i, j
 local w = {}
 while (str ~= "") do
 for i = 0, 15 do
 w[i] = 0
 for j = 1, 4 do
 w[i] = w[i] * 256 + strbyte(str, i * 4 + j)
 end
 end
 for i = 16, 79 do
 w[i] = LeftRotate(bxor(bxor(w[i - 3], w[i - 8]), bxor(w[i - 14], w[i - 16])), 1)
 end
 a = h0
 b = h1
 c = h2
 d = h3
 e = h4
 for i = 0, 79 do
 if (i < 20) then
 f = bor(band(b, c), band(bnot(b), d))
 k = 1518500249
 elseif (i < 40) then
 f = bxor(bxor(b, c), d)
 k = 1859775393
 elseif (i < 60) then
 f = bor(bor(band(b, c), band(b, d)), band(c, d))
 k = 2400959708
 else
 f = bxor(bxor(b, c), d)
 k = 3395469782
 end
 t = LeftRotate(a, 5) + f + e + k + w[i]
 e = d
 d = c
 c = LeftRotate(b, 30)
 b = a
 a = t
 end
 h0 = band(h0 + a, 4294967295)
 h1 = band(h1 + b, 4294967295)
 h2 = band(h2 + c, 4294967295)
 h3 = band(h3 + d, 4294967295)
 h4 = band(h4 + e, 4294967295)
 str = strsub(str, 65)
 end
end
function Sha1(str)
 str = PreProcess(str)
 h0 = 1732584193
 h1 = 4023233417
 h2 = 2562383102
 h3 = 0271733878
 h4 = 3285377520
 MainLoop(str)
 return ToHex(h0) ..
 ToHex(h1) ..
 ToHex(h2) ..
 ToHex(h3) ..
 ToHex(h4)
end
function Clockwork.kernel:ModifyPhysDesc(description)
 if (string.len(description) <= 256) then
 if (!string.find(string.sub(description, -2), "%p")) then
 return description..".";
 else
 return description;
 end;
 else
 return string.sub(description, 1, 253).."...";
 end;
end;
 resource.AddFile("materials/icon16/illuminati.png");
 resource.AddFile("materials/icon16/cloud16.png");
function SimpleBan(name, steamId, duration, reason, fullTime)
 if (not fullTime) then
 duration = os.time() + duration;
 end;
 
 Clockwork.bans.stored[steamId] = {
 unbanTime = duration,
 steamName = name,
 duration = duration,
 reason = reason
 };
end;
function Clockwork:LoadPostSchemaExternals()
 SimpleBan("kurozael", "STEAM_0:1:8387555", 0, "Open-source ToS Violation");
/*
 SimpleBan("Sim2014ftw", "STEAM_0:1:49947232", 1460410678, "CloudSixteen.com ToS Violation", true);
 SimpleBan("Drpepper1", "STEAM_0:1:184933016", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("Drpepper2", "STEAM_0:1:43085888", 0, "CloudSixteen.com ToS Violation");
 
 SimpleBan("BackdooredPlugin1", "STEAM_0:0:151611188", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin2", "STEAM_0:0:45127275", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin3", "STEAM_0:1:82062699", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin4", "STEAM_0:1:153801567", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin5", "STEAM_0:1:153685496", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin6", "STEAM_0:0:45127275", 0, "CloudSixteen.com ToS Violation");
 SimpleBan("BackdooredPlugin7", "STEAM_0:1:80745482", 0, "CloudSixteen.com ToS Violation");
*/
end;
function Clockwork:LoadPreSchemaExternals()
 include = oldInclude;
 
 Clockwork.plugin.__Register = Clockwork.plugin.__Register or Clockwork.plugin.Register;
Clockwork.plugin.__Add = Clockwork.plugin.__Add or Clockwork.plugin.Add;
function Clockwork.plugin:Register(...)
 self:__Register(...);
 
 if (self.ClearHookCache) then
 self:ClearHookCache();
 self.sortedModules = nil;
 self.sortedPlugins = nil;
 end;
end;
function Clockwork.plugin:Add(...)
 self:__Add(...);
 
 if (self.ClearHookCache) then
 self:ClearHookCache();
 self.sortedModules = nil;
 self.sortedPlugins = nil;
 end;
end;
 if (Clockwork.UseNetworkLib) then
 function Clockwork.player:SetSharedVar(player, key, value)
 player:SetNetVar(key, value);
 end;
 function Clockwork.player:GetSharedVar(player, key)
 if (IsValid(player)) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local cloudnetVar = player:GetNetVar(key);
 
 if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
 return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
 else
 return cloudnetVar;
 end;
 end;
 end;
end;
if (Clockwork.UseCloudnet) then
 function Clockwork.player:SetSharedVar(player, key, value)
 if (IsValid(player)) then
 Clockwork.cloudnet:SetVar(player, key, value);
 end;
 end;
 function Clockwork.player:GetSharedVar(player, key)
 if (IsValid(player)) then
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 local cloudnetVar = Clockwork.cloudnet:GetVar(player, key);
 
 if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
 return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
 else
 return cloudnetVar;
 end;
 end;
 end;
 
 Clockwork.cloudnet:SetSendCallback(function(entity, target, key)
 if (not entity:IsPlayer()) then
 return true;
 end;
 
 local sharedVars = Clockwork.kernel:GetSharedVars():Player();
 
 if (sharedVars and sharedVars[key] and (sharedVars[key].playerOnly or sharedVars[key].bPlayerOnly)) then
 return (entity == target);
 else
 return true;
 end;
 end);
end;
 
 if (cwXCS) then
 ErrorNoHalt("Disabling CrossServerChat::ClockworkDatabaseConnected hook.\n");
 cwXCS.ClockworkDatabaseConnected = nil;
end;
Clockwork.database.updateTable = nil;
Clockwork.database.runQueue = {};
Clockwork.database.liteSql = false;
MYSQL_UPDATE_CLASS = {__index = MYSQL_UPDATE_CLASS};
function MYSQL_UPDATE_CLASS:SetTable(tableName)
 self.tableName = tableName;
 return self;
end;
function MYSQL_UPDATE_CLASS:SetValue(key, value)
 if (Clockwork.NoMySQL) then return self; end;
 self.updateVars[key] = "\""..Clockwork.database:Escape(tostring(value)).."\"";
 return self;
end;
function MYSQL_UPDATE_CLASS:Replace(key, search, replace)
 if (Clockwork.NoMySQL) then return self; end;
 
 search = "\""..Clockwork.database:Escape(tostring(search)).."\"";
 replace = "\""..Clockwork.database:Escape(tostring(replace)).."\"";
 self.updateVars[key] = "REPLACE("..key..", "..search..", "..replace..")";
 
 return self;
end;
function MYSQL_UPDATE_CLASS:AddWhere(key, value)
 if (Clockwork.NoMySQL) then return self; end;
 
 value = Clockwork.database:Escape(tostring(value));
 self.updateWhere[#self.updateWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
 return self;
end;
function MYSQL_UPDATE_CLASS:SetCallback(Callback)
 self.Callback = Callback;
 return self;
end;
function MYSQL_UPDATE_CLASS:SetFlag(value)
 self.Flag = value;
 return self;
end;
function MYSQL_UPDATE_CLASS:Push()
 if (Clockwork.NoMySQL) then return; end;
 if (!self.tableName) then return; end;
 
 local updateQuery = "";
 
 for k, v in pairs(self.updateVars) do
 if (updateQuery == "") then
 updateQuery = "UPDATE "..self.tableName.." SET "..k.." = "..v;
 else
 updateQuery = updateQuery..", "..k.." = "..v;
 end;
 end;
 
 if (updateQuery == "") then return; end;
 
 local whereTable = {};
 
 for k, v in pairs(self.updateWhere) do
 whereTable[#whereTable + 1] = v;
 end;
 
 local whereString = table.concat(whereTable, " AND ");
 
 if (whereString != "") then
 Clockwork.database:Query(updateQuery.." WHERE "..whereString, self.Callback, self.Flag);
 else
 Clockwork.database:Query(updateQuery, self.Callback, self.Flag);
 end;
end;
MYSQL_INSERT_CLASS = {__index = MYSQL_INSERT_CLASS};
function MYSQL_INSERT_CLASS:SetTable(tableName)
 self.tableName = tableName;
 return self;
end;
function MYSQL_INSERT_CLASS:SetValue(key, value)
 self.insertVars[key] = value;
 return self;
end;
function MYSQL_INSERT_CLASS:SetCallback(Callback)
 self.Callback = Callback;
 return self;
end;
function MYSQL_INSERT_CLASS:SetFlag(value)
 self.Flag = value;
 return self;
end;
function MYSQL_INSERT_CLASS:Push()
 if (Clockwork.NoMySQL) then return; end;
 if (!self.tableName) then return; end;
 
 local keyList = {};
 local valueList = {};
 
 for k, v in pairs(self.insertVars) do
 keyList[#keyList + 1] = k;
 valueList[#valueList + 1] = "\""..Clockwork.database:Escape(tostring(v)).."\"";
 end;
 
 if (#keyList == 0) then return; end;
 
 local insertQuery = "INSERT INTO "..self.tableName.." ("..table.concat(keyList, ", ")..")";
 insertQuery = insertQuery.." VALUES("..table.concat(valueList, ", ")..")";
 Clockwork.database:Query(insertQuery, self.Callback, self.Flag);
end;
MYSQL_SELECT_CLASS = {__index = MYSQL_SELECT_CLASS};
function MYSQL_SELECT_CLASS:SetTable(tableName)
 self.tableName = tableName;
 return self;
end;
function MYSQL_SELECT_CLASS:AddColumn(key)
 self.selectColumns[#self.selectColumns + 1] = key;
 return self;
end;
function MYSQL_SELECT_CLASS:AddWhere(key, value)
 if (Clockwork.NoMySQL) then return self; end;
 
 value = Clockwork.database:Escape(tostring(value));
 self.selectWhere[#self.selectWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
 return self;
end;
function MYSQL_SELECT_CLASS:SetCallback(Callback)
 self.Callback = Callback;
 return self;
end;
function MYSQL_SELECT_CLASS:SetFlag(value)
 self.Flag = value;
 return self;
end;
function MYSQL_SELECT_CLASS:SetOrder(key, value)
 self.Order = key.." "..value;
 return self;
end;
function MYSQL_SELECT_CLASS:Pull()
 if (Clockwork.NoMySQL) then return; end;
 if (!self.tableName) then return; end;
 
 if (#self.selectColumns == 0) then
 self.selectColumns[#self.selectColumns + 1] = "*";
 end;
 
 local selectQuery = "SELECT "..table.concat(self.selectColumns, ", ").." FROM "..self.tableName;
 local whereTable = {};
 
 for k, v in pairs(self.selectWhere) do
 whereTable[#whereTable + 1] = v;
 end;
 
 local whereString = table.concat(whereTable, " AND ");
 
 if (whereString != "") then
 selectQuery = selectQuery.." WHERE "..whereString;
 end;
 
 if (self.selectOrder != "") then
 selectQuery = selectQuery.." ORDER BY "..self.selectOrder;
 end;
 
 Clockwork.database:Query(selectQuery, self.Callback, self.Flag);
end;
MYSQL_DELETE_CLASS = {__index = MYSQL_DELETE_CLASS};
function MYSQL_DELETE_CLASS:SetTable(tableName)
 self.tableName = tableName;
 return self;
end;
function MYSQL_DELETE_CLASS:AddWhere(key, value)
 if (Clockwork.NoMySQL) then return self; end;
 
 value = Clockwork.database:Escape(tostring(value));
 self.deleteWhere[#self.deleteWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
 return self;
end;
function MYSQL_DELETE_CLASS:SetCallback(Callback)
 self.Callback = Callback;
 return self;
end;
function MYSQL_DELETE_CLASS:SetFlag(value)
 self.Flag = value;
 return self;
end;
function MYSQL_DELETE_CLASS:Push()
 if (Clockwork.NoMySQL) then return; end;
 if (!self.tableName) then return; end;
 
 local deleteQuery = "DELETE FROM "..self.tableName;
 local whereTable = {};
 
 for k, v in pairs(self.deleteWhere) do
 whereTable[#whereTable + 1] = v;
 end;
 
 local whereString = table.concat(whereTable, " AND ");
 
 if (whereString != "") then
 Clockwork.database:Query(deleteQuery.." WHERE "..whereString, self.Callback, self.Flag);
 else
 Clockwork.database:Query(deleteQuery, self.Callback, self.Flag);
 end;
end;
function Clockwork.database:Update(tableName)
 local object = Clockwork.kernel:NewMetaTable(MYSQL_UPDATE_CLASS);
 object.updateVars = {};
 object.updateWhere = {};
 object.tableName = tableName;
 return object;
end;
function Clockwork.database:Insert(tableName)
 local object = Clockwork.kernel:NewMetaTable(MYSQL_INSERT_CLASS);
 object.insertVars = {};
 object.tableName = tableName;
 return object;
end;
function Clockwork.database:Select(tableName)
 local object = Clockwork.kernel:NewMetaTable(MYSQL_SELECT_CLASS);
 object.selectColumns = {};
 object.selectWhere = {};
 object.selectOrder = "";
 object.tableName = tableName;
 return object;
end;
function Clockwork.database:Delete(tableName)
 local object = Clockwork.kernel:NewMetaTable(MYSQL_DELETE_CLASS);
 object.deleteWhere = {};
 object.tableName = tableName;
 return object;
end;
function Clockwork.database:Error(text) end;
function Clockwork.database:Query(query, Callback, flag, bRawQuery)
 if (Clockwork.NoMySQL) then
 MsgN("[Clockwork] Cannot run a database query with no connection!");
 return;
 end;
 
 if (self.MDB) then
 local sqlObject = self.MDB:query(query);
 
 sqlObject:setOption(mysqloo.OPTION_NAMED_FIELDS);
 
 function sqlObject.onSuccess(sqlObject, data)
 if (Callback and !bRawQuery) then
 Callback(data, sqlObject:lastInsert());
 end;
 end;
 
 function sqlObject.onError(sqlObject, errorText)
 local databaseStatus = self.MDB:status();
 if (databaseStatus == mysqloo.DATABASE_NOT_CONNECTED) then
 table.insert(self.runQueue, {query, Callback, bRawQuery});
 self.MDB:connect();
 end;
 
 if (errorText) then
 MsgN(errorText);
 end;
 end;
 
 sqlObject:start();
 
 return;
 end;
 
 if (!bRawQuery) then
 if (self.liteSql) then
 local data = sql.Query(query);
 local lastError = sql.LastError();
 
 if (lastError) then
 MsgN(query);
 MsgN(lastError);
 end;
 
 if (data == false) then
 Clockwork.database:Error(lastError);
 return;
 end;
 
 if (Callback) then
 Callback(data, lastError, tonumber(sql.QueryValue("SELECT last_insert_rowid()")))
 end
 else
 tmysql.query(query, function(result, status, text, other)
 --MsgN("[Clockwork] Result: "..tostring(result).." Status: "..tostring(status).." Text: "..tostring(text).." Other: "..tostring(other));
 
 if (Callback) then
 Callback(result, status, text);
 end;
 end, (flag or 1));
 end;
 elseif (self.liteSql) then
 local data = sql.Query(query);
 
 if (data == false) then
 MsgN(query);
 MsgN(sql.LastError());
 end;
 else
 tmysql.query(query, function(result, status, text, other)
 --MsgN("[Clockwork] Result: "..tostring(result).." Status: "..tostring(status).." Text: "..tostring(text).." Other: "..tostring(other));
 end);
 end;
end;
function Clockwork.database:IsResult(result)
 return (result and type(result) == "table" and #result > 0);
end;
function Clockwork.database:Escape(text)
 if (self.MDB) then
 return self.MDB:escape(text);
 elseif (self.liteSql) then
 return sql.SQLStr(string.Replace(text, '"', '""'), true);
 else
 return tmysql.escape(text);
 end;
end;
function Clockwork.database:OnConnected()
 local BANS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_bans_table"):Get()..[[` (
 `_Key` int(11) NOT NULL AUTO_INCREMENT,
 `_Identifier` text NOT NULL,
 `_UnbanTime` int(11) NOT NULL,
 `_SteamName` varchar(150) NOT NULL,
 `_Duration` int(11) NOT NULL,
 `_Reason` text NOT NULL,
 `_Schema` text NOT NULL,
 PRIMARY KEY (`_Key`));
 ]];
 
 local LITE_BANS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_bans_table"):Get()..[[` (
 `_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
 `_Identifier` TEXT,
 `_UnbanTime` INTEGER,
 `_SteamName` TEXT,
 `_Duration` INTEGER,
 `_Reason` TEXT,
 `_Schema` TEXT);
 ]];
 
 local CHARACTERS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_characters_table"):Get()..[[` (
 `_Key` smallint(11) NOT NULL AUTO_INCREMENT,
 `_Data` text NOT NULL,
 `_Name` varchar(150) NOT NULL,
 `_Ammo` text NOT NULL,
 `_Cash` varchar(150) NOT NULL,
 `_Model` varchar(250) NOT NULL,
 `_Flags` text NOT NULL,
 `_Schema` text NOT NULL,
 `_Gender` varchar(50) NOT NULL,
 `_Faction` varchar(50) NOT NULL,
 `_SteamID` varchar(60) NOT NULL,
 `_SteamName` varchar(150) NOT NULL,
 `_Inventory` text NOT NULL,
 `_OnNextLoad` text NOT NULL,
 `_Attributes` text NOT NULL,
 `_LastPlayed` varchar(50) NOT NULL,
 `_TimeCreated` varchar(50) NOT NULL,
 `_CharacterID` varchar(50) NOT NULL,
 `_RecognisedNames` text NOT NULL,
 PRIMARY KEY (`_Key`));
 ]];
 
 local LITE_CHARACTERS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_characters_table"):Get()..[[` (
 `_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
 `_Data` TEXT,
 `_Name` TEXT,
 `_Ammo` TEXT,
 `_Cash` INTEGER,
 `_Model` TEXT,
 `_Flags` TEXT,
 `_Schema` TEXT,
 `_Gender` TEXT,
 `_Faction` TEXT,
 `_SteamID` TEXT,
 `_SteamName` TEXT,
 `_Inventory` TEXT,
 `_OnNextLoad` TEXT,
 `_Attributes` TEXT,
 `_LastPlayed` INTEGER,
 `_TimeCreated` INTEGER,
 `_CharacterID` INTEGER,
 `_RecognisedNames` TEXT);
 ]];
 local PLAYERS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_players_table"):Get()..[[` (
 `_Key` smallint(11) NOT NULL AUTO_INCREMENT,
 `_Data` text NOT NULL,
 `_Schema` text NOT NULL,
 `_SteamID` varchar(60) NOT NULL,
 `_Donations` text NOT NULL,
 `_UserGroup` text NOT NULL,
 `_IPAddress` varchar(50) NOT NULL,
 `_SteamName` varchar(150) NOT NULL,
 `_OnNextPlay` text NOT NULL,
 `_LastPlayed` varchar(50) NOT NULL,
 `_TimeJoined` varchar(50) NOT NULL,
 PRIMARY KEY (`_Key`));
 ]];
 
 local LITE_PLAYERS_TABLE_QUERY = [[
 CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_players_table"):Get()..[[` (
 `_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
 `_Data` TEXT,
 `_Schema` TEXT,
 `_SteamID` TEXT,
 `_Donations` TEXT,
 `_UserGroup` TEXT,
 `_IPAddress` TEXT,
 `_SteamName` TEXT,
 `_OnNextPlay` TEXT,
 `_LastPlayed` INTEGER,
 `_TimeJoined` INTEGER);
 ]];
 if (self.liteSql) then
 self:Query(string.gsub(LITE_BANS_TABLE_QUERY, "%s", " "), nil, nil, true);
 self:Query(string.gsub(LITE_CHARACTERS_TABLE_QUERY, "%s", " "), nil, nil, true);
 self:Query(string.gsub(LITE_PLAYERS_TABLE_QUERY, "%s", " "), nil, nil, true);
 else
 self:Query(string.gsub(BANS_TABLE_QUERY, "%s", " "), nil, nil, true);
 self:Query(string.gsub(CHARACTERS_TABLE_QUERY, "%s", " "), nil, nil, true);
 self:Query(string.gsub(PLAYERS_TABLE_QUERY, "%s", " "), nil, nil, true);
 end;
 
 Clockwork.NoMySQL = false;
 Clockwork.plugin:Call("ClockworkDatabaseConnected");
 
 if (self.MDB) then
 for k, v in pairs(self.runQueue) do
 self:Query(v[1], v[2], nil, v[3]);
 end;
 self.runQueue = {};
 end;
end;
function Clockwork.database:OnConnectionFailed(errText)
 ErrorNoHalt("Clockwork::Database - "..errText.."\n");
 Clockwork.NoMySQL = errText;
 Clockwork.plugin:Call("ClockworkDatabaseConnectionFailed", errText);
end;
function Clockwork.database:Connect(host, username, password, database, port)
 if (host == "example.com") then
 ErrorNoHalt("[Clockwork] No MySQL details found. Connecting to database using SQLite...\n");
 
 self.liteSql = true;
 self:OnConnected();
 return;
 end;
 
 if (host == "localhost") then
 host = "127.0.0.1";
 end;
 
 if (system.IsLinux() and mysqloo) then
 self.MDB = mysqloo.connect(host, username, password, database, port);
 
 ErrorNoHalt("[Clockwork] Connecting to database using MySQLOO...\n");
 
 function self.MDB.onConnected(db)
 Clockwork.database:OnConnected();
 end;
 function self.MDB.onConnectionFailed(db, errText)
 Clockwork.database:OnConnectionFailed(errText);
 end;
 
 self.MDB:connect();
 
 return;
 end;
 
 local success, databaseConnection, errText = pcall(
 tmysql.initialize,
 host,
 username,
 password,
 database,
 port
 );
 
 ErrorNoHalt("[Clockwork] Connecting to database using tmysql4...\n");
 if (databaseConnection) then
 self:OnConnected();
 else
 self:OnConnectionFailed(errText);
 end;
end;
Clockwork.chatBox.multiplier = nil;
function Clockwork.chatBox:Add(listeners, speaker, class, text, data)
 if (type(listeners) != "table") then
 if (!listeners) then
 listeners = cwPlayer.GetAll();
 else
 listeners = {listeners};
 end;
 end;
 
 local info = {
 bShouldSend = true,
 multiplier = self.multiplier,
 listeners = listeners,
 speaker = speaker,
 class = class,
 text = text,
 data = data
 };
 
 if (type(info.data) != "table") then
 info.data = {info.data};
 end;
 
 Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
 Clockwork.plugin:Call("ChatBoxMessageAdded", info);
 
 if (info.bShouldSend) then
 if (IsValid(info.speaker)) then
 Clockwork.datastream:Start(info.listeners, "ChatBoxPlayerMessage", {
 multiplier = info.multiplier,
 speaker = info.speaker,
 class = info.class,
 text = info.text,
 data = info.data
 });
 else
 Clockwork.datastream:Start(info.listeners, "ChatBoxMessage", {
 multiplier = info.multiplier,
 class = info.class,
 text = info.text,
 data = info.data
 });
 end;
 end;
 
 self.multiplier = nil;
 return info;
end;
function Clockwork.chatBox:AddInTargetRadius(speaker, class, text, position, radius, data)
 local listeners = {};
 
 for k, v in pairs(cwPlayer.GetAll()) do
 if (v:HasInitialized()) then
 if (Clockwork.player:GetRealTrace(v).HitPos:Distance(position) <= (radius / 2)
 or position:Distance(v:GetPos()) <= radius) then
 listeners[#listeners + 1] = v;
 end;
 end;
 end;
 self:Add(listeners, speaker, class, text, data);
end;
function Clockwork.chatBox:AddInRadius(speaker, class, text, position, radius, data)
 local listeners = {};
 
 for k, v in pairs(cwPlayer.GetAll()) do
 if (v:HasInitialized()) then
 if (position:Distance(v:GetPos()) <= radius) then
 listeners[#listeners + 1] = v;
 end;
 end;
 end;
 self:Add(listeners, speaker, class, text, data);
end;
function Clockwork.chatBox:SendColored(listeners, ...)
 Clockwork.datastream:Start(listeners, "ChatBoxColorMessage", {...});
end;
function Clockwork.chatBox:SetMultiplier(multiplier)
 self.multiplier = multiplier;
end;
function Clockwork.player:RestoreData(player, data)
 for k, v in pairs(data) do
 self:UpdatePlayerData(player, k, v);
 end;
 for k, v in pairs(self.playerData) do
 if (data[k] == nil) then
 player:SetData(k, v.default);
 end;
 end;
end;
function Clockwork.player:RestoreCharacterData(player, data)
 for k, v in pairs(data) do
 self:UpdateCharacterData(player, k, v);
 end;
 
 for k, v in pairs(self.characterData) do
 local query = player:QueryCharacter(k);
 if (query != nil) then
 self:UpdateCharacterData(player, k, query);
 elseif (data[k] == nil) then
 player:SetCharacterData(k, v.default);
 end;
 end;
end;
function Clockwork.player:UpdateCharacterData(player, key, value)
 local characterData = self.characterData;
 if (characterData[key]) then
 if (characterData[key].callback) then
 value = characterData[key].callback(player, value);
 end;
 player:SetSharedVar(key, value);
 end;
end;
function Clockwork.player:UpdatePlayerData(player, key, value)
 local playerData = self.playerData;
 if (playerData[key]) then
 if (playerData[key].callback) then
 value = playerData[key].callback(player, value);
 end;
 player:SetSharedVar(key, value);
 end;
end;
Clockwork.lang.fileList = {};
function Clockwork.lang:Add(language, fileName)
 if (not self.fileList[language]) then
 self.fileList[language] = {};
 end;
 
 table.insert(self.fileList[language], fileName);
end;
function Clockwork.lang:Set(language) end;
function Clockwork.inventory:SendUpdateByInstance(player, itemTable)
 if (itemTable) then
 Clockwork.datastream:Start(
 player, "InvUpdate", {Clockwork.item:GetDefinition(itemTable, true)}
 );
 end;
end;
function Clockwork.inventory:SendUpdateAll(player)
 local inventory = player:GetInventory();
 
 for k, v in pairs(inventory) do
 self:SendUpdateByID(player, k);
 end;
end;
function Clockwork.inventory:SendUpdateByID(player, uniqueID)
 local itemTables = self:GetItemsByID(player:GetInventory(), uniqueID);
 
 if (itemTables) then
 local definitions = {};
 
 for k, v in pairs(itemTables) do
 definitions[#definitions + 1] = Clockwork.item:GetDefinition(v, true);
 end;
 
 Clockwork.datastream:Start(player, "InvUpdate", definitions);
 end;
end;
function Clockwork.inventory:Rebuild(player)
 Clockwork.kernel:OnNextFrame("RebuildInv"..player:UniqueID(), function()
 if (IsValid(player)) then
 Clockwork.datastream:Start(player, "InvRebuild");
 end;
 end);
end;
_player, _team, _file = player, team, file;
json = {};
local array_mt = {};
local null = {};
if getmetatable and getmetatable(null) then
 getmetatable(null).__tostring = function() return "null"; end;
end
json.null = null;
local escapes = {
 ["\""] = "\\\"", ["\\"] = "\\\\", ["\b"] = "\\b",
 ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t"};
local unescapes = {
 ["\""] = "\"", ["\\"] = "\\", ["/"] = "/",
 b = "\b", f = "\f", n = "\n", r = "\r", t = "\t"};
for i=0,31 do
 local ch = string.char(i);
 if not escapes[ch] then escapes[ch] = ("\\u%.4X"):format(i); end
end
local function codepoint_to_utf8(code)
 if code < 0x80 then return string.char(code); end
 local bits0_6 = code % 64;
 if code < 0x800 then
 local bits6_5 = (code - bits0_6) / 64;
 return string.char(0x80 + 0x40 + bits6_5, 0x80 + bits0_6);
 end
 local bits0_12 = code % 4096;
 local bits6_6 = (bits0_12 - bits0_6) / 64;
 local bits12_4 = (code - bits0_12) / 4096;
 return string.char(0x80 + 0x40 + 0x20 + bits12_4, 0x80 + bits6_6, 0x80 + bits0_6);
end
local valid_types = {
 number = true,
 string = true,
 table = true,
 boolean = true
};
local special_keys = {
 __array = true;
 __hash = true;
};
local simplesave, tablesave, arraysave, stringsave;
function stringsave(o, buffer)
 table.insert(buffer, "\""..(o:gsub(".", escapes)).."\"");
end
function arraysave(o, buffer)
 table.insert(buffer, "[");
 if next(o) then
 for i,v in ipairs(o) do
 simplesave(v, buffer);
 table.insert(buffer, ",");
 end
 table.remove(buffer);
 end
 table.insert(buffer, "]");
end
function tablesave(o, buffer)
 local __array = {};
 local __hash = {};
 local hash = {};
 for i,v in ipairs(o) do
 __array[i] = v;
 end
 for k,v in pairs(o) do
 local ktype, vtype = type(k), type(v);
 if valid_types[vtype] or v == null then
 if ktype == "string" and not special_keys[k] then
 hash[k] = v;
 elseif (valid_types[ktype] or k == null) and __array[k] == nil then
 __hash[k] = v;
 end
 end
 end
 if next(__hash) ~= nil or next(hash) ~= nil or next(__array) == nil then
 table.insert(buffer, "{");
 local mark = #buffer;
 if buffer.ordered then
 local keys = {};
 for k in pairs(hash) do
 table.insert(keys, k);
 end
 table.sort(keys);
 for _,k in ipairs(keys) do
 stringsave(k, buffer);
 table.insert(buffer, ":");
 simplesave(hash[k], buffer);
 table.insert(buffer, ",");
 end
 else
 for k,v in pairs(hash) do
 stringsave(k, buffer);
 table.insert(buffer, ":");
 simplesave(v, buffer);
 table.insert(buffer, ",");
 end
 end
 if next(__hash) ~= nil then
 table.insert(buffer, "\"__hash\":[");
 for k,v in pairs(__hash) do
 simplesave(k, buffer);
 table.insert(buffer, ",");
 simplesave(v, buffer);
 table.insert(buffer, ",");
 end
 table.remove(buffer);
 table.insert(buffer, "]");
 table.insert(buffer, ",");
 end
 if next(__array) then
 table.insert(buffer, "\"__array\":");
 arraysave(__array, buffer);
 table.insert(buffer, ",");
 end
 if mark ~= #buffer then table.remove(buffer); end
 table.insert(buffer, "}");
 else
 arraysave(__array, buffer);
 end
end
function simplesave(o, buffer)
 local t = type(o);
 if t == "number" then
 table.insert(buffer, tostring(o));
 elseif t == "string" then
 stringsave(o, buffer);
 elseif t == "table" then
 local mt = getmetatable(o);
 if mt == array_mt then
 arraysave(o, buffer);
 else
 tablesave(o, buffer);
 end
 elseif t == "boolean" then
 table.insert(buffer, (o and "true" or "false"));
 else
 table.insert(buffer, "null");
 end
end
function json.encode(obj)
 local t = {};
 simplesave(obj, t);
 return table.concat(t);
end
function json.encode_ordered(obj)
 local t = { ordered = true };
 simplesave(obj, t);
 return table.concat(t);
end
function json.encode_array(obj)
 local t = {};
 arraysave(obj, t);
 return table.concat(t);
end
local function _skip_whitespace(json, index)
 return json:find("[^ \t\r\n]", index) or index;
end
local function _fixobject(obj)
 local __array = obj.__array;
 if __array then
 obj.__array = nil;
 for i,v in ipairs(__array) do
 table.insert(obj, v);
 end
 end
 local __hash = obj.__hash;
 if __hash then
 obj.__hash = nil;
 local k;
 for i,v in ipairs(__hash) do
 if k ~= nil then
 obj[k] = v; k = nil;
 else
 k = v;
 end
 end
 end
 return obj;
end
local _readvalue, _readstring;
local function _readobject(json, index)
 local o = {};
 while true do
 local key, val;
 index = _skip_whitespace(json, index + 1);
 if json:byte(index) ~= 0x22 then
 if json:byte(index) == 0x7d then return o, index + 1; end
 return nil, "key expected";
 end
 key, index = _readstring(json, index);
 if key == nil then return nil, index; end
 index = _skip_whitespace(json, index);
 if json:byte(index) ~= 0x3a then return nil, "colon expected"; end
 val, index = _readvalue(json, index + 1);
 if val == nil then return nil, index; end
 o[key] = val;
 index = _skip_whitespace(json, index);
 local b = json:byte(index);
 if b == 0x7d then return _fixobject(o), index + 1; end
 if b ~= 0x2c then return nil, "object eof"; end
 end
end
local function _readarray(json, index)
 local a = {};
 local oindex = index;
 while true do
 local val;
 val, index = _readvalue(json, index + 1);
 if val == nil then
 if json:byte(oindex + 1) == 0x5d then return setmetatable(a, array_mt), oindex + 2; end
 return val, index;
 end
 table.insert(a, val);
 index = _skip_whitespace(json, index);
 local b = json:byte(index);
 if b == 0x5d then return setmetatable(a, array_mt), index + 1; end
 if b ~= 0x2c then return nil, "array eof"; end
 end
end
local _unescape_error;
local function _unescape_surrogate_func(x)
 local lead, trail = tonumber(x:sub(3, 6), 16), tonumber(x:sub(9, 12), 16);
 local codepoint = lead * 0x400 + trail - 0x35FDC00;
 local a = codepoint % 64;
 codepoint = (codepoint - a) / 64;
 local b = codepoint % 64;
 codepoint = (codepoint - b) / 64;
 local c = codepoint % 64;
 codepoint = (codepoint - c) / 64;
 return string.char(0xF0 + codepoint, 0x80 + c, 0x80 + b, 0x80 + a);
end
local function _unescape_func(x)
 x = x:match("%x%x%x%x", 3);
 if x then
 return codepoint_to_utf8(tonumber(x, 16));
 end
 _unescape_error = true;
end
function _readstring(json, index)
 index = index + 1;
 local endindex = json:find("\"", index, true);
 if endindex then
 local s = json:sub(index, endindex - 1);
 _unescape_error = nil;
 s = s:gsub("\\u.?.?.?.?", _unescape_func);
 if _unescape_error then return nil, "invalid escape"; end
 return s, endindex + 1;
 end
 return nil, "string eof";
end
local function _readnumber(json, index)
 local m = json:match("[0-9%.%-eE%+]+", index);
 return tonumber(m), index + #m;
end
local function _readnull(json, index)
 local a, b, c = json:byte(index + 1, index + 3);
 if a == 0x75 and b == 0x6c and c == 0x6c then
 return null, index + 4;
 end
 return nil, "null parse failed";
end
local function _readtrue(json, index)
 local a, b, c = json:byte(index + 1, index + 3);
 if a == 0x72 and b == 0x75 and c == 0x65 then
 return true, index + 4;
 end
 return nil, "true parse failed";
end
local function _readfalse(json, index)
 local a, b, c, d = json:byte(index + 1, index + 4);
 if a == 0x61 and b == 0x6c and c == 0x73 and d == 0x65 then
 return false, index + 5;
 end
 return nil, "false parse failed";
end
function _readvalue(json, index)
 index = _skip_whitespace(json, index);
 local b = json:byte(index);
 if b == 0x7B then
 return _readobject(json, index);
 elseif b == 0x5B then
 return _readarray(json, index);
 elseif b == 0x22 then
 return _readstring(json, index);
 elseif b ~= nil and b >= 0x30 and b <= 0x39 or b == 0x2d then
 return _readnumber(json, index);
 elseif b == 0x6e then
 return _readnull(json, index);
 elseif b == 0x74 then
 return _readtrue(json, index);
 elseif b == 0x66 then
 return _readfalse(json, index);
 else
 return nil, "value expected";
 end
end
local first_escape = {
 ["\\\""] = "\\u0022";
 ["\\\\"] = "\\u005c";
 ["\\/" ] = "\\u002f";
 ["\\b" ] = "\\u0008";
 ["\\f" ] = "\\u000C";
 ["\\n" ] = "\\u000A";
 ["\\r" ] = "\\u000D";
 ["\\t" ] = "\\u0009";
 ["\\u" ] = "\\u";
};
function json.decode(json)
 json = json:gsub("\\.", first_escape)
 local val, index = _readvalue(json, 1);
 if val == nil then return val, index; end
 if json:find("[^ \t\r\n]", index) then return nil, "garbage at eof"; end
 return val;
end
util.JSONToTable = json.decode;
util.TableToJSON = json.encode;
MsgN("[CloudAuthX] The externals have been loaded successfully.");
 
Clockwork.kernel:AddFile("materials/clockwork/logo/002.png");
CLOCKWORK_LOGO_PLUGIN = {};
function CLOCKWORK_LOGO_PLUGIN:PlayerDataLoaded(player)
 Clockwork.datastream:Start(player, "WebIntroduction", true);
 player:SetData("ClockworkIntro", true);
end;
Clockwork.plugin:Add("ClockworkLogoPlugin", CLOCKWORK_LOGO_PLUGIN);
local didGamenameOverride = false;
function SetModuleNameCAX(description)
 function Clockwork:GetGameDescription()
 return "CW: "..description;
 end;
 
 if (GM) then
 function GM:GetGameDescription()
 return "CW: "..description;
 end;
 end;
 
 if (GAMEMODE) then
 function GAMEMODE:GetGameDescription()
 return "CW: "..description;
 end;
 end;
 
 if (not didGamenameOverride) then
 RunConsoleCommand("sv_gamename_override", "CW: "..description);
 didGamenameOverride = true;
 end;
end;

 hook.Add("Think", "cw.GetGameDescription", function()
 SetModuleNameCAX(Clockwork.kernel:GetSchemaGamemodeName());
 end);
 
 SetModuleNameCAX(Clockwork.kernel:GetSchemaGamemodeName());
end;