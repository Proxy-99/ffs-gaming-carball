
--[[----Class-Main----||--

	Description:
		Controls Main Behaviour

--||------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

Stadium = { };

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Stadium.getLimits(stadium)
	local fieldLimit = Stadium.getFieldLimit(stadium);
	local x, y, z = getElementPosition(fieldLimit);
	local limit = getData(fieldLimit, "LimitPosition");
	return x, y, z + 1, limit.x, limit.y, limit.z;
end

function Stadium.getTeamAmount(stadium)
	return #getData(stadium, "TeamData");
end

function Stadium.getTeamData(stadium, teamID)
	return getData(stadium, "TeamData")[teamID];
end

function Stadium.getBallSpawn(stadium)
	return getData(stadium, "BallSpawn");
end

function Stadium.getFieldLimit(stadium)
	return getData(stadium, "FieldLimit");
end

function Stadium.getName(stadium)
	return getData(stadium, "Name");
end

function Stadium.getFromName(name)
	for _, stadium in ipairs(getElementsByType("stadium")) do
		if (getData(stadium, "FileName") == name) then
			return stadium;
		end
	end
	return false;
end


