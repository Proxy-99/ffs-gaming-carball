
--[[----Class-Main----||--

	Description:
		Does Ball Behaviour

	To-do: Gotta add a push button with a spring-like effect.. hold it down and when you release you get a small speed-boost to kick the ball.. then I can make the ball heavier as well.
	* Stop syncing when syncer changes
--||------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

BALL_SYNC_RATE = 100;
WALL_DECLERATION_FACTOR = 0.8;
BOTTOM_DECLERATION_FACTOR = 0.95;
addEvent("onClientBallHit");

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		for _, ball in pairs(getElementsByType("ball", source)) do
			Ball.createPhysicalRepresentation(ball);
		end
	end
);

function Ball.createPhysicalRepresentation(ball)
	-- remove previous instances if still existing
	Ball.destroyPhysicalRepresentation(ball);
	local dimension = Arena.getDimension(getElementArena(ball));
	
	local x, y, z = getElementPosition(ball);
	local vx, vy, vz = getElementVelocity(ball);
	
	-- create physical representation (a vehicle with the specified model and an object attached to it)
	local veh = createVehicle(BALL_VEHICLE_MODEL, x, y, z);
	setElementDimension(veh, dimension);
	setElementParent(veh, ball);
	setElementVelocity(veh, vx, vy, vz);
	setElementFrozen(veh, isElementFrozen(ball) or false);
	
	-- modify it, so the physics apply better
	setVehicleDamageProof(veh, true);
	setElementStreamable(veh, false);
	--setData(veh, "Blip", createBlipAttachedTo(veh, 48, 1, 255, 255, 0));
	--for i = 1, 4, 1 do
	--	engineSetModelLODDistance(BALL_MODEL - 1 + i, 1000);
	--end
	engineSetModelLODDistance(BALL_VEHICLE_MODEL, 1000);
	setFarClipDistance(1000);
	
	setVehicleColor( veh, 10, 10, 10, 170, 170, 170 )
	setVehicleWheelStates(veh, 3, 3, 3, 3);
	setVehicleOverrideLights(veh, 1);
	
	--Use shaders for texture replacement instead
	-- create an object which will get its texture replaced
	--[[local obj = createObject(getData(ball, "Model"), x, y, z);
	setElementDimension(obj, dimension);
	attachElements(obj, veh, 0.0, 0.0, 0.0);
	setElementCollisionsEnabled(obj, false);
	--setElementAlpha(veh, 0);
	setObjectScale(obj, 1);
	setData(veh, "Object", obj);
	setData(obj, "BallObject", true);]]--
	
	-- testing (if position and velocity of the ball get inherited from the physical part)
	attachElements(ball, veh);
	-- attach a spectate vehicle to the ball
	if (isValid(getData(ball, "SpectateVehicle"))) then
		attachElements(getData(ball, "SpectateVehicle"), veh);
	end
	
	-- remember the object
	setData(veh, "BallParent", ball);
	setData(ball, "ClientPhysicalRepresentation", veh);

	for k, object in ipairs(getElementsByType("object")) do
		if getElementModel(object) == 8558 then
			setElementCollidableWith(veh, object, false);
		end
	end

	return veh;
end

function Ball.createSaveChecker()
	-- create physical representation (a vehicle with the specified model and an object attached to it)
	local veh = createVehicle(BALL_VEHICLE_MODEL, 0, 0, 0);
	setElementDimension(veh, 0);
	setElementFrozen(veh, false);
	-- modify it, so the physics apply better
	setVehicleDamageProof(veh, true);
	setElementStreamable(veh, false);
	setVehicleWheelStates(veh, 2, 2, 2, 2);
	setVehicleOverrideLights(veh, 1);
	setElementAlpha(veh, 0);
	return veh;
end

setTimer(
	function ()
		local arena = getElementArena(localPlayer);
		if (not isValid(arena)) then return end
		local veh = Player.getVehicle(localPlayer);
		if (isValid(veh)) then
			setElementDimension(Ball.SaveChecker, getElementDimension(localPlayer));
			setElementCollidableWith(Ball.SaveChecker, veh, false);
			setElementCollidableWith(veh, Ball.SaveChecker, false);
		end
		
		if (Arena.getMode(arena) == "Match") then
			for _, ball in ipairs(getElementsByType("ball", arena)) do
				local vball = getData(ball, "ClientPhysicalRepresentation");
				--if (isValid(vball)) then
					setElementCollidableWith(Ball.SaveChecker, vball, false);
					setElementCollidableWith(vball, Ball.SaveChecker, false);
				--end
			end
		end
	end, 1337, 0
);

addModeHandler("onClientGameRender", "Match",
	function ()
		local arena = source;
		local ball = getElementsByType("ball", arena)[1];
		
		local veh = Player.getVehicle(localPlayer);
		if (not veh) then return end
	
		if (not getData(ball, "GoalTriggerBlocked") and getData(Ball.SaveChecker, "DisableSync")) then
			local goal = Goal.getOwn();
			if (goal) then
				local x, y, z = getElementPosition(goal);
				local limitPos = getData(goal, "Limit");
				local bx, by, bz = getElementPosition(Ball.SaveChecker);
		
				local px, py, pz = getElementPosition(localPlayer);
				--dxDrawLine3D(px, py, pz, bx, by, bz, tocolor(255, 0, 0), 2);
				if (bx >= x and by >= y and bz >= z and bx <= limitPos.x and by <= limitPos.y and bz <= limitPos.z) then
					--outputChatBox("saved!!!!!");
					triggerServerEvent("onServerGoalSaveNotify", localPlayer, getData(Ball.SaveChecker, "InAir"));
					setData(Ball.SaveChecker, "DisableSync", false);
					setData(Ball.SaveChecker, "InAir", false);
					--setData(ball, "GoalTriggerBlocked", true);
				end
			end
		end
	end
);

addEventHandler("onClientPreRender", root,
	function ()
		local arena = getCurrentArena();
		if (arena ~= LOBBY_ARENA) then
			for _, ball in ipairs(getElementsByType("ball", arena)) do
				local specVeh = getData(ball, "SpectateVehicle");
				if (specVeh) then
					local x, y, z = getElementPosition(ball);
					setElementPosition(specVeh, x, y, z);
				end
			end
		end
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		-- clean up balls
		for _, ball in pairs(getElementsByType("ball", source)) do
			Ball.destroyPhysicalRepresentation(ball)
		end
	end
);

function Ball.destroyPhysicalRepresentation(ball)
	local veh = getData(ball, "ClientPhysicalRepresentation");
	if (isValid(veh)) then
		-- destroy to it belonging elements
		cleanUp(getData(veh, "Object"));
		cleanUp(getData(veh, "Blip"));
		-- destroy and reset
		setData(ball, "ClientPhysicalRepresentation", nil);
		destroyElement(veh);
	end
end

VEL_TO_DIST = 10;
DIST_TO_VEL = 1/VEL_TO_DIST;--0.1;

addEventHandler("onClientTjongDataChange", resourceRoot,
	function (data, oldValue, newValue)
		if (getElementType(source) == "ball") then
			if (getElementArena(source) == getElementArena(localPlayer)) then
				-- something changed on the ball data and player is not the syncer in the same arena -> received a sync package
				local veh = getData(source, "ClientPhysicalRepresentation");
				if (isValid(veh)) then
					if (data == "Pos") then
						local vx, vy, vz = getElementVelocity(source);
						if (newValue.force) then
							setElementPosition(veh, newValue.x, newValue.y, newValue.z);
							setElementVelocity(veh, 0.0, 0.0, 0.0);
						elseif (vx == 0 and vy == 0 and vz == 0 and Ball.getSyncer(source) ~= localPlayer) then
							setElementPosition(veh, newValue.x, newValue.y, newValue.z);
							setElementVelocity(veh, (newValue.x - oldValue.x) * DIST_TO_VEL, (newValue.y - oldValue.y) * DIST_TO_VEL, (newValue.z - oldValue.z) * DIST_TO_VEL);
						end
						--setElementPosition(veh, newValue.x, newValue.y, newValue.z);
						return;
					elseif (data == "Vel") then
						if (newValue.force or Ball.getSyncer(source) ~= localPlayer) then
							-- get the previously received synced ball position
							local ballPos = getData(source, "Pos");
							local x, y, z = ballPos.x, ballPos.y, ballPos.z
							-- get the actual ball position on this client
							local bx, by, bz = getElementPosition(source);
							local distance = getDistanceBetweenPoints3D(x, y, z, bx, by, bz);
							if (distance < 30) then
								--[[ perform nice sync -> calculate where the ball is possibly now on the other players screen
								local aimX, aimY, aimZ = x + newValue.vx * VEL_TO_DIST, y + newValue.vy * VEL_TO_DIST, z + newValue.vz * VEL_TO_DIST;
								-- calculate velocity for the client-side ball to aim at the syncer's ball position
								local velX, velY, velZ = aimX - bx, aimY - by, aimZ - bz;
								velX, velY, velZ = velX * DIST_TO_VEL, velY * DIST_TO_VEL, velZ * DIST_TO_VEL;
				
								-- if everything works perfect you don't even need position sync
								setElementVelocity(veh, velX, velY, velZ);
								
								local vx, vy, vz = (x - bx + newValue.vx * VEL_TO_DIST) * DIST_TO_VEL, 
												   (y - by + newValue.vy * VEL_TO_DIST) * DIST_TO_VEL,
												   (z - bz + newValue.vz * VEL_TO_DIST) * DIST_TO_VEL;]]
												   
								-- reduced -> calculates a velocity vector to the position where the ball is going on the syncers-client
								setElementVelocity(veh,
													(x - bx) * DIST_TO_VEL + newValue.vx,
													(y - by) * DIST_TO_VEL + newValue.vy,
													(z - bz) * DIST_TO_VEL + newValue.vz);
							else
								-- no more nice sync, just SYNC the ball so the positions match somehow
								setElementPosition(veh, x, y, z);
								setElementVelocity(veh, newValue.vx, newValue.vy, newValue.vz);
							end
						end
								
						if (Arena.getMode(getElementArena(source)) == "Match" and not getData(Ball.SaveChecker, "DisableSync")) then
							local sx, sy, sz = getElementPosition(Ball.SaveChecker);
							local ballPos = getData(source, "Pos");
							local x, y, z = ballPos.x, ballPos.y, ballPos.z
							if (getDistanceBetweenPoints3D(x, y, z, sx, sy, sz) < 30) then
								setElementVelocity(Ball.SaveChecker,
													(x - sx) * DIST_TO_VEL + newValue.vx,
													(y - sy) * DIST_TO_VEL + newValue.vy,
													(z - sz) * DIST_TO_VEL + newValue.vz);
							else
								setElementPosition(Ball.SaveChecker, x, y, z);
								setElementVelocity(Ball.SaveChecker, newValue.vx, newValue.vy, newValue.vz);
							end
						end
						
						--setElementVelocity(veh, newValue.vx, newValue.vy, newValue.vz);
						return;
					elseif (data == "Frozen") then
						setElementFrozen(veh, newValue);
						return;
					end
				end
			end
			if (data == "Syncer") then
				if (newValue == localPlayer) then
					Ball.sendSyncPackage(source);
					return;
				end
			end
		elseif (getElementType(source) == ARENA_ELEMENT_TYPE) then
		end
	end
);

setTimer(
	function ()
		local arena = getCurrentArena();
		if (arena ~= LOBBY_ARENA) then
			for _, ball in ipairs(getElementsByType("ball", arena)) do
				--addToDebug("speed: "..tostring(getElementSpeed(ball)));
				--[[local speed = getElementSpeed(ball);
				if not maxspeed or speed > maxspeed then
					maxspeed = speed;
					outputChatBox(speed);
				end]]
				if (getElementSpeed(ball) >= BALL_MAX_SPEED) then
					setData(ball, "FireActivated", getTickCount() + 2000);
				end
				local active = getData(ball, "FireActivated");
				if (active) then
					if (getTickCount() < active) then
						local x, y, z = getElementPosition(ball);
						createExplosion(x, y, z, 12, false, 0.0, false);
						setVehicleColor( ball, 255, 65, 54, 255, 65, 54 );
					else
						setData(ball, "FireActivated", false);
						setVehicleColor( ball, 10, 10, 10, 170, 170, 170 );
					end
				end
				
				local vx, vy, vz = getElementVelocity(ball);
				setElementAngularVelocity(ball, -math.clamp(-1.0, vy, 1.0)/2, math.clamp(-1.0, vx, 1.0)/2, 0);
			end
		end
	end, 50, 0
);

setTimer(
	function ()
		local arena = getCurrentArena();
		if (arena) then
			local balls = getElementsByType("ball", arena);
			for _, ball in pairs(balls) do
				if (Ball.getSyncer(ball) == localPlayer) then
					Ball.sendSyncPackage(ball);
				end
			end
		end
	end, BALL_SYNC_RATE, 0
);

function Ball.sendSyncPackage(ball)
	local x, y, z = getElementPosition(ball);
	local vx, vy, vz = getElementVelocity(ball);
	--if (vx ~= 0 or vy ~= 0 or vz ~= 0) then
	triggerServerEvent("onServerBallSyncPackageReceive", resourceRoot, ball, x, y, z, vx, vy, vz);
	--end
end

-- override element position functions just in case MTA tries to retardly sync these positions
local _getElementVelocity = getElementVelocity;
function getElementVelocity(element, ...)
	if (getElementType(element) == "ball") then
		local veh = getData(element, "ClientPhysicalRepresentation");
		if (isValid(veh)) then
			return getElementVelocity(veh);
		end
		local vel = getData(element, "Vel");
		if (vel) then
			return vel.vx, vel.vy, vel.vz;
		else
			return 0.0, 0.0, 0.0;
		end
	else
		return _getElementVelocity(element, ...);
	end
end 

local _getElementPosition = getElementPosition;
function getElementPosition(element, ...)
	if (getElementType(element) == "ball") then
		local veh = getData(element, "ClientPhysicalRepresentation");
		if (isValid(veh)) then
			return _getElementPosition(veh);
		end
		local pos = getData(element, "Pos");
		return pos.x, pos.y, pos.z;
	else
		return _getElementPosition(element, ...);
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

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		if not Ball.SaveChecker then
			Ball.SaveChecker = Ball.createSaveChecker();
		end
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

function replace(name, id, textureOnly)
	--local txd = engineLoadTXD("data/models/"..name..".txd");
	--engineImportTXD(txd, id);
	if (not textureOnly) then
		local col = engineLoadCOL("data/models/"..name..".col");
		engineReplaceCOL(col, id);
	end
	--[[if (name:find("balltexture")) then
		name = "balltexture";
	end]]--
	local dff = engineLoadDFF("data/models/"..name..".dff", 0);
	engineReplaceModel(dff, id);
end

--[[-----------------||--
		PHYSIC
		
		
--||-----------------]]--

gFieldMinX, gFieldMinY, gFieldMinZ = false, false, false;
gFieldMaxX, gFieldMaxY, gFieldMaxZ = false, false, false;

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		gFieldMinX, gFieldMinY, gFieldMinZ, gFieldMaxX, gFieldMaxY, gFieldMaxZ = Stadium.getCurrentLimits();
		
		--createColCuboid(gFieldMinX, gFieldMinY, gFieldMinZ, gFieldMaxX - gFieldMinX, gFieldMaxY - gFieldMinY, gFieldMaxZ - gFieldMinZ)
	end
);

