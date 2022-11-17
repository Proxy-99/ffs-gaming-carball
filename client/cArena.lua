
--[[----Class-Main----||--

	Description:
		Controls the different Arenas and its client-side represantation

--||------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--

 
--||-------------------]]--

--[[----General-Data----||--


--||--------------------]]--

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientArenaPlayerInit", resourceRoot, 
	function (player)
		local time = Arena.getOption(source, "DayTime") or 21;
		local weather = Arena.getOption(source, "Weather") or 0;
		outputDebugString("Weather: "..tostring(weather).." Time: "..tostring(time));
		setTime(time, 0);
		setWeather(weather);
		--setWaterLevel(-1000);
		--setCameraClip(true, false);
		--OutputMessage("You joined Arena: #55ff55"..tostring(Arena.getID(source)))
		
		exports.ffs:addNotification("Joined arena: "..tostring(Arena.getName(source)), 1);
	end
);

addEventHandler("onClientArenaStateChange", resourceRoot, 
	function (oldState, newState)
		outputDebugString("client arena state change: "..tostring(oldState).." -> "..tostring(newState));
	end
);

function getCurrentArena()
	return getElementArena(localPlayer);
end

