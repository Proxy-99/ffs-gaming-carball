if not CLIENT_GLOBALS_DEFINED then
	CLIENT_GLOBALS_DEFINED = true;
	
	
--[[------------------------------------------------------||--
  					(<---Settings--->)									
													
		NEEDS TO BE COMPILED AT FIRST
																				
--||------------------------------------------------------]]--
	
	--[[--------------||--
	  (<---Useful--->)									
																				
	--||--------------]]--
	
		gScreenSizeX, gScreenSizeY = guiGetScreenSize()
		gScreenCenterX, gScreenCenterY = gScreenSizeX/2, gScreenSizeY/2;
		localPlayer = getLocalPlayer();
		gRelativeMultX, gRelativeMultY = gScreenSizeX / 1920, gScreenSizeY / 1080; 

	--[[--------------||--
	  (<---General--->)									
																				
	--||--------------]]--
	
		DEBUG = DEBUG or isDebugViewActive();
	
		setDevelopmentMode(DEBUG);

		addEvent("onClientPlayerInit", true);
		addEvent("onClientPlayerExit", true);
	
		addEvent("onClientArenaPlayerPreInit", true);
		addEvent("onClientArenaPlayerInit", true);
		addEvent("onClientArenaPlayerExit", true);
		addEvent("onClientArenaStateChange", true);
		addEvent("onClientGoalScore", true);
		
		addEvent("onClientOptionChange");
		addEvent("onClientBallWallHit");
		addEvent("onIntroFinished");
		addEvent("onClientLobbyRender");
		addEvent("onClientGameRender");
		
		addEvent("onClientCarballPlayerLogin", true);
		
		addEvent("onClientDeltaRender");
		addEvent("onClientDeltaPreRender");

		LOBBY_MAIN_NORMAL_FONT = "arial";
		LOBBY_MAIN_NORMAL_FONT_SIZE = 2.0 / 1080 * gScreenSizeY;

		LOBBY_MAIN_WINDOW_POS_X = gScreenSizeX * 0.2;
		LOBBY_MAIN_WINDOW_POS_Y = gScreenSizeY * 0.17;
		LOBBY_MAIN_WINDOW_WIDTH = gScreenSizeX * 0.6;
		LOBBY_MAIN_WINDOW_HEIGHT = gScreenSizeY * 0.75;
		LOBBY_MAIN_WINDOW_HIGH_POS_X = LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH;
		LOBBY_MAIN_WINDOW_HIGH_POS_Y = LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT;

		LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT = LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y = LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT - LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT;
		LOBBY_ARENA_LIST_ITEMS_PER_LINE = 3;
		LOBBY_SPACE_BETWEEN_ARENA_ITEMS = LOBBY_MAIN_WINDOW_WIDTH * 0.04;
		LOBBY_ARENA_LIST_ITEM_WIDTH = (LOBBY_MAIN_WINDOW_WIDTH - (LOBBY_ARENA_LIST_ITEMS_PER_LINE + 1) * LOBBY_SPACE_BETWEEN_ARENA_ITEMS) / LOBBY_ARENA_LIST_ITEMS_PER_LINE;
		LOBBY_ARENA_LIST_ITEM_HEIGHT = LOBBY_ARENA_LIST_ITEM_WIDTH * (250/300);
		LOBBY_ARENA_LIST_ITEM_SPACE_X = LOBBY_ARENA_LIST_ITEM_WIDTH + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
		LOBBY_ARENA_LIST_ITEM_SPACE_Y = LOBBY_ARENA_LIST_ITEM_HEIGHT + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
		
		LOBBY_ARENA_LOCK_SIZE = math.ceil(LOBBY_ARENA_LIST_ITEM_WIDTH / 300 * 72);
		
		LOBBY_ARENA_LIST_ITEM_MAX_INFO_LINES = 8;
		LOBBY_ARENA_ITEM_HEADLINE_FONT = "arial";
		LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE = 2.0 / 1080 * gScreenSizeY;
		LOBBY_ARENA_ITEM_HEADLINE_RECTANGLE_HEIGHT = dxGetFontHeight(LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
		LOBBY_ARENA_ITEM_INFO_FONT = "arial";
		LOBBY_ARENA_ITEM_INFO_FONT_SIZE = 2.5 / 1080 * gScreenSizeY;
		
		LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT = 0.82 * LOBBY_ARENA_LIST_ITEM_HEIGHT;
		LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT = 0.18 * LOBBY_ARENA_LIST_ITEM_HEIGHT;
		
		LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT = dxGetFontHeight( LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT );
		
		LOBBY_ARENA_BLACK_FONT = dxCreateFont("data/fonts/cb-black.ttf", math.min(36, 36 * RELATIVE_MULT_Y), true) or 'arial';
		--LOBBY_ARENA_BOLD_FONT = dxCreateFont("data/fonts/cb-bold.ttf", 36, true);
		--LOBBY_ARENA_LIGHT_FONT = dxCreateFont("data/fonts/cb-light.ttf", 24, false);
		
		--HUD GLOBALS
		HUD_CIRCLE_WIDTH = math.floor( 64 * gScreenSizeY / 1080 );

		HUD_LABEL_WIDTH = math.floor( 100 * gScreenSizeY / 1080 );
		HUD_POS_Y = math.floor( 0.02 * gScreenSizeX );
		HUD_POS_X = gScreenSizeX - HUD_POS_Y - HUD_CIRCLE_WIDTH - HUD_LABEL_WIDTH;
		
		HUD_TIME_FONT_SIZE = 1.5 * gScreenSizeY / 1200;
		HUD_FONT_SIZE = 1.4 * gScreenSizeY / 1200;
		HUD_FONT = "default";
		
		HUD_PADDING = 5 * gScreenSizeY / 1080;

end
