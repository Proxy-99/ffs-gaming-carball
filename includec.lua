
--SIMULATED_SIZE_X, SIMULATED_SIZE_Y = 800, 600;
--SIMULATED_SIZE_X, SIMULATED_SIZE_Y = 1024, 768;

if (SIMULATED_SIZE_X) then
SCREEN_SIZE_X, SCREEN_SIZE_Y = SIMULATED_SIZE_X, SIMULATED_SIZE_Y;
local _getCursorPosition = getCursorPosition;
function getCursorPosition(...)
	local pos = { _getCursorPosition(...) };
	if (pos[1] and pos[2]) then
		pos[1], pos[2] = math.min(1, pos[1] * 1920 / SIMULATED_SIZE_X), math.min(1, pos[2] * 1080 / SIMULATED_SIZE_Y);
	end
	return unpack(pos);
end
local _guiGetScreenSize = guiGetScreenSize;
function guiGetScreenSize(...)
	return SIMULATED_SIZE_X, SIMULATED_SIZE_Y;
end
else
SCREEN_SIZE_X, SCREEN_SIZE_Y = guiGetScreenSize();
end
gScreenSizeX, gScreenSizeY = SCREEN_SIZE_X, SCREEN_SIZE_Y;
RELATIVE_MULT_X, RELATIVE_MULT_Y = SCREEN_SIZE_X/1920, SCREEN_SIZE_Y/1080;
SCREEN_RATIO = SCREEN_SIZE_X / SCREEN_SIZE_Y;

function relVal(v) return v * RELATIVE_MULT_Y end

localPlayer = getLocalPlayer();

BLACK = tocolor(0, 0, 0);
WHITE = tocolor(255, 255, 255);
RED = tocolor(255, 0, 0);
GREEN = tocolor(0, 255, 0);
BLUE = tocolor(0, 0, 255);
YELLOW = tocolor(255, 255, 0);
ORANGE = tocolor(255, 128, 0);
GREY = tocolor(127, 127, 127);
INVISIBLE = tocolor(0, 0, 0, 0);

--[[------------------------------------------------------------------------||--
						(<---Useful Events--->)								
																				
--||------------------------------------------------------------------------]]--

addEvent("onClientDeltaRender");
addEvent("onClientDeltaPreRender");

