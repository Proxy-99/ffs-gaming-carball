local _DO_NOT_COMPILE

--[[----Class-Main----||--

	Description:
		Initializes main structures

--||------------------]]--

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	CurrentArena
	
--||-------------------]]--

--[[----General-Data----||--
	
	
	gArenas [{}]
	gRegisteredTeams [*{}]
	gSavedReplays [*] ((file-)names only, info itself saved on disk)
	
--||--------------------]]--

gArenas = { };
gRegisteredTeams = { };
--gSavedReplays = { };
gServerOptions = { };

--gStaticTables = { ["Options.data"] = gServerOptions, ["registeredTeams.data"] = gRegisteredTeams, ["savedReplays.data"] = gSavedReplays }
STATIC_TABLES_SAVE_INTERVAL = 1 * MINUTES;

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		setGameType("FFS CarBall");
	
		--exports.scoreboard:addScoreboardColumn("Arena", getRootElement(), 3, 0.06);
		--exports.scoreboard:addScoreboardColumn("User Rank", getRootElement(), 3, 0.12);
		
		gServerOptions = loadTable("Options.data");
		--setData(root, "NewsText", gServerOptions.NewsText, true);
	end
);

function joinCarball(id)
	if id == thisArena or not IS_FFS then
		pFinishedDownloaders[source] = true;

		triggerEvent("onPlayerInit", resourceRoot, source);
		triggerClientEvent(source, "onClientPlayerInit", resourceRoot);
	end
end
addEventHandler( "onPlayerArenaJoin", root, joinCarball );

addEvent("onPlayerInitialized", true);
addEventHandler("onPlayerInitialized", resourceRoot,
	function()
		if client then
			triggerEvent("onClientDownloadFinished", resourceRoot, source);
		end
	end
)

function leaveCarball(id)
	if id == thisArena or not IS_FFS then
		Player.leave(source);
		triggerEvent("onPlayerExit", resourceRoot, source);
		triggerClientEvent(source, "onClientPlayerExit", resourceRoot);
		pFinishedDownloaders[source] = true;
	end
end
addEventHandler( "onPlayerArenaLeave", root, leaveCarball );

if (not IS_FFS) then
	addEventHandler("onPlayerJoin", root, joinCarball);
	addEventHandler("onResourceStart", resourceRoot,
		function()
			for k, player in ipairs(getElementsByType("player")) do
				triggerEvent("onPlayerArenaJoin", player);
			end
		end
	);
	addEventHandler("onPlayerQuit", root, leaveCarball);
end


function OutputMessage(message, outputTo)
    return outputChatBox("[#FF6464INFO#FFFFFF] "..tostring(message), outputTo or root, 255, 255, 255, true);
end

addEventHandler("onResourceStop", resourceRoot, 
	function ()		
		saveTable(gServerOptions, "Options.data");
	end
);

--[[addCommandHandler("setnewstext",
	function (player, _, ...)
		local str = "";
		for _, s in ipairs( {...} ) do
			str = str .. " " .. s;
		end
		str = str:gsub("\\n", "\n");
		outputDebugString("new news text: "..tostring(str));
		gServerOptions.NewsText = str;
		setData(root, "NewsText", gServerOptions.NewsText, true);
	end, true, false
);]]
