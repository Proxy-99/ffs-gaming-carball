local _DO_NOT_COMPILE

if not SERVER_GLOBALS_DEFINED then
	SERVER_GLOBALS_DEFINED = true;

--[[------------------------------------------------------||--
  					(<---Settings--->)									
																				
--||------------------------------------------------------]]--
	--[[--------------||--
	  (<---General--->)									
																				
	--||--------------]]--
		addEvent( "onPlayerArenaLeave", true );
		addEvent( "onPlayerArenaJoin", true );
	
		addEvent("onArenaInit");
		addEvent("onArenaExit");
		addEvent("onArenaPlayerPreInit");
		addEvent("onArenaPlayerInit");
		addEvent("onArenaPlayerExit");
		addEvent("onArenaStateChange");
		
		addEvent("onClientArenaCreationRequest", true);
		addEvent("onServerBallSyncPackageReceive", true);
		addEvent("onPlayerArenaJoinRequest", true);
		addEvent("onPlayerMatchTeamSelect", true);
		addEvent("onServerGoalHitNotify", true);
		addEvent("onGoalScore");

		addEvent("onCarballPlayerLogin");
		
		addEvent("onPlayerInit");
		addEvent("onClientDownloadFinished", true);
		
		ENABLE_EVENT_TRIGGER_CHECKS = true;

		ARENA_PASSWORD_SALT = "bKE6iOZ2hak/R(NnT"
end