--[[------------------------------------------------------------------------||--
						(<---Overriding Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function resetWaterColor()
	setWaterColor(0, 130, 255);
end

--[[------------------------------------------------------------------------||--
						(<---General Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function dxGetImageSize(image)
	local tex = isElement(image) and image or dxCreateTexture(image);
	local texpx = dxGetTexturePixels(tex);
	local x, y = dxGetPixelsSize(texpx);
	if (not isElement(image)) then destroyElement(tex); end
	return x, y
end

function dxGetImageRatio(image)
	local x, y = dxGetImageSize(image);
	return x/y;
end

function getCursorScreenPosition()
	local cx, cy = getCursorPosition();
	return (cx or -1) * gScreenSizeX, (cy or -1) * gScreenSizeY;
end

local pTickDifference = 0;
addEvent("onClientServerTickReceive", true);
addEventHandler("onClientServerTickReceive", root,
	function (tick)
		pTickDifference = tick - getTickCount();
	end
);

function getServerTick()
	return (getTickCount() + pTickDifference);
end

if (not getResources) then
function getResources()
	return table.lfilter(table.lmap(getElementsByType("resource"), function (resRoot) return getResourceFromName(getElementID(resRoot)) end)); 
end
end

if (not isPedDead) then
isPedDead = isPedDead;
end

function callClientFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onServerCallsClientFunction", true)
addEventHandler("onServerCallsClientFunction", resourceRoot, callClientFunction)

--[[------------------------------------------------------------------------||--
						(<---Element Functions--->)								
																				
--||------------------------------------------------------------------------]]--

addEvent("onClientTjongDataReceive", true);
addEvent("onClientTjongInitDataReceive", true);
addEvent("onClientTjongDataChange");

local pDataStorage = { };

function dataEquals(element, data, value)
	return ((pDataStorage[element] and pDataStorage[element][data]) == value);
end

function getData(element, data)
	return (pDataStorage[element] and pDataStorage[element][data]);
end

function getAllData(element)
	return (pDataStorage[element] or { });
end

function increaseData(element, data, value)
	value = value or 1;
	if (not pDataStorage[element]) then pDataStorage[element] = { }; end
	if (not pDataStorage[element][data]) then pDataStorage[element][data] = 0; end
	pDataStorage[element][data] = pDataStorage[element][data] + value;
end

function setData(element, data, value)
	if (not pDataStorage[element]) then pDataStorage[element] = { }; end
	if (value ~= pDataStorage[element][data]) then
		if (ENABLE_TJONG_DATA_DEBUG) then
		outputDebugString(tostring(element).." received data "..data..": "..tostring(value), 0, 128, 0, 255);
		end
		if (isElement(element)) then
			triggerEvent("onClientTjongDataChange", element, data, pDataStorage[element][data], value);
		end
		pDataStorage[element][data] = value;
	end
end
addEventHandler("onClientTjongDataReceive", resourceRoot, setData, false);

addEventHandler("onClientTjongInitDataReceive", resourceRoot,
	function (syncedData)
		if (syncedData) then
			for element, elementInfo in pairs(syncedData) do
				for data, value in pairs(elementInfo) do
					setData(element, data, value)
				end
			end
		end
	end
);

addEventHandler("onClientElementDestroy", root,
	function ()
		if (pDataStorage[source]) then
			pDataStorage[source] = nil;
		end
	end
);

function getRemotePlayers()
	local players = getElementsByType("player");
	table.vremove(players, localPlayer);
	return players;
end

--[[------------------------------------------------------------------------||--
						(<---Other Functions--->)								
																				
--||------------------------------------------------------------------------]]--
function replaceModel(name, id, textureOnly)
	local txd = engineLoadTXD("data/models/"..name..".txd");
	engineImportTXD(txd, id);
	if (not textureOnly) then
		local col = engineLoadCOL("data/models/"..name..".col");
		engineReplaceCOL(col, id);
	end
	local dff = engineLoadDFF("data/models/"..name..".dff", 0);
	engineReplaceModel(dff, id);
end

function dxDrawImage3D(x, y, z, width, height, image, angle, color)
	color = color or tocolor(255, 255, 255);
	local faceX, faceY = getPointOnCircle(x, y, 100.0, angle);
	dxDrawMaterialLine3D(x, y, z + height / 2, x, y, z - height / 2, 
							image, width, color, faceX, faceY, z);
end 

local WORLD_TEXT_BASE_SCALE = 2.5 / gScreenSizeY * 800;
-- Ensure the text doesn't get too big
local maxScaleCurve = { {0, 0}, {3, 3}, {13, 5} }
-- Ensure the text doesn't get too small/unreadable
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
-- Make the text a bit brighter and fade more gradually
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }

function drawTextAtPosition(text, x, y, z, size, r, g, b, a, font, fadeOutDist)
	a = a or 120;
	font = font or "default";
	fadeOutDist = fadeOutDist or 160;
	local alphaDist = fadeOutDist / 3;
	local cx,cy,cz = getCameraMatrix()
	local pdistance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)
	if pdistance <= fadeOutDist then
		--Get screenposition
		local sx, sy = getScreenFromWorldPosition(x, y, z+0.95, 0.06)
		if not sx or not sy then return false end
		--Calculate our components
		local scale = 1/(WORLD_TEXT_BASE_SCALE * (pdistance / fadeOutDist))
		local alpha = ((pdistance - alphaDist) / (fadeOutDist - alphaDist))
		alpha = (alpha < 0) and a or a-(alpha*a)
		scale = math.evalCurve(maxScaleCurve,scale)
		local textscale = math.evalCurve(textScaleCurve,scale)
		local textalpha = math.evalCurve(textAlphaCurve,alpha)
		--Draw our text
		dxDrawText(text, sx, sy - scale, sx, sy - scale, tocolor(r,g,b,textalpha), textscale*size, font, "center", "bottom", false, false, false, true);
	end
end
function drawBorderedTextAtPosition(offset, borderColor, text, x, y, z, size, r, g, b, a, font, fadeOutDist)
	a = a or 120;
	font = font or "default";
	fadeOutDist = fadeOutDist or 160;
	local alphaDist = fadeOutDist / 3;
	local cx,cy,cz = getCameraMatrix()
	local pdistance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)
	if pdistance <= fadeOutDist then
		--Get screenposition
		local sx, sy = getScreenFromWorldPosition(x, y, z+0.95, 0.06)
		if not sx or not sy then return false end
		--Calculate our components
		local scale = 1/(WORLD_TEXT_BASE_SCALE * (pdistance / fadeOutDist))
		local alpha = ((pdistance - alphaDist) / (fadeOutDist - alphaDist))
		alpha = (alpha < 0) and a or a-(alpha*a)
		scale = math.evalCurve(maxScaleCurve,scale)
		local textscale = math.evalCurve(textScaleCurve,scale)
		local textalpha = math.evalCurve(textAlphaCurve,alpha)
		--Draw our text
		dxDrawBorderedText(offset, borderColor, text, sx, sy - scale, sx, sy - scale, tocolor(r,g,b,textalpha), textscale*size, font, "center", "top", false, false, false, true, true);
	end
end

function dxDrawBorderedTextWithBackground(fontOffset, fontBorderColor, rectOffset, rectBorderColor, rectColor, text, posX, posY, color, scale, font, clip, wordBreak, postGUI, colorCoded, ...)
	fontOffset = fontOffset * scale;
	local width, height = getTextDimension(text, font, scale);
	width, height = width * 1.1, height * 1.1;
	posX = posX - width / 2;--, posY - height / 2;
	dxDrawBorderedRectangle(rectOffset, rectBorderColor, posX, posY, width, height, rectColor, ...)
	
	local shadowText = colorCoded and removeColorTags(text) or text;
	local highX, highY = posX + width, posY + height;
	
	dxDrawBorderedText(fontOffset, fontBorderColor, text, posX, posY, posX + width, posY + height, color, scale, font, "center", "top", clip, wordBreak, postGUI, colorCoded, ...);
end

function dxDrawBorderedTextLow(offset, borderColor, text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...)
	local shadowText = colorCoded and removeColorTags(text) or text;
	
	dxDrawText(shadowText, posX + offset, posY + offset, highX + offset, highY + offset, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	
	dxDrawText(text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...);
end

function dxDrawBorderedTextNormal(offset, borderColor, text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...)
	local shadowText = colorCoded and removeColorTags(text) or text;

	local bLowXl, bLowXh, bLowYl, bLowYh = posX - offset, posX + offset, posY - offset, posY + offset;
	local bHighXl, bHighXh, bHighYl, bHighYh = highX - offset, highX + offset, highY - offset, highY + offset;
	
	dxDrawText(shadowText, posX, bLowYl, highX, bHighYl, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXh, posY, bHighXh, highY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, posX, bLowYh, highX, bHighYh, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXl, posY, bHighXl, highY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);

	dxDrawText(text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...);
end

function dxDrawBorderedTextHigh(offset, borderColor, text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...)
	local shadowText = colorCoded and removeColorTags(text) or text;
	--dxDrawText(shadowText, posX			, posY + offset, highX 			, highY + offset, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	--dxDrawText(shadowText, posX + offset, posY			, highX + offset, highY			, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	
	local bLowXl, bLowXh, bLowYl, bLowYh = posX - offset, posX + offset, posY - offset, posY + offset;
	local bHighXl, bHighXh, bHighYl, bHighYh = highX - offset, highX + offset, highY - offset, highY + offset;
	
	dxDrawText(shadowText, posX, bLowYl, highX, bHighYl, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXh, posY, bHighXh, highY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, posX, bLowYh, highX, bHighYh, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXl, posY, bHighXl, highY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	
	dxDrawText(shadowText, bLowXl, bLowYl, bHighXl, bHighYl, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXh, bLowYl, bHighXh, bHighYl, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXl, bLowYh, bHighXl, bHighYh, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(shadowText, bLowXh, bLowYh, bHighXh, bHighYh, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, ...);
	dxDrawText(text, posX, posY, highX, highY, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, ...);
end

function dxDrawBorderedRectangle(borderWidth, borderColor, posX, posY, width, height, color, postGui, ...)
	dxDrawRectangle(posX, posY, width, height, color, postGui, ...);
	local halfBorder = borderWidth/2;
	dxDrawLine(posX - halfBorder, posY - 1, posX + width + halfBorder, posY - 1, borderColor, borderWidth, postGui);
	dxDrawLine(posX - halfBorder, posY + height, posX + width + halfBorder, posY + height, borderColor, borderWidth, postGui);
	dxDrawLine(posX - 1, posY - halfBorder, posX - 1, posY + height + halfBorder, borderColor, borderWidth, postGui);
	dxDrawLine(posX + width, posY - halfBorder, posX + width, posY + height + halfBorder, borderColor, borderWidth, postGui);
end

function dxDrawBorderedImageLow(borderWidth, borderColor, posX, posY, width, height, ...)
	dxDrawRectangle(posX - borderWidth / 2, posY - borderWidth / 2, width + borderWidth, height + borderWidth, borderColor);
	dxDrawImage(posX, posY, width, height, ...);
end

function dxDrawBorderedImageHigh(borderWidth, borderColor, posX, posY, width, height, tex, a, b, c, d, postGui, ...)
	dxDrawImage(posX, posY, width, height, tex, a, b, c, d, postGui, ...);
	local halfBorder = borderWidth/2;
	dxDrawLine(posX - halfBorder, posY - 1, posX + width + halfBorder, posY - 1, borderColor, borderWidth, postGui);
	dxDrawLine(posX - halfBorder, posY + height, posX + width + halfBorder, posY + height, borderColor, borderWidth, postGui);
	dxDrawLine(posX - 1, posY - halfBorder, posX - 1, posY + height + halfBorder, borderColor, borderWidth, postGui);
	dxDrawLine(posX + width, posY - halfBorder, posX + width, posY + height + halfBorder, borderColor, borderWidth, postGui);
end

function dxDrawBorderedImageSectionLow(borderWidth, borderColor, posX, posY, width, height, ...)
	dxDrawRectangle(posX - borderWidth / 2, posY - borderWidth / 2, width + borderWidth, height + borderWidth, borderColor);
	dxDrawImageSection(posX, posY, width, height, ...)
end

function dxDrawBorderedImageSectionHigh(borderWidth, borderColor, posX, posY, width, height, ...)
	dxDrawImageSection(posX, posY, width, height, ...)
	local halfBorder = borderWidth/2;
	dxDrawLine(posX - halfBorder, posY - 1, posX + width + halfBorder, posY - 1, borderColor, borderWidth);
	dxDrawLine(posX - halfBorder, posY + height, posX + width + halfBorder, posY + height, borderColor, borderWidth);
	dxDrawLine(posX - 1, posY - halfBorder, posX - 1, posY + height + halfBorder, borderColor, borderWidth);
	dxDrawLine(posX + width, posY - halfBorder, posX + width, posY + height + halfBorder, borderColor, borderWidth);
end

MULTI_RENDER_QUALITY_ENTITIES = {
	dxDrawBorderedText = {
		Low = dxDrawBorderedTextLow,
		Medium = dxDrawBorderedTextNormal,
		High = dxDrawBorderedTextHigh,
	},
};
dxDrawBorderedImage = dxDrawBorderedImageHigh;
dxDrawBorderedImageSection = dxDrawBorderedImageSectionHigh;

function addMultiRenderQualityEntity(aim, qualityEntities)
	MULTI_RENDER_QUALITY_ENTITIES[aim] = qualityEntities;
	_G[aim] = qualityEntities[CURRENT_QUALITY] or qualityEntities["High"];
end

addEvent("onClientRenderQualityChange");
addEventHandler("onClientRenderQualityChange", resourceRoot,
	function (quality)
		for aim, qualityEntities in pairs(MULTI_RENDER_QUALITY_ENTITIES) do
			_G[aim] = qualityEntities[quality] or qualityEntities["High"];
		end
		CURRENT_QUALITY = quality;
	end
);
triggerEvent("onClientRenderQualityChange", resourceRoot, "High");

function dxDrawBorderedLine(borderWidth, borderColor, x1, y1, x2, y2, color, width, ...)
	dxDrawLine(x1, y1, x2, y2, borderColor, borderWidth + width, ...);
	dxDrawLine(x1, y1, x2, y2, color, width, ...);
end

function dxDrawBorderedLineEx(borderWidth, borderColor, x1, y1, x2, y2, color, width, ...)
	local addX, addY = getNormalizedVector(x2 - x1, y2 - y1);
	dxDrawLine(x1 - addX * borderWidth, y1 - addY * borderWidth, x2 + addX * borderWidth, y2 + addY * borderWidth, borderColor, borderWidth + width, ...);
	dxDrawLine(x1, y1, x2, y2, color, width, ...);
end

local tmp = {}
local MASK_WIDTH = 300;
local MASK_HEIGHT = 250;
local MASK_OFFSET_X = 106;
local MASK_OFFSET_Y = 131;
function dxDrawRoundedImage( posX, posY, width, height, image, opacity, drawHeight, bottom )
	width = math.round(width);
	drawHeight = math.round(drawHeight);
	height = math.round(height);
	
	if not tmp['init'] then
		tmp['mask'] = dxCreateTexture( "data/images/stadium-mask.png" );
		tmp['init'] = true;
	end
	
	if not tmp[image] then
		tmp[image] = dxCreateShader( "data/shaders/hud_mask.fx" );
		tmp['txd_' .. image] = dxCreateTexture( image );
		dxSetShaderValue( tmp[image], "sPicTexture", tmp['txd_' .. image] );
		dxSetShaderValue( tmp[image], "sMaskTexture", tmp['mask'] );
		dxSetShaderValue( tmp[image], "gUVScale", 1.4, 1.4 );
		dxSetShaderValue( tmp[image], "gUVPosition", 0, 0.02 );
	end
	
	if tmp[image] then
		local shadow_width = math.round(380 * width / MASK_WIDTH * 0.995);
		local shadow_height = math.round(330 * height / MASK_HEIGHT * 0.995);
		
		local shadow_xoffset = math.round(( shadow_width - width ) / 2);
		local shadow_yoffset = math.round(( shadow_height - height ) / 2);
		
		if ( height - drawHeight ) > 1 then
			local shadow_draw_height = drawHeight + shadow_yoffset;
			
			if bottom then
				dxDrawImageSection( posX - shadow_xoffset, posY, shadow_width, shadow_draw_height, 0, ( 1 - shadow_draw_height / shadow_height ) * 330, 380, ( shadow_draw_height / shadow_height ) * 330, "data/images/stadium-shadow.png" );
				dxDrawImageSection( posX, posY, width, drawHeight, MASK_OFFSET_X, MASK_OFFSET_Y + ( 1 - drawHeight / height ) * MASK_HEIGHT, MASK_WIDTH, ( drawHeight / height ) * MASK_HEIGHT, tmp[image], 0, 0, 0, tocolor( 255, 255, 255, opacity ) );
			else
				dxDrawImageSection( posX - shadow_xoffset, posY - shadow_yoffset, shadow_width, shadow_draw_height, 0, 0, 380, shadow_draw_height / shadow_height * 330, "data/images/stadium-shadow.png" );
				dxDrawImageSection( posX, posY, width, drawHeight, MASK_OFFSET_X, MASK_OFFSET_Y, MASK_WIDTH, ( drawHeight / height ) * MASK_HEIGHT, tmp[image], 0, 0, 0, tocolor( 255, 255, 255, opacity ) );
			end
		else
			if opacity == 255 then
				dxDrawImageSection( posX - 3, posY - 3, width + 6, height + 6, MASK_OFFSET_X, MASK_OFFSET_Y, MASK_WIDTH, MASK_HEIGHT, tmp['mask'] );
			end
			dxDrawImage( posX - shadow_xoffset, posY - shadow_yoffset, shadow_width, shadow_height, "data/images/stadium-shadow.png" );
			dxDrawImageSection( posX, posY, width, drawHeight, MASK_OFFSET_X, MASK_OFFSET_Y, MASK_WIDTH, MASK_HEIGHT, tmp[image], 0, 0, 0, tocolor( 255, 255, 255, opacity ) );
		end
		
		--Draw playercount background
		if (bottom) then
			local clipped = math.min( 0.18, drawHeight / height );
			dxDrawImageSection( posX, posY + drawHeight - height * clipped, width, height * clipped, MASK_OFFSET_X, MASK_OFFSET_Y + 250 * (1 - clipped), MASK_WIDTH, MASK_HEIGHT * clipped, tmp['mask'], 0, 0, 0, tocolor( 0, 0, 0, opacity ) );
		else
			local clipped = math.max( 0, 0.18 - ( 1 - drawHeight / height ) );
			dxDrawImageSection( posX, posY + height * 0.82, width, height * clipped, MASK_OFFSET_X, MASK_OFFSET_Y + 250 * 0.82, MASK_WIDTH, MASK_HEIGHT * clipped, tmp['mask'], 0, 0, 0, tocolor( 0, 0, 0, opacity ) );
		end
	end
end

function dxDrawPartialCircle( x, y, r, color, corner )
	--color = tocolor(255,255,255,255);
	corner = corner or 1;
	
	local start = corner % 2 == 0 and 0 or -r;
	local stop = corner % 2 == 0 and r or 0;
	local m = corner > 2 and -1 or 1;
	local h = (corner == 1 or corner == 3) and -1 or 1;
	
 	for yoff = start, stop do
 		local xoff = math.sqrt(r*r-yoff*yoff) * m;
		--xsolid = math.floor(xoff);
		--xblur = xoff - xsolid;
		
 		dxDrawRectangle(x-xoff, y+yoff, xoff, h, color); 
		--dxDrawRectangle(x-xoff+m, y+yoff, 1, h, tocolor(255,255,255,100*xblur));
	end 
end

function dxDrawRoundedRectangle( posX, posY, width, height, radius, color )	
	posX = math.round(posX);
	posY = math.round(posY);
	width = math.round(width);
	height = math.round(height);
	
	if type(radius) == "table" then
		
		for i=1, 4 do
			radius[i] = radius[i] and math.min( radius[i], math.min(width, height) / 2) or 12;
		end
		
		local maxTop = math.max( radius[1], radius[3] );
		local maxBottom = math.max( radius[2], radius[4] );
		local maxLeft =  math.max( radius[1], radius[2] );
		local maxRight =  math.max( radius[3], radius[4] );
		
		dxDrawRectangle( posX, posY + maxTop, width, height - maxTop - maxBottom, color );
		dxDrawRectangle( posX + radius[1], posY, width - radius[1] - radius[3], maxTop, color );
		dxDrawRectangle( posX + radius[2], posY + height - maxBottom, width - radius[2] - radius[4], maxBottom, color );
		
		dxDrawPartialCircle( posX + radius[1], posY + radius[1], radius[1], color, 1 );
		dxDrawPartialCircle( posX + radius[2], posY + height - radius[2], radius[2], color, 2 );
		dxDrawPartialCircle( posX + width - radius[3], posY + radius[3], radius[3], color, 3 );
		dxDrawPartialCircle( posX + width - radius[4], posY + height - radius[4], radius[4], color, 4 );
	else
		radius = radius and math.min( radius, math.min(width, height) / 2 ) or 12;
		
		dxDrawRectangle( posX, posY + radius, width, height - radius * 2, color );
		dxDrawRectangle( posX + radius, posY, width - 2 * radius, radius, color );
		dxDrawRectangle( posX + radius, posY + height - radius, width - 2 * radius, radius, color);
		
		dxDrawPartialCircle( posX + radius, posY + radius, radius, color, 1 );
		dxDrawPartialCircle( posX + radius, posY + height - radius, radius, color, 2 );
		dxDrawPartialCircle( posX + width - radius, posY + radius, radius, color, 3 );
		dxDrawPartialCircle( posX + width - radius, posY + height - radius, radius, color, 4 );
	end
end

function getTextDimension(text, font, size)
	local lines = split(removeColorTags(text), "\n");
	local max = -1;
	for _, line in ipairs(lines) do max = math.max(max, dxGetTextWidth(line, size, font)); end
	return max, dxGetFontHeight(size, font) * (1 + string.findamount(text, "\n"));--#lines;
end

function getFontSizeFittingWidth(text, width, font, multiplier)
    font = font or "default";
    local ch = dxGetTextWidth(text, 1, font);
    return width/ch * (multiplier or 0.95);
end

function getFontSizeFittingHeight(height, font, multiplier)
    font = font or "default";
    local ch = dxGetFontHeight(1, font);
    return height/ch * (multiplier or 0.95);
end

function getFontSizeFittingRectangle(text, width, height, font)
	return math.min(getFontSizeFittingWidth(text, width, font), getFontSizeFittingHeight(height, font));
end

function bindSettableKey()

end

function isUserPanelActive()
	return (getElementData(localPlayer, "isLobbyOpened") or getElementData(localPlayer, "isUserpanelOpened"));
end

-- SANDBOXNG
IS_FFS = getResourceFromName("ffs");
if (IS_FFS) then

	SANDBOX_INITIALIZED = nil;

	_addEvent = addEvent;
	_addEventHandler = addEventHandler;
	_setTimer = setTimer;
	_bindKey = bindKey;

	BYPASS_SANDBOX = {"onClientPlayerInit", "onClientPlayerExit", "onClientResourceStop"};
	-- Another way to bypas is to just use underscored original function

	DELAYED_EVENTS = {};
	function addEvent(event, ...)
		if (table.contains(BYPASS_SANDBOX, event) or SANDBOX_INITIALIZED) then
			_addEvent(event, ...);
		else
			table.insert(DELAYED_EVENTS, {event, ...});
		end
	end

	DELAYED_EVENT_HANDLERS = {};
	ATTACHED_EVENT_HANDLERS = {};
	function addEventHandler(event, ...)
		if (table.contains(BYPASS_SANDBOX, event) or SANDBOX_INITIALIZED) then
			_addEventHandler(event, ...);
			table.insert(ATTACHED_EVENT_HANDLERS, {event, ...});
		elseif (SANDBOX_INITIALIZED == nil) then
			table.insert(DELAYED_EVENT_HANDLERS, {event, ...});
		end
	end

	DELAYED_TIMERS = {};
	RUNNING_TIMERS = {};
	function setTimer(fn, t, n, ...)
		if (SANDBOX_INITIALIZED) then
			local timer = _setTimer(fn, t, n, ...);
			table.insert(RUNNING_TIMERS, timer);
		elseif (SANDBOX_INITIALIZED == nil and n == 0) then
			table.insert(DELAYED_TIMERS, {fn, t, n, ...});
		end
	end

	DELAYED_BINDS = {};
	BOUND_KEYS = {};
	function bindKey(...)
		if (SANDBOX_INITIALIZED) then
			_bindKey(...);
			table.insert(BOUND_KEYS, {...});
		elseif (SANDBOX_INITIALIZED == nil) then
			table.insert(DELAYED_BINDS, {...});
		end
	end

	function INITIALIZE_SANDBOX()
		SANDBOX_INITIALIZED = true;

		for _, v in ipairs(DELAYED_EVENTS) do
			addEvent(unpack(v));
		end
		--we don't need to re-do that
		DELAYED_EVENTS = {};

		for _, v in ipairs(DELAYED_EVENT_HANDLERS) do
			addEventHandler(unpack(v));
		end

		for _, v in ipairs(DELAYED_TIMERS) do
			setTimer(unpack(v));
		end

		for _, v in ipairs(DELAYED_BINDS) do
			bindKey(unpack(v));
		end

		triggerEvent("onClientResourceStart", resourceRoot);
	end

	function DESTROY_SANDBOX()
		SANDBOX_INITIALIZED = false;

		triggerEvent("onClientResourceStop", resourceRoot);

		for _, v in ipairs(ATTACHED_EVENT_HANDLERS) do
			if not table.contains(BYPASS_SANDBOX, v[1]) then
				removeEventHandler(unpack(v));
			end
		end
		RUNNING_TIMERS = {};

		for _, timer in ipairs(RUNNING_TIMERS) do
			if isTimer(timer) then
				killTimer(timer);
			end
		end
		RUNNING_TIMERS = {};

		for _, v in ipairs(BOUND_KEYS) do
			unbindKey(unpack(v));
		end
		BOUND_KEYS = {};
	end

else
	function INITIALIZE_SANDBOX()
	end

	function DESTROY_SANDBOX()
	end
end