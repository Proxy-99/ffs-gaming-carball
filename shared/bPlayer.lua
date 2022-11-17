
--[[----Class-Player----||--

	Description:
		Handles Player functions

--||--------------------]]--

Player = { };

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Player.getVehicle(player)
	return getData(player, "Vehicle");
end

function Player.getMatchTeam(player)
	return getData(player, "MatchTeam");
end

function getPlayerClanID( player )
	local clanID = getElementData( player, "clan" )
	if clanID then
		return clanID
	elseif isPlayerAdmin( player ) then
		return 1
	elseif isDonator( player ) then
		return 2
	end
end

function isPlayerAdmin( player )
	local ugid = getElementData(player or localPlayer, "usergroupid")
	return ugid == 5 or ugid == 6 or ugid == 7;
end

function isDonator( player )
	player = player or localPlayer
	return (isPlayerAdmin(player) or getElementData(player, "usergroupid") == 12);
end

function getPlayerUserID(player)
	return getElementData(player or localPlayer, "userid") or 0;
end
