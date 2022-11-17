-- (C) 2008-2015 by Benedikt Adrian aka Tjong or Tjong :: You are not allowed to copy, publish, distribute or sell any parts of this resource. Violation may result in prosecution. You were not allowed to copy my copyright information text!!!1111oneeleven

--[[------------------------------------------------------------------------||--
								(<---Log--->)									
	
	
	
--||------------------------------------------------------------------------]]--

--[[------------------------------||--
		(<---ToDo--->)	
				
	[x] Add more GUI Elements like Checkbox AND switching box for stadiums and teamamount
	[x] Stadium Selection for ^
	[x] Team Selection (also limitation)
	[x] Add Name Tags
	[x] Add Team members no collision
	[x] Add missing ball and boo sounds
	[x] Spectator Cam
	[x] Arena Creation GUI
	[x] Options Menu and options saving/applying
	[x] Arena display in Scoreboard
	[x] Output Messages
	[x] turn off boo in training
	[x] new logo
	[x] include useful resources
	[x] Fill third Main Menu
	[x] fix ball hanging
	[x] fix wrong vehicle collision
	[x] display player amount in arena list
	[x] add useful notifications
	[x] Add Goal Sequence and Name of Scorer
	[x] do position interpolation in replay
	[x] fix wrong detected own goals
	[x] audience sound loop laggy
	[x] fix ball hit sound not playing
	[x] add small effect at walls when bouncing
	
	[x] editfield
	[x] password protected Arenas
	[x] fixed lag at the end due to saving a huge replay-table
	[x] saving stats and loginsystem
	
	[x] add more music and stream it
	[-] fix laggy ball or add at least some other clientside approximation
	
	
	[-] fix empty arenas not being destroyed
	[-] save replays somehow
	[-] add highping-kicker option
	[-] find a solution for the Member problem (which members should get rights on the server)
	[-] password protected arenas
	
	[-] add /rules
	[-] Match Options sometimes showing when Training selected
	[-] /start, /restart command for arena creators
	[-] show goal amount in training mode 
	[-] add daytime option to arena creation
	[-] add golden goal option to arena creation
	[-] arena chat
	[-] show highlights after a match has ended
	
	[-] cuniversal 59
	[?] Optional: Visualize Invisible Walls
	[-] Optional: change notificiation sound
	[-] Optional: Add more Spawnpoints to Neon Soccer
					
--||------------------------------]]--

--[[------------------------------||--
			(<---Settings--->)									
																			
--||------------------------------]]--


--[[-----------------------------------||--
			(<---Main--->)									
																				
--||-----------------------------------]]--

addEventHandler("onClientPlayerInit", resourceRoot,
	function ()
		PRE_INITIALIZATION();
	end
);

function PRE_INITIALIZATION()
	if not isTransferBoxActive() then
		INITIALIZE_CARBALL();
	else
		setTimer(PRE_INITIALIZATION, 500, 1);
	end
end

function INITIALIZE_CARBALL()
	INITIALIZE_SANDBOX();

	showCursor(true);
	showChat(false);
	fadeCamera(false, 0.0);
	
	guiSetInputMode("no_binds_when_editing");
	setMinuteDuration(100000000);
	loadGraphics();

	exports.arenas:setGhostmodeEnabled(false);

	--GTA SPECIFIC STUFF
	setPlayerHudComponentVisible("all", false);
	toggleControl("enter_exit", false)
	setBlurLevel(0);
	setGravity(0.01);

	triggerServerEvent("onPlayerInitialized", localPlayer);
end

addEventHandler("onClientPlayerExit", resourceRoot,
	function ()
		DESTROY_SANDBOX();
		
		unloadGraphics();
		setGravity(0.008);
	end
);

LOADED_GRAPHICS = {};
function loadGraphics()
	-- Remove lag sources
	for model = 613, 20000, 1 do removeWorldModel(model, 99999999.0, 0.0, 0.0, 0.0); end

	-- Load ball model
	local dff = engineLoadDFF("data/models/ball.dff", BALL_VEHICLE_MODEL);
	engineReplaceModel(dff, BALL_VEHICLE_MODEL);
	table.insert(LOADED_GRAPHICS, dff);
	--fileDelete("data/models/ball.dff");

	--Load sandking
	local txd = engineLoadTXD("data/models/sandking.txd");
	engineImportTXD(txd, 495);
	local dff = engineLoadDFF("data/models/sandking.dff", 495);
	engineReplaceModel(dff, 495);
	table.insert(LOADED_GRAPHICS, txd);
	table.insert(LOADED_GRAPHICS, dff);
	--fileDelete("data/models/sandking.dff");

	SKIN_SANDKING_BLUE = dxCreateShader( "data/shaders/tex_replace.fx" );
	local txd = dxCreateTexture("data/models/skins/sandking-blue.png");
	dxSetShaderValue( SKIN_SANDKING_BLUE, "Tex0", txd );

	table.insert(LOADED_GRAPHICS, SKIN_SANDKING_BLUE);
	table.insert(LOADED_GRAPHICS, txd);
end

function unloadGraphics()
	restoreAllWorldModels();
	for k, v in pairs(LOADED_GRAPHICS) do
		if isElement(v) then
			destroyElement(v);
		end
	end
	LOADED_GRAPHICS = {};
	SKIN_SANDKING_BLUE = nil;
end

setTimer(
	function ()
		DEBUG = isDebugViewActive();
		guiSetInputMode("no_binds_when_editing");
	end, 1000, 0
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function (stoppedResource)
	
	end
);

function OutputMessage(message)
    return outputChatBox("[#FF6464INFO#FFFFFF] "..tostring(message), 255, 255, 255, true);
end

--[[
function takeScreenShot(mode)
	local screenSource = dxCreateScreenSource(500, 321);
	if (screenSource) then
		dxUpdateScreenSource(screenSource);
		local pixels = dxGetTexturePixels(screenSource);
		if (imageCheck(pixels)) then
			pixels = dxConvertPixels(pixels, "jpeg", 100);
	
			local fileHandle = fileCreate("tollerscreenshot.jpg");
			fileWrite(fileHandle, pixels);
			fileClose(fileHandle);
	
			outputDebugString("Screenshot taken!");
		else
			outputDebugString("Screenshot failed!");
		end
	end
end
bindKey("z", "down", takeScreenShot);

function imageCheck(image)
	for x = 0, 499, 1 do
		for y = 0, 320, 1 do
			local r, g, b, a = dxGetPixelColor(image, x, y);
			if ((r ~= 0 or g ~= 0 or b ~= 0) and a ~= 0) then
				--outputDebugString("pixel: "..tostring(x).." "..tostring(y));
				return true;
			end
		end
	end
	return false;
end]]
