--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local surface = surface;

Clockwork.render = Clockwork.kernel:NewLibrary("Render");

SLICE_OBJECT = {__index = SLICE_OBJECT};

--[[
	@codebase Client
	@details A function to draw the sliced sprite at a location (corner size can be overriden.)
	@param {Unknown} Missing description for corner size can be overriden..
	@returns {Unknown}
--]]
function SLICE_OBJECT:Draw(x, y, w, h, overrideCornerSize, overrideColor, overrideAlpha)
	if (not overrideAlpha) then
		if (overrideColor) then
			overrideAlpha = overrideColor.a;
		else
			overrideAlpha = 255;
		end;
	end;
	
	overrideColor = overrideColor or color_white;
	
	local finalColor = Color(overrideColor.r, overrideColor.g, overrideColor.b, overrideAlpha);
	
	surface.SetMaterial(self.material);
	surface.SetDrawColor(finalColor);

	local topCornerSize = h * self.top;
	local cornerSize = w * self.left;

	if (topCornerSize < cornerSize) then
		cornerSize = topCornerSize;
	end;
	
	if (overrideCornerSize) then
		cornerSize = overrideCornerSize;
	end;

	local tlCornerW = cornerSize;
	local tlCornerH = cornerSize;
	local tlCornerX = x;
	local tlCornerY = y;
	
	surface.DrawTexturedRectUV(tlCornerX, tlCornerY, tlCornerW, tlCornerH, 0, 0, self.left, self.top);
	
	local trCornerW = cornerSize;
	local trCornerH = cornerSize;
	local trCornerX = (x + w) - trCornerW;
	local trCornerY = y;

	surface.DrawTexturedRectUV(trCornerX, trCornerY, trCornerW, tlCornerH, self.right, 0, 1, self.top);
	
	local blCornerW = cornerSize;
	local blCornerH = cornerSize;
	local blCornerX = x
	local blCornerY = (y + h) - blCornerH;

	surface.DrawTexturedRectUV(blCornerX, blCornerY, blCornerW, blCornerH, 0, self.bottom, self.left, 1);

	local brCornerW = cornerSize;
	local brCornerH = cornerSize;
	local brCornerX = (x + w) - brCornerW;
	local brCornerY = (y + h) - blCornerH;

	surface.DrawTexturedRectUV(brCornerX, brCornerY, brCornerW, brCornerH, self.right, self.bottom, 1, 1);
	
	local topW = w - (cornerSize * 2);
	local topH = cornerSize;
	local topX = x + tlCornerW;
	local topY = y;

	surface.DrawTexturedRectUV(topX, topY, topW, topH, self.left, 0, self.right, self.top);
	
	local bottomW = w - (cornerSize * 2);
	local bottomH = cornerSize;
	local bottomX = x + blCornerW;
	local bottomY = (y + h) - bottomH;

	surface.DrawTexturedRectUV(bottomX, bottomY, bottomW, bottomH, self.left, self.bottom, self.right, 1);
	
	local leftW = cornerSize;
	local leftH = h - (cornerSize * 2);
	local leftX = x;
	local leftY = y + tlCornerH;

	surface.DrawTexturedRectUV(leftX, leftY, leftW, leftH, 0, self.top, self.left, self.bottom);
	
	local rightW = cornerSize;
	local rightH = h - (cornerSize * 2);
	local rightX = (x + w) - rightW;
	local rightY = y + tlCornerH;

	surface.DrawTexturedRectUV(rightX, rightY, rightW, rightH, self.right, self.top, 1, self.bottom);
	
	local centerW = w - (cornerSize * 2);
	local centerH = h - (cornerSize * 2);
	local centerX = x + cornerSize;
	local centerY = y + cornerSize;

	surface.DrawTexturedRectUV(centerX, centerY, centerW, centerH, self.left, self.top, self.right, self.bottom);
end;

--[[
	@codebase Client
	@details Add a new 9 Sliced sprite.
	@param {String} A name to identify the sprite by.
	@param {String} The file name of the sprite (.png only).
	@param {Number} The size of the sprite's corners.
	@returns The SliceObject created.
--]]
function Clockwork.render:AddSlice9(name, fileName, cornerSize)
	local material = Material(fileName..".png", "noclamp");
	local sliceObject = Clockwork.kernel:NewMetaTable(SLICE_OBJECT);

	sliceObject.material = material;
	sliceObject.texture = material:GetTexture("$basetexture");
	sliceObject.origW = sliceObject.texture:GetMappingWidth();
	sliceObject.origH = sliceObject.texture:GetMappingHeight();
	sliceObject.name = name;
	
	local left = cornerSize;
	local right = sliceObject.origW - cornerSize;
	local bottom = sliceObject.origH - cornerSize;
	local top = cornerSize;

	sliceObject.left = (1 / sliceObject.origW) * left;
	sliceObject.right = (1 / sliceObject.origW) * right;
	sliceObject.bottom = (1 / sliceObject.origH) * bottom;
	sliceObject.top = (1 / sliceObject.origH) * top;

	return sliceObject;
end;

SMALL_BAR_BG = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
SMALL_BAR_FG = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
INFOTEXT_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
MENU_ITEM_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
SLICED_SMALL_TINT = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
SLICED_INFO_MENU_INSIDE = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
PANEL_LIST_SLICED = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);
DERMA_SLICED_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
SLICED_LARGE_DEFAULT = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
SLICED_PROGRESS_BAR = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
SLICED_PLAYER_INFO = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
SLICED_INFO_MENU_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
CUSTOM_BUSINESS_ITEM_BG = Clockwork.render:AddSlice9("BigBox", "clockwork/sliced/bigbox", 28);
SLICED_COLUMNSHEET_BUTTON = Clockwork.render:AddSlice9("SmallBox", "clockwork/sliced/smallbox", 6);