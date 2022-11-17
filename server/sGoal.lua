local _DO_NOT_COMPILE

--[[----Class-Goal----||--

	Description:
		Handles Goal creation and scoring

--||------------------]]--

GOAL_BALL_RESPAWN_DELAY = 16 * SECONDS;
GOAL_KICK_OFF_DELAY = 21 * SECONDS;

TRAINING_BALL_RESPAWN_DELAY = 2 * SECONDS;
TRAINING_KICK_OFF_DELAY = 3 * SECONDS;

Goal = { };

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Goal.create(teamElement, corners)
	-- create element
	local goal = createElement("goal");
	local minX, minY, minZ, maxX, maxY, maxZ = filterMinMaxPositions(corners);
	
	-- set info
	setData(goal, "Parent", teamElement, true);
	setData(goal, "ID", getData(teamElement, "ID"), true);
	setData(goal, "Stadium", getData(teamElement, "Parent"), true);
	setElementPosition(goal, minX, minY, minZ);
	setData(goal, "Limit", { x = maxX, y = maxY, z = maxZ }, true);
	
	return goal;
end

function Goal.getMatchTeam(goal, arena)
	local matchteams = getElementsByType("matchteam", arena);
	local id = getData(goal, "ID");
	return matchteams[id];
end

function processGoalScore(goal, arena, ball)
	local failTeam = Goal.getMatchTeam(goal, arena);
	
	local scoringTeam = false;
	local bestTick = 0;
	for team, hitTick in pairs(getData(ball, "LastTeamHits") or { }) do
		if (team ~= failTeam and hitTick > bestTick) then
			scoringTeam = team;
			bestTick = hitTick;
		end
	end
	-- no team-kick found, so it must've been an own goal alone
	if (not scoringTeam) then
		for _, team in pairs(getElementsByType("matchteam", arena)) do
			if (team ~= failTeam) then
				scoringTeam = team;
				break;
			end
		end
	end
	
	local scoringPlayer = false;
	local assistPlayer = false;
	local assistTick = 0;
	bestTick = 0;
	for player, hitTick in pairs(getData(ball, "LastPlayerHits") or { }) do
		if (isValid(player)) then
			if (hitTick > bestTick) then
				if (isValid(scoringPlayer) and Player.getMatchTeam(scoringPlayer) == scoringTeam) then
					assistPlayer = scoringPlayer;
					assistTick = bestTick;
				else
					assistPlayer = false;
					assistTick = bestTick;
				end
				scoringPlayer = player;
				bestTick = hitTick;
			elseif (hitTick > assistTick) then
				if (Player.getMatchTeam(player) == scoringTeam) then
					assistPlayer = player;
					assistTick = hitTick;
				else
					assistPlayer = false;
					assistTick = hitTick;
				end
			end
		end
	end
	if (not scoringPlayer) then
		scoringPlayer = getElementsByType("player", arena)[1];
	end
	--assistPlayer = scoringPlayer;
	setData(ball, "LastPlayerHits", { });
	
	local info = { };
	local bx, by, bz = getElementPosition(ball);
	local ppos = getData(scoringPlayer, "LastHitPosition");
	info.distance = ppos and getDistanceBetweenPoints3D(bx, by, bz, ppos.x, ppos.y, ppos.z) or 0;
	info.speed = getElementSpeed(ball);
	info.assist = assistPlayer;
	
	setData(arena, "BufferedGoalInfo", { scorer = scoringPlayer });
	
	triggerEvent("onGoalScore", goal, scoringTeam, scoringPlayer, ball, info);
	triggerClientEvent(arena, "onClientGoalScore", goal, scoringTeam, scoringPlayer, ball, info);
end

addEventHandler("onGoalScore", resourceRoot,
	function (team, player, ball, info)
		increaseData(team, "Score", 1, true);
		
		local arena = getElementArena(player);
		
		outputDebugString("goal score! ball: "..tostring(ball).." info : "..tostring(info and table.dump(info)));
		
		-- play goal-replay sequence
		fadeCamera(arena, false, 1);
		setTimer(
			function (ball)
				local arena = getElementArena(ball);
				local veh = getData(ball, "SpectateVehicle");
				
				--[[for _, player in ipairs(getElementsByType("player", arena)) do
					warpPedIntoVehicle(player, veh);
				end
				setTimer(
					function (ball)
						local arena = getElementArena(ball);
						for _, player in ipairs(getElementsByType("player", arena)) do
							warpPedIntoVehicle(player, getData(player, "Vehicle"));
						end
					end, RECORDING_TIME, 1, ball
				);]]
			end, 1000, 1, ball
		);
		setTimer(
			function (arena)
				fadeCamera(arena, true, 1);
			end, 2000, 1, arena
		);
		setTimer(
			function (ball)
							--setElementFrozen(ball, true);
			end, 2000, 1, ball
		);
	end
);

