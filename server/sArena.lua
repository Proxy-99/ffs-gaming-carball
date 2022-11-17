local _DO_NOT_COMPILE
--[[----Class-Arena----||--

	Description:
		Controls the different matches

--||-------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

DEFAULT_MATCH_LENGTH = 9 * MINUTES;

--[[----Player-Data----||--

	
--||-------------------]]--

gArenas = { };

--[[----General-Data----||--
	
	DELETE_AFTER_IDLE_TIME
	
	gArenas [{}]
		ID
		Options [{}]
			Mode
				Match
				Training
				Replay
			Friendly (Only in Match Mode)
			Teams [{}] (Only in Match Mode)
			MatchLength (Only in Match Mode)
			-- TeamSize = 1, 2, 3, 4, 5, 11 (Only in Match Mode) (Moved to MatchTeam data)
			PingLimit = 50, 100, 200, 300, 500, Unlimited
			Stadium
			FileName (Only in Replay Mode)
			BallAmount (Only varyable in Training)
			Persistent (Only settable by Admins)
		State
			Initializing
			Running
			Paused
			GoldenGoal
			Finished
		
		
--||--------------------]]--
--[[
addCommandHandler("createarena",
	function (player)
		local stadium = Stadium.getFromName((math.random() < 0.5 and "neonSoccer" or "euro2012"));
		local arena = Arena.create({ Stadium = stadium, BallAmount = #gArenas });
		--outputChatBox("Arena "..tostring(Arena.getID(arena)).." created! stadium: "..tostring(stadium), root);
	end
);

addCommandHandler("joinarena",
	function (player, _, arenaID)
		local arena = Arena.getByID(tonumber(arenaID));
		if (arena) then
			Arena.insertPlayer(arena, player);
			outputChatBox("Joined Arena: "..tostring(arenaID).." with Stadium: "..tostring(Arena.getStadium(arena)), player);
		else
			outputChatBox("There's no Arena with the ID: "..tostring(arenaID));
		end
	end
);]]

addCommandHandler("arenakick",
	function (player, _, playerPartName)
		local kickPlayer = getPlayerFromPartName(playerPartName);
		
		if (isValid(kickPlayer) and (getElementArena(player) ~= LOBBY_ARENA) and (getElementArena(kickPlayer) ~= LOBBY_ARENA) and 
			getElementArena(player) == getElementArena(kickPlayer)) then
			
			local ranks = exports.mysql:getPlayerRanks(player);
			outputConsole("ranks: "..tostr(ranks));
			if (Arena.getOption(getElementArena(player), "Creator") == player or table.exists(ranks, function (rank) return (rank == "Member" or rank == "Trial"); end)) then
				Player.showLobby(kickPlayer, false, "Arena Kick");
				if (IS_FFS) then
					exports.ffs:addNotification(kickPlayer, "You were kicked from the arena by: " .. getPlayerName(player), 3);
				end
			end
		else
			if (IS_FFS) then
				exports.ffs:addNotification(player, "Unique player with that name not found", 3);
			end
		end
	end
);

addEventHandler("onPlayerArenaJoinRequest", root,
	function (arena, password, spectateOnly)
		if (isValid(arena)) then
			local arenaPW = Arena.getOption(arena, "Password");
			-- check if there is a password and return if not correct
			if (arenaPW) then
				if (spectateOnly) then
					setData(source, "Spectator", true);
				elseif(not password or md5(ARENA_PASSWORD_SALT .. password) ~= arenaPW) then
					if (IS_FFS) then
						exports.ffs:addNotification(source, "Wrong password!", 3);
					end
					return
				end
			end
			-- insert else
			Arena.insertPlayer(arena, source);
		end
	end
);

addEventHandler("onClientArenaCreationRequest", root,
	function (options)
		if (getData(source, "Arena") == LOBBY_ARENA) then
			-- check options to prevent manipulation by clients
			if (options.Mode == "Match" or options.Mode == "Training" or options.Mode == "Replay") then
				if ((options.Mode == "Replay" and gReplays[options.FileName]) or
					(options.Mode ~= "Replay" and isValid(options.Stadium) and getElementType(options.Stadium) == "stadium")) then
					if (options.Mode ~= "Match" or (type(options.Teams) == "table" and #options.Teams == Stadium.getTeamAmount(options.Stadium))) then
						-- correct/add options
						options.Creator = source;
						options.CreatorName = getPlayerName(source);
						if (options.Mode == "Training") then
							options.BallAmount = 10;
						elseif (options.Mode == "Match") then
							options.BallAmount = 1;
							options.PingLimit = tonumber(options.PingLimit) or 100000;
						end
						options.Persistent = DEBUG;
						
						if (type(options.Vehicle) ~= "string") then
							options.Vehicle = "Sandking";
						end
						options.VehicleModel = getVehicleModelFromName(options.Vehicle:lower()) or 495;
						
						-- calculate password hash
						local clearPW = options.Password;
						if (options.Password and type(options.Password) == "string" and #options.Password > 0) then
							options.Password = md5(ARENA_PASSWORD_SALT .. options.Password);
						else
							options.Password = false;
						end
						
						outputDebugString("ARENA CREATE OPTIONS: "..tostring(table.dump(options)));
					
						-- create arena
						local arena = Arena.create(options);
						--table.exec(getElementsByType("player"), showSmallNotifier, "users", getPlayerName(source, true) .. " #ffffffcreated Arena #00ff00"..tostring(Arena.getID(arena)) .. (options.Mode == "Match" and " #ffffff["..tostring(options.Teams[1].size).."vs"..tostring(options.Teams[2].size).."]" or ""));
						
						-- insert player
						Arena.insertPlayer(arena, source);
						if (IS_FFS) then
							exports.ffs:addNotification(source, "Arena successfully created! Name: " .. Arena.getName(arena) .. (options.Password and " (Password: " .. tostring(clearPW) .. ")" or ""), 1);
						end
					end
				end
			end
		end
	end
);

function Arena.create(options)
	local id = #gArenas + 1;
	-- insert at the first free slot
	local arena = createElement("cbArena");
	setElementParent(arena, arenaElement);
	gArenas[id] = arena;
	setData(arena, "ID", id, true);
	setData(arena, "TeamSize", options.TeamSize, false);
	
	-- read and modify options
	if (options.Mode == "Match") then
		for id, info in ipairs(options.Teams) do
			local team = MatchTeam.create(arena, id, info);
		end
		
		options.MatchLength = options.MatchLength or DEFAULT_MATCH_LENGTH;
		setData(arena, "RemainingTime", options.MatchLength, true);
	end
	setData(arena, "Options", options, true);
	
	-- create balls
	for i = 1, options.BallAmount or 1, 1 do
		Ball.create(arena, i * 4);
	end
	
	-- initialize
	Arena.goToState(arena, "Initializing");
	triggerEvent("onArenaInit", arena);
	return arena;
end

function Arena.restart(arena)
	Arena.goToState(arena, "Initializing");

	local options = getData(arena, "Options");
	setData(arena, "RemainingTime", options.MatchLength, true);
	setData(arena, "SpawnPosCount", 0);

	local teams = getElementsByType("matchteam", arena);

	for _, team in ipairs(teams) do
		setData(team, "Score", 0, true);
	end
	
	Arena.respawn(arena);

	--Respawn balls
	for id, ball in ipairs(getElementsByType("ball", arena)) do
		Ball.respawn(ball);
		Ball.setBestSyncer(ball, true);
		setElementVelocity(ball, 0.0, 0.0, 0.0, true);
	end

	if (#getElementsByType("player", arena) >= 1) then
		setTimer(
			function (arena)
				if (Arena.getState(arena) == "Initializing" and #getElementsByType("player", arena) >= 1) then
					Arena.goToState(arena, "Running");
				end
			end, (DEBUG and 1000 or 5000), 1, arena
		);
	end
end

function Arena.respawn(arena)
	setData(arena, "SpawnPosCount", 0);
	for _, player in pairs(getElementsByType("player", arena)) do
		Player.MatchRespawn(player);
	end
end

function arenaEndTimerElapsed(arena)
	-- basically check if game is finished (and doesn't continue to Golden Goal)
	local teams = getElementsByType("matchteam", arena);
	local score = MatchTeam.getScore(teams[1]);
	table.remove(teams, 1);
	local finished = true;
	for _, team in ipairs(teams) do
		local newScore = MatchTeam.getScore(team);
		if (newScore > score) then
			finished = true;
			score = newScore;
		elseif (newScore == score) then
			finished = false;
		end
	end
	if (finished) then
		Arena.goToState(arena, "Finished");
	else
		Arena.goToState(arena, "GoldenGoal");
	end
end

addModeHandler("onArenaStateChange", "Match",
	function (oldState, newState)
		--if (Arena.getMode(source) == "Match") then
			local timer = Arena.getEndTimer(source);
			if (timer and isTimer(timer)) then
				killTimer(timer);
			end
			if (newState == "Initializing") then
				-- initialize
				setData(source, "StartTick", getRealTime()["timestamp"] * 1000);
				setData(source, "TimePlayed", 0);
			elseif (newState == "Running") then
				-- set new tick
				setData(source, "StartTick", getRealTime()["timestamp"] * 1000);
				local remainingTime = Arena.getMatchLength(source) - getData(source, "TimePlayed");
				setData(source, "EndTimer", setTimer(arenaEndTimerElapsed, (remainingTime > 50) and remainingTime or 50, 1, source));

				for _, player in pairs(getElementsByType("player", source)) do
					local vehicle = Player.getVehicle(player);
					if (isValid(vehicle)) then
						setElementFrozen(vehicle, false);
					end
				end
			elseif (newState == "Finished") then
				--respawn and restart
				for _, player in pairs(getElementsByType("player", arena)) do
					outputChatBox("New match starts in 30 seconds", player);
				end
				setTimer( Arena.restart, 25 * SECONDS, 1, source);
			else
				-- calculate the diff until then
				Arena.updateTimePlayed(source);
			end
		--end
	end
);

function Arena.updateTimePlayed(arena)
	if (Arena.getState(arena) == "Running") then
		local tick = getRealTime()["timestamp"] * 1000;
		local diff = tick - getData(arena, "StartTick");
		increaseData(arena, "TimePlayed", diff);
		setData(arena, "StartTick", tick);
	end
end

function Arena.getRemainingTime(arena)
	Arena.updateTimePlayed(arena);
	return (math.max(0, Arena.getMatchLength(arena) - getData(arena, "TimePlayed")));
end

function Arena.getEndTimer(arena)
	return getData(arena, "EndTimer");
end

addModeHandler("onArenaPlayerPreInit", "Match",
	function (player)
		outputDebugString("arena pre init: "..tostring(player).." arena: "..tostring(arena and Arena.getID(arena)));
		if (not getData(source, "StartTick")) then
			setData(source, "StartTick", getRealTime()["timestamp"] * 1000);
			setData(source, "TimePlayed", 0);
		end
		
		setData(source, "RemainingTime", Arena.getRemainingTime(source), true);
	end
);

function Arena.goToState(arena, state)
	if (isValid(arena)) then
		outputDebugString("arena "..tostring(Arena.getID(arena)).." state changing: "..tostring(getData(arena, "State")).." -> "..tostring(state));
		triggerEvent("onArenaStateChange", arena, getData(arena, "State"), state);
		triggerClientEvent(arena, "onClientArenaStateChange", arena, getData(arena, "State"), state);
		setData(arena, "State", state, true);
	end
end

function Arena.destroy(arena)
	if (isValid(arena) and not getData(arena, "ARENA_EXITING")) then
		local id = Arena.getID(arena);
		--local arena = gArenas[id];
		triggerEvent("onArenaExit", arena);
		setData(arena, "ARENA_EXITING", true);
		-- exit players
		for _, player in pairs(getElementsByType("player", arena)) do
			Player.showLobby(player, "Arena has been terminated.");
		end
		local endTimer = getData(arena, "EndTimer");
		if (endTimer and isTimer(endTimer)) then
			killTimer(endTimer);
		end
		-- remove arena
		destroyElement(arena);
		gArenas[id] = nil;
	end
end

function Arena.isIDActive(arenaID)
	return Arena.getByID(arenaID);
end

function Arena.getByID(arenaID)
	return gArenas[arenaID];
end

function Arena.insertPlayer(arena, player)
	local oldArena = getElementArena(player);
	if (arena ~= oldArena) then
		if (oldArena and oldArena ~= LOBBY_ARENA) then
			triggerEvent("onArenaPlayerExit", arena, player, "Leave");
			triggerClientEvent(player, "onClientArenaPlayerExit", arena, player);
		end
		--[[
		local active = false;
		local mode = Arena.getMode(arena);
		if (mode == "Match") then
			active = Arena.isTeamParticipating(arena, Player.getTeam(player));
		elseif (mode == "Training") then
			active = true;
		end]]
		triggerEvent("onArenaPlayerPreInit", arena, player, active);
		
		-- set arena
		setElementArena(player, arena);
		triggerClientEvent(player, "onClientArenaPlayerPreInit", arena, player, active);
		triggerEvent("onArenaPlayerInit", arena, player, active);
		triggerClientEvent(player, "onClientArenaPlayerInit", arena, player, active);
	end
end

function Arena.isTeamParticipating(arena, team)
	for _, pTeam in pairs(Arena.getOptions().Teams) do
		if (pTeam == team) then
			return true;
		end
	end
	return false;
end

function setElementArena(element, arena)
	setData(element, "Arena", arena, true, true);
	local dimension = Arena.getDimension(arena) or LOBBY_ARENA_DIMENSION;
	setTimer(function (element, dimension)
		--outputDebugString("setting dimension of a "..tostring(getElementType(element)).." to: "..tostring(id));
		setElementDimension(element, dimension);
	end, 50, 1, element, dimension);
	setElementParent(element, (arena == LOBBY_ARENA) and arenaElement or arena);
end

addEventHandler("onArenaPlayerInit", resourceRoot,
	function (player)
		if IS_FFS then
			exports.ffs_utils2:outputCrapBox( source, "join", getPlayerName( player ) .. "#ffffff joined", getPlayerClanID( player ) );
		end
	end
);

addEventHandler("onArenaPlayerExit", resourceRoot,
	function (player, reason)
		setData(player, "Spectator", false);
		
		if IS_FFS then
			exports.ffs_utils2:outputCrapBox( source, "join", getPlayerName( player ) .. "#ffffff joined", getPlayerClanID( player ) );
		end

		if (#getElementsByType("player", source) <= 1) then
			if not Arena.getOption(source, "Persistent") then
				setTimer(
					function (arena)
						Arena.destroy(arena);
					end, 50, 1, source
				);
			else
				--Restart arena for new-comers
				Arena.restart(source);
			end

		end
	end, true, "low-100000"
);

GREEK_ALPHABET = {"ALPHA", "BETA", "GAMMA", "DELTA", "EPSILON", "ZETA", "ETA", "THETA", "IOTA", "KAPPA", "LAMBDA", "MU", "NU", "XI", "OMICRON", "PI", "RHO", "SIGMA", "TAU", "UPSILON", "PHI", "CHI", "PSI", "OMEGA"};
RANDOM_DURATION = {9, 9, 15, 30, 45}
addEventHandler("onResourceStart", resourceRoot, 
	function ()
		setTimer(
			function ()
				for i = 1, (DEBUG and 6 or 3), 1 do
					Arena.create({ Vehicle = "Sandking", VehicleModel = 495, Name = "Training #" .. i, Mode = "Training", CreatorName = false, Stadium = Stadium.getFromName("stadium-ffs"), BallAmount = 10, Persistent = true });
					--local arena2 = Arena.create({ Vehicle = "Sandking", VehicleModel = 495, Name = "Training #" .. i, Mode = "Training", CreatorName = false, Stadium = Stadium.getFromName("carball-map"), BallAmount = 10, Persistent = true });
					--local arena3 = Arena.create({ Vehicle = "Sandking", VehicleModel = 495, Name = "Training #" .. i, Mode = "Training", CreatorName = false, Stadium = Stadium.getFromName("carball-map"), BallAmount = 10, Persistent = true });
		--[[
					local rand = math.random();
					local stadium = Stadium.getFromName((rand < 0.33 and "neonSoccer" or (rand < 0.66 and "euro2012" or "footballTime")));
					local mode = (math.random() < 0.5 and "Match" or "Training");
					local arena = Arena.create({ Mode = mode, Stadium = stadium, BallAmount = (mode == "Match" and 1 or 10), TeamSize = 3, Teams = (mode == "Match" and { false, false } or nil) });
		]]
					--outputChatBox("Arena "..tostring(Arena.getID(arena)).." created! stadium: "..tostring(stadium), root);
				end

				for i = 1, (DEBUG and 12 or 9), 1 do
					math.randomseed(getTickCount() * math.random());
					local randomSize = math.random(3, 6);
					local randomSize = (randomSize == 6) and 11 or randomSize;
					local pingLimit = math.random(1, 8) * 50;
					local mathLength = RANDOM_DURATION[math.random(1, 5)] * MINUTES;
					Arena.create({ Vehicle = "Sandking", VehicleModel = 495, Name = GREEK_ALPHABET[i], Mode = "Match", CreatorName = false, Stadium = Stadium.getFromName("stadium-ffs"), BallAmount = 1, MatchLength = mathLength, Persistent = true, TeamSize = randomSize, PingLimit = pingLimit, Teams = { false, false } });
				end

				for i = 1, 8 do
					Arena.create({ Vehicle = "Sandking", VehicleModel = 495, Name = "FACE-OFF #" .. i, Mode = "Match", CreatorName = false, Stadium = Stadium.getFromName("stadium-ffs"), BallAmount = 1, Persistent = true, TeamSize = 1, PingLimit = 50 * i, Teams = { false, false } });
				end
			end, 1000, 1
		);
	end
);