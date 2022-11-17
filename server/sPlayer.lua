local _DO_NOT_COMPILE

--[[----Class-Player----||--

	Description:
		Handles Player functions

--||--------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Player.setMatchTeam(player, team)
	local oldTeam = Player.getMatchTeam(player);
	if (oldTeam) then
		MatchTeam.removePlayer(oldTeam, player);
		setPlayerTeam(player);
	end
	setData(player, "MatchTeam", team, true);
	if (team) then
		MatchTeam.addPlayer(team, player);
	end
end

function Player.getStaticTeam(player)
	return getData(player, "Team");
end

function Player.setStaticTeam(player, team)
	setData(player, "Team", team, true);
	setPlayerTeam(player, team);
	setData(player, "StaticTeamID", Team.getID(team));
end

function Player.spawn(player)
	Player.selectModeFunction(player, { Training = Player.TrainingSpawn, Match = Player.MatchSpawn, Replay = Player.ReplaySpawn });
end

function Player.ReplaySpawn(player)
	--[[local arena = getElementArena(player);
	local stadium = Arena.getStadium(arena);
	local spawnpoints = Stadium.getSpawnpoints(stadium, 1);--math.random(Stadium.getTeamAmount(stadium)));
	spawnAtSpawnpoint(player, spawnpoints[1]);
	local veh = Player.getVehicle(player);
	local c = { r = math.random(255), g = math.random(255), b = math.random(255) };
	setVehicleColor(veh, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b);
	setElementFrozen(veh, true);
	setTimer(
		function (vehicle)
			if (isValid(vehicle)) then
				setElementFrozen(vehicle, false);
			end
		end, 2000, 1, veh
	);]]
end

function Player.TrainingSpawn(player)
	local arena = getElementArena(player);
	local stadium = Arena.getStadium(arena);
	local spawnpoints = Stadium.getSpawnpoints(stadium, 1);--math.random(Stadium.getTeamAmount(stadium)));
	spawnAtSpawnpoint(player, spawnpoints[1]);
	local veh = Player.getVehicle(player);
	local random = math.random(1, 2);
	--local c = { r = math.random(255), g = math.random(255), b = math.random(255) };
	local c = ((random == 1) and { r = 255, g = 64, b = 54 } or { r = 54, g = 64, b = 255 });
	setVehicleColor(veh, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b);
	setElementFrozen(veh, true);
	setTimer(
		function (vehicle, arena)
			if (isValid(vehicle)) then
				setElementFrozen(vehicle, false);
				if (Arena.getState(arena) == "GoldenGoal") then
					--Unfreeze balls if frozen
					for id, ball in ipairs(getElementsByType("ball", arena)) do
						if isValid(ball) and isElementFrozen(ball) then
							setElementFrozen(ball, false)
						end
					end
				end
			end
		end, 2000, 1, veh, arena
	);
end

