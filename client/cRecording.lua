
--[[----Class-Recording----||--

	Description:
		Controls Main Behaviour

--||------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

addEvent("onClientGoalReplayReceive", true);

--[[----Player-Data----||--
	
	
--||-------------------]]--

gSavedRecord = { };
local pPlaying = false;
local pScorer = false;
local pScorerName = false;
local pScorerTeam = false;
local pInfo = false;

local pFieldMinX, pFieldMinY, pFieldMinZ = false, false, false;
local pFieldMaxX, pFieldMaxY, pFieldMaxZ = false, false, false;
local pCenterX, pCenterY, pCenterZ = false, false, false;

GOAL_INFO_WIDTH = gScreenSizeX * 0.18;
GOAL_INFO_HEIGHT = gScreenSizeY * 0.35;
GOAL_INFO_POS_Y = (gScreenSizeY - GOAL_INFO_HEIGHT) / 2;
local pProgress = 0.0;

local pHeadlineSize = 2.5 / 1080 * gScreenSizeY;
local pNormalSize = 2.0 / 1080 * gScreenSizeY;

--[[----General-Data----||--
	
	
--||--------------------]]--

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = Stadium.getCurrentLimits();
		pCenterX, pCenterY, pCenterZ = (pFieldMaxX + pFieldMinX) / 2, (pFieldMaxY + pFieldMinY) / 2, (pFieldMaxZ + pFieldMinZ) / 2;
		gSavedRecord = { };
		
		if (Arena.getMode(source) == "Replay") then
			if (getPlayerUserID()) then
				bindKey("space", "down", likeReplay);
			end
			addEventHandler("onClientRender", root, renderLikeMessage);
		end
	end
);

function likeReplay()
	if (gSavedRecord.GoalID) then
		triggerServerEvent("onClientTopGoalLike", localPlayer, gSavedRecord.GoalID);
		gSavedRecord.Liked = not gSavedRecord.Liked;
	end
end

function renderLikeMessage()
	local text = getPlayerUserID() and ((gSavedRecord.Liked) and "Press SPACE to dislike the goal." or "Press SPACE to like the goal.") or "Register at ffsgaming.com to like the goal.";
	
	dxDrawRoundedRectangle( gScreenSizeX / 2 - HUD_LABEL_WIDTH * 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 6, HUD_LABEL_WIDTH * 4, 2 * HUD_CIRCLE_WIDTH / 3, 100, gSavedRecord.Liked and tocolor(255, 64, 54, 200) or tocolor( 46, 204, 64, 200 ) );
	dxDrawText( text, gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, tocolor(255, 255, 255, 255), 
							HUD_FONT_SIZE, "default-bold", "center", "center" );
end

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		gSavedRecord = { };
		pPlaying = false;
		pLastControls = { };
		pScorer = false;
		pScorerName = false;
		pScorerTeam = false;
		
		for _, player in ipairs(getElementsByType("dummyPlayer")) do
			cleanUp(getData(player, "Vehicle"));
			cleanUp(player);
		end
		
		if (Arena.getMode(source) == "Replay") then
			if (getPlayerUserID()) then
				unbindKey("space", "down", likeReplay);
			end
			removeEventHandler("onClientRender", root, renderLikeMessage);
		end
	end
);