addEventHandler("onServerGoalHitNotify", resourceRoot,
	function (player, ball)
		local arena = getElementArena(player);
		if (arena and isElement(arena) and Ball.getSyncer(ball) == player and not getData(ball, "GoalTriggerBlocked") and Arena.getMode(arena) ~= "Replay") then
			outputDebugString("GOAL Hit in Arena: "..tostring(Arena.getID(arena)));
			if (Arena.getMode(arena) == "Match") then
				if (Arena.getState(arena) ~= "Running" and Arena.getState(arena) ~= "GoldenGoal") then
					return;
				end
				setData(ball, "GoalTriggerBlocked", true, true);
				local state = Arena.getState(arena);
				setTimer(
					function (ball, arena, state)
						if (isValid(ball)) then
							Ball.respawn(ball);
							setElementFrozen(ball, true);
						end

						if state ~= "GoldenGoal" then
							Arena.respawn(arena);
						end
					end, GOAL_BALL_RESPAWN_DELAY, 1, ball, arena, state
				);
				setTimer(
					function (ball)
						if (isValid(ball)) then
							outputDebugString("Goal trigger unblocked in Arena: "..tostring(Arena.getID(getElementArena(ball))));
							setData(ball, "GoalTriggerBlocked", false, true);
						end
					end, GOAL_KICK_OFF_DELAY, 1, ball
				);
			
			
				if (Arena.getState(arena) == "Running") then
					Arena.goToState(arena, "Paused");
					processGoalScore(source, arena, ball);
					--triggerEvent("onGoalScore", source, arena, ball);
					setTimer(
						function (arena)
							Arena.goToState(arena, "Running");
						end, GOAL_KICK_OFF_DELAY, 1, arena
					);
					setTimer(function (ball)
						if (KEEPER_TRAINING) then
							keeperTrainingShot(ball);
						end
					end, GOAL_KICK_OFF_DELAY + 100, 1, ball);
				elseif (Arena.getState(arena) == "GoldenGoal") then
					Arena.goToState(arena, "Paused");
					processGoalScore(source, arena, ball);
					--triggerEvent("onGoalScore", source, arena, ball);
					setTimer(
						function (arena)
							Arena.goToState(arena, "Finished");
						end, GOAL_RECORDING_TIME + 3 * SECONDS, 1, arena
					);
				end
			else
				setData(ball, "GoalTriggerBlocked", true, true);
				setTimer(
					function (ball)
						if (isValid(ball)) then
							Ball.respawn(ball);
							setElementFrozen(ball, true);
						end
					end, TRAINING_BALL_RESPAWN_DELAY, 1, ball
				);
				setTimer(
					function (ball)
						if (isValid(ball)) then
							setElementFrozen(ball, false);
							setData(ball, "GoalTriggerBlocked", false, true);
							
							if (KEEPER_TRAINING) then
								keeperTrainingShot(ball);
							else
								setElementVelocity(ball, 0.0, 0.0, 0.4, true);
							end
							--Ball.respawn(ball);
						end
					end, TRAINING_KICK_OFF_DELAY, 1, ball
				);
			end
		end
	end
);



function keeperTrainingShot(ball)
	local keeperTimer = getData(ball, "GoalKeeperTimer");
	if (keeperTimer and isTimer(keeperTimer)) then killTimer(keeperTimer); end
	
	Ball.respawn(ball);
	setElementVelocity(ball, 0.0, 0.0, 0.4, true);
	
	if (isValid(ball) and not getData(ball, "GoalTriggerBlocked")) then
		setTimer(
			function (ball)
				setElementVelocity(ball, math.random()*0.35-0.175, -1.8-math.random()*0.2, 0.2+math.random()*0.2, true);
				setData(ball, "GoalKeeperTimer", setTimer(keeperTrainingShot, 5000, 1, ball));
			end, 1000 + math.random(2000), 1, ball
		);
	end
end
