
--[[----Class-Options----||--

	Description:
		Loads and saves Options

--||------------------]]--

gOptions = { };

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
		gOptions = loadTable("Options.data");
		
		outputDebugString("options: "..tostring(table.dump(gOptions)));
		--gOptions = table.copy(gSavedOptions);
	end
);

addEventHandler("onClientOptionChange", root,
	function (option, value)
		gOptions[option] = value;
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
		saveTable(gOptions, "Options.data");
	end
);

