local _DO_NOT_COMPILE
--[[----Class-Antilag----||--

	Description:
		Kicks Players with High Ping from Arenas

--||------------------]]--

HIGH_PING_AMOUNT_LIMIT = 15;

addEventHandler("onArenaPlayerInit", resourceRoot,
	function (player)
		-- init count
		setData(player, "HighPingCount", 0);
	end
);

setTimer(
	function ()
		for _, arena in ipairs(getElementsByType(ARENA_ELEMENT_TYPE)) do
			if (Arena.getMode(arena) == "Match") then
				-- check in every match arena
				local limit = Arena.getOption(arena, "PingLimit");
				for _, player in ipairs(getElementsByType("player", arena)) do
					-- only if player is actually participating
					if (not Player.isSpectator(player)) then
						if (getPlayerPing(player) > limit) then
							increaseData(player, "HighPingCount", 2);
							--outputDebugString("icnreased high pingcount: "..tostring(getData(player, "HighPingCount")));
							if (getData(player, "HighPingCount") >= HIGH_PING_AMOUNT_LIMIT) then
								Player.showLobby(player, false, "High Ping");
								if (IS_FFS) then
									exports.ffs:addNotification(player, "You were kicked to lobby for HIGH PING", 3);
								end
							end
						else
							local current = getData(player, "HighPingCount") or 0;
							if (current > 0) then
								setData(player, "HighPingCount", current - 1);
							end
						end
					end
				end
			end
		end
	end, 1000, 0
);
