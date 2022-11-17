
--[[----Class-Team----||--

	Description:
		Controls Team Behaviour

--||------------------]]--

Team = { };
MatchTeam = { };


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function MatchTeam.getName(team)
	return getData(team, "Name")
end

function MatchTeam.getScore(team)
	return getData(team, "Score")
end

function MatchTeam.getPlayerAmount(team)
	return table.size(getData(team, "Players"))
end

function MatchTeam.getSize(team)
	return getData(team, "Size")
end


