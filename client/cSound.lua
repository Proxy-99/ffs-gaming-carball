
--[[----Class-Sound----||--

	Description:
		Controls All Game Sound and Music

--||------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

SOUND_VOLUME = 1.0;
SOUND_BLOCK_TIME = 200;

gVolumes = {
	["referee"] = 0.6,
	["kick"] = 0.5,
	["goal"] = 1.0,
	["audience"] = 1.0
}
gAudienceTimer = false;
gCurrentAudienceSound = false;

local pSounds = { };
local pLastSound = { };
local _setSoundVolume = setSoundVolume;
function setSoundVolume(sound, volume, ...)
	return _setSoundVolume(sound, volume * (gOptions.Volume or 10) / 10);
end

local _playSound = playSound;
function playSound(...)
	local sound = _playSound(...);
	_setSoundVolume(sound, (gOptions.Volume or 10) / 10);
	--setElementDimension(sound, getElementDimension(localPlayer) or 0);
	pSounds[sound] = false;
	return sound;
end

local _playSound3D = playSound3D;
function playSound3D(...)
	local sound = _playSound3D(...);
	_setSoundVolume(sound, (gOptions.Volume or 10) / 10);
	pSounds[sound] = false;
	setElementDimension(sound, getElementDimension(localPlayer));
	return sound;
end

function playMusic(file, ...)
	local sound = _playSound(file, ...);--_playSound("data/audio/"..tostring(file)..".mp3", ...);
	_setSoundVolume(sound, (gOptions.MusicVolume or 10) / 10);
	pSounds[sound] = true;
	setElementDimension(sound, getElementDimension(localPlayer));
	return sound;
end

addEventHandler("onClientArenaStateChange", resourceRoot,
	function (oldState, newState)
		if (source == getCurrentArena() and oldState == "Initializing") then
			playSound("data/audio/go.mp3", false);
		end
	end
);

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		-- disable sounds that are only going on everybodys nerves
		setAmbientSoundEnabled("general", false);
		setAmbientSoundEnabled("gunfire", false);
		setWorldSoundEnabled(2, false, 23);
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

-- referee and other state change sounds

addEventHandler("onClientArenaStateChange", resourceRoot,
	function (oldState, newState)
		if (source == getCurrentArena()) then
			-- game ends
			if (newState == "Finished") then
				setTimer(playSoundFile, 50, 1, "referee");
				setTimer(playSoundFile, 1000, 1, "referee");
				setTimer(
					function ()
						local sound = playSoundFile("referee");
						setSoundSpeed(sound, 0.5);
						setSoundProperties(sound, 44100.0, 0.00001, 12, false);
					end, 2000, 1);
				setTimer(playSoundFile, 2000, 1, "referee");
				setTimer(playSoundFile, 2300, 1, "referee");
				setTimer(playSoundFile, 2600, 1, "referee");
				
				setSoundVolume(playSoundFile("goal"), 0.55);
				setTimer(
					function ()
						if (getCurrentArena() ~= LOBBY_ARENA) then
							setSoundVolume(playSoundFile("goal"), 0.9);
						end
					end, 5000, 1
				);
			else
				-- state changed somehow else
				local sound = playSoundFile("referee");
				setTimer(
					function ()
					end, 200 + math.random(500), 1
				);
			end
		end
	end
);

-- Goal Audience Sounds

addEventHandler("onClientGoalScore", root,
	function (team, player, ball, info)
		if (getCurrentArena() ~= LOBBY_ARENA) then
			playSoundFile("goal");
			setTimer(
				function ()
					if (getCurrentArena() ~= LOBBY_ARENA) then
						playSoundFile("goal");
					end
				end, 5000, 2
			);
			
			-- player "scored" but his team was not the one getting points -> own goal
			if (isValid(player) and getData(player, "MatchTeam") ~= team) then
				playSoundFile("booing");
			end
		end
	end
);

--- Ball Hit Sounds ---
addEventHandler("onClientVehicleCollision", root,
	function (hitElement, force, bodypart, colX, colY, colZ, colvx, colvy, colvz)
		force = math.min(1, force / 300);
		if hitElement and force >= 0.1 then
			local model = getElementModel(hitElement);
			if model == 2800 then
				--frame sound
				local volume = math.min(1, force / 0.5);
				--outputChatBox("Frame: " .. force);
				playSoundFile("post", colX, colY, colZ + 1, volume);
				
				return;
			elseif model == 2801 then
				--net sound
				--outputChatBox("Net: " .. force);
				local volume = math.min( 1, force / 0.8 );
				playSoundFile("net", colX, colY, colZ + 1, volume);
				
				return;
			end

			if getElementModel(source) == BALL_VEHICLE_MODEL then
				local volume = math.min(1, force);
				playSoundFile( ( getElementType(hitElement) == "vehicle" ) and "kick" or "bounce", colX, colY, colZ, volume );
			end
		end
	end
)

--[[local pKickSoundBlocked = false;

addEventHandler("onClientBallHit", root,
	function (driver, vx, vy, vz)
		if (not pKickSoundBlocked) then
			local bx, by, bz = getElementPosition(source);
			playSoundFile("kick", bx, by, bz, getDistanceBetweenPoints2D(0.0, 0.0, vx, vy));
			pKickSoundBlocked = true;
			setTimer(function () pKickSoundBlocked = false; end, 200, 1);
		end
	end
);]]--

local pBounceSoundEffectBlocked = false;

addEventHandler("onClientBallWallHit", root,
	function (x, y, z, axis)
		local tick = getTickCount();
		if (not pBounceSoundEffectBlocked) then
			local vx, vy, vz = getElementVelocity(source);
			if (axis ~= "z" or math.abs(vz) > 0.05) then
				playSoundFile("kick", x, y, z, getDistanceBetweenPoints2D(0.0, 0.0, vx, vy));

			end
		end
	end
);

--- Foul Sound ---

local pFoulSoundBlocked = false;

addEventHandler("onClientVehicleCollision", resourceRoot,
	function (hitElement, force, bodypart, colX, colY, colZ, colvx, colvy, colvz)
		local arena = getCurrentArena();
		if (arena ~= LOBBY_ARENA and Arena.getMode(arena) == "Match") then
			if (not pFoulSoundBlocked and isValid(hitElement) and
				source ~= Ball.SaveChecker and hitElement ~= Ball.SaveChecker and
				not getData(source, "BallParent") and not getData(hitElement, "BallParent") and 
				getElementType(hitElement) == "vehicle" and getElementType(source) == "vehicle") then
				if (force > 400.0) then
					pFoulSoundBlocked = true;
					setTimer(function () pFoulSoundBlocked = false; end, 3000, 1);
					playSoundFile("ouh");
					if (force > 600.0) then
						playSoundFile("booing");
					end
				end
			end
		end
	end
);

--- Lobby Music ---

gLobbyMusic = false;
gMusicToggleFontSize = 2.0 / 1080 * gScreenSizeY;
gMusicOnAlpha = 0;
gMusicOffAlpha = 0;
gUserPaused = false;

local pLobbySounds = {
	{ Title = "The Rockafeller Shank", Author = "Fatboy Slim", Duration = (5 * MINUTES + 14 * SECONDS ) },
	{ Title = "Carneval De Paris", Author = "Dario G", Duration = (3 * MINUTES + 53 * SECONDS ) },
	{ Title = "Song 2", Author = "Blur", Duration = (1 * MINUTES + 57 * SECONDS ) },
	{ Title = "Three Lions", Author = "Baddiel, Skinner & The Lightning Seeds", Duration = (3 * MINUTES + 47 * SECONDS ) },
	{ Title = "Stop The Rock", Author = "Apollo 440", Duration = (3 * MINUTES + 32 * SECONDS ) },
}

MAX_LOBBY_MUSIC_INDEX = #pLobbySounds;
gNextLobbyMusicIndex = math.random(MAX_LOBBY_MUSIC_INDEX);
local pTimeUntilNextTrack = 0;

addEventHandler("onClientCarballPlayerLogin", root, 
	function ()
		--if not DEBUG then
		--gLobbyMusic = playMusic("lobbyMusic", true);
		--playNextLobbyTrack();
		
		--end
		--[[setTimer(
			function ()
				--exports.notifications:showNotifier("Audio", "Sound", "You can toggle the sound using 'M'", true, true);	
			end, 1000, 1
		);]]
	end
);

function playNextLobbyTrack()
	gLobbyMusic = playMusic("http://PATH_TO_LOBBY_MUSIC_FILES"..tostring(gNextLobbyMusicIndex-1)..".mp3", false);
	local length = pLobbySounds[gNextLobbyMusicIndex].Duration;--getSoundLength(gLobbyMusic);
	--setTimer(playLobbyMusic, length, 1);
	pTimeUntilNextTrack = length;
	if (gOptions.MusicVolume and gOptions.MusicVolume > 0) then
		--exports.notifications:showNotifier("Audio", "Now Playing:", tostring(pLobbySounds[gNextLobbyMusicIndex].Author).."\n"..tostring(pLobbySounds[gNextLobbyMusicIndex].Title), false, true);	
	end
	gNextLobbyMusicIndex = (gNextLobbyMusicIndex % MAX_LOBBY_MUSIC_INDEX) + 1;
end

if (not DEBUG) then
setTimer(
	function ()
		if (isValid(gLobbyMusic)) then
			if (not isSoundPaused(gLobbyMusic)) then
				pTimeUntilNextTrack = pTimeUntilNextTrack - 100;
				if (pTimeUntilNextTrack <= 0) then
					playNextLobbyTrack();
				end
			end
		else
			if (gLoggedIn) then
				playNextLobbyTrack();
			end
		end
	end, 100, 0
);
end

addEventHandler("onClientRender", root,
	function ()
		if (DEBUG and getCurrentArena() == LOBBY_ARENA) then
			addToDebug("Tick until next: "..tostring(pTimeUntilNextTrack));
		end
	end
);

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		--setSoundPaused(gLobbyMusic, true);
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		--setSoundPaused(gLobbyMusic, gUserPaused);
	end
);

function toggleLobbyMusic()
	if (getCurrentArena() == LOBBY_ARENA) then
		gUserPaused = not gUserPaused;
		setSoundPaused(gLobbyMusic, gUserPaused);
		if (gUserPaused) then
			showMusicOff();
		else
			showMusicOn();
		end
	end
end
--bindKey("m", "down", toggleLobbyMusic);

function showMusicOn()
	if (gMusicOffAlpha > 0) then
		gMusicOffAlpha = 0;
		removeEventHandler("onClientDeltaRender", root, fadeMusicOffText);
	end
	gMusicOnAlpha = 255;
	addEventHandler("onClientDeltaRender", root, fadeMusicOnText);
end

function fadeMusicOnText(delta)
	gMusicOnAlpha = math.max(gMusicOnAlpha - delta * 100, 0);
	dxDrawText("Sound:#00EE00 ON", 0, 0, gScreenSizeX, gScreenSizeY * 0.5, tocolor(255, 255, 255, gMusicOnAlpha), gMusicToggleFontSize, "default", "center", "center", false, false, false, true);
	if (gMusicOnAlpha == 0) then
		removeEventHandler("onClientDeltaRender", root, fadeMusicOnText);
	end
end

function showMusicOff()
	if (gMusicOnAlpha > 0) then
		gMusicOnAlpha = 0;
		removeEventHandler("onClientDeltaRender", root, fadeMusicOnText);
	end
	gMusicOffAlpha = 255;
	addEventHandler("onClientDeltaRender", root, fadeMusicOffText);
end

function fadeMusicOffText(delta)
	gMusicOffAlpha = math.max(gMusicOffAlpha - delta * 100, 0);
	dxDrawText("Sound:#EE0000 OFF", 0, 0, gScreenSizeX, gScreenSizeY * 0.5, tocolor(255, 255, 255, gMusicOffAlpha), gMusicToggleFontSize, "default", "center", "center", false, false, false, true);
	if (gMusicOffAlpha == 0) then
		removeEventHandler("onClientDeltaRender", root, fadeMusicOffText);
	end
end

-- Goal Hit Sounds

local pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = false, false, false, false, false, false;
local pCenterX, pCenterY, pCenterZ = false, false, false;

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = Stadium.getCurrentLimits();
		pCenterX, pCenterY, pCenterZ = (pFieldMinX + pFieldMaxX) / 2, (pFieldMinY + pFieldMaxY) / 2, pFieldMinZ + 100 / 2 - 5;
	end
);
addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		-- reset limits
		pFieldMinX, pFieldMinY, pFieldMinZ = false, false, false;
		pFieldMaxX, pFieldMaxY, pFieldMaxZ = false, false, false;
		pCenterX, pCenterY, pCenterZ = false, false, false;
	end
);

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = Stadium.getCurrentLimits();
		if ((pFieldMaxX - pFieldMinX) > (pFieldMaxY - pFieldMinY)) then
			gCurrentStadiumOrientationX = true;
		else
			gCameraPosX, gCameraPosY, gCameraPosZ = pFieldMinX, ((pFieldMaxY + pFieldMinY)/2), pFieldMinZ + 50.0;
			pScorePosX, pScorePosY, pScorePosZ = pFieldMaxX, ((pFieldMaxY + pFieldMinY)/2), pFieldMinZ + 25.0;
			gCurrentStadiumOrientationX = false;
		end
		if (Arena.getMode(source) == "Match") then
			setSpectateCameraEnabled(true);
		end
	end
);