addEventHandler("onClientGoalScore", resourceRoot,
	function (team, player, ball, info)
		if (getCurrentArena() ~= LOBBY_ARENA) then
			pScorer = player;
			pScorerName = getPlayerName(pScorer);
			pScorerTeam = team;
			pInfo = info;
			if (getData(ball, "FireActivated")) then
				local x, y, z = getElementPosition(ball);
				createExplosion(x, y, z, 7, false, 0.0, false);
			end
		end
	end
);
--[[
local pLastControls = { };

local pSavingControls = { "accelerate", "brake_reverse", "vehicle_left", "vehicle_right", "handbrake" };

setTimer(
	function ()
		local arena = getCurrentArena();
		if (not pPlaying and arena ~= LOBBY_ARENA and Arena.getMode(arena) == "Match") then
			local partInfo = { players = { }, vehicles = { }, balls = { } };
			for _, player in ipairs(getElementsByType("player", arena)) do
				if (not pLastControls[player]) then
					pLastControls[player] = { };
				end
				local vehicle = getData(player, "Vehicle");
				if (isValid(vehicle)) then
					local vehicleInfo = { };
					vehicleInfo.x, vehicleInfo.y, vehicleInfo.z = getElementPosition(vehicle);
					vehicleInfo.rx, vehicleInfo.ry, vehicleInfo.rz = getElementRotation(vehicle);
					--vehicleInfo.vx, vehicleInfo.vy, vehicleInfo.vz = getElementVelocity(vehicle);
					--vehicleInfo.tvx, vehicleInfo.tvy, vehicleInfo.tvz = getVehicleTurnVelocity(vehicle);
					partInfo.vehicles[vehicle] = vehicleInfo;
				end
				local playerInfo = { };
				for _, control in ipairs(pSavingControls) do
					local state = getPedControlState(player, control);
					if (pLastControls[player][control] ~= state) then
						playerInfo[control] = state;
						pLastControls[player][control] = state;
					end
				end
				partInfo.players[player] = playerInfo;
			end
			for _, ball in ipairs(getElementsByType("ball", arena)) do
				local ballInfo = { };
				ballInfo.x, ballInfo.y, ballInfo.z = getElementPosition(ball);
				--ballInfo.vx, ballInfo.vy, ballInfo.vz = getElementVelocity(ball);
				partInfo.balls[ball] = ballInfo;
			end
			table.insert(gSavedRecord, partInfo);
			if (#gSavedRecord > RECORDING_AMOUNT) then
				table.remove(gSavedRecord, 1);
			end
		end
	end, RECORDING_INTERVAL, 0
);]]

local pLastVelX, pLastVelY, pLastVelZ = false, false, false;
local pLastTurnVelX, pLastTurnVelY, pLastTurnVelZ = false, false, false;

addEventHandler("onClientGoalReplayReceive", root,
	function (info, metaInfo)
		if (getCurrentArena() ~= LOBBY_ARENA) then
			-- replay without player elements → create dummy elements
			if (Arena.getMode(getCurrentArena()) == "Replay") then
				local dummyElements = { };
				for id, name in pairs(info.Players) do
					dummyElements[id] = createElement("dummyPlayer");
					local veh = createVehicle(495, 0.0, 0.0, 0.0);
					setElementDimension(veh, Arena.getDimension(getCurrentArena()));
					setData(dummyElements[id], "Vehicle", veh);
					setData(dummyElements[id], "Name", name);
				end
				info.Players = dummyElements;
			end
		
			gSavedRecord = info;
			gSavedRecord.useIntegerDecompression = info.saveMethodDate and (info.saveMethodDate >= "20130115")
			
			if (gSavedRecord.useIntegerDecompression) then
				local current = 1;
				local curInfo = gSavedRecord[current];
				while (curInfo) do
					for player, vInfo in pairs(curInfo.players) do
						vInfo[1], vInfo[2], vInfo[3] = vInfo[1] / RECORDING_POS_QUALITY, vInfo[2] / RECORDING_POS_QUALITY, vInfo[3] / RECORDING_POS_QUALITY;
						vInfo[4], vInfo[5], vInfo[6] = vInfo[4] / RECORDING_ROT_QUALITY, vInfo[5] / RECORDING_ROT_QUALITY, vInfo[6] / RECORDING_ROT_QUALITY;
					end
					
					for ball, bInfo in pairs(curInfo.balls) do
						bInfo[1], bInfo[2], bInfo[3] = bInfo[1] / RECORDING_POS_QUALITY, bInfo[2] / RECORDING_POS_QUALITY, bInfo[3] / RECORDING_POS_QUALITY;
					end
					current = current + 1;
					curInfo = gSavedRecord[current];
				end
			end
			outputDebugString("REPLAY RECEIVED");
			--setCameraTarget(pScorer);
			local vehicle = getData(localPlayer, "Vehicle");
			if (isValid(vehicle)) then
				pLastVelX, pLastVelY, pLastVelZ = getElementVelocity(vehicle);
				pLastTurnVelX, pLastTurnVelY, pLastTurnVelZ = getElementAngularVelocity(vehicle);
			end
			playRecord();
			--setCameraTarget(getData(getElementsByType("ball", getCurrentArena())[1], "ClientPhysicalRepresentation"));
			--local x, y, z = getElementPosition(getElementsByType("ball", getCurrentArena())[1]);
		end
	end
);

function playRecord()
	--pPlayRecordTimer = setTimer(playRecordingPart, RECORDING_INTERVAL, 0);
	pEndTick = getTickCount() + RECORDING_INTERVAL;
	pPlaying = 2;
	
	--saveTable(gSavedRecord, tostring(getTickCount())..".replay");
end

addEventHandler("onClientRender", root,
	function ()
		if (pPlaying) then
			if (int(getTickCount()/400)%2 == 0) then
				dxDrawText("REPLAY", 0, 0, gScreenSizeX * 0.95, gScreenSizeY * 0.95,
								tocolor(200, 0, 0, 255), 1, LOBBY_ARENA_BLACK_FONT, "right", "bottom", false, false);
			end
		end
	end
);

function getValidRotation(degrees)
	degrees = degrees % 360.0;
	if (degrees > 180.0) then degrees = degrees - 360.0 elseif (degrees < -180.0) then degrees = degrees + 360.0 end
	return degrees;
end

local pCurrentInterval = RECORDING_INTERVAL;

local lastRotationFuckerX, lastRotationFuckerY = 0, 0;

addEventHandler("onClientDeltaRender", root,
	function (delta)
		if (pPlaying) then
			while (getTickCount() > pEndTick) do
				pPlaying = pPlaying + 1;
				pCurrentInterval = (gSavedRecord[pPlaying+1] and gSavedRecord[pPlaying+1].Interval or RECORDING_INTERVAL) * 1.1;
				
				-- slow down replay when goal score is close
				if (pPlaying >= #gSavedRecord * 0.76 and pPlaying <= #gSavedRecord * 0.89) then
					pCurrentInterval = pCurrentInterval * 3;
				end
				
				pEndTick = pEndTick + pCurrentInterval;
			end
			local progress = 1-(pEndTick-getTickCount()) / pCurrentInterval;
			addToDebug("CurrentInterval: "..pCurrentInterval);
			
			local info = gSavedRecord[pPlaying];
			local infoAim = gSavedRecord[pPlaying + 1];
			if (infoAim) then
				for playerID, vInfo in pairs(info.players) do
					local vehicle = getData(gSavedRecord.Players[playerID], "Vehicle");
					if (isValid(vehicle) and infoAim.players[playerID]) then
						local vecPosX, vecPosY, vecPosZ = infoAim.players[playerID][1] - vInfo[1], infoAim.players[playerID][2] - vInfo[2], infoAim.players[playerID][3] - vInfo[3];
						local vecRotX, vecRotY, vecRotZ = infoAim.players[playerID][4] - vInfo[4], infoAim.players[playerID][5] - vInfo[5], infoAim.players[playerID][6] - vInfo[6];
						vecRotX, vecRotY, vecRotZ = getValidRotation(vecRotX), getValidRotation(vecRotY), getValidRotation(vecRotZ);
					
						setElementPosition(vehicle, vInfo[1] + vecPosX * progress, vInfo[2] + vecPosY * progress, vInfo[3] + vecPosZ * progress);
						setElementRotation(vehicle, (vInfo[4] + vecRotX * progress), (vInfo[5] + vecRotY * progress), (vInfo[6] + vecRotZ * progress));
						setElementFrozen(vehicle, true);
						--setElementVelocity(vehicle, vInfo.vx, vInfo.vy, vInfo.vz);
						--setVehicleTurnVelocity(vehicle, vInfo.tvx, vInfo.tvy, vInfo.tvz);
					end
				end
				info = gSavedRecord[pPlaying];
				infoAim = gSavedRecord[pPlaying + 1];
				for ballID, bInfo in pairs(info.balls) do
					local ball = getElementsByType("ball", getCurrentArena())[ballID];
					local vehicle = getData(ball, "ClientPhysicalRepresentation");
					local vecPosX, vecPosY, vecPosZ = infoAim.balls[ballID][1] - bInfo[1], infoAim.balls[ballID][2] - bInfo[2], infoAim.balls[ballID][3] - bInfo[3];
					setElementPosition(vehicle, bInfo[1] + vecPosX * progress, bInfo[2] + vecPosY * progress, bInfo[3] + vecPosZ * progress);
					
					local rx, ry = getValidRotation(lastRotationFuckerX - vecPosY * 300 * delta * 100 / pCurrentInterval),
									getValidRotation(lastRotationFuckerY + vecPosX * 300 * delta * 100 / pCurrentInterval);--, rz = getElementRotation(vehicle);
					setElementRotation(vehicle, rx, ry, 0);
					lastRotationFuckerX, lastRotationFuckerY = rx, ry;
					--addToDebug("ball: "..tostr(int(0)).." "..tostr(int(getValidRotation(ry + vecPosX * 100 * delta))));--  
					--addToDebug("vec: "..tostr(vecPosX).." "..tostr(vecPosY));
					
					setElementFrozen(vehicle, true);
					
					local bx, by, bz = getElementPosition(vehicle);
					local vecPosX, vecPosY, vecPosZ = infoAim.balls[ballID][1] - bx, infoAim.balls[ballID][2] - by, infoAim.balls[ballID][3] - bz;
					local ballApproxSpeed = 15;
		
					--setElementPosition(vehicle, bx + vecPosX/pCurrentInterval*ballApproxSpeed, by + vecPosY/pCurrentInterval*ballApproxSpeed, bz + vecPosZ/pCurrentInterval*ballApproxSpeed);
					
					if (pPlaying == 2) then
						local lastBallInfo = table.first(gSavedRecord[#gSavedRecord].balls);
						local goalX, goalY, goalZ = lastBallInfo[1], lastBallInfo[2], lastBallInfo[3];
						local ballX, ballY, ballZ = bInfo[1], bInfo[2], bInfo[3];
						local x, y, z = ballX * 2 - goalX + math.random(30)-15, ballY * 2 - goalY + math.random(30)-15, ballZ + 50;
						x, y = math.clamp(x, pFieldMinX, pFieldMaxX), math.clamp(y, pFieldMinY, pFieldMaxY);
						setCameraMatrix(x, y, z, ballX, ballY, ballZ);
						setElementFrozen(vehicle, true);
					else
						local aimX, aimY, aimZ = infoAim.balls[ballID][1], infoAim.balls[ballID][2], infoAim.balls[ballID][3];
						--aimX, aimY = (aimX + pCenterX) / 2, (aimY + pCenterY) / 2;
						local x, y, z, lx, ly, lz = getCameraMatrix();
			
						local speed = 0.8;
						local ballSpeed = 5;
			
						local diffX, diffY, diffZ = aimX - lx, aimY - ly, aimZ - lz;
						lx, ly, lz = lx + diffX/100*ballSpeed, ly + diffY/100*ballSpeed, lz + diffZ/100*ballSpeed;
						diffX, diffY, diffZ = (aimX + pCenterX) / 2 - x, (aimY + pCenterY) / 2 - y, (aimZ + 10) - z;
						x, y, z = x + diffX/100*speed, y + diffY/100*speed, z + diffZ/100*speed;
						--diffX, diffY, diffZ = vehX + gVehVectorX * dist / 2 - lx, vehY + gVehVectorY * dist / 2 - ly, vehZ - lz;
			
						setCameraMatrix(x, y, z, lx, ly, lz);
						--setElementVelocity(vehicle, bInfo.vx, bInfo.vy, bInfo.vz);
					end
				end
			else
				if (Arena.getMode(getCurrentArena()) == "Replay") then
					pPlaying = 2;
				else
					pPlaying = false;
					pLastControls = { };
					for _, player in ipairs(Arena.getActivePlayers(getCurrentArena())) do
						local vehicle = Player.getVehicle(player);
						if (isValid(vehicle)) then
							setElementFrozen(vehicle, false);
						end
					end
					for _, ball in ipairs(getElementsByType("ball", getCurrentArena())) do
						local vehicle = getData(ball, "ClientPhysicalRepresentation");
						setElementFrozen(vehicle, false);
					end
					setCameraTarget(localPlayer);
					local vehicle = getData(localPlayer, "Vehicle");
					if (isValid(vehicle) and pLastVelX) then
						setElementVelocity(vehicle, pLastVelX, pLastVelY, pLastVelZ);
						setElementAngularVelocity(vehicle, pLastTurnVelX, pLastTurnVelY, pLastTurnVelZ);
					end
				end
			end
		end
	end
);

gReplayBuffer = { };

addEventHandler("onClientArenaPlayerInit", resourceRoot, 
	function ()
		gReplayBuffer = { };
		-- destroy dummy elements on exit
	end
);

setTimer(
	function ()
		local arena = getCurrentArena();
		if (isValid(arena)) then
			if (#gReplayBuffer >= GOAL_RECORDING_AMOUNT) then
				table.remove(gReplayBuffer, 1);
			end
			
			local partInfo = { players = { }, balls = { } };
			
			for _, player in ipairs(getElementsByType("player", arena)) do
				local vehicle = getData(player, "Vehicle");
				if (isValid(vehicle)) then
					local x, y, z = getElementPosition(vehicle);
					x, y, z = math.floor(x * RECORDING_POS_QUALITY), math.floor(y * RECORDING_POS_QUALITY), math.floor(z * RECORDING_POS_QUALITY);
					local rx, ry, rz = getElementRotation(vehicle)
					rx, ry, rz = math.floor(rx * RECORDING_ROT_QUALITY), math.floor(ry * RECORDING_ROT_QUALITY), math.floor(rz * RECORDING_ROT_QUALITY);
					partInfo.players[player] = { x, y, z, rx, ry, rz };
				end
			end
			for id, ball in ipairs(getElementsByType("ball", arena)) do
				local x, y, z = getElementPosition(ball);
				x, y, z = math.floor(x * RECORDING_POS_QUALITY), math.floor(y * RECORDING_POS_QUALITY), math.floor(z * RECORDING_POS_QUALITY);
				partInfo.balls[id] =  { x, y, z };
			end
			table.insert(gReplayBuffer, partInfo);
		end
	end, RECORDING_INTERVAL, 0
);

--[[addEventHandler("onClientDeltaRender", root,
	function (delta)
		if (pPlaying and pScorer) then
			pProgress = math.min(1.0, pProgress + delta);
		else
			pProgress = math.max(0.0, pProgress - delta);
		end
		if (pProgress > 0.0) then
			local posX = gScreenSizeX - GOAL_INFO_WIDTH * getEasingValue(pProgress, "OutBack");
			--dxDrawRectangle(posX, GOAL_INFO_POS_Y, gScreenSizeX, GOAL_INFO_HEIGHT, tocolor(255, 255, 255, 100));
			dxDrawBorderedRectangle(gRelativeMultY * 3, tocolor(0, 0, 0), posX, GOAL_INFO_POS_Y, gScreenSizeX - posX, GOAL_INFO_HEIGHT, tocolor(255, 255, 255, 100));--, "data/images/roundBackground.png", 0, 0, 0, tocolor(255, 255, 255, 100));
			
			local posY = GOAL_INFO_POS_Y;
			local height = dxGetFontHeight(pHeadlineSize, "arial") * 1.1;
			dxDrawBorderedRectangle(gRelativeMultY, tocolor(0, 0, 0), posX, posY, gScreenSizeX - posX, height, tocolor(255, 255, 255, 0));
			if (isValid(pScorer) and getData(pScorer, "MatchTeam") ~= pScorerTeam) then
				dxDrawBorderedText(0.5, tocolor(0, 0, 0), "Own Goal Info", posX, posY, posX + GOAL_INFO_WIDTH, posY + height, tocolor(220, 100, 0, 255), pHeadlineSize, "arial", "center", "center");
			else
				dxDrawBorderedText(0.5, tocolor(0, 0, 0), "Goal Info", posX, posY, posX + GOAL_INFO_WIDTH, posY + height, tocolor(255, 190, 50, 255), pHeadlineSize, "arial", "center", "center");
			end
			
			posY = posY + height;
			height = dxGetFontHeight(pNormalSize, "arial") * 1.1;
			dxDrawBorderedText(0.5, tocolor(0, 0, 0), " Scorer: "..tostring(pScorerName), posX, posY, posX + GOAL_INFO_WIDTH, posY + height, tocolor(100, 200, 255, 255), pNormalSize, "arial", "left", "center");
			
			if (pInfo) then
				posY = posY + height;
				dxDrawBorderedText(0.5, tocolor(0, 0, 0), " Shot Distance: "..tostring(math.round(pInfo.distance, 1)).." meters", posX, posY, posX + GOAL_INFO_WIDTH, posY + height, tocolor(100, 200, 235, 255), pNormalSize, "arial", "left", "center");
				posY = posY + height;
				dxDrawBorderedText(0.5, tocolor(0, 0, 0), " Shot Speed: "..tostring(math.floor(pInfo.speed * SHOT_SPEED_MULTIPLIER)) .. " km/h", posX, posY, posX + GOAL_INFO_WIDTH, posY + height, tocolor(100, 200, 215, 255), pNormalSize, "arial", "left", "center");
			end
		end
	end
);]]

GoalScore = {
	FadeProgress = 0,
	FadeIn = false,
	FadeOut = false,
};

addEventHandler("onClientGoalScore", root,
	function ()
		GoalScore.FadeIn = true;
	end
);

if (isDonator()) then
	bindKey("enter", "down",
		function ()
			local arena = getCurrentArena();
			if (isDonator() and isValid(arena) and Arena.getMode(arena) == "Match" and Arena.getState(arena) == "Paused") then
				triggerServerEvent("onServerReplaySaveRequest", localPlayer);
				GoalScore.FadeOut = true;
			end
		end
	);
end

function GoalScore.show()
	GoalScore.FadeIn = true;
	GoalScore.FadeOut = false;
end

function GoalScore.hide()
	cleanUpTimer(GoalScore.FadeTimer);
	GoalScore.FadeTimer = false;
	GoalScore.FadeIn = false;
	GoalScore.FadeOut = true;
end

addModeHandler("onClientGameRender", "Match",
	function (delta)
		local arena = source;
		if (GoalScore.FadeIn) then
			GoalScore.FadeProgress = math.min(1, GoalScore.FadeProgress + delta * 2);
			if (GoalScore.FadeProgress == 1) then
				GoalScore.FadeIn = false;
				GoalScore.FadeOut = false;
				GoalScore.FadeTimer = setTimer(GoalScore.hide, 10 * SECONDS, 1);
			end
		elseif (GoalScore.FadeOut) then
			GoalScore.FadeProgress = math.max(0, GoalScore.FadeProgress - delta * 2);
			if (GoalScore.FadeProgress == 0) then
				GoalScore.FadeOut = false;
			end
		end

		local progress = getEasingValue(GoalScore.FadeProgress, "OutBack");
		if (progress > 0) then
		
			local text = "";
			if (isValid(pScorer) and getData(pScorer, "MatchTeam") ~= pScorerTeam) then
				text = text .. "#FF4136OWN GOAL!\n";
			else
				text = text .. "#FF8900GOAL!\n";
			end
			text = text .. "#ff8900Scorer: #ffffff" .. tostring(pScorerName) ..
					(isElement(pInfo.assist) and ("\#ff8900Assist: #ffffff" .. tostring(getPlayerName(pInfo.assist))) or "") ..
					"\n#ff8900Shot Distance: #ffffff" .. tostring(math.round(pInfo.distance, 1)).." meters" ..
					"\n#ff8900Shot Speed: #ffffff"..tostring(math.floor(pInfo.speed * SHOT_SPEED_MULTIPLIER)) .. " km/h";
				
			local width, height = getTextDimension(text, gScoreDisplayFont, gScoreDisplayFontSize * 2.7);
			width, height = width * 1.05, height + 20;
			local posX, posY = gScreenSizeX * 0.5 - width / 2, gScreenSizeY * 0.015 + height;
			local offsetY = gScreenSizeY*0.98 - (progress) * (height);
			
			--dxDrawBorderedRectangle(gRelativeMultY, tocolor(0, 0, 0), posX, offsetY, width, gScreenSizeY + height, tocolor(100, 100, 100, 100));
			dxDrawRoundedRectangle( posX, offsetY, width, height, 12, tocolor(0, 0, 0, 100) );
			dxDrawText(text, 0, offsetY + 10, gScreenSizeX, gScreenSizeY, 
										tocolor(255, 255, 255, 255), gScoreDisplayFontSize * 2.7, gScoreDisplayFont, 
										"center", "top", false, false, false, true);
		
			if (isValid(getCurrentArena())) then
				local offsetY = (1 - progress) * 2 * HUD_POS_Y;
				local HUD_POS_Y = HUD_POS_Y - offsetY;
				
				if (isDonator()) then
					dxDrawRoundedRectangle( gScreenSizeX / 2 - HUD_LABEL_WIDTH * 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 6, HUD_LABEL_WIDTH * 4, 2 * HUD_CIRCLE_WIDTH / 3, 100, tocolor( 46, 204, 64, 200 ) );
					dxDrawText( "Press ENTER to save the goal-replay!", gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, tocolor(255, 255, 255, 255), 
											HUD_FONT_SIZE, "default-bold", "center", "center" );
				elseif (table.foldr(getElementsByType("matchteam", arena), function (team, score) return score + MatchTeam.getScore(team); end, 0) == 1) then
					dxDrawRoundedRectangle( gScreenSizeX / 2 - HUD_LABEL_WIDTH * 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 6, HUD_LABEL_WIDTH * 4, 2 * HUD_CIRCLE_WIDTH / 3, 100, tocolor( 255, 64, 54, 200 ) );
					dxDrawText( "Become a donator to save goal-replays!", gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, gScreenSizeX / 2, HUD_POS_Y + HUD_CIRCLE_WIDTH / 2, tocolor(255, 255, 255, 255), 
											HUD_FONT_SIZE, "default-bold", "center", "center" );
				end
			end
		end
	end
);

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

