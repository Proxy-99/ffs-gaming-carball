local _DO_NOT_COMPILE

--[[
addEventHandler("onPlayerJoin", root,
	function ()
		outputDebugString("player ficker init! "..tostr(source));
		for _, data in ipairs(StaticPlayerData) do
			outputDebugString("sql "..tostring(data)..": "..tostring(loadPlayerSQLInformation(source, data)));
			setData(source, data, loadPlayerSQLInformation(source, data));
		end
	end
);]]
--[[local StaticPlayerData = { "Saves", "InAirSaves", "OnlineTime", "BallHits", "Goals", "OwnGoals", "WonMatches", "LostMatches", "LongestGoalShot", "FastestGoalShot" };

addEventHandler("onPlayerInit", resourceRoot,
	function (player)
		--outputDebugString("player initbimbo! "..tostr(player).." nigga: "..tostr(StaticPlayerData));
		for _, data in ipairs(StaticPlayerData) do
			outputDebugString("sql "..tostring(data)..": "..tostring(exports.mysql:loadPlayerSQLInformation(player, data, 0, "carball")));
			setData(player, data, exports.mysql:loadPlayerSQLInformation(player, data, 0, "carball"));
		end
	end
);

addEventHandler("onPlayerQuit", root,
	function ()
		savePlayerStaticData(source);
	end
);

function savePlayerStaticData(player)
	for _, data in ipairs(StaticPlayerData) do
		exports.mysql:savePlayerSQLInformation(player, data, getData(player, data), "carball");
	end
end

setTimer(
	function ()
		table.exec(getElementsByType("player"), savePlayerStaticData);
	end, 2 * MINUTES, 0
);]]
