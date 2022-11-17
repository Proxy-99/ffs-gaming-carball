local _DO_NOT_COMPILE

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||-------------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||-------------------]]--

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		if (gStaticTables) then
			for fileName, global in pairs(gStaticTables) do
				global = loadTable(fileName);
			end
			
			setTimer(
				function ()
					for fileName, global in pairs(gStaticTables) do
						saveTable(global, fileName);
					end
				end, STATIC_TABLES_SAVE_INTERVAL or 5 * MINUTES, 0
			);
		end
	end
);

addEventHandler("onResourceStop", resourceRoot, 
	function ()
		if (gStaticTables) then
			for fileName, global in pairs(gStaticTables) do
				saveTable(global, fileName);
			end
		end
	end
);