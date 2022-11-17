
--[[----Class-Camera----||--

	Description:
		Updates the spectator Camera

--||------------------]]--

Camera = { };

SPECTATE_CAMERA_MOVE_SPEED = 5.0;

gCameraPosX, gCameraPosY, gCameraPosZ = false, false, false;

local pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ;
local pBallCamActive = false;

addEvent("onClientBallCameraEnable", true);

function setSpectateCameraEnabled(active)
	if (active) then
		if (not pBallCamActive) then
			for i = 1, 10, 1 do
				setCameraMatrix(gCameraPosX, gCameraPosY, gCameraPosZ, gCameraPosX, gCameraPosY + 1, gCameraPosZ);
			end
			addEventHandler("onClientPreRender", root, updateCamera);
			setElementPosition(localPlayer, gCameraPosX, gCameraPosY, gCameraPosZ+20.0);
			setElementFrozen(localPlayer, true);
		end
	else
		if (pBallCamActive) then
			removeEventHandler("onClientPreRender", root, updateCamera);
			setCameraTarget(localPlayer);
		end
	end
	pBallCamActive = active;
end
addEventHandler("onClientBallCameraEnable", root, setSpectateCameraEnabled);

function updateCamera()
	local ball = getElementsByType("ball", getCurrentArena())[1];
	if (ball) then
		local bx, by, bz = getElementPosition(ball);
	
		--local mx, my, mz = x - gCameraPosX, y - gCameraPosY, z - gCameraPosZ;
	
		local cx, cy, cz, lx, ly, lz = getCameraMatrix();
	
		local dx, dy, dz = gCameraPosX - cx, gCameraPosY - cy, gCameraPosZ - cz;
		local bdx, bdy, bdz = bx - lx, by - ly, bz - lz;
	
		setCameraMatrix(cx + dx / 100 * SPECTATE_CAMERA_MOVE_SPEED, cy + dy / 100 * SPECTATE_CAMERA_MOVE_SPEED, cz + dz / 100 * SPECTATE_CAMERA_MOVE_SPEED, 
						lx + bdx / 100 * SPECTATE_CAMERA_MOVE_SPEED, ly + bdy / 100 * SPECTATE_CAMERA_MOVE_SPEED, lz + bdz / 100 * SPECTATE_CAMERA_MOVE_SPEED);
		--setCameraMatrix(gCameraPosX + dx/5, gCameraPosY + dy/5, gCameraPosZ, x, y, z);
	end
end

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = Stadium.getCurrentLimits();
		if ((pFieldMaxX - pFieldMinX) > (pFieldMaxY - pFieldMinY)) then
			gCameraPosX, gCameraPosY, gCameraPosZ = ((pFieldMaxX + pFieldMinX)/2), pFieldMinY, pFieldMinZ + 50.0;
		else
			gCameraPosX, gCameraPosY, gCameraPosZ = pFieldMinX, ((pFieldMaxY + pFieldMinY)/2), pFieldMinZ + 50.0;
		end
		if (Arena.getMode(source) == "Match") then
			setSpectateCameraEnabled(true);
		end
	end
);

function disableCamera()
	setSpectateCameraEnabled(false);
end

addEventHandler("onClientArenaPlayerExit", resourceRoot, disableCamera);
addEventHandler("onClientTjongDataChange", localPlayer,
	function (data, oldValue, newValue)
		if (data == "MatchTeam") then
			-- team was selected successfull
			disableCamera();
		end
	end
);
