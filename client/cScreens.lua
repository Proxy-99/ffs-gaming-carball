
--[[----Class-Screen----||--

	Description:
		Controls the different Main Menu Screens

--||------------------]]--

Screen = { };


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

gScreens = { };
gCurrentScreen = false;

SCROLL_ACCLERATION = 0.3 * RELATIVE_MULT_Y;
SCROLL_DECELERATION = 0.8;

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function Screen.create(name, onInit, onExit, onRender)
	local screen = createElement("screen");
	setData(screen, "Name", name);
	setData(screen, "onInit", onInit);
	setData(screen, "onExit", onExit);
	setData(screen, "onRender", onRender);
	return screen;
end

function Screen.getFromName(name)
	for _, screen in ipairs(getElementsByType("screen")) do
		if (getData(screen, "Name") == name) then
			return screen;
		end
	end
	return false;
end

function Screen.attachItem(screen, item)
	setElementParent(item, screen);
	ClickableItem.setVisible(item, screen == gCurrentScreen);
end

function Screen.switchTo(screen)
	if (gCurrentScreen) then
		--outputChatBox(getData(gCurrentScreen, "Name"));
		local onExit = getData(gCurrentScreen, "onExit");
		if (onExit) then
			onExit();
		end
		for _, item in ipairs(getElementsByType("clickableitem", gCurrentScreen)) do
			ClickableItem.setVisible(item, false);
		end
	end
	
	--Re-set scrollbars
	gScrollCounter = 0;
	gScrollSpeed = 0;

	local onInit = getData(screen, "onInit");
	if (onInit) then
		onInit();
	end
	for _, item in ipairs(getElementsByType("clickableitem", screen)) do
		ClickableItem.setVisible(item, true);
	end
	gCurrentScreen = screen;
end

addEventHandler("onClientLobbyRender", root,
	function ()
		local onRender = getData(gCurrentScreen, "onRender");
		if (onRender and not isUserPanelActive()) then
			onRender();
		end
	end, true, "high+20"
);

--- Team Selection ---

gTeamButtons = { };
TEAM_SELECTION_BUTTON_SIZE_X = gScreenSizeX * 0.15;
TEAM_SELECTION_BUTTON_SIZE_Y = TEAM_SELECTION_BUTTON_SIZE_X / 2;

local TeamData = {
	{"RED", { r=255, g=65, b=54 } },
	{"BLUE", { r=54, g=64, b=255 } }
}

