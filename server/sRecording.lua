local _DO_NOT_COMPILE

--[[----Class-Main----||--

	Description:
		Initializes main structures

--||------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

PLAYER_RECORDING_INTERVAL = 100;
SAVE_METHOD_DATE = "20130115";

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

gSavedReplays = { };
gRecordings = { };

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		gSavedReplays = loadTable("Database/Replays.data");
	end
);

addEventHandler("onResourceStop", resourceRoot, 
	function ()
		saveTable(gSavedReplays, "Database/Replays.data");
	end
);

addModeHandler("onArenaStateChange", "Match",
	function (oldState, newState)
		local arena = source;
		if (oldState == "Initializing") then
			gRecordings[arena] = {
				record = { },
				options = Arena.getOptions(arena),
				drivers = { },
				saveMethodDate = SAVE_METHOD_DATE
			};
		elseif (newState == "Finished") then
			-- prevent other event handlers from laggin as it may be a huge table
			setTimer(
				function (arena)
					local time = getRealTime();
					local fileName = fillString(time.year+1900, 4).."_"..fillString(time.month+1).."_"..fillString(time.monthday).."_"..fillString(time.hour).."_"..fillString(time.minute).."_"..fillString(time.second).."_"..tostring(Arena.getID(arena));
					--saveTable(gRecordings[arena], "Database/Replays/"..fileName..".replay");
					--table.insert(gSavedReplays, fileName);
					gRecordings[arena] = nil;
				end, 50, 1, arena
			);
		end
	end
);

addEventHandler("onArenaExit", resourceRoot,
	function ()
		if (gRecordings[source]) then
			gRecordings[source] = nil;
		end
	end
);

setTimer(
	function ()
		for arena, info in pairs(gRecordings) do
			--recordArena(arena);
		end
	end, RECORDING_INTERVAL, 0
);

function recordArena(arena)
	local info = gRecordings[arena];
	if (info and not getData(arena, "RecordingBlocked")) then
		if (not getData(arena, "LastRecordTick")) then
			setData(arena, "LastRecordTick", getTickCount() - 100);
		end
		local partInfo = { vehicles = { }, balls = { }, Interval = math.min(200, getTickCount() - getData(arena, "LastRecordTick")) };
		setData(arena, "LastRecordTick", getTickCount());
		for _, player in ipairs(getElementsByType("player", arena)) do
			local vehicle = getData(player, "Vehicle");
			if (isValid(vehicle)) then
				if (not info.drivers[vehicle]) then
					info.drivers[vehicle] = getPlayerName(player);
				end
				--local vehicleInfo = { };
				--vehicleInfo.x, vehicleInfo.y, vehicleInfo.z = getElementPosition(vehicle);
				--vehicleInfo.rx, vehicleInfo.ry, vehicleInfo.rz = getElementRotation(vehicle);
				local x, y, z = getElementPosition(vehicle);
				x, y, z = math.floor(x * RECORDING_POS_QUALITY), math.floor(y * RECORDING_POS_QUALITY), math.floor(z * RECORDING_POS_QUALITY);
				
				local lastPos = getData(player, "LastRecordedPosition");
				if (lastPos) then
					if (x == lastPos.x and y == lastPos.y and z == lastPos.z) then
						local lastVel = getData(player, "LastRecordedVelocity");
						x, y, z = math.floor(lastPos.x + lastVel.x * RECORDING_INTERVAL/50 * RECORDING_POS_QUALITY), 
									math.floor(lastPos.y + lastVel.y * RECORDING_INTERVAL/50 * RECORDING_POS_QUALITY), 
									math.floor(lastPos.z + lastVel.z * RECORDING_INTERVAL/50 * RECORDING_POS_QUALITY);
						--outputDebugString("SAME POSITION RECORDED "..tostring(x));
					end
				end
				
				local vx, vy, vz = getElementVelocity(vehicle);
				setData(player, "LastRecordedVelocity", { x = vx, y = vy, z = vz });
				setData(player, "LastRecordedPosition", { x = x, y = y, z = z });
				
				local rx, ry, rz = getElementRotation(vehicle)
				rx, ry, rz = math.floor(rx * RECORDING_ROT_QUALITY), math.floor(ry * RECORDING_ROT_QUALITY), math.floor(rz * RECORDING_ROT_QUALITY);
				partInfo.vehicles[vehicle] = { x, y, z, rx, ry, rz };
			end
		end
		for _, ball in ipairs(getElementsByType("ball", arena)) do
			--local ballInfo = { };
			--ballInfo.x, ballInfo.y, ballInfo.z = getElementPosition(ball);
			--local factor = 0.01*(getTickCount() - (getData(ball, "LastSyncedTick") or getTickCount()));
			local x, y, z = getElementPosition(ball);
			--local vx, vy, vz = getElementVelocity(ball);
			x, y, z = math.floor(x * RECORDING_POS_QUALITY), math.floor(y * RECORDING_POS_QUALITY), math.floor(z * RECORDING_POS_QUALITY);
			--x, y, z = x + vx * factor, y + vy * factor, z + vz * factor;
			partInfo.balls[ball] =  { x, y, z };
		end
		table.insert(info.record, partInfo);
	end
end

addRemoteEventHandler("onServerReplayReceive", resourceRoot,
	function (replay)
		if (getData(source, "ReplayBlock") or Arena.getState(source) ~= "Paused") then return end
		setData(source, "ReplayBlock", true);
		setTimer(setData, GOAL_RECORDING_TIME, 1, source, "ReplayBlock", false);
		
		replay.saveMethodDate = SAVE_METHOD_DATE;
		local info = getData(source, "BufferedGoalInfo");
		local replayMetaData = {
			Teams = { },
			Stadium = getData(Arena.getStadium(source), "FileName"),
			Time = getRealTime().timestamp,
			ScorerUserID = getPlayerUserID(info.scorer),
			ScorerName = getPlayerName(info.scorer),
			
		};
		for _, team in ipairs(getElementsByType("matchteam", source)) do
			table.insert(replayMetaData.Teams, { Name = getData(team, "Name"), Score = getData(team, "Score") });
		end
				
		local players = { };
		local playerList = { };
		for _, frameInfo in ipairs(replay) do
			local newPlayers = { };
			for player, playerInfo in pairs(frameInfo.players) do
				if (not players[player]) then
					local id = #playerList + 1;
					players[player] = id;
					playerList[id] = player;
				end
				newPlayers[players[player]] = playerInfo;
			end
			frameInfo.players = newPlayers;
		end
		replay.Players = playerList;
		
		setData(source, "ReplayBuffer", { MetaData = replayMetaData, WorldData = replay });
		--table.save(replay, "Database/Goals/" .. tostr(getTickCount()) .. ".replay");
		triggerClientEvent(source, "onClientGoalReplayReceive", root, replay);
	end
);

--[[
	Goal Info Structure
		ID
		Likes
		ScorerName
		Stadium
		MatchScore
		Timestamp


]]

function convertToClientReplayData(data)
	local info = {
		ID = data.ID,
		Likes = table.size(data.Likes),
		ScorerName = data.ScorerName,
		Stadium = data.Stadium,
		MatchScore = "",
		Timestamp = data.Time,
	};
	for _, teamInfo in ipairs(data.Teams) do
		info.MatchScore = info.MatchScore .. tostring(teamInfo.Score) .. " : ";
	end
	-- remove the last " : "
	info.MatchScore = info.MatchScore:sub(1, #info.MatchScore - 3);
	return info;
end

addRemoteEventHandler("onPlayerGoalViewRequest", resourceRoot,
	function (goal)
		local info = gGoalReplays[goal];
		if (info) then
			local options = { };
			options.Stadium = Stadium.getFromName(info.Stadium);
			options.Creator = source;
			options.CreatorName = getPlayerName(source);
			options.Mode = "Replay";
			options.BallAmount = 1;
			options.PingLimit = 100000;
			options.Persistent = false;
			options.Vehicle = "Sandking";
			options.VehicleModel = 495;
			options.Password = false;
		
			options.Teams = { };
			for _, teamInfo in ipairs(info.Teams) do
				table.insert(options.Teams, { name = teamInfo.name });
			end
			
			-- create arena
			local arena = Arena.create(options);
						
			-- insert player
			Arena.insertPlayer(arena, source);
			
			--setData(arena, 
			local replayInfo = table.load("Database/Goals/Goal"..tostring(goal)..".replay");
			
			local userID = getPlayerUserID(source);
			if (userID) then
				replayInfo.Liked = info.Likes[userID];
			end
			replayInfo.GoalID = goal;
			triggerClientEvent(source, "onClientGoalReplayReceive", root, replayInfo);
		end
	end
);

gGoalReplays = table.load("Database/Goals/GoalList.dat");
gClientGoalReplays = table.map(gGoalReplays, convertToClientReplayData);

addRemoteEventHandler("onServerReplaySaveRequest", resourceRoot,
	function ()
		local arena = getElementArena(source);
		if (isValid(arena) and isDonator(source)) then -- check if player is donator
			local info = getData(arena, "ReplayBuffer");
			if (info) then
				info.MetaData.ID = #gGoalReplays + 1;
				info.MetaData.Likes = { };
			
				table.lmap(info.WorldData.Players, getPlayerName);
				
				gGoalReplays[info.MetaData.ID] = info.MetaData;
				gClientGoalReplays[info.MetaData.ID] = convertToClientReplayData(info.MetaData);
				table.save(gGoalReplays, "Database/Goals/GoalList.dat");
				filePut("Database/Goals/GoalList.dump", tostr(gGoalReplays));
				table.save(info.WorldData, "Database/Goals/Goal" .. tostring(info.MetaData.ID) .. ".replay");
				triggerClientEvent(arenaElement, "onClientTopGoalsReceive", root, { gClientGoalReplays[info.MetaData.ID] });
				
				setData(arena, "ReplayBuffer", nil);
				exports.ffs:addNotification(source, "Goal successfully saved!", 1);
			else
				exports.ffs:addNotification(source, "No goal available to be saved", 3);
				showSmallNotifier(source, "trophy", "#ff1111No saveable goal available in your Arena!");
			end
		end
	end
);

addRemoteEventHandler("onClientTopGoalLike", resourceRoot,
	function (goalID)
		local userID = getPlayerUserID(source);
		if (goalID and userID and gGoalReplays[goalID]) then
			if (gGoalReplays[goalID].Likes[userID]) then
				gGoalReplays[goalID].Likes[userID] = nil;
			else
				gGoalReplays[goalID].Likes[userID] = 1;
			end
			gClientGoalReplays[goalID].Likes = table.size(gGoalReplays[goalID].Likes);
			table.save(gGoalReplays, "Database/Goals/GoalList.dat");
			triggerClientEvent(arenaElement, "onClientTopGoalLikeUpdate", root, goalID, gClientGoalReplays[goalID].Likes);
		end
	end
);

addEventHandler("onClientDownloadFinished", resourceRoot,
	function (player)
		triggerClientEvent(player, "onClientTopGoalsReceive", root, gClientGoalReplays);
	end
);

addEventHandler("onGoalScore", root,
	function (_, _, ball)
		local arena = getElementArena(ball);
		setData(ball, "TempFurtherSyncingAllowed", true);
		setTimer(
			function (ball, arena)
				local record = gRecordings[arena] and gRecordings[arena].record;
				if (isValid(arena) and record) then
					local insertUntil = getData(arena, "LastReplayEnd") or 0;
					--[[local replay = { };
					for i = 0, GOAL_RECORDING_AMOUNT-1, 1 do
						local section = #record - i;
						if (section > insertUntil) then
							table.insert(replay, 1, record[section]);
						else
							break;
						end
					end]]
					setData(arena, "LastReplayEnd", #record);
					--[[
					setTimer(
						function ()
							triggerEvent("onServerReplaySaveRequest", getElementsByType("player")[1]);
						end, 3000, 1
					);]]
					--replay.saveMethodDate = gRecordings[arena].saveMethodDate;
					
					--outputDebugString("RT:"..table.dump(replay));
					--triggerClientEvent(arena, "onClientGoalReplayReceive", root, replay);
					setData(arena, "RecordingBlocked", true);
					setTimer(
						function (arena)
							if (isValid(arena)) then
								setData(arena, "RecordingBlocked", false);
							end
						end, GOAL_RECORDING_TIME, 1, arena
					);
					setData(ball, "TempFurtherSyncingAllowed", false);
				end
			end, 1500, 1, ball, arena
		);
	end
);