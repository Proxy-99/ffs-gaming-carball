local _DO_NOT_COMPILE

--[[----Class-Main----||--

	Description:
		Initializes main structures

--||------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

STAT_PLAYER_LIMIT = (KEEPER_TRAINING) and 1 or 4;

--[[----General-Data----||--
	
	
--||--------------------]]--

local pPlayerStats = {
	BallHits = { name = "Ball Hits", color = { r = 150, g = 150, b = 150 } },
	Goals = { name = "Goals", score = 15, color = { r = 10, g = 160, b = 0 } },
	Assists = { name = "Assists", score = 8, color = { r = 200, g = 255, b = 0 } },
	OwnGoals = { name = "Own Goals", color = { r = 255, g = 128, b = 0 } },
	Saves = { name = "Saves", score = 10, color = { r = 0, g = 200, b = 255 } },
	InAirSaves = { name = "In Air Saves", score = 5, color = { r = 100, g = 0, b = 255 } },
	WonMatches = { name = "Won Matches", score = 50, color = { r = 124, g = 252, b = 0 } },
	LostMatches = { name = "Lost Matches", score = 20, color = { r = 255, g = 25, b = 0 } },
	LongestGoalShot = { name = "Longest Goal Shot", unit = "meters", color = { r = 0, g = 0, b = 255 } },
	FastestGoalShot = { name = "Fastest Goal Shot", unit = "km/h", color = { r = 140, g = 70, b = 20 } }
}

addEvent("onServerGoalSaveNotify", true);
addEventHandler("onServerGoalSaveNotify", root,
	function (inAir)
		local arena = getElementArena(source);
		if (isValid(arena) and #Arena.getActivePlayers(arena) >= STAT_PLAYER_LIMIT and Arena.getState(arena) == "Running") then
			increasePlayerStat(source, "Saves");
			if (inAir) then
				increasePlayerStat(source, "InAirSaves");
			end
		end
	end
);
--[[
setTimer(
	function ()
		for _, player in ipairs(getElementsByType("player")) do
			increasePlayerStat(player, "OnlineTime", true);
		end
	end, 60 * SECONDS, 0
);]]

function increasePlayerStat(player, stat, silent, scoreMultiplier)
	--increaseData(player, stat);
	--increaseStaticData(player, stat);
	
	-- HERE YOU COULD FILL IN HIGHSCORE SAVINGS
	
	if (pPlayerStats[stat].score) then
		--increaseStaticScore(player, int(pPlayerStats[stat].score * (scoreMultiplier or 1)));
	end
	if (not silent) then
		--triggerClientEvent(player, "onClientStatUpdate", root, pPlayerStats[stat].name, getStaticData(player, stat), pPlayerStats[stat].color, pPlayerStats[stat].unit);
	end
end

function setPedStat(player, stat, value, silent)
	
	--setStaticData(player, stat, value);
	
	-- HERE YOU COULD FILL IN HIGHSCORE SAVINGS
	
	if (not silent) then
		--triggerClientEvent(player, "onClientStatUpdate", root, pPlayerStats[stat].name, getStaticData(player, stat), pPlayerStats[stat].color, pPlayerStats[stat].unit); 
	end
end

addEventHandler("onPlayerBallHit", root,
	function ()
		--increasePlayerStat(source, "BallHits", true);
	end
);

addEventHandler("onGoalScore", root,
	function (team, player, _, info)
		if (isValid(player) and #Arena.getActivePlayers(getElementArena(team)) >= STAT_PLAYER_LIMIT) then
			if (Player.getMatchTeam(player) == team) then
				increasePlayerStat(player, "Goals");
				if (isValid(info.assist)) then
					increasePlayerStat(info.assist, "Assists");
				end
				local dist = math.round(info.distance, 1);
				if (dist > (getStaticData(player, "LongestGoalShot") or -1)) then
					setPedStat(player, "LongestGoalShot", dist);
				end
				local speed = math.floor(info.speed * SHOT_SPEED_MULTIPLIER);
				if (speed > (getStaticData(player, "FastestGoalShot") or -1)) then
					setPedStat(player, "FastestGoalShot", speed);
				end
			else
				increasePlayerStat(player, "OwnGoals");
			end
		end
	end
);

-- protect against kiddies that try to leave before they lose
addEventHandler("onArenaPlayerExit", resourceRoot,
	function (player, reason)
		if (Arena.getMode(source) == "Match" and Arena.getState(source) ~= "Finished") then
			local pTeam = Player.getMatchTeam(player);
			if (isValid(pTeam) and (not reason or reason == "Leave" or reason == "Disconnect") and getPlayerAndRagequittersAmount(source) >= STAT_PLAYER_LIMIT) then
				local playerScore = MatchTeam.getScore(pTeam);
			
				local highestScore = table.max(table.lmap(getElementsByType("matchteam", source), MatchTeam.getScore));
				local diff = highestScore - playerScore;
				
				if (diff > 0 and diff * 1 * MINUTES > Arena.getRemainingTime(source)) then
					increasePlayerStat(player, "LostMatches");
					increaseData(source, "RageQuittersAmount");
					setData(player, "RageQuitter", true);
					setTimer(
						function (player, arena)
							if (isValid(player)) then
								setData(player, "RageQuitter", false);
							end
							if (isValid(arena)) then
								increaseData(arena, "RageQuittersAmount", -1);
							end
						end, 60 * SECONDS, 1, source
					);
				end
			end
		end
	end
);

function getPlayerAndRagequittersAmount(arena)
	return (#Arena.getActivePlayers(arena) + (getData(arena, "RageQuittersAmount") or 0));
end

addEventHandler("onArenaStateChange", root,
	function (oldState, newState)
		if (newState == "Finished" and Arena.getMode(source) == "Match" and getPlayerAndRagequittersAmount(source) >= STAT_PLAYER_LIMIT) then
			local winnerTeam = false;
			local highestScore = -1;
			for _, matchTeam in ipairs(getElementsByType("matchteam", source)) do
				local score = MatchTeam.getScore(matchTeam);
				if (score > highestScore) then
					winnerTeam = matchTeam;
					highestScore = score;
				end
			end
			for _, player in ipairs(getElementsByType("player", source)) do
				local team = Player.getMatchTeam(player);
				if (isValid(team)) then
					if (team == winnerTeam or not getData(player, "RageQuitter")) then 
						increasePlayerStat(player, (team == winnerTeam) and "WonMatches" or "LostMatches", false, Arena.getOption(source, "MatchLength") / (15 * MINUTES));
					end
				end
			end
		end
	end
);