function showTeamSelection()
	local teams = getElementsByType("matchteam", getCurrentArena());
	local sizeX = TEAM_SELECTION_BUTTON_SIZE_X;
	for id, team in ipairs(teams) do
		sizeX = math.max(sizeX, 1.1 * dxGetTextWidth(getData(team, "Name"), LOBBY_MAIN_MENU_BUTTON_FONT_SIZE, LOBBY_MAIN_MENU_BUTTON_FONT))
	end
	
	local posX = gScreenSizeX * 0.5 - (#teams) / 2 * sizeX;
	local posY = gScreenSizeY * 0.5 - TEAM_SELECTION_BUTTON_SIZE_Y * 0.5;
	
	TEAM_SELECTION_POS_X = posX;
	TEAM_SELECTION_POS_Y = posY;
	
	for id, team in ipairs(teams) do
		local c = TeamData[id][2] or getData(team, "Color");
		local borderRadius = ( ( id == 1 ) and {100, 100, 0, 0} ) or ( id == #teams and {0, 0, 100, 100} or 0 );
		
		local button = Button.create( TeamData[id][1] or tostring(getData(team, "Name")), posX, posY,
										sizeX, TEAM_SELECTION_BUTTON_SIZE_Y,
										function (item, team)
											triggerServerEvent("onPlayerMatchTeamSelect", localPlayer, team);
											--triggerServerEvent("onPlayerMatchTeamSelect", root, localPlayer, team);
										end, { team }, c, borderRadius);

		setData(button, "NoLobbyGUI", true);
		table.insert(gTeamButtons, button);
		posX = posX + sizeX;
	end

	local posX = gScreenSizeX * 0.5 - sizeX;
	local posY = gScreenSizeY - TEAM_SELECTION_BUTTON_SIZE_Y * 0.6;
	local button = Button.create( "SPECTATE", posX, posY,
										sizeX * 2, TEAM_SELECTION_BUTTON_SIZE_Y*0.5,
										function ()
											triggerEvent("onPlayerSpectatorSelect", localPlayer);
										end, nil, {r=0, g=0, b=0}, 100);
	setData(button, "NoLobbyGUI", true);
	table.insert(gTeamButtons, button);
	
	setData(localPlayer, "Client.TeamSelectionActive", true);
end

function resetTeamSelection()
	for _, button in ipairs(gTeamButtons) do
		if (isValid(button)) then
			destroyElement(button);
		end
	end
	setData(localPlayer, "Client.TeamSelectionActive", false);
	gTeamButtons = { };
end

addEvent("onPlayerSpectatorSelect");
addEventHandler("onPlayerSpectatorSelect", root,
	function()
		resetTeamSelection()
	end
);

function resetLobby( cloaseAll )
	for _, item in ipairs(getElementsByType("clickableitem")) do
		setData(item, "Active", false);
		if getElementParent(item) and getElementType(getElementParent(item)) == "screen" then
			ClickableItem.setVisible(item, false);
		end
	end
	
	if not closeAll then
		setData(Screen.BTN_ARENAS, "Active", true);
		Screen.switchTo(Screen.ARENAS);
	end
end

addEventHandler("onClientRender", root,
	function ()
		-- draw player names which are in the team
		if (getData(localPlayer, "Client.TeamSelectionActive")) then
			local teams = getElementsByType("matchteam", getCurrentArena());
			local posX = gScreenSizeX * 0.5 - (#teams) / 2 * TEAM_SELECTION_BUTTON_SIZE_X;
			local posY = gScreenSizeY * 0.5 + TEAM_SELECTION_BUTTON_SIZE_Y * 0.6;
			for id, team in ipairs(teams) do
				local c = getData(team, "Color");
				
				local draw = "testosteron\nbla\npenis\ntestosteron\nbla\npenis\n";--"testosteron\nbla\npenis\n";
				
				for _, player in ipairs(getElementsByType("player", getCurrentArena())) do
					if (getData(player, "MatchTeam") == team) then
						draw = draw .. tostring(getPlayerName(player)) .. "\n";
					end
				end
				
				dxDrawText(draw, posX + TEAM_SELECTION_BUTTON_SIZE_X * 0.2, posY, posX + TEAM_SELECTION_BUTTON_SIZE_X * 0.8, posY,
							tocolor(c.r, c.g, c.b, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "left", "top", false, false);
				posX = posX + TEAM_SELECTION_BUTTON_SIZE_X;
			end
		end
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot, resetTeamSelection);
addEventHandler("onClientTjongDataChange", localPlayer,
	function (data, oldValue, newValue)
		if (data == "MatchTeam") then
			-- team was selected successfull
			resetTeamSelection();
			showCursor(false);
		end
	end
);

--- Welcome and Help Screen ---

Screen.Draw = { };

function Screen.Draw.Welcome()

	dxDrawBorderedRectangle(1, tocolor(0, 0, 0), LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (1/5), LOBBY_MAIN_WINDOW_POS_Y * 1.04, 
							LOBBY_MAIN_WINDOW_WIDTH * (3/5), dxGetFontHeight(LOBBY_MAIN_NORMAL_FONT_SIZE) * 3.5, tocolor(100, 100, 100, 200), false);
	dxDrawBorderedText(0.5, tocolor(0, 0, 0), "Welcome", LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y * 1.05, LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT,
							tocolor(50, 90, 255, 255), LOBBY_MAIN_NORMAL_FONT_SIZE * 2, LOBBY_MAIN_NORMAL_FONT, "center", "top");
							
	dxDrawBorderedText(0.5, tocolor(0, 0, 0), "to Carball!",
					LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (1/5), LOBBY_MAIN_WINDOW_POS_Y * 1.07 + dxGetFontHeight(LOBBY_MAIN_NORMAL_FONT_SIZE, LOBBY_MAIN_NORMAL_FONT) * 2, 
					LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (4/5), LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT,
					tocolor(20, 100, 155, 255), LOBBY_MAIN_NORMAL_FONT_SIZE, LOBBY_MAIN_NORMAL_FONT, "center", "top", true, true);
	
	local text = "The aim of this Gamemode is very simple:\nPlay football with cars!\n\nYou can join an existing Carball match by browsing the arena list or create your own match by clicking the button \"Create Arena\".\n\nControls:\nL - Leave Arena and show the Lobby\nLeft Shift - Jump\nLeft Shift (x2) - Double Jump";
	width, height = LOBBY_MAIN_WINDOW_WIDTH * (3/5), (LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT - (LOBBY_MAIN_WINDOW_POS_Y * 1.07 + dxGetFontHeight(LOBBY_MAIN_NORMAL_FONT_SIZE, LOBBY_MAIN_NORMAL_FONT) * 4)) * 0.98;
	
	dxDrawBorderedRectangle(1, tocolor(0, 0, 0), LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (1/5), LOBBY_MAIN_WINDOW_POS_Y * 1.07 + dxGetFontHeight(LOBBY_MAIN_NORMAL_FONT_SIZE) * 4, 
							width, height, tocolor(100, 100, 100, 200), false);
	dxDrawBorderedText(0.5, tocolor(0, 0, 0), text,
					LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (1/5), 
					LOBBY_MAIN_WINDOW_POS_Y * 1.07 + dxGetFontHeight(LOBBY_MAIN_NORMAL_FONT_SIZE, LOBBY_MAIN_NORMAL_FONT) * 4, 
					LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * (4/5), LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT,
					tocolor(200, 200, 200, 255), LOBBY_MAIN_NORMAL_FONT_SIZE, LOBBY_MAIN_NORMAL_FONT, "left", "top", true, true);
					
					
end

--- Options Screen ---

--- Goal Screen ---

--[[
	Goal Info Structure
		ID
		Likes
		ScorerName
		Stadium
		MatchScore
		Timestamp


]]

local pTopGoals = { };
gScrollSpeed = 0;
gScrollCounter = 0;
--[[
setTimer(
	function ()
		for i = 1, 1000, 1 do
			table.insert(pTopGoals,
				{
					ID = i,
					Likes = math.random(500),
					ScorerName = "Tjong" .. tostring(math.random(100)),
					Stadium = table.random(getElementsByType("stadium")),
					MatchScore = tostring(math.random(10)) .. " : " .. tostring(math.random(10)),
					Timestamp = 1000000000 + math.random(1000000000),
				});
		end
	end, 1000, 1
);]]

_addEvent("onClientTopGoalsReceive", true);
_addEventHandler("onClientTopGoalsReceive", root,
	function (goals)
		for _, info in ipairs(goals) do
			table.insert(pTopGoals, info);
		end
	end
);

addRemoteEventHandler("onClientTopGoalLikeUpdate", root,
	function (goalID, likes)
		pTopGoals[goalID].Likes = likes;
	end
);

addEventHandler("onClientClick", root,
	function (button, state)
		if (getCurrentArena() ~= LOBBY_ARENA or isUserPanelActive()) then
			return;
		end
		if (button == "left" and state == "down") then
			local goal = getData(localPlayer, "Client.SelectedGoal");
			if (goal) then
				triggerServerEvent("onPlayerGoalViewRequest", localPlayer, goal);
				setData(localPlayer, "Client.SelectedGoal", false);
				playSound("data/audio/buttonSelect.mp3");
			end
		end
	end
);

function sortTopGoals()
	gScrollCounter = 0;
	gScrollSpeed = 0;
	table.sort(pTopGoals,
		function (a, b)
			return (a.Likes > b.Likes);
		end
	);
end

function sortNewGoals()
	gScrollCounter = 0;
	gScrollSpeed = 0;
	table.sort(pTopGoals,
		function (a, b)
			return (a.Timestamp > b.Timestamp);
		end
	);
end

function Screen.Draw.TopGoals()
	local lastSelectedArena = getData(localPlayer, "Client.SelectedGoal");
	setData(localPlayer, "Client.SelectedGoal", false);
	
	local lineAmount = math.ceil((#pTopGoals)/LOBBY_ARENA_LIST_ITEMS_PER_LINE);

	local maxHeight = math.max(0, lineAmount * LOBBY_ARENA_LIST_ITEM_SPACE_Y - LOBBY_MAIN_WINDOW_HEIGHT - LOBBY_SPACE_BETWEEN_ARENA_ITEMS);

	if (isCursorIn(LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT)) then
		gScrollSpeed = gScrollSpeed - SCROLL_ACCLERATION;
	elseif (isCursorIn(LOBBY_MAIN_WINDOW_POS_X, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y, 
						LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y + LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT)) then
		gScrollSpeed = gScrollSpeed + SCROLL_ACCLERATION;
	else
		gScrollSpeed = gScrollSpeed * SCROLL_DECELERATION;
	end

	--counter = counter + (math.sin(getTickCount()/200)*5+5) * (down and 1 or -1);
	gScrollCounter = gScrollCounter + gScrollSpeed;
	if (gScrollCounter < 0 or gScrollCounter > maxHeight) then 
		addToDebug("clamping o.ô: "..tostring(maxHeight));
		gScrollCounter = math.clamp(gScrollCounter, 0, maxHeight);
		gScrollSpeed = 0;
	end
	addToDebug("Scroll: "..tostring(gScrollCounter));
	--[[dxDrawText("lineAmount "..tostring(lineAmount), 0, 0, gScreenSizeX, gScreenSizeY * 0.5, 
				tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "top");
	dxDrawText("counter "..tostring(counter), 0, gScreenSizeY * 0.1, gScreenSizeX, gScreenSizeY, 
				tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "top");]]

	local posX = LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
	local posY = LOBBY_MAIN_WINDOW_POS_Y - gScrollCounter;
	local xCounter = 1;
	
	for _, goalInfo in ipairs(pTopGoals) do
		--outputDebugString("options.Stadium: "..tostring(options.Stadium).." stadium: "..tostring(getData(options.Stadium, "FileName")));
		local firstHeight = posY + LOBBY_ARENA_LIST_ITEM_HEIGHT - LOBBY_MAIN_WINDOW_POS_Y;
		if (firstHeight > 0) then
			if (firstHeight >= LOBBY_ARENA_LIST_ITEM_HEIGHT) then
				local drawableHeight = (LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) - posY;
				local drawHeight = math.min(LOBBY_ARENA_LIST_ITEM_HEIGHT, drawableHeight);
				--dxDrawRectangle(posX, posY, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, tocolor(100, 100, 100, 100), false);
				local selected = not getData(localPlayer, "Client.SelectedGoal") and isCursorIn(posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + drawHeight);
				if (selected) then 
					setData(localPlayer, "Client.SelectedGoal", goalInfo.ID);
					if (not lastSelectedArena and not isUserPanelActive()) then
						playSound("data/audio/buttonHover.mp3");
					end
				end
				
				dxDrawRoundedImage(posX, posY, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, "data/images/"..tostring(goalInfo.Stadium)..".jpg", selected and 255 or 150, drawHeight);
				
				local title = "GOAL "..tostring(goalInfo.ID);
				
				local titleSize = math.min(1, getFontSizeFittingWidth( title, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.95, LOBBY_ARENA_BLACK_FONT ));
				local titleHeight = dxGetFontHeight( titleSize, LOBBY_ARENA_BLACK_FONT );
				
				dxDrawText(title, posX, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - titleHeight ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + titleHeight ) / 2 ), 
						tocolor(255, 255, 255, selected and 255 or 200), titleSize, LOBBY_ARENA_BLACK_FONT, "center", "top", true, false, false, false, true);
				
				local hoster = tostring(goalInfo.ScorerName);
				if (hoster) then
					hoster = "Scorer: " .. hoster;
					hoster = hoster:upper();
					
					local hosterSize = math.min(1, getFontSizeFittingWidth( hoster, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.6, LOBBY_ARENA_BLACK_FONT ));
					local hosterHeight = dxGetFontHeight( hosterSize, LOBBY_ARENA_BLACK_FONT );
					
					dxDrawText(hoster, posX, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - hosterHeight ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + hosterHeight ) / 2 ), 
						tocolor(255, 137, 0, selected and 255 or 200), hosterSize, LOBBY_ARENA_BLACK_FONT, "center", "top", true, false, false, false, true);

				end
				
				if (drawableHeight >= 42 * RELATIVE_MULT_Y) then
					local height = dxGetFontHeight( LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT );
					dxDrawRoundedRectangle( posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10  * RELATIVE_MULT_Y, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.8, 32 * RELATIVE_MULT_Y, 100, tocolor(33, 33, 33, 150) );
					dxDrawText( tostring(formatTime("d.m.Y h:i", false, goalInfo.Timestamp)), posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y - height ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.9, math.min( posY + drawableHeight, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y + height ) / 2),
							tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top");
				end

				dxDrawText( "Likes: " .. tostring(goalInfo.Likes), posX, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT - LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT + LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2 ), 
					tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top", true, false, false, false, true);
				

				--dxDrawText(info, posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + height, 
				--		tocolor(255, 255, 255, 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE, LOBBY_ARENA_ITEM_INFO_FONT, "left", "top", true, false, false, false, false);
				--[[if (posY + LOBBY_ARENA_ITEM_HEADLINE_RECTANGLE_HEIGHT < LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) then
					dxDrawText("Arena "..tostring(getData(arena, "ID")), posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + LOBBY_ARENA_ITEM_HEADLINE_RECTANGLE_HEIGHT, 
								tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center");
				end]]
			else
				local selected = not getData(localPlayer, "Client.SelectedGoal") and isCursorIn(posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + firstHeight);
				if (selected) then 
					setData(localPlayer, "Client.SelectedGoal", goalInfo.ID);
					if (not lastSelectedArena and not isUserPanelActive()) then
						playSound("data/audio/buttonHover.mp3");
					end
				end
			
				local internalDrawHeight = 321 * (firstHeight / LOBBY_ARENA_LIST_ITEM_HEIGHT);
				
				dxDrawRoundedImage(posX, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, "data/images/"..tostring(goalInfo.Stadium)..".jpg", selected and 255 or 150, firstHeight, true)

				local clipped = LOBBY_ARENA_LIST_ITEM_HEIGHT - firstHeight;
				local clipped_rel = clipped / LOBBY_ARENA_LOCK_SIZE;
				
				local title = "GOAL "..tostring(goalInfo.ID);
				local titleSize = math.min(1, getFontSizeFittingWidth( title, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.95, LOBBY_ARENA_BLACK_FONT ));
				local titleHeight = dxGetFontHeight( titleSize, LOBBY_ARENA_BLACK_FONT );
				
				dxDrawText(title, posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - titleHeight ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + titleHeight ) / 2, 
						tocolor(255, 255, 255, selected and 255 or 200), titleSize, LOBBY_ARENA_BLACK_FONT, "center", "bottom", true, false, false, false, true);
				
				local hoster = tostring(goalInfo.ScorerName);
				if (hoster) then
					hoster = "Scorer: " .. hoster;
					hoster = hoster:upper();
					
					local hosterSize = math.min(1, getFontSizeFittingWidth( hoster, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.6, LOBBY_ARENA_BLACK_FONT ));
					local hosterHeight = dxGetFontHeight( hosterSize, LOBBY_ARENA_BLACK_FONT );
					
					dxDrawText(hoster, posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - hosterHeight ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + hosterHeight ) / 2, 
						tocolor(255, 137, 0, selected and 255 or 200), hosterSize, LOBBY_ARENA_BLACK_FONT, "center", "bottom", true, false, false, false, true);

				end

				if (clipped <= 10 * RELATIVE_MULT_Y) then
					local height = dxGetFontHeight( LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT );
					dxDrawRoundedRectangle( posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10  * RELATIVE_MULT_Y, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.8, 32 * RELATIVE_MULT_Y, 100, tocolor(33, 33, 33, 150) );
					dxDrawText( tostring(formatTime("d.m.Y h:i", false, goalInfo.Timestamp)), posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y - height ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.9, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y + height ) / 2,
							tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top");
				end
				
				dxDrawText( "Likes: " .. tostring(goalInfo.Likes), posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT - LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT + LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2, 
					tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "bottom", true, false, false, false, true);
			end
		end

		posX = posX + LOBBY_ARENA_LIST_ITEM_WIDTH + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
		xCounter = xCounter + 1;
		if (xCounter > LOBBY_ARENA_LIST_ITEMS_PER_LINE) then
			posY = posY + LOBBY_ARENA_LIST_ITEM_HEIGHT + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
			posX = LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
			xCounter = 1;
			if (posY >= LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) then
				break;
			end
		end
	end
	
	local scrollHeight = LOBBY_MAIN_WINDOW_HEIGHT + maxHeight;
	local scrollBarHeight = LOBBY_MAIN_WINDOW_HEIGHT / scrollHeight * ( LOBBY_MAIN_WINDOW_HEIGHT - 6 );
	local scrollOffset = gScrollCounter / scrollHeight * ( LOBBY_MAIN_WINDOW_HEIGHT - 6 );
	
	if (maxHeight > 0) then
		dxDrawRoundedRectangle(LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH - ( LOBBY_SPACE_BETWEEN_ARENA_ITEMS + 16 ) / 2, LOBBY_MAIN_WINDOW_POS_Y, 16, LOBBY_MAIN_WINDOW_HEIGHT, 100, tocolor(0, 0, 0, 155) );
		dxDrawRoundedRectangle(LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH - ( LOBBY_SPACE_BETWEEN_ARENA_ITEMS + 16 ) / 2 + 3, LOBBY_MAIN_WINDOW_POS_Y + 3 + scrollOffset, 10, scrollBarHeight, 100, tocolor(255, 137, 0, 155) );
	end
end

--- Manage Team Screen ---

function Screen.Draw.ManageTeam()
	dxDrawText("Coming soon!", LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y * 1.05, LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT,
							tocolor(20, 20, 255, 200), LOBBY_MAIN_MENU_BUTTON_FONT_SIZE * 10, LOBBY_MAIN_NORMAL_FONT, "center", "center");
end

--- Arena List & Password Screen ---

function confirmArenaPassword()
	local pwBox = getData(Screen.PASSWORD, "PasswordBox");
	triggerServerEvent("onPlayerArenaJoinRequest", localPlayer, getData(localPlayer, "Client.PasswordPromptArena"), EditField.getText(pwBox));
	Screen.switchTo(Screen.ARENAS);
end

--[[bindKey("enter", "down",
	function ()
		if (gCurrentScreen == Screen.PASSWORD) then
			confirmArenaPassword();
		end
	end
);]]

addEventHandler("onClientGUIAccepted", root,
	function (editbox)
		if (editbox == getData(Screen.PASSWORD, "PasswordBox")) then
			confirmArenaPassword();
		end
	end
);

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		resetLobby();
		--Screen.switchTo(Screen.ARENAS);
	end
);

addEventHandler("onClientClick", root,
	function (button, state)
		if (getCurrentArena() ~= LOBBY_ARENA or isUserPanelActive()) then
			return;
		end
		if (button == "left" and state == "down") then
			local arena = getData(localPlayer, "Client.SelectedArena");
			if (isValid(arena)) then
				if (Arena.getOption(arena, "Password")) then
					setData(localPlayer, "Client.PasswordPromptArena", arena);
					Screen.switchTo(Screen.PASSWORD);
				else
					triggerServerEvent("onPlayerArenaJoinRequest", localPlayer, arena);
					Screen.switchTo(Screen.ARENAS);
				end
				playSound("data/audio/buttonSelect.mp3");
			end
		end
	end
);

function Screen.Draw.ArenaList()
	local lastSelectedArena = getData(localPlayer, "Client.SelectedArena");
	setData(localPlayer, "Client.SelectedArena", false);
	
	local arenas = table.lfilter(getElementsByType(ARENA_ELEMENT_TYPE), function (arena) return (Arena.getMode(arena) ~= "Replay"); end);
	Screen.INFO_ARENACOUNT = #arenas;
	
	local lineAmount = math.ceil((#arenas)/LOBBY_ARENA_LIST_ITEMS_PER_LINE);

	local maxHeight = math.max(0, lineAmount * LOBBY_ARENA_LIST_ITEM_SPACE_Y - LOBBY_MAIN_WINDOW_HEIGHT - LOBBY_SPACE_BETWEEN_ARENA_ITEMS);

	if (isCursorIn(LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT)) then
		gScrollSpeed = gScrollSpeed - SCROLL_ACCLERATION;
	elseif (isCursorIn(LOBBY_MAIN_WINDOW_POS_X, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y, 
						LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y + LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT)) then
		gScrollSpeed = gScrollSpeed + SCROLL_ACCLERATION;
	else
		gScrollSpeed = gScrollSpeed * SCROLL_DECELERATION;
	end

	--counter = counter + (math.sin(getTickCount()/200)*5+5) * (down and 1 or -1);
	gScrollCounter = gScrollCounter + gScrollSpeed;
	if (gScrollCounter < 0 or gScrollCounter > maxHeight) then 
		addToDebug("clamping o.ô: "..tostring(maxHeight));
		gScrollCounter = math.clamp(gScrollCounter, 0, maxHeight);
		gScrollSpeed = 0;
	end
	addToDebug("Scroll: "..tostring(gScrollCounter));
	--[[dxDrawText("lineAmount "..tostring(lineAmount), 0, 0, gScreenSizeX, gScreenSizeY * 0.5, 
				tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "top");
	dxDrawText("counter "..tostring(counter), 0, gScreenSizeY * 0.1, gScreenSizeX, gScreenSizeY, 
				tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "top");]]

	local posX = LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
	local posY = LOBBY_MAIN_WINDOW_POS_Y - gScrollCounter;
	local xCounter = 1;
	
	for _, arena in ipairs(arenas) do
		local options = getData(arena, "Options");
		if (options) then
			--outputDebugString("options.Stadium: "..tostring(options.Stadium).." stadium: "..tostring(getData(options.Stadium, "FileName")));
			local firstHeight = posY + LOBBY_ARENA_LIST_ITEM_HEIGHT - LOBBY_MAIN_WINDOW_POS_Y;
			if (firstHeight > 0) then
				if (firstHeight >= LOBBY_ARENA_LIST_ITEM_HEIGHT) then
					local drawableHeight = (LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) - posY;
					local drawHeight = math.min(LOBBY_ARENA_LIST_ITEM_HEIGHT, drawableHeight);
					--dxDrawRectangle(posX, posY, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, tocolor(100, 100, 100, 100), false);
					local selected = not getData(localPlayer, "Client.SelectedArena") and isCursorIn(posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + drawHeight);
					if (selected) then 
						setData(localPlayer, "Client.SelectedArena", arena);
						if (not lastSelectedArena and not isUserPanelActive()) then
							playSound("data/audio/buttonHover.mp3");
						end
					end
					--dxDrawBorderedImageSection(1, tocolor(0, 0, 0, selected and 255 or 100), posX, posY, LOBBY_ARENA_LIST_ITEM_WIDTH, drawHeight,
					--					0, 0, 500, 321 * drawHeight / LOBBY_ARENA_LIST_ITEM_HEIGHT,
					--					"data/images/"..tostring(getData(options.Stadium, "FileName"))..".jpg", 0, 0, 0, 
					--					tocolor(255, 255, 255, selected and 255 or 100));
										
					dxDrawRoundedImage(posX, posY, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, "data/images/"..tostring(getData(options.Stadium, "FileName"))..".jpg", selected and 255 or 150, drawHeight)
					
					if (options.Password) then
						dxDrawImageSection( posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY, - LOBBY_ARENA_LOCK_SIZE, math.min( drawHeight, LOBBY_ARENA_LOCK_SIZE ), 0, 0, 72, math.min( drawHeight, LOBBY_ARENA_LOCK_SIZE ) / LOBBY_ARENA_LOCK_SIZE * 72,
											"data/images/password.png", 0, 0, 0, tocolor(255, 255, 255, selected and 255 or 155) );
					end
					
					local title = Arena.getName(arena):upper();
					
					local titleSize = math.min(1, getFontSizeFittingWidth( title, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.95, LOBBY_ARENA_BLACK_FONT ));
					local titleHeight = dxGetFontHeight( titleSize, LOBBY_ARENA_BLACK_FONT );
					
					dxDrawText(title, posX, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - titleHeight ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + titleHeight ) / 2 ), 
							tocolor(255, 255, 255, selected and 255 or 200), titleSize, LOBBY_ARENA_BLACK_FONT, "center", "top", true, false, false, false, true);
					
					local hoster = Arena.getOption(arena, "CreatorName");
					if (hoster) then
						hoster = "Host: " .. hoster;
						hoster = hoster:upper();
						
						local hosterSize = math.min(1, getFontSizeFittingWidth( hoster, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.6, LOBBY_ARENA_BLACK_FONT ));
						local hosterHeight = dxGetFontHeight( hosterSize, LOBBY_ARENA_BLACK_FONT );
						
						dxDrawText(hoster, posX, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - hosterHeight ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + hosterHeight ) / 2 ), 
							tocolor(255, 137, 0, selected and 255 or 200), hosterSize, LOBBY_ARENA_BLACK_FONT, "center", "top", true, false, false, false, true);
	
					end
					
					local scoreStr = "Score: ";
					local slots = 0;
					--local players = 0;
					for id, matchTeam in ipairs(getElementsByType("matchteam", arena)) do
						slots = slots + MatchTeam.getSize(matchTeam);
						--players = players + MatchTeam.getPlayerAmount(matchTeam);
						scoreStr = scoreStr .. getData(matchTeam, "Score") .. " : ";
					end
					local players = #(table.lfilter(getElementsByType("player", arena), function (element) return (Player.getMatchTeam(element)); end));
					scoreStr = scoreStr:sub(1, #scoreStr-3);
					
					dxDrawText( "Players: " .. players .. (slots > 0 and (" / " .. slots) or ""), posX, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT - LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, math.min( posY + drawableHeight, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT + LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2 ), 
						tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top", true, false, false, false, true);
					
					if (Arena.getMode(arena) == "Match") then
						if (drawableHeight >= 42 * RELATIVE_MULT_Y) then
							local text = selected and ("Ping limit: " .. options.PingLimit .. "ms") or scoreStr;
							local height = dxGetFontHeight( LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT );
							dxDrawRoundedRectangle( posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10  * RELATIVE_MULT_Y, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.8, math.floor( 32 * RELATIVE_MULT_Y ), 100, tocolor(0, 0, 0, selected and 255 or 150) );
							dxDrawText( text, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y - height ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.9, math.min( posY + drawableHeight, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y + height ) / 2),
									tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top");
						end
					end
					
					--dxDrawText(info, posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + height, 
					--		tocolor(255, 255, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false, false, false, true);
					--[[if (posY + LOBBY_ARENA_ITEM_HEADLINE_RECTANGLE_HEIGHT < LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) then
						dxDrawText("Arena "..tostring(getData(arena, "ID")), posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + LOBBY_ARENA_ITEM_HEADLINE_RECTANGLE_HEIGHT, 
									tocolor(0, 50, 255, 200), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center");
					end]]
				else
					local selected = not getData(localPlayer, "Client.SelectedArena") and isCursorIn(posX, posY, posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + firstHeight);
					if (selected) then 
						setData(localPlayer, "Client.SelectedArena", arena);
						if (not lastSelectedArena and not isUserPanelActive()) then
							playSound("data/audio/buttonHover.mp3");
						end
					end
					
					dxDrawRoundedImage(posX, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_ARENA_LIST_ITEM_HEIGHT, "data/images/"..tostring(getData(options.Stadium, "FileName"))..".jpg", selected and 255 or 150, firstHeight, true)

					local clipped = LOBBY_ARENA_LIST_ITEM_HEIGHT - firstHeight;
					local clipped_rel = clipped / LOBBY_ARENA_LOCK_SIZE;
					
					if (options.Password) then
						dxDrawImageSection( posX + LOBBY_ARENA_LIST_ITEM_WIDTH, LOBBY_MAIN_WINDOW_POS_Y, - LOBBY_ARENA_LOCK_SIZE, math.max( 0, LOBBY_ARENA_LOCK_SIZE - clipped ), 0, clipped_rel * 72, 72, ( 1 - clipped_rel ) * 72,
											"data/images/password.png", 0, 0, 0, tocolor(255, 255, 255, selected and 255 or 155) );
					end
					
					local title = Arena.getName(arena):upper();
					local titleSize = math.min(1, getFontSizeFittingWidth( title, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.95, LOBBY_ARENA_BLACK_FONT ));
					local titleHeight = dxGetFontHeight( titleSize, LOBBY_ARENA_BLACK_FONT );
					
					dxDrawText(title, posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - titleHeight ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + ( LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + titleHeight ) / 2, 
							tocolor(255, 255, 255, selected and 255 or 200), titleSize, LOBBY_ARENA_BLACK_FONT, "center", "bottom", true, false, false, false, true);
					
					local hoster = Arena.getOption(arena, "CreatorName");
					if (hoster) then
						hoster = "Host: " .. hoster;
						hoster = hoster:upper();
						
						local hosterSize = math.min(1, getFontSizeFittingWidth( hoster, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.6, LOBBY_ARENA_BLACK_FONT ));
						local hosterHeight = dxGetFontHeight( hosterSize, LOBBY_ARENA_BLACK_FONT );
						
						dxDrawText(hoster, posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 - hosterHeight ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + ( titleHeight * 1.5 + LOBBY_ARENA_LIST_ITEM_HEIGHT * 0.82 + hosterHeight ) / 2, 
							tocolor(255, 137, 0, selected and 255 or 200), hosterSize, LOBBY_ARENA_BLACK_FONT, "center", "bottom", true, false, false, false, true);
	
					end
					
					local scoreStr = "Score: ";
					local slots = 0;
					local players = 0;
					for id, matchTeam in ipairs(getElementsByType("matchteam", arena)) do
						slots = slots + MatchTeam.getSize(matchTeam);
						players = players + MatchTeam.getPlayerAmount(matchTeam);
						scoreStr = scoreStr .. getData(matchTeam, "Score") .. " : ";
					end
					scoreStr = scoreStr:sub(1, #scoreStr-3);
					
					dxDrawText( "Players: " .. players .. (slots > 0 and (" / " .. slots) or ""), posX, math.max( LOBBY_MAIN_WINDOW_POS_Y, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT - LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2 ), posX + LOBBY_ARENA_LIST_ITEM_WIDTH, posY + LOBBY_ARENA_LIST_ITEM_BODY_HEIGHT + ( LOBBY_ARENA_LIST_ITEM_PLAYERINFO_HEIGHT + LOBBY_ARENA_ITEM_INFO_FONT_HEIGHT ) / 2, 
						tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "bottom", true, false, false, false, true);
					
					if (Arena.getMode(arena) == "Match") then
						if (clipped <= 10 * RELATIVE_MULT_Y) then
							local text = selected and ("Ping limit: " .. options.PingLimit .. "ms") or scoreStr;
							local height = dxGetFontHeight( LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT );
							dxDrawRoundedRectangle( posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10  * RELATIVE_MULT_Y, LOBBY_ARENA_LIST_ITEM_WIDTH * 0.8, math.floor( 32 * RELATIVE_MULT_Y ), 100, tocolor(0, 0, 0, selected and 255 or 150) );
							dxDrawText( text, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.1, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y - height ) / 2, posX + LOBBY_ARENA_LIST_ITEM_WIDTH * 0.9, posY + 10 * RELATIVE_MULT_Y + ( 32 * RELATIVE_MULT_Y + height ) / 2,
									tocolor(255, 255, 255, selected and 255 or 200), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.65, LOBBY_ARENA_ITEM_INFO_FONT, "center", "top");
						end
					end
				end
			end
	
			posX = posX + LOBBY_ARENA_LIST_ITEM_WIDTH + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
			xCounter = xCounter + 1;
			if (xCounter > LOBBY_ARENA_LIST_ITEMS_PER_LINE) then
				posY = posY + LOBBY_ARENA_LIST_ITEM_HEIGHT + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
				posX = LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
				xCounter = 1;
				if (posY >= LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT) then
					break;
				end
			end
		end
	end
	
	
	--[[if (gScrollSpeed > 0.02) then
		dxDrawImageSection(LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y, LOBBY_MAIN_WINDOW_WIDTH - LOBBY_SPACE_BETWEEN_ARENA_ITEMS * 2, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, 1, 1, 127, 127,
					"data/images/scroll-shadow.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		--dxDrawImage(LOBBY_MAIN_WINDOW_POS_X, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y, LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, 
		--			"data/images/arrowdown.png", 0, 0, 0, tocolor(255, 255, 255, math.min(gScrollSpeed * 100, 100)));
		--dxDrawRectangle(LOBBY_MAIN_WINDOW_POS_X, LOBBY_ARENA_LIST_SCROLL_DOWN_POS_Y, LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, tocolor(255, 50, 0, 50), false);
	elseif (gScrollSpeed < -0.02) then
		dxDrawImageSection(LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_WINDOW_WIDTH - LOBBY_SPACE_BETWEEN_ARENA_ITEMS * 2, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, 4, 4, 124, 124,
					"data/images/scroll-shadow.png", 180, 0, 0, tocolor(255, 255, 255, 255))
		--dxDrawImage(LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, 
		--			"data/images/arrowup.png", 0, 0, 0, tocolor(255, 255, 255, math.min(gScrollSpeed * -100, 100)));
		--dxDrawRectangle(LOBBY_MAIN_WINDOW_POS_X, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_WINDOW_WIDTH, LOBBY_ARENA_LIST_SCROLL_BOX_HEIGHT, tocolor(50, 255, 0, 50), false);
	end
	]]
	
	local scrollHeight = LOBBY_MAIN_WINDOW_HEIGHT + maxHeight;
	local scrollBarHeight = LOBBY_MAIN_WINDOW_HEIGHT / scrollHeight * ( LOBBY_MAIN_WINDOW_HEIGHT - 6 );
	local scrollOffset = gScrollCounter / scrollHeight * ( LOBBY_MAIN_WINDOW_HEIGHT - 6 );
	
	if (maxHeight > 0) then
		dxDrawRoundedRectangle(LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH - ( LOBBY_SPACE_BETWEEN_ARENA_ITEMS + 16 ) / 2, LOBBY_MAIN_WINDOW_POS_Y, 16, LOBBY_MAIN_WINDOW_HEIGHT, 100, tocolor(0, 0, 0, 155) );
		dxDrawRoundedRectangle(LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH - ( LOBBY_SPACE_BETWEEN_ARENA_ITEMS + 16 ) / 2 + 3, LOBBY_MAIN_WINDOW_POS_Y + 3 + scrollOffset, 10, scrollBarHeight, 100, tocolor(255, 137, 0, 155) );
	end
end

bindKey("mouse_wheel_up", "both",
	function()
		local arena = getCurrentArena();
		if (arena == LOBBY_ARENA) then
			local SCROLL_ACCLERATION = SCROLL_ACCLERATION * 3;
			gScrollSpeed = gScrollSpeed - SCROLL_ACCLERATION * 10;
		end
	end
)

bindKey("mouse_wheel_down", "both",
	function()
		local arena = getCurrentArena();
		if (arena == LOBBY_ARENA) then
			local SCROLL_ACCLERATION = SCROLL_ACCLERATION * 3;
			gScrollSpeed = gScrollSpeed + SCROLL_ACCLERATION * 10;
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

