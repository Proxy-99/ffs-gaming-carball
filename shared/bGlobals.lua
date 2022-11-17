if not SHARED_GLOBALS_DEFINED then
	SHARED_GLOBALS_DEFINED = true;
--[[------------------------------------------------------||--
  					(<---Settings--->)									
																				
--||------------------------------------------------------]]--

	--[[--------------||--
	  (<---General--->)									
																				
	--||--------------]]--
	
		DEBUG = true;

		thisArena = 12;
		arenaMapType = "[CB]";
		shortModeName = "cb";

		IS_FFS = getResourceFromName("ffs");

		arenaElement = IS_FFS and getElementByID('cbPlayers') or resourceRoot;
		if not isClient() and arenaElement ~= resourceRoot then
			--hijack the element
			setElementParent(arenaElement, getResourceDynamicElementRoot(thisResource));
		end

		ARENA_ELEMENT_TYPE = "cbArena";
		
		LOCAL_SERVER = DEBUG;
		KEEPER_TRAINING = false;--LOCAL_SERVER
		
		SECONDS = 1000;

		GOAL_RECORDING_TIME = 8 * SECONDS;
		RECORDING_INTERVAL = 100;
		GOAL_RECORDING_AMOUNT = GOAL_RECORDING_TIME / RECORDING_INTERVAL;
		RECORDING_POS_QUALITY = 100;
		RECORDING_ROT_QUALITY = 10;
		
		SHOT_SPEED_MULTIPLIER = 0.8 * 100;--1.61 * 100;
end
