local _DO_NOT_COMPILE
--[[----Class-Ball----||--

	Description:
		Organizes Ball handling and sync

--||------------------]]--

addEvent("onPlayerBallHit", true);
addEvent("onSyncerQualityFail", true);

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

BALL_SPAWN_Z_OFFSET = 20.0;

--[[----General-Data----||--
	
	
--||--------------------]]--

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		-- modify handling data of the ball-physic-emulation-vehicle
		setModelHandling(BALL_VEHICLE_MODEL, "mass", 1.0);
		setModelHandling(BALL_VEHICLE_MODEL, "turnMass", 0.1);
		setModelHandling(BALL_VEHICLE_MODEL, "tractionLoss", 100.0);

		setModelHandling(BALL_VEHICLE_MODEL, "centerOfMass", { [1] = 0.0, [2] = 0.0, [3] = 0.0 });

		--[[for k,_ in pairs(getModelHandling(441)) do
			setModelHandling( BALL_VEHICLE_MODEL, k, nil )
		end
		
		setModelHandling( BALL_VEHICLE_MODEL, "mass", 1 )
		setModelHandling( BALL_VEHICLE_MODEL, "turnMass", 0.1 )
		setModelHandling( BALL_VEHICLE_MODEL, "centerOfMass", { 0, 0, 0 } )
		--setModelHandling( BALL_VEHICLE_MODEL, "percentSubmerged", 50 )

		setModelHandling( BALL_VEHICLE_MODEL, "suspensionForceLevel", 100 )
		setModelHandling( BALL_VEHICLE_MODEL, "suspensionDamping", 160 )
		setModelHandling( BALL_VEHICLE_MODEL, "suspensionAntiDiveMultiplier", 30 )]]
		--setModelHandling( BALL_VEHICLE_MODEL, "collisionDamageMultiplier", 10 )
	end
);

addEventHandler("onResourceStop", resourceRoot, 
	function ()
		-- reset handling of the modified ball model
		local handling = getOriginalHandling(BALL_VEHICLE_MODEL);
		setModelHandling(BALL_VEHICLE_MODEL, "mass", handling.mass);
		setModelHandling(BALL_VEHICLE_MODEL, "turnMass", handling.turnMass);
		setModelHandling(BALL_VEHICLE_MODEL, "tractionLoss", handling.tractionLoss);
		setModelHandling(BALL_VEHICLE_MODEL, "centerOfMass", handling.centerOfMass);
	end
);

addEventHandler("onArenaStateChange", resourceRoot,
	function (oldState, newState)
		if (newState == "Running") then
			for id, ball in ipairs(getElementsByType("ball", source)) do
				Ball.respawn(ball);
				setElementFrozen(ball, false);
				setElementVelocity(ball, 0.0, 0.0, 0.4, true);
			end
		end
	end
);