addEventHandler("onClientRender", root,
	function ()
		--addToDebug(tostr(dxGetStatus ()));
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		gFieldMinX, gFieldMinY, gFieldMinZ = false, false, false;
		gFieldMaxX, gFieldMaxY, gFieldMaxZ = false, false, false;
	end
);

addEventHandler("onClientVehicleCollision", root,
--element theHitElement, float force, int bodypart, float collisionX, float collisionY, float collisionZ, float velocityX, float velocityY, float velocityZ, float hitElementForce, int model
	function (hitElement, force, bodypart, colX, colY, colZ, colvx, colvy, colvz)
		if (isValid(source)) then
			local ball = getData(source, "BallParent");
			if (isValid(ball)) then
				force = force / 500;
				triggerEvent("onClientBallHit", source, ball, force, hitElement, colZ);
			end
		end
	end
);

addEventHandler("onClientBallHit", root,
	function (ball, force, element, colZ)
		if (isValid(ball)) then
			
			local driver = getElementType(element) == "vehicle" and getVehicleOccupant( element ) or false;
			doBallPhysics( source, force, element, driver, colZ );
			
			if driver then
				if (driver == localPlayer) then
					triggerServerEvent("onPlayerBallHit", resourceRoot, ball);
					setData(ball, "Syncer", localPlayer);
					Ball.sendSyncPackage(ball);
					
					if (not getData(Ball.SaveChecker, "DisableSync")) then
						setData(Ball.SaveChecker, "DisableSync", true);
						local _, _, bz = getElementPosition(ball);
						outputDebugString("in air: "..tostring(bz - gFieldMinZ));
						if (bz - gFieldMinZ > 4) then
							setData(Ball.SaveChecker, "InAir", true);
						end
						Ball.SaveCheckerTimer = setTimer(
							function ()
								setData(Ball.SaveChecker, "InAir", false);
								setData(Ball.SaveChecker, "DisableSync", false);
							end, 2500, 1
						);
					end
				else
					setData(Ball.SaveChecker, "InAir", false);
					setData(Ball.SaveChecker, "DisableSync", false);
					cleanUpTimer(Ball.SaveCheckerTimer);
					if (Ball.getSyncer(ball) == localPlayer) then
						triggerServerEvent("onPlayerBallHit", resourceRoot, ball, true);
					end
				end
			end
		end
	end
);

