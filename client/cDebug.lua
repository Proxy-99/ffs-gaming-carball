
--[[----Class-Debug----||--

	Description:
		Adds Useful Debug Info

--||------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

if (getPlayerName(localPlayer, true) == "[Ne]#ffa800Tjong") then
	--[[local pFile = fileCreate("dataTransmitted.log");
	addEventHandler("onClientTjongDataChange", resourceRoot,
		function (data, oldValue, newValue)
			fileWrite(pFile, tostr(source).."["..tostr(data).."] -> "..tostr(newValue).."\n");
		end
	);
	setTimer(function () fileFlush(pFile); end, 5 * SECONDS, 0);
	addEventHandler("onClientResourceStop", resourceRoot, function () fileClose(pFile); end);]]
end

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

local pFontSize = 2.0 / 1080 * gScreenSizeY;

gDebugMsg = { };

function addToDebug(msg)
	if (DEBUG) then
		table.insert(gDebugMsg, msg);
	end
end

addEventHandler("onClientRender", root,
	function ()
		if (DEBUG) then
			local output = "DEBUG MESSAGES:\n";
			for _, msg in ipairs(gDebugMsg) do
				output = output .. tostring(msg) .. "\n";
			end
			dxDrawText(output, gScreenSizeX * 0.5, gScreenSizeY * 0.2, gScreenSizeX, gScreenSizeY, 
										tocolor(255, 255, 255, 255), pFontSize, "arial", 
										"center", "top", false, false, false, true);
			gDebugMsg = { };
		
			local arena = getCurrentArena();
			if (arena ~= LOBBY_ARENA) then
				for _, ball in ipairs(getElementsByType("ball", arena)) do
					local syncer = Ball.getSyncer(ball);
					if (isValid(syncer)) then
						local bx, by, bz = getElementPosition(ball);
						local x, y, z = getElementPosition(syncer);
						dxDrawLine3D(x, y, z, bx, by, bz, tocolor(0, 255, 0), 2);
					end
				end
			end
		end
	end
);