local pGoalHitSoundBlocked = false;

addEventHandler("onClientVehicleCollision", root,
	function (hitElement, force, bodypart, colX, colY, colZ, colvx, colvy, colvz)
		--if (ballParent) then
			
			if (source ~= Ball.SaveChecker and isValid(hitElement) and getElementData(hitElement, "goalobject")) then--hitElement == getPedOccupiedVehicle(localPlayer)) then
				local ballParent = getData(source, "BallParent");
				local vx, vy, vz = getElementVelocity(source);
				local bx, by, bz = getElementPosition(source);
				local speed = getElementSpeed(source);
				speed = speed * speed;
				if (not ballParent) then speed = speed * 2; end
				if (speed > 0.15 and not pGoalHitSoundBlocked) then
					if (Arena.getMode(getCurrentArena()) == "Match" and ballParent) then
						if (gCurrentStadiumOrientationX) then
							local diffX = bx - pCenterX;
							if ((diffX > 0 and vx > 0) or (diffX < 0 and vx < 0)) then
								playSoundFile("ouh");
							end
						else
							local diffY = by - pCenterY;
							if ((diffY > 0 and vy > 0) or (diffY < 0 and vy < 0)) then
								playSoundFile("ouh");
							end
						end
					end
					pGoalHitSoundBlocked = true;
					setTimer(function () pGoalHitSoundBlocked = false end, 200, 1);
					playSoundFile("hardposthit", bx, by, bz, speed);
				end
			end
		--end
	end
);

