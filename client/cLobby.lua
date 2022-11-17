
--[[----Class-Main----||--

	Description:
		Controls the visual and interactive-behaviour of the lobby

--||------------------]]--
gMenuFontSize = 1 + 1.5 / 1080 * gScreenSizeY;
gMenuLoadingFontSize = gMenuFontSize * 100;
gMenuFont = "arial";--dxCreateFont("data/fonts/proevo5.ttf", gMenuLoadingFontSize, false);

gHeadlineFontSize = 1.0 + 1.5 / 1080 * gScreenSizeY;
gHeadlineLoadingFontSize = gMenuFontSize * 100;
gHeadlineFont = "arial";--dxCreateFont("data/fonts/mexcellent.ttf", gHeadlineLoadingFontSize, false);

SPACE_BETWEEN_MAIN_WINDOW = gScreenSizeX * 0.002;

LOBBY_MESSAGE_WINDOW_POS_X = gScreenSizeX * 0.75 + SPACE_BETWEEN_MAIN_WINDOW;
LOBBY_MESSAGE_WINDOW_POS_Y = gScreenSizeY * 0.25;
LOBBY_MESSAGE_WINDOW_WIDTH = gScreenSizeX * 0.25;
LOBBY_MESSAGE_WINDOW_HEIGHT = gScreenSizeY * 0.25 - SPACE_BETWEEN_MAIN_WINDOW;

LOBBY_EXTRA_WINDOW_POS_X = LOBBY_MESSAGE_WINDOW_POS_X;
LOBBY_EXTRA_WINDOW_POS_Y = LOBBY_MESSAGE_WINDOW_POS_Y + LOBBY_MESSAGE_WINDOW_HEIGHT + SPACE_BETWEEN_MAIN_WINDOW * 2;
LOBBY_EXTRA_WINDOW_WIDTH = gScreenSizeX * 0.25;
LOBBY_EXTRA_WINDOW_HEIGHT = LOBBY_MESSAGE_WINDOW_HEIGHT;

LOBBY_CAMERA_SWING_AMOUNT = 100;
LOBBY_CAMERA_SWING_SPEED_X = LOBBY_CAMERA_SWING_AMOUNT / 17 * 1000;
LOBBY_CAMERA_SWING_SPEED_Y = LOBBY_CAMERA_SWING_AMOUNT / 23 * 1000;
LOBBY_BACKGROUND_POS_Y = gScreenSizeY * 0.23;
LOBBY_BACKGROUND_HEIGHT = gScreenSizeY * 0.54;

LOBBY_MAIN_MENU_BUTTONS = { "Arenas" , "Top Goals", "New Goals" }; --, "Options"
LOBBY_MAIN_MENU_POS_X = gScreenSizeX * 0.0 + LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
LOBBY_MAIN_MENU_POS_Y = LOBBY_MAIN_WINDOW_POS_Y;
LOBBY_MAIN_MENU_WIDTH = gScreenSizeX * 0.2 - LOBBY_SPACE_BETWEEN_ARENA_ITEMS;
LOBBY_MAIN_MENU_BUTTON_HEIGHT = gScreenSizeY * 0.077;
LOBBY_MAIN_MENU_HEIGHT = LOBBY_MAIN_MENU_BUTTON_HEIGHT * #LOBBY_MAIN_MENU_BUTTONS;
LOBBY_SPACE_FROM_EDGE = 0;
LOBBY_MAIN_MENU_BUTTON_WIDTH = LOBBY_MAIN_MENU_WIDTH - LOBBY_SPACE_FROM_EDGE*2;
LOBBY_MAIN_MENU_BUTTON_DRAW_HEIGHT = LOBBY_MAIN_MENU_BUTTON_HEIGHT - math.floor( 4 * RELATIVE_MULT_Y );
LOBBY_MAIN_MENU_BUTTON_POS_X = LOBBY_MAIN_MENU_POS_X + (LOBBY_MAIN_MENU_WIDTH - LOBBY_MAIN_MENU_BUTTON_WIDTH)/2
LOBBY_MAIN_MENU_BUTTON_FONT = gMenuFont;
LOBBY_MAIN_MENU_BUTTON_FONT_SIZE = gMenuFontSize;