addEventHandler("onArenaPlayerInit", resourceRoot,
	function (player)
		if (#getElementsByType("player", source) == 1) then
			for id, ball in ipairs(getElementsByType("ball", source)) do
				Ball.respawn(ball);
				setElementVelocity(ball, 0.0, 0.0, 0.0, true);
			end
		end
		setData(player, "SyncedBalls", { });
		for _, ball in ipairs(getElementsByType("ball", source)) do
			if (not Ball.getSyncer(ball)) then
				Ball.setBestSyncer(ball);
			end
		end
	end
);

addEventHandler("onArenaPlayerExit", resourceRoot,
	function (player)
		local syncedBalls = getData(player, "SyncedBalls");
		for ball, _ in pairs(getData(player, "SyncedBalls")) do
			Ball.setBestSyncer(ball, true);
		end
		setData(player, "SyncedBalls", { });
	end
);

-- handle a sync package, if forcePositionSync is true the client wont sync "velocity" only
addEventHandler("onServerBallSyncPackageReceive", resourceRoot,
	function (ball, x, y, z, vx, vy, vz)
		if client then
			local arena = getElementArena(client);
			if (arena and arena == getElementArena(ball) and Ball.getSyncer(ball) == client) then
				if (not getData(ball, "GoalTriggerBlocked") or getData(ball, "TempFurtherSyncingAllowed")) then
					if (vx ~= 0 or vy ~= 0 or vz ~= 0) then
						setElementPosition(ball, x, y, z);
						setElementVelocity(ball, vx, vy, vz);
						setData(ball, "LastSyncedTick", getTickCount());
						if (not getData(client, "FirstSyncPackage")) then
							recordArena(arena);
						else
							setData(client, "FirstSyncPackage", false);
						end
					else
						if (not getData(ball, "NewSyncerSearchBlocked") and not isElementFrozen(ball)) then
							setData(ball, "NewSyncerSearchBlocked", true);
							setTimer(function (ball) if (isValid(ball)) then setData(ball, "NewSyncerSearchBlocked", false); end end, 1000, 1, ball);
							Ball.setBestSyncer(ball, true);
						end
					end
				end
			end
		end
	end
);

addEventHandler("onSyncerQualityFail", root,
	function (ball)
		if (Ball.getSyncer(ball) == source) then
			Ball.setBestSyncer(ball, true);
		end
	end
);

-- remote declars if the a remote player notified the ball hit (so it may also be a false positive and at least the current syncer has wrong ball information)
addEventHandler("onPlayerBallHit", resourceRoot,
	function (ball, remote)
		if (client and isValid(ball) and getElementArena(ball) == getElementArena(client)) then
			Ball.setSyncer(ball, client);
			local arena = getElementArena(ball);
			if (not remote and Arena.getMode(arena) == "Match") then
				local matchTeam = Player.getMatchTeam(client);
				local hitters = getData(ball, "LastTeamHits") or { };
				hitters[matchTeam] = getTickCount();
				setData(ball, "LastTeamHits", hitters);
				
				hitters = getData(ball, "LastPlayerHits") or { };
				hitters[client] = getTickCount();
				setData(ball, "LastPlayerHits", hitters);
				local x, y, z = getElementPosition(ball);
				setData(client, "LastHitPosition", { x = x, y = y, z = z });
			end
		end
	end
);

function Ball.create(arena, zOffset)
	local ball = createElement("ball");
	setElementArena(ball, arena);
	local stadium = Arena.getStadium(arena);
	local ballSpawn = Stadium.getBallSpawn(stadium);
	local x, y, z = getElementPosition(ballSpawn);
	setElementPosition(ball, x, y, z + BALL_SPAWN_Z_OFFSET + (zOffset or 0));
	if Arena.getMode(arena) == "Match" then
		setElementFrozen(ball, not (Arena.getState(arena) == "Running"));
	end
	--setData(ball, "Model", BALL_MODEL, arena); --BALL_MODEL - 1 + math.random(4)
	--[[local veh = createVehicle(515, x, y, z);
	setElementAlpha(veh, 0);
	setElementCollisionsEnabled(veh, false);
	setVehicleDamageProof(veh, true);
	setVehicleOverrideLights(veh, 1);
	--attachElements(veh, ball);
	setData(ball, "SpectateVehicle", veh, true);
	setElementArena(veh, arena);]]
	return ball;
end

function Ball.respawn(ball)
	outputDebugString("ball respawn!");
	local arena = getElementArena(ball);
	local stadium = Arena.getStadium(arena);
	local ballSpawn = Stadium.getBallSpawn(stadium);
	local x, y, z = getElementPosition(ballSpawn);
	--setElementPosition(ball, x, y, z + (math.random()* 3));
	setElementPosition(ball, x, y, z + BALL_SPAWN_Z_OFFSET, true);
	if Arena.getMode(arena) == "Match" then
		setElementFrozen(ball, not (Arena.getState(arena) == "Running" or Arena.getState(arena) == "Running"));
	end
end

function Ball.setSyncer(ball, player)
	local syncer = Ball.getSyncer(ball);
	if (syncer ~= player) then
		-- syncer and player are not the same -> reset last syncer
		if (syncer) then
			local syncedBalls = getData(syncer, "SyncedBalls") or { };
			syncedBalls[ball] = nil;
			setData(syncer, "FirstSyncPackage", false);
		end
		
		-- set new info for new syncer
		if (player) then
			local syncedBalls = getData(player, "SyncedBalls") or { };
			syncedBalls[ball] = true;
		end
		
		-- tell clients about the new syncer and set ball data
		--triggerClientEvent(getElementArena(player), "onClientSyncerUpdate", player, ball);
		outputDebugString("new syncer: "..tostring(getPlayerName(player)));
		setData(ball, "Syncer", player, getElementArena(ball));
		setData(player, "FirstSyncPackage", true);
	end
end

function Ball.setBestSyncer(ball, forceNewPlayer)
	local arena = getData(ball, "Arena");
	
	if (arena) then-- and Arena.isActive(arena)) then
		local chosen = false;
		local closest = false;
		for _, player in ipairs(getElementsByType("player", arena)) do
			if (not forceNewPlayer or player ~= Ball.getSyncer(ball)) then
				local dist = getDistanceBetweenElements(player, ball) * getPlayerPing(player) * getPlayerPing(player);
				if (not closest or dist < closest) then
					closest = dist;
					chosen = player;
				end
			end
		end
		chosen = chosen or Ball.getSyncer(ball);
		if (chosen) then
			Ball.setSyncer(ball, chosen);
		else
			outputDebugString("no new syncer found");
			Ball.setSyncer(ball, false);
		end
	end
end

local _setElementFrozen = setElementFrozen;
function setElementFrozen(element, frozen)
	if (getElementType(element) == "ball") then
		setData(element, "Frozen", frozen, getElementArena(element));
		return true;
	else
		return _setElementFrozen(element, frozen);
	end
end 

local _isElementFrozen = isElementFrozen;
function isElementFrozen(element, ...)
	if (getElementType(element) == "ball") then
		return getData(element, "Frozen");
	else
		return _isElementFrozen(element, ...);
	end
end 

-- override element velocity functions just in case MTA tries to retardly sync it aswell
local _setElementVelocity = setElementVelocity;
function setElementVelocity(element, vx, vy, vz, force, ...)
	if (getElementType(element) == "ball") then
		setData(element, "Vel", { vx = vx, vy = vy, vz = vz, force = force }, getElementArena(element));
		return true;
	else
		return _setElementVelocity(element, vx, vy, vz, force, ...);
	end
end 

local _getElementVelocity = getElementVelocity;
function getElementVelocity(element, ...)
	if (getElementType(element) == "ball") then
		local vel = getData(element, "Vel");
		return vel.vx, vel.vy, vel.vz;
	else
		return _getElementVelocity(element, ...);
	end
end 

-- override element position functions just in case MTA tries to retardly sync it aswell
local _setElementPosition = setElementPosition;
function setElementPosition(element, x, y, z, force, ...)
	if (getElementType(element) == "ball") then
		setData(element, "Pos", { x = x, y = y, z = z, force = force }, getElementArena(element));
		return true;
	else
		return _setElementPosition(element, x, y, z, force, ...);
	end
end 

local _getElementPosition = getElementPosition;
function getElementPosition(element, ...)
	if (getElementType(element) == "ball") then
		local pos = getData(element, "Pos");
		return pos.x, pos.y, pos.z;
	else
		return _getElementPosition(element, ...);
	end
end 
