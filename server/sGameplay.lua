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
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

setTimer(
	function ()
		for _, player in ipairs(getElementsByType("player"), arenaElement) do
			local veh = Player.getVehicle(player)
			if (isValid(veh) and getPedOccupiedVehicle(player) ~= veh) then
				warpPedIntoVehicle(player, veh)
			end
		end
	end, 3*SECONDS, 0
);
--[[
gInfoTextCount = 1;
gInfoTexts = {
	"If you want to talk with other players\njoin our Mumble Server!\nJust Google and install Mumble and connect to\nIP: neon-gaming.de Port: 64738",
	"You want to play different Minigames?\nThen join our Neon Fun Main Server!\nJust type /neonfun",
	"You want to play Race DM?\nThen join our Neon Race Server!\nJust type /neonrace",
	"You can open Private-Chat\nby pressing F3!",
	"New maps or ideas are always welcome!\nPost them at forum.neon-gaming.de"
}

setTimer(
	function ()
		exports.notifications:showNotifier(root, "Info", "Info", gInfoTexts[gInfoTextCount], false);
		gInfoTextCount = (gInfoTextCount % #gInfoTexts) + 1;
	end, 20 * MINUTES, 0
);]]