gScrollCounter = 0;
gScrollSpeed = 0;

gWeatherToString = { [0] = "Normal", [17] = "Sunny", [16] = "Rainy", [9] = "Foggy" }

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--g
	
	
--||--------------------]]--
addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		showChat(false);
		showCursor(true);
		
		-- create virtual screens for attaching/detaching
		--Screen.WELCOME = Screen.create("Welcome", false, false, Screen.Draw.Welcome);
		Screen.ARENAS = Screen.create("Arenas", false, function () setData(localPlayer, "Client.SelectedArena", false); end, Screen.Draw.ArenaList);
		Screen.CREATE_ARENA = Screen.create("Create Arena", createArenaCreationMenu, false, false);
		--Screen.MANAGE_TEAM = Screen.create("Manage Team", false, false, Screen.Draw.ManageTeam);
		Screen.TOP_GOALS = Screen.create("Top Goals", sortTopGoals, function () setData(localPlayer, "Client.SelectedGoal", false); end, Screen.Draw.TopGoals);
		Screen.NEW_GOALS = Screen.create("New Goals", sortNewGoals, function () setData(localPlayer, "Client.SelectedGoal", false); end, Screen.Draw.TopGoals);
		Screen.OPTIONS = Screen.create("Options", createOptionsMenu, function () setData(localPlayer, "Client.SelectedArena", false); end, false);
		--Screen.HELP = Screen.create("Help", false, false, Screen.Draw.Welcome);
		Screen.PASSWORD = Screen.create("Password", createPasswordMenu, false, false);
		
		
		
		-- create buttons
		local menuPosY = LOBBY_MAIN_MENU_POS_Y;
		for id, name in ipairs(LOBBY_MAIN_MENU_BUTTONS) do
			local borderRadius = ( ( id == 1 ) and {12, 0, 12, 0} ) or ( id == #LOBBY_MAIN_MENU_BUTTONS and {0, 12, 0, 12} or 0 );
			
			local btn = Button.create(name, LOBBY_MAIN_MENU_BUTTON_POS_X, menuPosY, 
							LOBBY_MAIN_MENU_BUTTON_WIDTH, LOBBY_MAIN_MENU_BUTTON_DRAW_HEIGHT, 
							function (item, menu)
								Screen.switchTo(Screen.getFromName(menu));
							end, { name }, false, borderRadius);
			menuPosY = menuPosY + LOBBY_MAIN_MENU_BUTTON_HEIGHT;
			
			if name == "Arenas" then
				Screen.BTN_ARENAS = btn;
				setData(Screen.BTN_ARENAS, "Active", true);
			end
		end
		
		
		if (true or DEBUG) then
		Button.create('+Create Arena', LOBBY_MAIN_WINDOW_POS_X + LOBBY_SPACE_BETWEEN_ARENA_ITEMS, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015, LOBBY_MAIN_WINDOW_WIDTH - LOBBY_SPACE_BETWEEN_ARENA_ITEMS * 2, gScreenSizeY*0.05,
						function ()
							Screen.switchTo(Screen.CREATE_ARENA)
						end, false, {r=255,g=137,b=0}, 100);
		end
		-- set the welcome screen as current
		Screen.switchTo(Screen.ARENAS);
	end
);

