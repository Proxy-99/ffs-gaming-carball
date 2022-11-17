local _DO_NOT_COMPILE

addEvent("onPlayerInit");
addEvent("onClientDownloadFinished", true);
addEvent("onTjongDataChange");

addEventHandler("onResourceStart", resourceRoot,
	function ()
		if (DEBUG) then
			outputDebugString("Resource started with debug mode: ON");
		end
	end
);

--[[------------------------------------------------------------------------||--
						(<---Overriding Functions--->)								
																				
--||------------------------------------------------------------------------]]--

--if (ENABLE_EVENT_TRIGGER_CHECKS) then
	
local _triggerClientEvent = triggerClientEvent;
function triggerClientEvent(rootElement, ...)
	if (not isElement(rootElement)) then
		for _, player in ipairs(table.lfilter(getElementsByType("player"), isPlayerDownloadFinished)) do
			_triggerClientEvent(player, rootElement, ...);
		end
	elseif (rootElement == root) then
		for _, player in ipairs(table.lfilter(getElementsByType("player"), isPlayerDownloadFinished)) do
			_triggerClientEvent(player, ...);
		end
	elseif (getElementType(rootElement) == "player") then
		local args = { ... };
		if (isPlayerDownloadFinished(rootElement)) then
			_triggerClientEvent(rootElement, ...);
		end
	else
		for _, player in ipairs(table.lfilter(getChildren(rootElement, "player"), isPlayerDownloadFinished)) do
			_triggerClientEvent(player, ...);
		end
	end
end
	
local _triggerLatentClientEvent = triggerLatentClientEvent;
function triggerLatentClientEvent(rootElement, ...)
	if (not isElement(rootElement)) then
		for _, player in ipairs(table.lfilter(getElementsByType("player"), isPlayerDownloadFinished)) do
			_triggerLatentClientEvent(player, rootElement, ...);
		end
	elseif (rootElement == root) then
		for _, player in ipairs(table.lfilter(getElementsByType("player"), isPlayerDownloadFinished)) do
			_triggerLatentClientEvent(player, ...);
		end
	elseif (getElementType(rootElement) == "player") then
		local args = { ... };
		if (isPlayerDownloadFinished(rootElement)) then
			_triggerLatentClientEvent(rootElement, ...);
		end
	else
		for _, player in ipairs(table.lfilter(getChildren(rootElement, "player"), isPlayerDownloadFinished)) do
			_triggerLatentClientEvent(player, ...);
		end
	end
end

--end

--[[------------------------------------------------------------------------||--
						(<---General Functions--->)								
																				
--||------------------------------------------------------------------------]]--

function callClientFunction(client, funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerClientEvent(client, "onServerCallsClientFunction", resourceRoot, funcname, unpack(arg or {}))
end

pFinishedDownloaders = { };

addEventHandler("onClientDownloadFinished", resourceRoot,
	function (player) 
		pFinishedDownloaders[player] = true;
		triggerClientEvent(player, "onClientServerTickReceive", root, getTickCount());
	end, false, "high+1000000000"
);

addEventHandler("onPlayerQuit", root,
	function () 
		pFinishedDownloaders[source] = nil;
	end
);

function isPlayerDownloadFinished(player)
	return pFinishedDownloaders[player];
end

function getPlayersWithDownloadFinished()
	return table.lfilter(getElementsByType("player"), isPlayerDownloadFinished);
end

function getResourceNameInfo(resource)
	return (getResourceInfo(resource, "name") or getResourceName(resource));
end

function isPedAlive(ped)
	return not isPedDead(ped);
end

--[[------------------------------------------------------------------------||--
						(<---Element Functions--->)								
																				
--||------------------------------------------------------------------------]]--

local pDataStorage = { };
local pSyncedDataStorage = { };

function dataEquals(element, data, value)
	return ((pDataStorage[element] and pDataStorage[element][data]) == value);
end

function getData(element, data)
	return (pDataStorage[element] and pDataStorage[element][data]);
end

function getAllData(element)
	return (pDataStorage[element] or { });
end

function increaseData(element, data, value, sync, keepOrder)
	value = value or 1;
	if (not pDataStorage[element]) then pDataStorage[element] = { }; end
	if (not pDataStorage[element][data]) then pDataStorage[element][data] = 0; end
	setData(element, data, (pDataStorage[element][data] or 0) + (value or 1), sync, keepOrder)
end

function forceDataSync(element, data, syncElement)
	triggerClientEvent(syncElement or root, "onClientTjongDataReceive", resourceRoot, element, data, pDataStorage[element] and pDataStorage[element][data]);
end

function setData(element, data, value, sync, keepOrder)
	keepOrder = true;
	if (not pDataStorage[element]) then pDataStorage[element] = { }; end
	
	if (value ~= pDataStorage[element][data]) then
		if (isElement(element)) then
			triggerEvent("onTjongDataChange", element, data, pDataStorage[element][data], value);
		end
		pDataStorage[element][data] = value;
		if (sync) then
			local syncElement = isElement(sync) and sync or root;
			if (not pSyncedDataStorage[syncElement]) then pSyncedDataStorage[syncElement] = { }; end
			if (not pSyncedDataStorage[syncElement][element]) then pSyncedDataStorage[syncElement][element] = { }; end
			pSyncedDataStorage[syncElement][element][data] = value;
			if (keepOrder) then
				triggerClientEvent(syncElement, "onClientTjongDataReceive", resourceRoot, element, data, value);
			else
				triggerLatentClientEvent(syncElement, "onClientTjongDataReceive", 10 * MEGA_BYTE, resourceRoot, element, data, value);
			end
		end
		--setElementData(element, data, value);
	end
end

local _setElementParent = setElementParent;
function setElementParent(element, parent)
	if (getElementType(element) == "player") then
		if (pSyncedDataStorage[parent]) then
			triggerClientEvent(element, "onClientTjongInitDataReceive", resourceRoot, pSyncedDataStorage[parent]);
		end
	end
	_setElementParent(element, parent);
end

addEventHandler("onClientDownloadFinished", resourceRoot,
	function (player)
		pFinishedDownloaders[player] = true;
		--triggerLatentClientEvent(player, "onClientTjongInitDataReceive", 10 * MEGA_BYTE, resourceRoot, pSyncedDataStorage[root]);
		triggerClientEvent(player, "onClientTjongInitDataReceive", resourceRoot, pSyncedDataStorage[root]);
		local parent = getElementParent(player);
		if (parent ~= root and pSyncedDataStorage[parent]) then
			--triggerLatentClientEvent(player, "onClientTjongInitDataReceive", 10 * MEGA_BYTE, resourceRoot, pSyncedDataStorage[parent]);
			triggerClientEvent(player, "onClientTjongInitDataReceive", resourceRoot, pSyncedDataStorage[parent]);
		end
	end, true, "high+1000000"
);

addEventHandler("onElementDestroy", root,
	function ()
		if (pDataStorage[source]) then
			pDataStorage[source] = nil;
		end
		if (pSyncedDataStorage[root] and pSyncedDataStorage[root][source]) then
			pSyncedDataStorage[source] = nil;
		end
		local parent = getElementParent(source);
		if (pSyncedDataStorage[parent] and pSyncedDataStorage[parent][source]) then
			pSyncedDataStorage[parent][source] = nil;
		end
	end, true, "low-10000"
);