-- Physics
-- TO-DO: normalize the effects for all vehicles
BALL_MAX_SPEED = 2.5;
BALL_MIN_FORCE = 0.1;
maxforce = 0;
BALL_AIRBALL_OFFSET = 0.5; --additional force needed in addition to MIN_FORCE before we start adding velocity to z-axis on the course of an exponential curve

LAST_TICK = {};
LAST_ELEMENT = {};

function doBallPhysics( ball, force, element, driver, colZ )

	if driver then
		local vx, vy, vz = getElementVelocity(element);
		local x, y, z = getElementPosition(ball);
		local colX, colY = getElementPosition(element);
		x, y, z = x - colX, y - colY, z - colZ;

		local vehX, vehY = x, y;
		vehX, vehY = getNormalizedVector(vehX, vehY);
		local mult = 0.2 + getDistanceBetweenPoints3D(0.0, 0.0, 0.0, vx, vy, vz) * 1.3;
		vx = vehX * mult + vx;
		vy = vehY * mult + vy;
		setElementVelocity(ball, vx, vy, 0.1*(math.abs(vx)*1.5+math.abs(vy)*1.5));
		--triggerEvent("onClientBallHit", source, driver, vx, vy, vz, x, y, z);

	elseif not driver then
		local tick = getTickCount();
		local diff = tick - (LAST_TICK[ball] or 0);

		local BALL_MIN_FORCE = driver and 0.05 or BALL_MIN_FORCE;
		
		force = math.min( 1.25, force );
		if element then
			local model = getElementModel(element);
			if model == 2801 then
				force = force / 10;
			elseif model == 8558 then
				--donothing
			else
				force = force / 8
			end
		else
			force = force / 8;
		end
	
		if ( force >= BALL_MIN_FORCE ) then
			local tick = getTickCount();
			
			if driver then
				LAST_TICK[ball] = tick;
				LAST_ELEMENT[ball] = element;
			end
			
			local vx, vy, vz = getElementVelocity( ball );
			if driver then
				local cx, cy, cz = getElementVelocity( element );
				--[[local downscale = 1 - math.min(0.3, math.max(0, force - 0.8));
				local upscale = 1 - downscale;
				--outputChatBox(upscale);
				--outputChatBox(1 / ( math.max(1, ( upscale * math.abs(vy) ) / math.abs(cy) ) ) .. " : " .. 1 / ( math.min(1, ( upscale * math.abs(vy) ) / math.abs(cy) ) ) .. " : " .. 1 / ( math.min(1, ( upscale * math.abs(vz) ) / math.abs(cz) ) ))
				if upscale > 0 then
					--upscale = upscale * 0.9; --10% loss upon impact
					cx, cy, cz = cx * 1 / ( math.min(1, ( upscale * math.abs(vx) ) / math.abs(cx) ) ), cy * 1 / ( math.min(1, ( upscale * math.abs(vy) ) / math.abs(cy) ) ), cz * 1 / ( math.min(1, ( upscale * math.abs(vz) ) / math.abs(cz) ) );
				end
				vx, vy, vz = vx * downscale + cx, vy * downscale + cy, vz * downscale + cz;
				
				if (vx ~= 0 or vy ~= 0 or vz ~= 0 ) then
					local MAX_FORCE = BALL_MAX_SPEED ^ 2 / ( vx ^ 2 + vy ^ 2 + vz ^ 2 );
					if MAX_FORCE < 1 then
						vx, vy, vz = vx * MAX_FORCE, vy * MAX_FORCE, vz * MAX_FORCE;
					end
				end]]

				vx, vy, vz = vx + cx, vy + cy, vz + cz;
			end

			local MAX_FORCE = 10;
			if vx ~= 0 or vy ~= 0 then
				local BALL_MAX_SPEED = 2.8 / 2.5 * BALL_MAX_SPEED;
				MAX_FORCE = math.max( 1, BALL_MAX_SPEED ^ 2 / ( vx ^ 2 + vy ^ 2 ) );
			end

			local F = math.min( MAX_FORCE, math.sqrt( math.max( 1, 1 - BALL_MIN_FORCE + force ) ) );
			local F2 = math.min( MAX_FORCE, F ); --might need down-scaling by a square-root or so
			
			local F3 = 0;
			if ( driver and diff > 300 and force >= ( BALL_MIN_FORCE * 2 + BALL_AIRBALL_OFFSET ) ) then
				F3 = math.sqrt( math.max( 1, ( ( vx ^ 2 + vy ^ 2 + vz ^ 2 ) ^ (0.5) ) / 0.4 ) ) - 1; --correction for speed
			end

			local vz = math.min( BALL_MAX_SPEED * 0.25, vz * F + math.max( 0, ( 2.7 ^ ( F - 1 - BALL_AIRBALL_OFFSET ) - 1 ) ) + 0.5 * F3 );

			setElementVelocity( ball, vx * F2, vy * F2, vz )
			
			if DEBUG and driver then
				--oDS("Driver: " .. getPlayerName(driver) .. "; Force: " .. force .. "; Speed: " .. getElementSpeed(ball) );
			end
			
			--local tx, ty, tz = getVehicleTurnVelocity( source )
			--setVehicleTurnVelocity( source, tx, 0, 0 )
		end
	end