function createPasswordMenu()
	if (not getData(Screen.PASSWORD, "INITIALIZED")) then
		local msx, msy = LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH * 0.25, 
						 LOBBY_MAIN_WINDOW_POS_Y +  LOBBY_MAIN_WINDOW_HEIGHT * 0.35;
		local mswidth, msheight = LOBBY_MAIN_WINDOW_WIDTH * 0.5, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
						
		local passwordBox = EditField.create(msx, msy, mswidth, msheight, "", "Enter Arena Password:");
		local tx, ty = msx, msy + LOBBY_MAIN_WINDOW_HEIGHT * 0.5;
		local twidth, theight = LOBBY_MAIN_WINDOW_WIDTH * 0.2, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		
		local spectateButton = Button.create("Spectate", tx, ty - theight * 1.5, twidth * 2 + LOBBY_MAIN_WINDOW_WIDTH * 0.1, theight, 
				function ()
					triggerServerEvent("onPlayerArenaJoinRequest", localPlayer, getData(localPlayer, "Client.PasswordPromptArena"), "", true);
					Screen.switchTo(Screen.ARENAS);
				end);
		local backButton = Button.create("Back", tx, ty, twidth, theight,
											function ()
												local pwBox = getData(Screen.PASSWORD, "PasswordBox");
												Screen.switchTo(Screen.ARENAS);
											end);
		tx = tx + twidth + LOBBY_MAIN_WINDOW_WIDTH * 0.1;
		local enterButton = Button.create("Enter", tx, ty, twidth, theight, confirmArenaPassword);
		local screen = Screen.getFromName("Password");
		setData(screen, "PasswordBox", passwordBox);
		Screen.attachItem(screen, passwordBox);
		Screen.attachItem(screen, backButton);
		Screen.attachItem(screen, enterButton);
		Screen.attachItem(screen, spectateButton);
		Screen.PASSWORD = screen;
		setData(Screen.PASSWORD, "INITIALIZED", true);
	end
	local pwBox = getData(Screen.PASSWORD, "PasswordBox");
	EditField.setText(pwBox, "");
end

