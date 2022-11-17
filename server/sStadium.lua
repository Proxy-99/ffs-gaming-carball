local _DO_NOT_COMPILE

--[[----Class-Stadium----||--

	Description:
		Organizes Stadium Options and data

--||---------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

gStadiums = { 
	--["carball-map"] = false,
	--["euro2012"] = false
};
gTeamData = {

};

--[[----General-Data----||--
	
	gStadiums [{}]
		Objects [{}]
		BallSpawn
		FieldLimit
			Min
			Max
		TeamData [{}]
			Goal
				Min
				Max
			Spawnpoints [{}]
			ReserveSpawnpoints [{}]
			
		
--||--------------------]]--

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		for _, resource in ipairs(getResources()) do
			if (getResourceInfo(resource, "type") == "map" and getResourceInfo(resource, "gamemodes") == "cbl") then
				if (getResourceState(resource) == "Running") then
					Stadium.create(resource)
				else
					startResource(resource)
				end
			end
		end
		for name, stadium in pairs(gStadiums) do
			--[[ check if all map resources are loaded and running
			local resource = getResourceFromName(name);
			if (resource and getResourceState(resource) == "Running") then
				gStadiums[name] = Stadium.create(name, resource);
			else
				outputDebugString("Carball could not be started because at least one stadium ("..tostring(name)..") was not running!", 1);
				--cancelEvent();
				--return;
			end]]
		end
	end
);

addEventHandler("onResourceStop", resourceRoot, 
	function ()
		for _, resource in ipairs(getResources()) do
			if (getResourceInfo(resource, "type") == "map" and getResourceInfo(resource, "gamemodes") == "cbl") then
				stopResource(resource)
			end
		end
	end
);

addEventHandler("onResourceStart", root,
	function (resource)
		if (getResourceInfo(resource, "type") == "map" and getResourceInfo(resource, "gamemodes") == "cbl") then
			Stadium.create(resource)
		end
	end
); 

addEventHandler("onPlayerJoin", root,
	function ()
		if (NEON_UNITED) then
			for _, stadium in ipairs(getElementsByType("stadium")) do
				exports.mapmgr:addPlayerToMap(getData(stadium, "Resource"), source)
			end
		end
	end
);

function Stadium.getFromName(name)
	return name and gStadiums["stadium-"..tostring(name)] or gStadiums[tostring(name)]
end

function Stadium.create(resource)
	local mapRoot = getResourceRootElement(resource)
	local name = getResourceName(resource)
	local stadium = createElement("stadium")
	
	-- general info:
	setData(stadium, "ID", name, true)
	setData(stadium, "Name", getResourceNameInfo(resource), true)
	setData(stadium, "FileName", getResourceName(resource), true)
	setData(stadium, "Resource", resource)
	setData(stadium, "ResourceRoot", mapRoot, true)
	setData(stadium, "Author", getResourceInfo(resource, "author") or "Unknown", true)
	
	-- elements
	--setData(stadium, "Objects", getElementsByType("object", mapRoot), true);
	local ballSpawnpoints = getElementsByType("ballspawn", mapRoot)
	
	if (#ballSpawnpoints == 0) then
		return fail(stadium, "No Ball Spawn!")
	end
	setData(stadium, "BallSpawn", ballSpawnpoints[1], true);
	
	-- load field limits
	setData(stadium, "FieldLimit", loadFieldLimit(getElementsByType("fieldcorner", mapRoot)), true)
	
	local teamData = { };
	
	for id, teamInfo in ipairs(getElementsByType("teaminfo", mapRoot)) do
		-- create teamdata element
		local dataElement = createElement("TeamData");
		teamData[id] = dataElement;
		setData(dataElement, "ID", id, true);
		setData(dataElement, "Parent", stadium, true);
		
		-- get goal boundries
		local goal = Goal.create(dataElement, getChildren(teamInfo, "goalcorner"));
		setData(dataElement, "Goal", goal, true);
		
		-- get spawnpoints
		setData(dataElement, "Spawnpoints", getChildren(teamInfo, "spawnpoint"));
		setData(dataElement, "ReserveSpawnpoints", getChildren(teamInfo, "reservespawnpoint"));
	end
	setData(stadium, "TeamData", teamData, true);
	gStadiums[name] = stadium;
	outputDebugString("Stadium "..tostring(name).." loaded!");
	return stadium;
end

function Stadium.getSpawnpoints(stadium, teamID)
	return getData(Stadium.getTeamData(stadium, teamID), "Spawnpoints");
end

function loadFieldLimit(fieldcorners)
	-- get the lowest and the highest positions in the corners
	local minX, minY, minZ, maxX, maxY = filterMinMaxPositions(fieldcorners);
	
	-- and create an element with the information
	local fieldlimit = createElement("FieldLimit");
	setElementPosition(fieldlimit, minX, minY, minZ);
	setData(fieldlimit, "LimitPosition", { x = maxX, y = maxY, z = minZ + 200 }, true);
	return fieldlimit;
end

function fail(stadium, reason)
	outputDebugString("[Stadium] Load of: "..tostring(getData(stadium, "Name")).." failed. Reason: "..tostring(reason));
	destroyElement(stadium);
	return false
end