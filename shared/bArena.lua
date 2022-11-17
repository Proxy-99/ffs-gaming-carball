
--[[----Class-Main----||--

	Description:
		Contains universal arena functions

--||------------------]]--

Arena = { };

LOBBY_ARENA = false;
LOBBY_ARENA_DIMENSION = 22;

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function getElementArena(element)
	return getData(element, "Arena") or LOBBY_ARENA;
end

function Arena.getActivePlayers(arena)
	return table.filter(getElementsByType("player", arena), Player.getMatchTeam);
end

function Arena.getDimension(arena)
	local id = Arena.getID( arena );
	return id and ( 1000 + id ) or false; --start from 10,000 to avoid any theoretical collapse with ffs arenas
end

function Arena.getID(arena)
	return getData(arena, "ID");
end

function Arena.getOptions(arena)
	return getData(arena, "Options");
end

function Arena.getOption(arena, option)
	return getData(arena, "Options")[option];
end

function Arena.getStadium(arena)
	local options = getData(arena, "Options");
	return options and options.Stadium;
end

function Arena.getState(arena)
	return getData(arena, "State");
end

function Arena.getMode(arena)
	--outputDebugString("trace: "..tostring(debug.traceback()));
	return isValid(arena) and (Arena.getOptions(arena)).Mode;
end

function Arena.getName(arena)
	return (Arena.getOptions(arena)).Name;
end

function getArenaName(arena)
	return Arena.getName(arena);
end

function Arena.getCreator(arena)
	return (Arena.getOptions(arena)).Creator;
end

function Arena.getMatchLength(arena)
	return getData(arena, "Options").MatchLength;
end

function Arena.selectModeFunction(arena, functions, ...)
	if (isValid(arena) and arena ~= LOBBY_ARENA) then
		local mode = Arena.getMode(arena);
		local func = functions[mode];
		if (func) then
			func(arena, ...);
			return true
		else
			outputDebugString("Couldn't select function for arena: "..tostring(Arena.getID(arena)).." and mode: "..tostring(mode));
		end
	end
	return false;
end

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