function createOptionsMenu()
	if (not getData(Screen.OPTIONS, "INITIALIZED")) then
		local edgeSpace = LOBBY_MAIN_WINDOW_WIDTH * 0.05;
	
		local vx, vy = LOBBY_MAIN_WINDOW_POS_X + edgeSpace, LOBBY_MAIN_WINDOW_POS_Y + edgeSpace;
		local vwidth, vheight = LOBBY_MAIN_WINDOW_WIDTH * 0.25, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		local volume = TurningSelection.create(vx, vy, vwidth, vheight, 
							{ 10, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
							
								local draw = "";
								local left = 10;
								for i = 1, selected, 1 do
									local r, g = getRedGreenColor(i-1, 9, true);
									draw = draw .. string.format("#%.2x%.2x%.2x", r, g, 0) .. "|";
									left = left - 1;
								end
							
								draw = draw .. "#AAAAAA";
							
								for i = 1, left, 1 do
									draw = draw .. "|";
								end
							
								dxDrawText(draw, x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE * 1.2, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false, false, true);
							end, "Sound Volume",
								function (item, selected)
									triggerEvent("onClientOptionChange", root, "Volume", selected);
									gOptions.Volume = selected;
								end,
								(gOptions.Volume or 10)
							);
		local mvx, mvy = vx, vy + vheight + edgeSpace;
		local mvwidth, mvheight = vwidth, vheight;
		local musicVolume = TurningSelection.create(mvx, mvy, mvwidth, mvheight, 
							{ 10, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
							
								local draw = "";
								local left = 10;
								for i = 1, selected, 1 do
									local r, g = getRedGreenColor(i-1, 9, true);
									draw = draw .. string.format("#%.2x%.2x%.2x", r, g, 0) .. "|";
									left = left - 1;
								end
							
								draw = draw .. "#AAAAAA";
							
								for i = 1, left, 1 do
									draw = draw .. "|";
								end
							
								dxDrawText(draw, x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE * 1.2, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false, false, true);
							end, "Music Volume",
								function (item, selected)
									triggerEvent("onClientOptionChange", root, "MusicVolume", selected);
									gOptions.MusicVolume = selected;
								end,
								(gOptions.MusicVolume or 10)
							);
		local screen = Screen.getFromName("Options");
		Screen.attachItem(screen, volume);
		Screen.attachItem(screen, musicVolume);
		
		Screen.OPTIONS = screen;
		setData(Screen.OPTIONS, "INITIALIZED", true);
	end
end

EDGE_SPACE = LOBBY_MAIN_WINDOW_WIDTH * 0.04;

function createArenaCreationMenu()
	if (not getData(Screen.CREATE_ARENA, "INITIALIZED")) then
		-- stadium selection
		
		local edgeSpace = EDGE_SPACE;
		
		local x, y = LOBBY_MAIN_WINDOW_POS_X + edgeSpace, LOBBY_MAIN_WINDOW_POS_Y + edgeSpace;
		local width, height = LOBBY_MAIN_WINDOW_WIDTH * 0.25, LOBBY_MAIN_WINDOW_WIDTH * 0.20;
		
		local stadiumSel = TurningSelection.create(x, y, width, height,
							getElementsByType("stadium"), 
							function (item, x, y, width, height, stadium)
								dxDrawBorderedImage(1, tocolor(0, 0, 0), x, y, width, height, "data/images/"..tostring(getData(stadium, "FileName"))..".jpg", 0, 0, 0, tocolor(255, 255, 255));
								dxDrawBorderedText(gRelativeMultY * 0.3, tocolor(0, 0, 0), tostring(getData(stadium, "Name")), x, y, x + width, y + height/2,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", false, true);
							end, "Stadium", 
							function (item, stadium)
								recreateTeamSizeSelection(Stadium.getTeamAmount(stadium));
							end, Stadium.getFromName("stadium-ffs")
							);
							
		local msx, msy = x, y + height + edgeSpace;
		local mswidth, msheight = width, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
							
		local modeSel = TurningSelection.create(msx, msy, mswidth, msheight,
							{ "Match", "Training" }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", false, true);
							end, "Mode",
							function (item, selected)
								local match = (selected == "Match");
								local screen = Screen.CREATE_ARENA;
								for _, sel in ipairs(getData(Screen.CREATE_ARENA, "TeamSizeSel")) do
									ClickableItem.setVisible(sel, match);
								end
								ClickableItem.setVisible(getData(screen, "GUI.MatchLengthSel"), match);
								ClickableItem.setVisible(getData(screen, "GUI.PingLimitSel"), match);
								ClickableItem.setVisible(getData(screen, "GUI.Team1"), match);
								ClickableItem.setVisible(getData(screen, "GUI.Team2"), match);
							end
							);
							
		local tx, ty = x + width + edgeSpace, y;
		local twidth, theight = LOBBY_MAIN_WINDOW_WIDTH * 0.2, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		local team1 = EditField.create(tx, ty, twidth, theight, "Team1", "Team 1 Name");
		tx = tx + twidth + edgeSpace;
		local team2 = EditField.create(tx, ty, twidth, theight, "Team2", "Team 2 Name");
		
		Team2Sel = team2;
		Team1Sel = team1;
		--[[local team1 = Button.create("Team 1", tx, ty, twidth, theight,
											function ()
												--outputChatBox("Team 1");
											end);
		tx = tx + twidth + edgeSpace;
		local team2 = Button.create("Team 2", tx, ty, twidth, theight,
											function ()
												--outputChatBox("Team 2");
											end);]]
		local tsx, tsy = x + width + edgeSpace, ty + theight + edgeSpace;
		local tswidth, tsheight = (LOBBY_MAIN_WINDOW_WIDTH * 0.2), theight;
		local tsonex = tsx;
		local tssepwidth = (tswidth - edgeSpace) / 2;
		
		recreateTeamSizeSelection(2);
		--[[local teamSizeSel = TurningSelection.create(tsx, tsy, tswidth, tsheight, 
							{ 1, 2, 3, 4, 5, 11 }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(gRelativeMultY, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected).." vs. "..tostring(selected), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "TeamSize"
							);]]
							
		local plx, ply = tsx + tswidth + edgeSpace, ty + theight + edgeSpace;
		local plwidth, plheight = (LOBBY_MAIN_WINDOW_WIDTH * 0.2), theight;
		local pingLimitSel = TurningSelection.create(plx, ply, plwidth, plheight, 
							{ 150, 200, 300, 500, "Unlimited", 50, 100 }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Ping Limit"
							);
							
		local mlx, mly = tsx, tsy + tsheight + edgeSpace;
		local mlwidth, mlheight = twidth, theight;
		local matchLengthSel = TurningSelection.create(mlx, mly, mlwidth, mlheight, 
							{ 15, 30, 60, 90, 120, 1, 3, 5, 9, }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected).." Minute"..((selected == 1) and "" or "s"), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Match Length"
							);
		local pwx, pwy = tsx + tswidth + edgeSpace, tsy + tsheight + edgeSpace;
		local pwwidth, pwheight = (LOBBY_MAIN_WINDOW_WIDTH * 0.2), theight;
		passwordBox = EditField.create(pwx, pwy, pwwidth, pwheight, "", "Password");
		
		local tix, tiy = mlx, mly + tsheight + edgeSpace;
		local tiwidth, tiheight = mlwidth, mlheight;
		local dayTimeSel = TurningSelection.create(tix, tiy, tiwidth, tiheight,
							{ 8, 14, 21, 1 }, 
							function (item, x, y, width, height, selected)
								local pTimeToString = { [14] = "Midday", [21] = "Evening", [1] = "Night", [8] = "Morning" }
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(pTimeToString[selected]), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Day Time"
							);
		
		local colx, coly = pwx, tiy;
		local colwidth, colheight = (LOBBY_MAIN_WINDOW_WIDTH * 0.2), theight;
		
		local vehicleSel = TurningSelection.create(colx, coly, colwidth, colheight,
							{ "Sandking", "Dune", "Dumper", "Monster", "Infernus", }, 
							function (item, x, y, width, height, selected)
								dxDrawRectangle(x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Vehicle"
							);
		--[[local collisionSel = TurningSelection.create(colx, coly, colwidth, colheight,
							{ "Enemy", "Off", "On", "Damage", "Enemy Damage" }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(gRelativeMultY, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(selected), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Collision"
							);]]
		
		local wex, wey = tix, tiy + tiheight + edgeSpace;
		local wewidth, weheight = mlwidth, mlheight;
		local weatherSel = TurningSelection.create(wex, wey, wewidth, weheight, 
							{ 0, 17, 16, 9 }, 
							function (item, x, y, width, height, selected)
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(tostring(gWeatherToString[selected]), x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "Weather"
							);
							
		local height = LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		local posY = LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT - height;
		local createButton = Button.create("Create Arena", LOBBY_MAIN_WINDOW_POS_X + LOBBY_MAIN_WINDOW_WIDTH / 4, posY,
											LOBBY_MAIN_WINDOW_WIDTH / 2, height,
											function ()
												local options = { };
												local screen = Screen.CREATE_ARENA;
												options.Mode = TurningSelection.getValue(getData(screen, "GUI.ModeSel"));
												options.Stadium = TurningSelection.getValue(getData(screen, "GUI.StadiumSel"));
												options.Teams = { };
												options.Teams[1] = { name = EditField.getText(getData(screen, "GUI.Team1")) };--TurningSelection.getValue(getData(screen, "GUI.Team1"));
												options.Teams[2] = { name = EditField.getText(getData(screen, "GUI.Team2")) };--TurningSelection.getValue(getData(screen, "GUI.Team2"));
												
												for id, sel in ipairs(getData(Screen.CREATE_ARENA, "TeamSizeSel")) do
													options.Teams[id].size = TurningSelection.getValue(sel);
													--table.insert(options.TeamSize, TurningSelection.getValue(sel));
												end
												options.MatchLength = TurningSelection.getValue(getData(screen, "GUI.MatchLengthSel")) * MINUTES;
												options.PingLimit = tonumber(TurningSelection.getValue(getData(screen, "GUI.PingLimitSel"))) or 100000;
												options.Password = EditField.getText(getData(screen, "GUI.Password"));
												options.DayTime = TurningSelection.getValue(getData(screen, "GUI.DayTimeSel"));
												options.Weather = TurningSelection.getValue(getData(screen, "GUI.WeatherSel"));
												options.Vehicle = TurningSelection.getValue(getData(screen, "GUI.VehicleSel"));
												--options.Collision = TurningSelection.getValue(getData(screen, "GUI.CollisionSel"));
												triggerServerEvent("onClientArenaCreationRequest", localPlayer, options);
											end);
		
		local screen = Screen.getFromName("Create Arena");
		setData(screen, "GUI.StadiumSel", stadiumSel);
		setData(screen, "GUI.ModeSel", modeSel);
		--setData(screen, "GUI.TeamSizeSel", teamSizeSel);
		setData(screen, "GUI.PingLimitSel", pingLimitSel);
		setData(screen, "GUI.MatchLengthSel", matchLengthSel);
		setData(screen, "GUI.Team1", team1);
		setData(screen, "GUI.Team2", team2);
		setData(screen, "GUI.Create", createButton);
		setData(screen, "GUI.Password", passwordBox);
		setData(screen, "GUI.DayTimeSel", dayTimeSel);
		setData(screen, "GUI.WeatherSel", weatherSel);
		setData(screen, "GUI.VehicleSel", vehicleSel);
		--setData(screen, "GUI.CollisionSel", collisionSel);
		
		Screen.attachItem(screen, stadiumSel);
		Screen.attachItem(screen, modeSel);
		Screen.attachItem(screen, pingLimitSel);
		Screen.attachItem(screen, matchLengthSel);
		Screen.attachItem(screen, team1);
		Screen.attachItem(screen, team2);
		Screen.attachItem(screen, createButton);
		Screen.attachItem(screen, passwordBox);
		Screen.attachItem(screen, dayTimeSel);
		Screen.attachItem(screen, weatherSel);
		Screen.attachItem(screen, vehicleSel);
		--Screen.attachItem(screen, collisionSel);
		Screen.CREATE_ARENA = screen;
		setData(Screen.CREATE_ARENA, "INITIALIZED", true);
	else
		guiSetText(getData(Team1Sel, "EF.Parent"), "Team1");
		guiSetText(getData(Team2Sel, "EF.Parent"), "Team2");
		guiSetText(getData(passwordBox, "EF.Parent"), "");
	end
end

function recreateTeamSizeSelection(size)
	if (size ~= gTeamSizeSelectionSize) then
		outputDebugString("Recreating Team Size Selection!");
		for _, sel in ipairs(getData(Screen.CREATE_ARENA, "TeamSizeSel") or { }) do
			destroyElement(sel);
		end
		local newSel = { };
		
		local x, y = LOBBY_MAIN_WINDOW_POS_X + EDGE_SPACE, LOBBY_MAIN_WINDOW_POS_Y + EDGE_SPACE;
		local twidth, theight = LOBBY_MAIN_WINDOW_WIDTH * 0.2, LOBBY_MAIN_WINDOW_HEIGHT * 0.1;
		local width, height = LOBBY_MAIN_WINDOW_WIDTH * 0.25, LOBBY_MAIN_WINDOW_WIDTH * 0.20;
		local tsx, tsy = x + width + EDGE_SPACE, y + theight + EDGE_SPACE;
		local tswidth, tsheight = (LOBBY_MAIN_WINDOW_WIDTH * 0.2), theight;
		local tsonex = tsx;
		local tssepwidth = (tswidth - EDGE_SPACE) / 2;
		
		local teamSizeSelOne = TurningSelection.create(tsonex, tsy, tssepwidth, tsheight, 
							{ 1, 2, 3, 4, 5, 11 }, 
							function (item, x, y, width, height, selected)
								local draw = "";
								local selections = getData(Screen.CREATE_ARENA, "TeamSizeSel");
								width = (width + EDGE_SPACE) * #selections - EDGE_SPACE;
								for _, sel in ipairs(selections) do
									draw = draw .. tostring(TurningSelection.getValue(sel)) .. " vs. ";
								end
								draw = draw:sub(1, #draw - 5);
								
								dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(100, 100, 100, 200), false);
								dxDrawText(draw, x, y, x + width, y + height,
											tocolor(200, 200, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true, false);
							end, "#1"
							);
		Screen.attachItem(Screen.CREATE_ARENA, teamSizeSelOne);
		table.insert(newSel, teamSizeSelOne);
		tsonex = tsonex + tssepwidth + EDGE_SPACE;	
		for i = 2, size, 1 do
			local sel = TurningSelection.create(tsonex, tsy, tssepwidth, tsheight, 
							{ 1, 2, 3, 4, 5, 11 }, 
							false, "#"..tostring(size)
							);
			table.insert(newSel, sel);
			Screen.attachItem(Screen.CREATE_ARENA, sel);
		end
		setData(Screen.CREATE_ARENA, "TeamSizeSel", newSel);
		gTeamSizeSelectionSize = size;
	end
end

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientArenaPlayerInit", resourceRoot,
	function ()
		showChat(true);
		setCameraTarget(localPlayer);
		setTimer(
			function ()
				fadeCamera(true, 5.0);
			end, 2000, 1
		);
		
		if (Arena.getMode(source) == "Match") then
			resetLobby(true);
			showTeamSelection();
		else
			showCursor(false);
		end
	end
);

addEventHandler("onClientArenaPlayerExit", resourceRoot,
	function ()
		showCursor(true);
		showChat(false);
		fadeCamera(false, 0.0);
		resetLobby(true);
	end
);

addEventHandler("onClientDeltaRender", root,
	function (delta)
		addToDebug("Rendering");
		local arena = getCurrentArena();
		if (arena == LOBBY_ARENA) then
			addToDebug("Rendering Lobby");
			triggerEvent("onClientLobbyRender", root, delta);
		elseif (isValid(arena)) then
			addToDebug("Rendering Game");
			triggerEvent("onClientGameRender", arena, delta);
		end
	end, true, "high+100"
);

addEventHandler("onClientLobbyRender", root,
	function ()
		local cursorX, cursorY = getCursorPosition();
		
		-- draw background image
		dxDrawImage(math.sin(getTickCount()/LOBBY_CAMERA_SWING_SPEED_X)*LOBBY_CAMERA_SWING_AMOUNT - LOBBY_CAMERA_SWING_AMOUNT, 
					math.sin(getTickCount()/LOBBY_CAMERA_SWING_SPEED_Y)*LOBBY_CAMERA_SWING_AMOUNT - LOBBY_CAMERA_SWING_AMOUNT, 
					gScreenSizeX + LOBBY_CAMERA_SWING_AMOUNT * 2, gScreenSizeY + LOBBY_CAMERA_SWING_AMOUNT * 2,
					"data/images/bg.jpg", 0, 0, 0, tocolor(255, 255, 255, 255), false);
		
		if (not isUserPanelActive()) then
			local logoWidth = math.floor( 1030 / 1920 * gScreenSizeX );
			local logoHeight = math.floor( logoWidth / 1030 * 116 );
			local logoPositionHeight = math.floor( logoWidth / 1030 * 94 );
			
			dxDrawImage( ( gScreenSizeX - logoWidth ) / 2, ( LOBBY_MAIN_WINDOW_POS_Y - logoPositionHeight ) / 2, logoWidth, logoHeight, "data/images/logo.png" ); 
			
			dxDrawRoundedRectangle( LOBBY_MAIN_MENU_POS_X, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015, LOBBY_MAIN_MENU_WIDTH, gScreenSizeY*0.05, 100, tocolor(33, 33, 33, 150));
			
			dxDrawText( "Players: " .. tostring( #getElementsByType("player") ), LOBBY_MAIN_MENU_POS_X, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015, LOBBY_MAIN_MENU_POS_X + LOBBY_MAIN_MENU_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015 + gScreenSizeY*0.05,
							tocolor(255, 255, 255, 255), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.7, LOBBY_ARENA_ITEM_INFO_FONT, "center", "center");
							
			
			
			dxDrawRoundedRectangle( LOBBY_MAIN_WINDOW_HIGH_POS_X, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015, LOBBY_MAIN_MENU_WIDTH, gScreenSizeY*0.05, 100, tocolor(33, 33, 33, 150));
			
			dxDrawText( "Arenas: " .. tostring( Screen.INFO_ARENACOUNT or 0 ), LOBBY_MAIN_WINDOW_HIGH_POS_X, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015, LOBBY_MAIN_WINDOW_HIGH_POS_X + LOBBY_MAIN_MENU_WIDTH, LOBBY_MAIN_WINDOW_POS_Y + LOBBY_MAIN_WINDOW_HEIGHT + gScreenSizeY * 0.015 + gScreenSizeY*0.05,
							tocolor(255, 255, 255, 255), LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.7, LOBBY_ARENA_ITEM_INFO_FONT, "center", "center");
							
			
			dxDrawRoundedRectangle( LOBBY_MAIN_WINDOW_HIGH_POS_X, LOBBY_MAIN_WINDOW_POS_Y, LOBBY_MAIN_MENU_WIDTH, gScreenSizeY*0.25, 12, tocolor(33, 33, 33, 150));
			
			local text = "Carball is a team-based ball-game, where the winner is the team with the most goals when the time runs out.";
			dxDrawText( text, LOBBY_MAIN_WINDOW_HIGH_POS_X + 20 * RELATIVE_MULT_Y, LOBBY_MAIN_WINDOW_POS_Y + 20 * RELATIVE_MULT_Y, 
						LOBBY_MAIN_WINDOW_HIGH_POS_X + LOBBY_MAIN_MENU_WIDTH - 20 * RELATIVE_MULT_Y, LOBBY_MAIN_WINDOW_POS_Y + gScreenSizeY*0.25 - 20 * RELATIVE_MULT_Y, 
						white, LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.6, LOBBY_ARENA_ITEM_INFO_FONT, "left", "top", true, true );
			
			local controls = "#ff8900CONTROLS:\n#ffffffSHIFT - jump\n#ffffffMOUSE1 - power kick\nF2 - return to lobby\nF5 - toggle score display";
			dxDrawText( controls, LOBBY_MAIN_WINDOW_HIGH_POS_X + 20 * RELATIVE_MULT_Y, LOBBY_MAIN_WINDOW_POS_Y + 20 * RELATIVE_MULT_Y + gScreenSizeY*0.1, 
						LOBBY_MAIN_WINDOW_HIGH_POS_X + LOBBY_MAIN_MENU_WIDTH - 20 * RELATIVE_MULT_Y, LOBBY_MAIN_WINDOW_POS_Y + gScreenSizeY*0.25 - 20 * RELATIVE_MULT_Y, 
						white, LOBBY_ARENA_ITEM_INFO_FONT_SIZE * 0.6, LOBBY_ARENA_ITEM_INFO_FONT, "left", "top", false, false, false, true );
			
		end
		
		
	end, true, "high+30"
);