-- Audience --

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		if (Arena.getMode(source) == "Match") then
			if (isValid(gCurrentAudienceSound)) then
				stopSound(gCurrentAudienceSound);
			end
			playAudience();
			gAudienceTimer = setTimer(playAudience, 55000, 0);
		end
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		if (isValid(gCurrentAudienceSound)) then
			stopSound(gCurrentAudienceSound);
		end
		if (gAudienceTimer and isTimer(gAudienceTimer)) then
			killTimer(gAudienceTimer);
		end
	end
);

function playAudience()
	gCurrentAudienceSound = playSoundFile("audience");
end

-- Helping Functions --

addEventHandler("onClientOptionChange", root,
	function (option, value)
		if (option == "Volume") then
			local remove = { };
			for sound, isMusic in pairs(pSounds) do
				if (isValid(sound)) then
					if (not isMusic) then
						_setSoundVolume(sound, (value) / 10);
					end
				else
					table.insert(remove, sound);
				end
			end
			for _, sound in ipairs(remove) do
				pSounds[sound] = nil;
			end
		elseif (option == "MusicVolume") then
			local remove = { };
			for sound, isMusic in pairs(pSounds) do
				if (isValid(sound)) then
					if (isMusic) then
						_setSoundVolume(sound, (value) / 10);
					end
				else
					table.insert(remove, sound);
				end
			end
			for _, sound in ipairs(remove) do
				pSounds[sound] = nil;
			end
		end
	end
);

function playSoundFile(name, x, y, z, volumeMultiplier)
	local tick = getTickCount();
	if (pLastSound[name] and (tick - pLastSound[name]) < SOUND_BLOCK_TIME) then
		return;
	end
	pLastSound[name] = tick;

	local sound;
	if (x) then
		sound = playSound3D("data/audio/"..tostring(name)..".mp3", x, y, z);
		setSoundMaxDistance(sound, 200);
		--setSoundMinDistance(sound, 5);
	else
		sound = playSound("data/audio/"..tostring(name)..".mp3");
	end
	setSoundVolume(sound, volumeMultiplier or 1);
	--outputDebugString("played soundfile: "..tostring(name));
	return sound;
end
