
--[[----Class-Goal----||--

	Description:
		Handles mainly the Goal colshape detection

--||------------------]]--

Goal = { };


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--


--- Draw Goal Name ---

Goal.CurrentInstances = { };

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		Goal.CurrentInstances = { };
		for _, goal in ipairs(getElementsByType("goal")) do
			if (getData(goal, "Stadium") == Arena.getStadium(source)) then
				Goal.CurrentInstances[getData(goal, "ID")] = goal;
			end
		end
		--Goal.CurrentInstances = table.filter(getElementsByType("goal"), function (goal, arena) return (getData(goal, "Stadium") == Arena.getStadium(arena)); end, source); 
		--table.sort(Goal.CurrentInstances, function (a, b) return (getData(a, "ID") < getData(b, "ID")); end);
		for _, goal in pairs(Goal.CurrentInstances) do
			local x, y, z = getElementPosition(goal);
			local highPos = getData(goal, "Limit");
			setData(goal, "CenterPos", { ((x + highPos.x)/2), ((y + highPos.y)/2), ((z + highPos.z)/2) });
		end
	end
);

addModeHandler("onClientGameRender", "Match",
	function ()
		local arena = source;
		for id, team in ipairs(getElementsByType("matchteam", arena)) do
			local goal = Goal.CurrentInstances[getData(team, "ID")];
			local col = getData(team, "Color");
			local x, y, z = unpack(getData(goal, "CenterPos"));
			z = z + 5 + math.sin(getTickCount()/400);--drawTextAtPosition(text, x, y, z, size, r, g, b, a, font, fadeOutDist);
			drawTextAtPosition(tostring(MatchTeam.getName(team)), x, y, z, 0.3 * RELATIVE_MULT_Y, col.r, col.g, col.b, 155, LOBBY_ARENA_BLACK_FONT, 400);
		end
	end
);

gGoalDetectionBlocked = false;

addEventHandler("onClientGameRender", root,
	function ()
		if (Arena.getMode(source) == "Replay") then return end

		for id, goal in ipairs(Goal.CurrentInstances) do
			--outputDebugString("draw goal "..tostring(id));
			local x, y, z = getElementPosition(goal);
			local limitPos = getData(goal, "Limit");
			for id, ball in ipairs(getElementsByType("ball", source)) do
				if (Ball.getSyncer(ball) == localPlayer and not getData(ball, "GoalTriggerBlocked")) then
					local bx, by, bz = getElementPosition(ball);
					if (bx >= x and by >= y and bz >= z and bx <= limitPos.x and by <= limitPos.y and bz <= limitPos.z) then
						if (not gGoalDetectionBlocked) then
							gGoalDetectionBlocked = true;
							setTimer(function ()
									gGoalDetectionBlocked = false;
								end, 2000, 1
							);
							triggerServerEvent("onServerGoalHitNotify", goal, localPlayer, ball);
							
							if (Arena.getMode(source) == "Match") then
								setTimer(function (arena)
										triggerServerEvent("onServerReplayReceive", arena, gReplayBuffer);
									end, 1500, 1, getCurrentArena()
								);
							end
						end
						--setData(ball, "GoalTriggerBlocked", true);
					end
				end
			end
		end
	end
);

Ball.SaveChecker = false;

function Goal.getOwn()
	local arena = getCurrentArena();
	local team = getData(localPlayer, "MatchTeam");
	for id, goal in ipairs(Goal.CurrentInstances) do
		if (getData(goal, "ID") == getData(team, "ID")) then
			return goal;
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