function Player.MatchSpawn(player)
	local team = Player.getMatchTeam(player)
	if (team) then
		local arena = getElementArena(player)
		local stadium = Arena.getStadium(arena)
		local spawnpoints = Stadium.getSpawnpoints(stadium, getData(team, "ID"))
		setData(arena, "SpawnPosCount", ((getData(arena, "SpawnPosCount") or 0)) % #spawnpoints + 1)
		spawnAtSpawnpoint(player, spawnpoints[getData(arena, "SpawnPosCount")])
		local veh = Player.getVehicle(player)
		--local c = getData(team, "Color");
		--setVehicleColor(veh, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b, c.r, c.g, c.b);
		setElementFrozen(veh, true)
		if (Arena.getState(arena) == "Running" or Arena.getState(arena) == "GoldenGoal") then
			setTimer(
				function (vehicle, arena)
					if (isValid(vehicle) and (Arena.getState(arena) == "Running" or Arena.getState(arena) == "GoldenGoal")) then
						setElementFrozen(vehicle, false)
					end
				end, 2000, 1, veh, arena
			);
		end
	end
end

function Player.MatchRespawn(player)
	local team = Player.getMatchTeam(player);
	
	if team then
		
		local vehicle = Player.getVehicle(player);
		
		if isValid(vehicle) then

			local arena = getElementArena(player);
			local stadium = Arena.getStadium(arena);
			local spawnpoints = Stadium.getSpawnpoints(stadium, getData(team, "ID"));
			setData(arena, "SpawnPosCount", ((getData(arena, "SpawnPosCount") or 0)) % #spawnpoints + 1);
			local spawnpoint = spawnpoints[getData(arena, "SpawnPosCount")];

			local x, y, z = getElementPosition(spawnpoint);
			local rz =	getElementData(spawnpoint, "rotZ") or
						getElementData(spawnpoint, "rz") or
						getElementData(spawnpoint, "rotation");

			setElementPosition(vehicle, x, y, z + 1);
			setElementRotation(vehicle, 0, 0, rz);

			setElementFrozen(vehicle, true);

			local remainingTime = Arena.getRemainingTime(arena);

			triggerClientEvent(player, "onClientMatchRespawn", player, remainingTime);
		else
			Player.MatchSpawn(player);
		end
	
	end
end

function spawnAtSpawnpoint(player, spawnpoint)
	-- clean up
	cleanUp(getData(player, "Vehicle"))

	-- gain information
	local arena = getElementArena(player)
	local x, y, z = getElementPosition(spawnpoint)
	local rz = getElementData(spawnpoint, "rotZ") or
				getElementData(spawnpoint, "rz") or
				getElementData(spawnpoint, "rotation")
				
	-- create vehicle and modify it
	local model = Arena.getOption(arena, "VehicleModel")
	--[[local team = Player.getMatchTeam(player);
	if team and model == 495 then
		outputChatBox(model);
		local teams = getElementsByType("matchteam", arena);
		model = team == teams[1] and 495 or 500;
	end]]
	local teams = getElementsByType("matchteam", arena)
	local team = Player.getMatchTeam(player)

	local color = (team == teams[1]) and {255, 212, 63, 255, 49, 49} or {255, 255, 255, 16, 65, 131}
	
	local vehicle = createVehicle(Arena.getOption(arena, "VehicleModel"), x, y, z + 1, 0.0, 0.0, rz)
	
	setVehicleColor(vehicle, unpack(color))
	
	setElementArena(vehicle, arena)
	setVehicleHandling(vehicle, "tractionMultiplier", 2.0)
	setVehicleHandling(vehicle, "dragCoeff", 0.0)
	setVehicleHandling(vehicle, "centerOfMass", { 0.0, 0.0, -0.8 } )
	addVehicleUpgrade(vehicle, 1010)
	setVehicleDamageProof(vehicle, true)
	
	-- warp player into vehicle
	spawnPlayer(player, x, y, z + 15.0)
	warpPedIntoVehicle(player, vehicle)
	--setElementAlpha(player, 0);

	setData(player, "Vehicle", vehicle, true);
end

function Player.showLobby(player, msg, reason)
	local arena = getElementArena(player);
	if (arena ~= LOBBY_ARENA) then
		triggerEvent("onArenaPlayerExit", arena, player, reason or "Leave");
		triggerClientEvent(player, "onClientArenaPlayerExit", arena, player);
		setElementArena(player, LOBBY_ARENA);
		if (msg and IS_FFS) then
			if (IS_FFS) then
				--exports.ffs:addNotification(player, msg, 4);
			end
			--exports.notifications:showNotifier(player, "Info", "Arena", msg, false, false);	
		end
	end
end

function Player.isSpectator(player)
	return (not Player.getMatchTeam(player));
end

function Player.selectModeFunction(player, functions, ...)
	local arena = getElementArena(player);
	if (isValid(arena) and arena ~= LOBBY_ARENA) then
		local mode = Arena.getMode(arena);
		local func = functions[mode];
		if (func) then
			func(player, ...);
			return true
		else
			if (IS_FFS) then
				exports.ffs:addNotification(player, "Failed to join the arena.", 3);
			end
			outputDebugString("Couldn't select function for arena: "..tostring(Arena.getID(arena)).." and mode: "..tostring(mode), 1);
		end
	end
	setTimer(
		function (player)
			if (isValid(player)) then
				Player.showLobby(player);
			end
		end, 1000, 1, player
	);
	return false;
end

function Player.startMatch(player)
	local arena = getElementArena(player);
	if (arena ~= LOBBY_ARENA and isValid(arena) and Arena.getMode(arena) == "Match" and player == Arena.getCreator(arena)) then
		if (Player.getMatchTeam(player) and Arena.getState(arena) == "Initializing") then
			Arena.goToState(arena, "Running");
		end
	end
end

function Player.leave(player)
	local arena = getElementArena(player);
	if (isValid(arena) and arena ~= LOBBY_ARENA) then
		triggerEvent("onArenaPlayerExit", arena, player, "Leave");
	end
end

addEventHandler("onPlayerMatchTeamSelect", root,
	function (team)
		local arena = getElementArena(source);
		--outputDebugString("SEREVER arena: "..tostring(Arena.getID(arena)).." arena team: "..tostring(Arena.getID(getElementArena(team))));
		outputDebugString("Player Team Select: "..tostring(MatchTeam.getSize(team)).." team pa: "..tostring(MatchTeam.getPlayerAmount(team)));
		if (team and arena == getElementArena(team)) then
			if (not getData(source, "Spectator")) then
				if (MatchTeam.getPlayerAmount(team) < MatchTeam.getSize(team)) then
					outputDebugString("Player Team Select Ping: "..tostring(getPlayerPing(source)).." Limit: "..tostring(Arena.getOption(arena, "PingLimit")));
					if (getPlayerPing(source) <= Arena.getOption(arena, "PingLimit")) then
						Player.setMatchTeam(source, team);
						Player.spawn(source);
						if (Arena.getState(arena) == "Initializing" and not Arena.getCreator(arena)) then
							setTimer(
								function (arena)
									if (Arena.getState(arena) == "Initializing" and #getElementsByType("player", arena) >= 1) then
										Arena.goToState(arena, "Running");
									end
								end, (DEBUG and 1000 or 10000), 1, arena
							);
						end
					else
						if (IS_FFS) then
							exports.ffs:addNotification(source, "Ping is too high to enter!", 3);
						end
						--outputChatBox("[WARNING] #ffffffPing is too high to enter!", source, 255, 30, 30, true);
					end
				else
					if (IS_FFS) then
						exports.ffs:addNotification(source, "Team is full!", 3)
					end
					--outputChatBox("[WARNING] #ffffffTeam is full!", source, 255, 30, 30, true);
				end
			else
				if (IS_FFS) then
					exports.ffs:addNotification(source, "Cannot join, you are a spectator!", 3)
				end
				--exports.notifications:showNotifier(source, "Warning", "Team", "Can't enter the match.\nYou're spectator!", false, false);
				--outputChatBox("[WARNING] #ffffffCannot join, because you are a sepctator!", source, 255, 30, 30, true);
			end
		end
	end
);

addEventHandler("onArenaStateChange", root,
	function (oldState, newState)
		if (newState == "Paused") then
			setTimer(
				function (arena)
					if (isValid(arena)) then
						for _, player in ipairs(Arena.getActivePlayers(arena)) do
							fixVehicle(getData(player, "Vehicle"))
						end
					end
				end, GOAL_RECORDING_TIME + 3 * SECONDS, 1, source
			);
		end
	end
);

addEventHandler("onArenaPlayerInit", resourceRoot,
	function (player)
		Player.spawn(player);
		if (IS_FFS) then
			exports.ffs:addNotification(player, "Press F2 to return to lobby", 4)
		end	
	end
);

addEventHandler("onArenaPlayerExit", resourceRoot,
	function (player)
		setData(player, "MatchSpawn", false, false)
		if (Arena.getState(source) == "Paused") then
			setTimer(
				function (vehicle)
					cleanUp(vehicle);
				end, GOAL_RECORDING_TIME, 1, getData(player, "Vehicle")
			);
			setData(player, "Vehicle", false)
		else
			cleanUp(getData(player, "Vehicle"))
		end
		Player.setMatchTeam(player, false)
	end, true, "low-1000000"
)

addEventHandler("onArenaStateChange", root,
	function (oldState, newState)
		if (oldState == "Initializing") then
			for _, player in ipairs(getElementsByType("player", source)) do
				local vehicle = Player.getVehicle(player);
				if (isValid(vehicle)) then
					setElementFrozen(vehicle, false)
				end
			end
		end
	end
)


addEventHandler("onPlayerInit", resourceRoot, 
	function (player)
		bindKey(player, "F2", "down", Player.showLobby)
		bindKey(player, "enter", "down", Player.startMatch)
	end
)

addEventHandler("onPlayerExit", resourceRoot, 
	function (player)
		unbindKey(player, "F2", "down", Player.showLobby)
		unbindKey(player, "enter", "down", Player.startMatch)
	end
)
