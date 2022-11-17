
--[[------------------------------------------------------------------------||--
								(<---Functions--->)								
																				
--||------------------------------------------------------------------------]]--

local _getElementsByType = getElementsByType;
function getElementsByType(eType, rootElem, ...)
	if (isValid(rootElem) and getElementType(rootElem) == ARENA_ELEMENT_TYPE) then
		local elements = { };
		for _, element in ipairs(_getElementsByType(eType, root, ...)) do
			if (getElementArena(element) == rootElem) then
				table.insert(elements, element);
			end
		end
		return elements;
	else
		return _getElementsByType(eType, rootElem or root, ...);
	end
end

local pModeHandlers = { };

function modeHandlerEventWrapper(event, mode, ...)
	if (Arena.getMode(source) == mode) then
		if (pModeHandlers[event] and pModeHandlers[event][mode]) then
			for _, func in ipairs(pModeHandlers[event][mode]) do
				func(...);
			end
		end
	end
end

function addModeHandler(event, mode, func)
	if (not pModeHandlers[event]) then pModeHandlers[event] = { } end
	if (not pModeHandlers[event][mode]) then 
		pModeHandlers[event][mode] = { }
		local wrapperFunc = loadstring("return function (...) modeHandlerEventWrapper(\""..tostring(event).."\", \""..tostring(mode).."\", ...); end")();
		addEventHandler(event, resourceRoot, wrapperFunc);
	end
	table.insert(pModeHandlers[event][mode], func);
end

function fillString(number, length)
	length = length or 2;
	number = tostring(number);
	
	while (#number < length) do
		number = "0" .. number;
	end
	return number;
end