end

-- reflects the ball from invisible walls (field limits)
addEventHandler("onClientPreRender", root,
	function ()
		if (gFieldMinX) then
			for _, ball in ipairs(getElementsByType("ball", getCurrentArena())) do
				local x, y, z = getElementPosition(ball);
				local vx, vy, vz = getElementVelocity(ball);
				if (vx ~= 0 or vy ~= 0 or vz ~= 0) then
					if ((x < gFieldMinX and vx < 0.0) or (x > gFieldMaxX and vx > 0.0)) then
						vx = -vx * WALL_DECLERATION_FACTOR;
						triggerEvent("onClientBallWallHit", ball, x, y, z, "x");
					elseif ((y < gFieldMinY and vy < 0.0) or (y > gFieldMaxY and vy > 0.0)) then
						vy = -vy * WALL_DECLERATION_FACTOR;
						triggerEvent("onClientBallWallHit", ball, x, y, z, "y");
					elseif (z > gFieldMaxZ and vz > 0.0) then
						vz = -vz * WALL_DECLERATION_FACTOR;
						triggerEvent("onClientBallWallHit", ball, x, y, z, "z");
					elseif (z < gFieldMinZ + 0.25) then
						if (vz < 0.0) then
							vz = -vz * WALL_DECLERATION_FACTOR * 0.8;
							if (math.abs(vz) > 0.05) then
								vx, vy = vx * 0.8, vy * 0.8;
							end
							triggerEvent("onClientBallWallHit", ball, x, y, z, "z");
						elseif (z < gFieldMinZ - 1) then
							-- small script for the water map
							--setElementPosition(ball, x, y, gFieldMinZ - 1);
						end
					end
					setElementVelocity(ball, vx, vy, vz);
				end
			end
		end
	end
);

