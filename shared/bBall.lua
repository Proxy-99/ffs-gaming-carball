
--[[----Class-Main----||--

	Description:
		Contains universal ball functions

--||------------------]]--

Ball = { };

BALL_MODEL = 16442;
BALL_VEHICLE_MODEL = 457;

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Ball.getSyncer(ball)
	return getData(ball, "Syncer");
end


