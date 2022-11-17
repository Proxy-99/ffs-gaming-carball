

SECONDS = 1000;
MINUTES = 60 * SECONDS;
HOURS = 60 * MINUTES;
DAYS = 24 * HOURS;
YEARS = 365 * DAYS;

RESOURCE_NAME = getResourceName(getThisResource());

BYTE = 1;
KILO_BYTE = 1024 * BYTE;
MEGA_BYTE = 1024 * KILO_BYTE;
GIGA_BYTE = 1024 * MEGA_BYTE;
TERA_BYTE = 1024 * GIGA_BYTE;
PETA_BYTE = 1024 * TERA_BYTE;

oDS = outputDebugString;

function table.create(keys, value)
	local tab = { };
	for _, key in pairs(keys) do
		tab[key] = value;
	end
	return tab;
end

--[[------------------------------------------------------------------------||--
						(<---Overriding Functions--->)								
																				
--||------------------------------------------------------------------------]]--

--[[local _outputDebugString = outputDebugString;
function outputDebugString(msg, level, ...)
	if (level and level ~= 3) then
		_outputDebugString(msg, level, ...);
	elseif (DEBUG) then
		_outputDebugString("["..tostring(getResourceName(getThisResource())).."] "..msg, level, ...);
	end
end]]--

local _getPlayerName = getPlayerName;
function getPlayerName(player, withColors)
	local name = _getPlayerName(player);
	if (name and not withColors) then name = removeColorTags(name); end
	return name;
end

local _createVehicle = createVehicle;
function createVehicle(model, x, y, z, rx, ry, rz, numberplate, ...)
	return _createVehicle(model or 411, x or y or z or 0.0, y or x or z or 0.0, z or x or y or 10.0, rx or 0.0, ry or 0.0, rz or 0.0, numberplate, ...);
end

local _spawnPlayer = spawnPlayer;
function spawnPlayer(player, x, y, z, rz, skinID, interior, dimension, team)
	return _spawnPlayer(player, x, y, z, rz or 0.0, skinID or 0, interior or 0, dimension or 0, team);
end

local _fileCopy = fileCopy;
function fileCopy(source, dest, overwrite, ...)
	return _fileCopy(source, dest, overwrite or fileExists(dest), ...);
end


--[[------------------------------------------------------------------------||--
						(<---XML Functions--->)								
																				
--||------------------------------------------------------------------------]]--

-- Helper Functions because XML implementation sucks
function xmlGetAllChildren(xmlRoot, tag)
	local childs = { };
	local index = 0;
	while (true) do 
		local child = xmlFindChild(xmlRoot, tag, index);
		index = index + 1;
		if (child) then
			table.insert(childs, child);
		else
			return childs;
		end
	end
end

function xmlNodeSetAttributes(node, tab)
	for key, value in pairs(tab) do
		xmlNodeSetAttribute(node, key, value);
	end
end

function xmlNodeMoveToBottom(node)
	-- just recreate
	local newNode = xmlCreateChild(xmlNodeGetParent(node), xmlNodeGetName(node));
	xmlNodeSetAttributes(newNode, xmlNodeGetAttributes(node));
	xmlDestroyNode(node);
end

