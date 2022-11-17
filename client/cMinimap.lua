
--[[----Class-Minimap----||--

	Description:
		Draws a minimap on the topleft corner

--||---------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

MINIMAP_HEIGHT = gScreenSizeY * 0.4;
MINIMAP_WIDTH = MINIMAP_HEIGHT * 334 / 512;

BALL_ICON_SIZE = gScreenSizeY * 0.02;
PLAYER_ICON_SIZE = gScreenSizeY * 0.02;
LOCALPLAYER_ICON_SIZE = gScreenSizeY * 0.02;

DISTANCE_FROM_EDGE = gScreenSizeX * 0.02;

MINIMAP_POS_X = DISTANCE_FROM_EDGE;
MINIMAP_POS_Y = gScreenSizeY - DISTANCE_FROM_EDGE - MINIMAP_HEIGHT;

local pFieldMinX, pFieldMinY, pFieldMinZ = false, false, false;
local pFieldMaxX, pFieldMaxY, pFieldMaxZ = false, false, false;
local pFieldWidth, pFieldHeight = false, false;
local pRotate = false;

addEventHandler("onClientRender", root,
	function ()
		local arena = getCurrentArena();
		if (arena ~= LOBBY_ARENA and pFieldMinX and not getData(localPlayer, "Client.TeamSelectionActive")) then
			-- draw background
			--dxDrawBorderedRectangle(RELATIVE_MULT_Y, tocolor(0, 0, 0), MINIMAP_POS_X, MINIMAP_POS_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT, tocolor(100, 200, 100, 100), false);
			--dxDrawBorderedRectangle(RELATIVE_MULT_Y, tocolor(0, 0, 0), MINIMAP_POS_X, MINIMAP_POS_Y + MINIMAP_HEIGHT/2-RELATIVE_MULT_Y*5, 
			--						MINIMAP_WIDTH, RELATIVE_MULT_Y*5, tocolor(255, 255, 255, 200), false);
									
			dxDrawImage( MINIMAP_POS_X - MINIMAP_HEIGHT * 0.17383, MINIMAP_POS_Y, MINIMAP_HEIGHT, MINIMAP_HEIGHT, "data/images/field.png", 0, 0, 0, tocolor(255, 255, 255, 100) );
			
			-- draw goals
			--[[for id, goal in ipairs(getElementsByType("goal")) do
				if (getData(goal, "Stadium") == Arena.getStadium(arena)) then
					--outputDebugString("draw goal "..tostring(id));
					local x, y, z = getElementPosition(goal);
					local limitPos = getData(goal, "Limit");
					local lx, ly = limitPos.x, limitPos.y;--limitPos.x + (limitPos.x - x) * 0.0, limitPos.y  + (limitPos.y - y) * 0.0;
					--x, y = x - (limitPos.x - x) * 1.0, y - (limitPos.y - y) * 1.0;
					if (pRotate) then
						local tmp = x;
						x = y;
						y = -tmp;
						tmp = lx;
						lx = ly;
						ly = -tmp;
					end
					local relX, relY = (x - pFieldMinX) / pFieldWidth, 1 - (y - pFieldMinY) / pFieldHeight;
					local posX, posY = MINIMAP_POS_X + MINIMAP_WIDTH * relX, MINIMAP_POS_Y + MINIMAP_HEIGHT * relY;
					local relX2, relY2 = (lx - x) / pFieldWidth, (ly - y) / pFieldHeight;
					--outputDebugString("relX2, relY2: "..tostring(relX2)..", "..tostring(relY2));
					local width, height = math.abs(MINIMAP_WIDTH * relX2), math.abs(MINIMAP_HEIGHT * relY2);
					local drawn = false;
					if (Arena.getMode(arena) == "Match") then
						for _, team in ipairs(getElementsByType("matchteam", arena)) do
							if (getData(team, "ID") == getData(goal, "ID")) then
								local col = getData(team, "Color");
								dxDrawRectangle(posX, posY, width, height, tocolor(col.r, col.g, col.b, 200), false);
								drawn = true;
								break;
							end
						end
					end
					if (not drawn) then
						dxDrawRectangle(posX, posY, width, height, tocolor(200, 200, 200, 200), false);
					end
				end
			end--]]
			
			-- draw balls
			for _, ball in ipairs(getElementsByType("ball", arena)) do
				local x, y, z = getElementPosition(ball);
				if (pRotate) then
					local tmp = x;
					x = y;
					y = -tmp;
				end
				local relX, relY = (x - pFieldMinX) / pFieldWidth, 1 - (y - pFieldMinY) / pFieldHeight;
				local posX, posY = MINIMAP_POS_X + MINIMAP_WIDTH * relX - BALL_ICON_SIZE/2, MINIMAP_POS_Y + MINIMAP_HEIGHT * relY - BALL_ICON_SIZE/2;
				dxDrawImage(posX, posY, BALL_ICON_SIZE, BALL_ICON_SIZE, "data/images/ballicon.png", 0, 0, 0, tocolor(255, 255, 255, 255), false);
			end
			
			-- draw remote player icons
			for _, player in ipairs(getElementsByType("player", arena)) do
				if (player ~= localPlayer) then
					local veh = getPedOccupiedVehicle(player);
					if (veh) then
						local x, y, z = getElementPosition(player);
						local _, _, rz = getElementRotation(veh);
						if (pRotate) then
							local tmp = x;
							x = y;
							y = -tmp;
							rz = rz - 90;
						end
						local relX, relY = (x - pFieldMinX) / pFieldWidth, 1 - (y - pFieldMinY) / pFieldHeight;
						local posX, posY = MINIMAP_POS_X + MINIMAP_WIDTH * relX - PLAYER_ICON_SIZE/2, MINIMAP_POS_Y + MINIMAP_HEIGHT * relY - PLAYER_ICON_SIZE/2;
						local team = getData(player, "MatchTeam");
						local color = team and getData(team, "Color") or { r = 255, g = 255, b = 255 };
						dxDrawImage(posX, posY, PLAYER_ICON_SIZE, PLAYER_ICON_SIZE, "data/images/playerblip.png", -rz + 45, 0, 0, tocolor(color.r, color.g, color.b, 255), false);
						
						posX, posY = posX + PLAYER_ICON_SIZE/2, posY + PLAYER_ICON_SIZE;
						local boxSize = gScreenSizeX * 0.1;
						dxDrawText(getPlayerName(player), posX - boxSize, posY - boxSize, posX + boxSize, posY + boxSize, 
									tocolor(color.r, color.g, color.b, 255), 0.4 + 0.82 / 1080 * gScreenSizeY, "default", "center", "center", false, false, false);--true);
					end
				end
			end
			
			-- draw local player icon
			local veh = getPedOccupiedVehicle(localPlayer);
			if (veh) then
				local x, y, z = getElementPosition(localPlayer);
				local _, _, rz = getElementRotation(veh);
				if (pRotate) then
					local tmp = x;
					x = y;
					y = -tmp;
					rz = rz - 90-- - 45;
				end
				local relX, relY = (x - pFieldMinX) / pFieldWidth, 1 - (y - pFieldMinY) / pFieldHeight;
				local posX, posY = MINIMAP_POS_X + MINIMAP_WIDTH * relX - LOCALPLAYER_ICON_SIZE/2, MINIMAP_POS_Y + MINIMAP_HEIGHT * relY - LOCALPLAYER_ICON_SIZE/2;
				dxDrawImage(posX, posY, LOCALPLAYER_ICON_SIZE, LOCALPLAYER_ICON_SIZE, "data/images/localplayerblip.png", -rz, 0, 0, tocolor(255, 255, 255, 255), false);
				
				local team = getData(localPlayer, "MatchTeam");
				local color = team and getData(team, "Color") or { r = 255, g = 255, b = 255 };
				posX, posY = posX + LOCALPLAYER_ICON_SIZE/2, posY + LOCALPLAYER_ICON_SIZE;
				local boxSize = gScreenSizeX * 0.1;
				dxDrawText(getPlayerName(localPlayer), posX - boxSize, posY - boxSize, posX + boxSize, posY + boxSize, 
							tocolor(color.r, color.g, color.b, 255), 0.4 + 0.82 / 1080 * gScreenSizeY, "default", "center", "center", false, false, false);--true);
			end
		end
	end
);
addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		-- load limits
		pFieldMinX, pFieldMinY, pFieldMinZ, pFieldMaxX, pFieldMaxY, pFieldMaxZ = Stadium.getCurrentLimits();
		
		pFieldWidth, pFieldHeight = pFieldMaxX - pFieldMinX, pFieldMaxY - pFieldMinY;
		
		pRotate = pFieldWidth > pFieldHeight;
		
		if (pRotate) then
			local tmp = pFieldMaxX;
			pFieldMaxX = pFieldMaxY;
			pFieldMaxY = -tmp;
			tmp = pFieldMinX;
			pFieldMinX = pFieldMinY;
			pFieldMinY = -tmp;
			
			tmp = pFieldMinY;
			pFieldMinY = pFieldMaxY;
			pFieldMaxY = tmp;
			
			tmp = pFieldWidth;
			pFieldWidth = pFieldHeight;
			pFieldHeight = tmp;
		end
		
		local whfactor = pFieldWidth / pFieldHeight;
		--MINIMAP_WIDTH = MINIMAP_HEIGHT * whfactor;
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		pFieldMinX, pFieldMinY, pFieldMinZ = false, false, false;
		pFieldMaxX, pFieldMaxY, pFieldMaxZ = false, false, false;
	end
);

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