--[[------------------------------------------------------------------------||--
						(<---General Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function addRemoteEventHandler(event, ...)
	addEvent(event, true);
	addEventHandler(event, ...);
end

function isClient()
	return getLocalPlayer;
end

function timeSinceTick(tick)
	return (getTickCount() - tick);
end

function timeUntilTick(tick)
	return (tick - getTickCount());
end

function timeSinceTimestamp(timestamp)
	return (getRealTime().timestamp - timestamp);
end

function timeUntilTimestamp(timestamp)
	return (timestamp - getRealTime().timestamp);
end

function getTimestamp()
	return getRealTime().timestamp;
end

function getPlayerNameColor(player)
	return false;--exports.sandbox:getPlayerNameColor(player);
end

function getPlayerNameColorTag(player)
	return false;--getColorTagString(unpack(exports.sandbox:getPlayerNameColor(player)));
end

function getColorIntensity(r, g, b)
	return (math.max(r, math.max(g, b)))/255;
end

local pColors = {
	{ 255, 128, 0 },
	{ 0, 100, 255 },
	{ 140, 70, 20 },
	{ 255, 255, 0 },
	{ 130, 250, 255 },
	{ 255, 0, 255 },
	{ 255, 255, 255 },
	{ 0, 255, 0 },
	{ 255, 0, 0 },
	{ 100, 100, 100 },
	{ 124, 252, 0 },
	{ 0, 250, 150 },
	{ 255, 20, 147 },
}

function getNiceColor(id)
	return unpack(pColors[id and (((id - 1) % (#pColors - 1)) + 1) or math.random(#pColors)]);
end

function getResourceFromRootElement(rootElem)
	return getResourceFromName(getElementID(rootElem));
end

-- calculates the size of a lua item (not accurate)
function sizeof(a, blockedElements)
	blockedElements = blockedElements or { [_G] = true, };
	local size = 0;
	if (blockedElements[a]) then
		return 0;
	elseif (type(a) == "table") then
		blockedElements[a] = true;
		for k, v in pairs(a) do
			size = size + sizeof(v, blockedElements) + sizeof(k, blockedElements);
		end
	elseif (type(a) == "string") then
		size = #a * 4;
	else
		size = 4;
	end
	return size;
end

function cancelTheEvent() cancelEvent(); end

--[[ int int getRedGreenColor( int value, int limit, [ int lowBetter = nil ] )
	Calculates a color in the intervall from green to red.
	value: The current value, which is usually the one mainly changing.
	limit: The value that limits the calculation, so if value and limit are equal, the result is complete green (or red, s.b.)
	lowBetter: determines if low values should be "good"(and therefore colored green) ]]

function getRedGreenColor(value, limit, lowBetter)
	if (value >= limit) then
		if (lowBetter) then return 255, 0;
		else return 0, 255;
		end
	elseif (value <= 0) then
		if (lowBetter) then return 0, 255;
		else return 255, 0;
		end
	end
	local r, g;	-- calculate value color
	if (value < limit/2) then
		r = 255;
		g = math.floor((value*2)/limit * 255);
	else
		g = 255;
		r = math.floor(((limit-value)*2)/limit * 255);
	end
	if (lowBetter) then
		return g, r;
	end
	return r, g;
end

function isResource(thing)
	return (type(thing) == "userdata" and not isElement(thing) and getResourceName(thing));
end

function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end

--[[------------------------------------------------------------------------||--
						(<---String Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function getRankAppendix(rank)
	return ({ [11] = "th", [12] = "th" })[rank] or ({ [1] = "st", [2] = "nd", [3] = "rd" })[rank%10] or "th";
end

function addTextFittingNewLines(text, drawWidth, fontSize, font)
	local lines = parseTextToFittingLines(text, drawWidth, fontSize, font);
	local text = table.foldl(lines, function (text, line) return (text .. line .. "\n") end, "");
	return text:sub(1, #text - 1), #lines;
end

function parseTextToFittingLines(text, drawWidth, fontSize, font)
	drawWidth = drawWidth or gScreenSizeX;
	fontSize = fontSize or 1;
	font = font or "default";
	local spaceWidth = dxGetTextWidth(" ", fontSize, font);
	local lines = { };
	local index = 1;
	
	repeat
		local newIndex = text:find("\n", index) or #text + 1;
		local currentLine = "";
		local posX = 0;
		for _, word in ipairs(split(text:sub(index, newIndex-1) or "", " ")) do
			--outputDebugString("pos "..tostring(int(posX)).." "..currentLine);
		
			-- collect information
			local wordStripped = removeColorTags(word);
			local width = dxGetTextWidth(wordStripped, fontSize, font);
		
			if (width <= drawWidth) then
				if (posX + width > drawWidth) then
					-- width exceeds current line → insert into next line
					table.insert(lines, currentLine:sub(1, #currentLine-1));
					currentLine = getLastColorTag(currentLine) or "";
					posX = 0;
				end
			
				-- increase information
				posX = posX + width + spaceWidth;
				currentLine = currentLine .. word .. " ";--.text = currentLine.text .. word .. " ";
			else
				-- a Very long word that doesn't fit, maybe handle recursive
				local lastColor = (getLastColorTag(currentLine) or "");
				table.insert(lines, currentLine:sub(1, #currentLine-1));
				table.insert(lines, lastColor .. word);
				currentLine = getLastColorTag(word) or lastColor;
				posX = 0;
			end
		end
		table.insert(lines, currentLine:sub(1, #currentLine-1));
		
		index = newIndex + 1;
	until (index == #text + 2);
	return lines;
end

function string.findamount(str, sub)
	local amount, index = 0, 1;
	while (true) do
		index = str:find(sub, index);
		if (not index) then
			return amount;
		end
		index  = index + 1;
		amount = amount + 1;
	end
end

--[[function string.rfind(self, str)
	local pos = { string.find(string.reverse(self), string.reverse(str)) };
	for k, v in pairs(pos) do
		pos[k] = #self - v - #str +1;
	end
	return unpack(pos) or nil;
end]]
function string.rfind(self, str)
	local pos, tmp;
	repeat
		pos = tmp;
		tmp = string.find(self, str, (pos or 0) + 1);
	until (not tmp);
	return pos;
end

function getColorTagString(r, g, b)
	return string.format("#%.2x%.2x%.2x", r, g, b);
end

function getLastColorTag(str, pos)
	local cPos = str:sub(1, pos or #str):rfind("#%x%x%x%x%x%x");
	if (cPos) then
		return str:sub(cPos, cPos + 6), cPos;
	end
end

function removeColorTags(str)
	if (type(str) ~= "string") then
	outputDebugString("removeColorTagstrace: "..debug.traceback()); end
	return str:gsub("#%x%x%x%x%x%x", "");
end

function removeClanTags(str)
	return str:gsub("[%[%]%-|][%[%]%-|]?[a-zA-Z0-9]+[%[%]%-|]?[%]%[%-|]", ""):gsub("[a-zA-Z0-9]+[%]|%[%-]", "");
end

-- credits to ccw
function timeMsToTimeText(timeMs, hideMs)

	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	if (hideMs) then
		return string.format( '%02d:%02d', minutes, seconds );
	else
		local ms		= timeMs - seconds * 1000;
		return string.format( '%02d:%02d:%03d', minutes, seconds, ms );
	end
end

local pWeekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
local pMonths = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }

function getMonthName(month)
	return pMonths[month];
end
 
function calculateTime(time, multpl)
	time = time * multpl;
	
	local result = { };
	result.years = int(time / YEARS);
	time = time - result.years * YEARS;
	result.days = int(time / DAYS);
	time = time - result.days * DAYS;
	result.hours = int(time / HOURS);
	time = time - result.hours * HOURS;
	result.minutes = int(time / MINUTES);
	time = time - result.minutes * MINUTES;
	result.seconds = int(time / SECONDS);
	time = time - result.seconds * SECONDS;
	return result;
end

function FormatDate(format, escaper, timestamp)
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false
 
	time.year = time.year + 1900
	time.month = time.month + 1
 
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), M = pMonths[time.month], s = ("%02d"):format(time.second), w = pWeekDays[time.weekday+1]:sub(1, 2), W = pWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
 
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
 
	return formattedDate
end
formatDate = FormatDate;
formatTime = formatDate;

local pStringToBool = { ["true"] = true, ["false"] = false };
function tobool(str)
	return pStringToBool[str];
end

function tonative(value)
	local v = tobool(value);
	if (v == nil) then
		return tonumber(value) or value;
	else
		return v;
	end
end

function tostr(this)
	if (type(this) == "bool") then
		return tostring(this);
	elseif (type(this) == "string") then
		return "\""..tostring(this).."\"";
	elseif (type(this) == "table") then
		local output = "";
		for key, value in pairs(this) do
	        output = output .. "["..tostr(key).."] = "..tostr(value)..",\n";
		end
		return ("{" .. output .. "}");
	elseif (isResource(this)) then
		return tostring(this) .. "[Resource: "..getResourceName(this).."]";
	elseif (isElement(this)) then
		if (getElementType(this) == "player") then
			return tostring(this) .. "[Player: "..getPlayerName(this).."]";
		else
			return tostring(this) .. "["..getElementType(this).."]";
		end
	else
		return tostring(this);
	end
end

--[[------------------------------------------------------------------------||--
						(<---Element Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function isValid(element)
	return (element and isElement(element));
end

function isValidTimer(timer)
	return (timer and isTimer(timer));
end

function cleanUp(element)
	if (isValid(element)) then
		destroyElement(element);
	end
end

function cleanUpTimer(timer)
	if (timer and isTimer(timer)) then
		killTimer(timer);
	end
end

function moveElementPosition(element, addX, addY, addZ)
	local x, y, z = getElementPosition(element);
	setElementPosition(element, x + addX, y + addY, z + addZ);
end

function getDistanceBetweenElements(a, b)
	local ax, ay, az = getElementPosition(a);
	local bx, by, bz = getElementPosition(b);
	return getDistanceBetweenPoints3D(ax, ay, az, bx, by, bz);
end

local pWaterCraftIDs = table.create({ 539, 460, 417, 447, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 }, true);
function canVehicleSwim(vehicle)
	return pWaterCraftIDs[getElementModel(vehicle)];
end

function getElementSpeed(element)
	local vx, vy, vz = getElementVelocity(element);
	return math.sqrt(vx*vx + vy*vy + vz*vz);
end

function filterMinMaxPositions(tab)
	local minX, minY, minZ = 2^31, 2^31, 2^31;
	local maxX, maxY, maxZ = -2^31, -2^31, -2^31;
	for _, element in ipairs(tab) do
		local x, y, z = getElementPosition(element);
		minX = math.min(minX, x);
		minY = math.min(minY, y);
		minZ = math.min(minZ, z);
		
		maxX = math.max(maxX, x);
		maxY = math.max(maxY, y);
		maxZ = math.max(maxZ, z);
	end
	return minX, minY, minZ, maxX, maxY, maxZ;
end

local pRCModels = { [441] = true, [464] = true, [501] = true, [465] = true, [564] = true, [594] = true };
function isRCVehicle(veh)
	return pRCModels[veh];
end

--[[------------------------------------------------------------------------||--
						(<---Math Functions--->)								
																				
--||------------------------------------------------------------------------]]--

-- Base

function math.add(a, b) return a+b; end
function math.sub(a, b) return a-b; end
function math.mult(a, b) return a*b; end
function math.div(a, b) return a/b; end
function math.pow(value, exp) return value^exp; end
function math.zero() return 0; end
function math.one() return 1; end
function math.id(a) return a; end
function math.equals(a, b) return (a == b); end
function math.notequals(a, b) return (a ~= b); end
function math.higher(a, b) return (a > b); end
function math.lower(a, b) return (a < b); end
function math.signum(number) return (number == 0) and 0 or ((number > 0) and 1 or -1); end
function math.increase(a) return a+1; end
function math.straightsin(a) return (2/math.pi) * math.asin(math.sin(a)); end
equals = math.equals;
idFunc = math.id;
NOOP = function () end;

--- Intervals ---

function math.lerp(from, to, progress)
    return from + (to-from) * progress;
end

function math.clamp(value, lowLimit, highLimit)
	return math.min(highLimit, math.max(lowLimit, value));
end

function math.calcprogress(begin, value, dest)
	return (value - begin) / math.abs(dest - begin);
end
math.calcprogess = math.calcprogress;

function bezier3D(points, progress)
	local n = #points;
	while (n > 1) do
		for i = 1, n - 1, 1 do
			local x, y, z = unpack(points[i]);
			local x2, y2, z2 = unpack(points[i + 1]);
			points[i] = { x + (x2 - x) * progress, y + (y2 - y) * progress, z + (z2 - z) * progress };
		end
		n = n - 1;
	end
	return unpack(points[1]);
end

-- curve is { {x1, y1}, {x2, y2}, {x3, y3} ... }
function math.evalCurve(curve, input)
	-- First value
	if (input < curve[1][1]) then
		return curve[1][2]
	end
	
	-- Interpolate value
	for i = 2, #curve do
		if (input < curve[i][1]) then
			local x1 = curve[i-1][1]
			local y1 = curve[i-1][2]
			local x2 = curve[i][1]
			local y2 = curve[i][2]
			-- Interpolate
			return math.lerp(y1, y2, (input - x1)/(x2 - x1))
		end
	end
	
	-- Last value
	return curve[#curve][2]
end

--- Position and Rotation ---

function isIn(x, y, lowX, lowY, highX, highY)
	if (not x) then outputDebugString("trace: "..tostr(debug.traceback())); end
	return (x >= lowX and y >= lowY and x < highX and y < highY);
end

--[[ number, number getPointOnCircle( number midX, number midY, number radius, number angle )
	Calculates the x- and y-coordinate on a circle with the given values.
	midX: x-coordinate of the circle's middle point.
	midY: y-coordinate of the circle's middle point.
	radius: The circle's radius.
	angle: Angle between the segment from the circle's middle point to the point that should be calculated and the world's y-axis. ]]
function getPointOnCircle(midX, midY, radius, angle)
	angle = math.rad(angle)
	local distX = -radius * math.sin(angle)
	local distY = radius * math.cos(angle)
	return midX + distX, midY + distY
end

--[[ num, num, num getPointOnSphere ( num midX, num midY, num midZ, num radius, num angleZ, num angeXY )
 =: returns the desired position determined by two angles on a sphere with the given parameters
  midX, midY, midZ: the coordinates of the sphere's center
  radius: the sphere's radius
  angleZ: imagining the desired position being on a circle that is parallel to the global x/y-plane this is the z-angle the line from
   such a circle's center encloses with the global y-axis to hit the desired position on the circle (in degrees)
  angleXY: imagining a vertical circle now this angle determines the position on it whereas 90° is the top of the sphere and -90°
   the bottom; this value must be in the range [-90,90]; 0° causes the third returned value to be equal to midZ (in degrees)
 => the desired point's coordinates ]]
function getPointOnSphere(midX, midY, midZ, radius, angleZ, angleXY)
	angleZ = math.rad(getValidAngle(angleZ))
	angleXY = math.rad(getValidAngle(angleXY))
	
	local d = radius / math.tan(math.abs(.5 * (math.pi - angleXY)))
	
	local px = midX - (radius - d) * math.sin(angleZ)
	local py = midY + (radius - d) * math.cos(angleZ)
	local pz = midZ + radius * math.sin(angleXY)
	
	return px, py, pz
end

--[[ number, [number, number] getAngleBetweenPoints( number x1, number y1, [ number z1 , ] number x2, number y2, [ number z2 ] )
	Returns the angle between the two given points. If the z-coordinates are given it returns all three angles.
	x1: x-coordinate of the first point
	y1: y-coordinate of the first point
	z1: z-coordinate of the first point
	x2: x-coordinate of the second point
	y2: y-coordinate of the second point
	z2: z-coordinate of the second point ]]
function getAngleBetweenPoints(x1, y1, z1, x2, y2, z2)
	if (not y2) then
		x2, y2 = z1, x2
		return math.deg(math.atan2((y2 - y1), (x2 - x1))) - 90
	else
		local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
		return math.deg(math.atan2(dz, dy)), math.deg(math.atan2(dz, dx)), -math.deg(math.atan2(dx, dy))
	end
end

function getNormalizedVector(...)
	local dist = table.sum(table.lmap({ ... }, math.pow, 2))^0.5;
	return unpack(table.lmap({ ... }, (dist == 0) and math.zero or math.div, dist));
end

--[[ number getValidAngle( number angle )
	Returns the corresponding angle between -1 and 361 to the given one.
	angle: Potentially out-of-range angle. ]]
function getValidAngle(angle)
	angle = ((angle < 0 or angle >= 360) and angle - math.ceil(angle / 360) * 360 + 360 or angle)
	return (angle==360 and 0 or angle)
end

--- Other ---

function isNumeric(string) return (tonumber(string) ~= nil); end

function round(num, idp) return tonumber(string.format("%." .. (idp or 0) .. "f", num)) end
math.round = round
int = math.floor;

local crcConsts = { 0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F, 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D }
 
function crc32(str)
	local crc, l = 0xFFFFFFFF, str:len();
	for i = 1, l, 1 do
		crc = bitXor(bitRShift(crc, 8), crcConsts[bitAnd(bitXor(crc, str:byte(i)), 0xFF) + 1])
	end
	return bitXor(crc, -1)
end

if (not base64encode) then

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function base64encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

end

--[[------------------------------------------------------------------------||--
						(<---Table Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function table.foldl(tab, func, start, ...)
	local result = start;
	for id, value in ipairs(tab) do
		result = func(result, value, ...);
	end
	return result;
end

function table.fold(tab, func, start, ...)
	local result = start;
	for id, value in pairs(tab) do
		result = func(result, value, ...);
	end
	return result;
end

function table.foldr(tab, func, start, ...)
	local result = start;
	for id, value in ipairs(tab) do
		result = func(value, result, ...);
	end
	return result;
end

function table.rsort(tab, func, ...)
	local result = table.simplecopy(tab);
	table.sort(result, func, ...);
	return result;
end

function table.get(tab, index)
	return tab[index];
end

function table.flipget(index, tab)
	return tab[index];
end

function table.flipinsert(value, tab)
	table.insert(tab, value);
end

function table.add(tab, add)
	table.exec(add, table.flipinsert, tab);
end

function table.max(tab)
	return table.fold(tab, math.max, -2^63);
end

function table.min(tab)
	return table.fold(tab, math.min, 2^63);
end

function table.tonumber(tab)
	for k, value in pairs(tab) do
		tab[k] = tonumber(value) or value;
	end
	return tab;
end

function table.split(tab, func, ...)
	local truePot = { };
	local falsePot = { };
	for _, item in ipairs(tab) do
		table.insert(func(item, ...) and truePot or falsePot, item);
	end
	return truePot, falsePot;
end

function table.tonative(tab)
	return table.lmap(tab, tonative);
end

function table.last(tab)
	return tab[#tab];
end

function table.contains(tab, element)
	for _, a in ipairs(tab) do
		if (a == element) then
			return true;
		end
	end
	return false;
end

function table.reverse(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

-- apply a pattern on a set to sort out elements
function table.localfilter(tab, func, ...)
	func = func or math.id;
	local i = 1;
	local n = #tab;
	
	for j = 1, n do
		if (func(tab[j], ...)) then
			tab[i] = tab[j];
			i = i + 1;
		end
	end
	for j = i, n do
		tab[j] = nil;
	end
	return tab;
end
table.lfilter = table.localfilter;

function table.localfilter2(t, f, ...)
	f = f or math.id;
	local i = 1;
	local n = #t;
	
	for j = 1, n do
		if (f(t[j], ...)) then
			t[i] = t[j];
			i = i + 1;
		end
	end
	for j = i, n do
		t[j] = nil;
	end
	return t;
end

-- apply a pattern on a set to sort out elements
function table.filter(tab, func, ...)
	func = func or math.id;
	local result = { };
	for _, v in ipairs(tab) do
		if (func(v, ...)) then
			table.insert(result, v);
		end
	end
	return result;
end

-- apply a pattern on a set to sort out elements
function table.kfilter(tab, func, ...)
	func = func or math.id;
	local result = { };
	for k, _ in ipairs(tab) do
		if (func(k, ...)) then
			table.insert(result, k);
		end
	end
	return result;
end

function table.filterunsorted(tab, func, ...)
	func = func or math.id;
	local result = { };
	for k, element in pairs(tab) do
		if (func(element, ...)) then
			result[k] = element;
		end
	end
	return result;
end

function table.exists(tab, cond, ...)
	for id, a in pairs(tab) do
		if (cond(a, ...)) then
			return id;
		end
	end
	return false;
end

function table.every(tab, cond, ...)
	for _, a in pairs(tab) do
		if (not cond(a, ...)) then
			return false;
		end
	end
	return true;
end

function table.vremove(tab, value)
	for k, v in pairs(tab) do
		if (v == value) then
			table.remove(tab, k);
			return k;
		end
	end
	return false;
end

function getChildren ( rootElement, type )
	local elements = getElementsByType ( type )
	if (rootElement == root) then
		return elements;
	end
	local result = {}
	for elementKey,elementValue in ipairs(elements) do
		if ( getElementParent( elementValue ) == rootElement ) then
			result[ table.getn( result ) + 1 ] = elementValue
		end
	end
	return result
end

function table.sum(tab)
	return table.fold(tab, math.add, 0);
end

function table.getClientSafeVersion(tab)
	local result = { };
	for key, value in pairs(tab) do
		if (type(value) ~= "function" and (type(value) == "boolean" or isElement(value) or type(value) ~= "userdata")) then
			result[key] = (type(value) == "table") and table.getClientSafeVersion(value) or value;
		end
	end
	return result;
end

function table.simplecopy(tab)
	local result = { };
	for k, v in pairs(tab) do
		result[k] = v;
	end
	return result;
end

--[[ table table.copy( table tab )
	Copies a table.
	tab: Table to copy. ]]
function table.copy(tab, depth)
	depth = depth or -1;
	local ret = {}
	if (depth ~= 0) then
		for key, value in next, tab do ret[key] = (type(value)=="table" and table.copy(value, depth - 1) or value) end
	end
	return ret
end

function table.empty(a)
    if (type(a) ~= "table") then
        return false;
    end
    return not next(a);
end

function table.notempty(a)
    if (type(a) ~= "table") then
        return false;
    end
    return next(a);
end

function table.find(tab, value)
	for id, item in pairs(tab) do
		if (item == value) then
			return id;
		end
	end
end

function table.first(a)
	for _, first in pairs(a) do return first end;
    --return next(a);
end

function table.merge(src, dest)
	for key, value in pairs(src) do
		if (type(value) == "table" and type(dest[key]) == "table") then
			table.merge(dest[key], value);
		else
			dest[key] = value;
		end
	end
	return dest;
end

function table.mergelists(...)
	local result = { };
	for _, tab in ipairs({...}) do
		for _, value in ipairs(tab) do
			table.insert(result, value);
		end
	end
	return result;
end

function table.exec(tab, func, ...)
	if (not tab) then
		outputDebugString("table.exec: "..tostring(debug.traceback()));
	end
	for k, v in pairs(tab) do func(v, ...); end
end

function table.map(tab, func, ...)
	local result = { };
	for k, v in pairs(tab) do
		result[k] = func(v, ...);
	end
	return result;
end

function table.localmap(tab, func, ...)
	for k, v in pairs(tab) do
		tab[k] = func(v, ...);
	end
	return tab;
end
table.lmap = table.localmap;

function table.kmap(tab, func, ...)
	local result = { };
	for k, v in pairs(tab) do
		result[k] = func(k, ...);
	end
	return result;
end

function getPlayerFromPartName(name)
	local partName = removeColorTags(name):lower();
	local result = false;
	for _, player in ipairs(getElementsByType("player")) do
		local name = getPlayerName(player):lower();
		if (name == partName) then
			return player;
		elseif (name:find(partName)) then
			if (not result) then
				result = player;
			else
				return false, "Mupltiple players found";
			end
		end
	end
	return result;
end

function table.linkmap(src, func, ...)
	local tab = { };
	for _, v in pairs(src) do
		tab[v] = func(v, ...);
	end
	return tab;
end

function getRandomElement(tab)
	return (tab[math.random(#tab)]);
end
table.random = getRandomElement;

function table.poprandom(tab)
	local id = math.random(#tab);
	local result = tab[id];
	table.remove(tab, id);
	return (result);
end	

function table.popfirst(tab)
	local id = 1;
	local result = tab[id];
	table.remove(tab, id);
	return (result);
end	

function table.poplast(tab)
	local id = #tab;
	local result = tab[id];
	if (id > 0) then table.remove(tab, id); end
	return (result);
end	

-- like table.remove but takes a condition instead of an index
function table.condremove(tab, cond, ...)
	for k, v in ipairs(tab) do
		if (cond(v, ...)) then
			table.remove(tab, k);
			return k;
		end
	end
	return false;
end

function table.dataequals(tab, data, value)
	return (tab[data] == value);
end

function table.datadiffers(tab, data, value)
	return (tab[data] ~= value);
end

-- like table.find but takes a condition instead of an index
function table.condfind(tab, cond, ...)
	for k, v in ipairs(tab) do
		if (cond(v, ...)) then
			return k;
		end
	end
	return false;
end

-- like table.get but takes a condition instead of an index
function table.condget(tab, cond, ...)
	for k, v in ipairs(tab) do
		if (cond(v, ...)) then
			return v;
		end
	end
	return false;
end

function table.flipinsert(value, tab)
	return table.insert(tab, value);
end

function table.tolist(tab)
	local result = { };
	for key, _ in pairs(tab) do
		table.insert(result, key);
	end
	return result;
end

function table.listcut(tab, begin, to)
	if (not to) then to = begin; begin = 1; end
	local result = { };
	for i = begin, to, 1 do
		table.insert(result, tab[i]);
	end
	return result;
end

function getPlayerAmount()
	return #getElementsByType("player");
end

function table.size(tab)
	return table.fold(tab, math.increase, 0);
end
getTableSize = table.size;

function table.save(tab, file)
	filePut(file, toJSON(tab));
end
saveTable = table.save;

function table.load(file)
	local tab = fileGetContent(file);
	if (tab) then
		if (tab:sub(1, 1) == "[") then
			tab = fromJSON(tab);
			if (tab and type(tab) == "table") then
				return table.ktonative(tab);
			end
		else
			-- Backwards compatiblity on cost of a security leak? No D:
			--return loadTableOld(file);
		end
	end
	return { };
end
loadTable = table.load;

function table.ktonative(tab)
	local result = { };
	for k, v in pairs(tab) do
		result[tonumber(k) or k] = (type(v) == "table") and table.ktonative(v) or v;
	end
	return result;
end

function cleanUpFile(path)
	if (fileExists(path)) then return fileDelete(path); end
end

function filePut(path, str, append)
	if (append) then
		str = (fileGetContent(path) or "") .. str;
	end
	local file = fileCreate(path);
	fileWrite(file, str);
	fileClose(file);
end

function fileGetContent(file)
	if (fileExists(file)) then
		local fh = fileOpen(file); 
		if (fh) then
			local result = fileRead(fh, fileGetSize(fh));
			fileClose(fh);
			return result;
		end
	end
end

function fileGetChecksum(file)
	return md5(fileGetContent(file));
end

function table.dump(this, depth, references, nice)
    -- initialize variables, set defaults
    if (depth == nil) then depth = -1; end
    if (references == nil) then references = true; end
    if (nice) then nice = ""; end
    local dump = {};
    local prefix = nice or "";
    local suffix = (nice and ",\n" or ",");
    
    -- dump table
    for key, value in next, this do
        local keytype, valtype = type(key), type(value);
        
        if (references or
            (keytype ~= "function" and keytype ~= "table" and
             keytype ~= "thread" and keytype ~= "userdata" and
             valtype ~= "function" and valtype ~= "table" and
             valtype ~= "thread" and valtype ~= "userdata")) then

            if (type(value) == "string") then
            	--value = value:format("%q");
            	value = value:gsub("\"", "");
            	value = value:gsub("\\", "");
            	value = value:gsub("\n", "\\n");
            end
            
            if (type(key) == "string") then
            	--key = key:format("%q");
            	key = key:gsub("\"", "");
            	key = key:gsub("\\", "");
                table.insert(dump, prefix.."[\""..key.."\"]=");
            else
                table.insert(dump, prefix.."["..tostring(key).."]=");
            end
            
            if (valtype == "table") then
                if (value == this) then
                    table.insert(dump, "this,");
                elseif (depth ~= 0) then
                    table.insert(dump, table.dump(value, depth - 1, references,
                                                  nice and nice.."    ")..suffix);
                else
                    table.insert(dump, tostring(value)..suffix);
                end
            elseif (valtype == "string") then
                table.insert(dump, "\""..value.."\""..suffix);
            else
                table.insert(dump, tostring(value)..suffix);
            end
        end
    end
    
    -- check if table is empty
    if (not dump[1]) then
        return "{}";
    end
    
    return "{"..(nice and "\n" or "")..prefix..table.concat(dump).."}";
end

function showSmallNotifier()
	return true;
end