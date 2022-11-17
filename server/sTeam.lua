local _DO_NOT_COMPILE

--[[----Class-Team----||--

	Description:
		Controls Teams and their members

--||------------------]]--

gRandomIndex = 1;
gRandomColors = {
	{ r = 130, g = 250, b = 255 },
	{ r = 255, g = 255, b = 255 },
	{ r = 0, g = 255, b = 0 },
	{ r = 255, g = 128, b = 0 },
	{ r = 255, g = 255, b = 0 },
	{ r = 255, g = 0, b = 255 },
	{ r = 0, g = 0, b = 255 },
	{ r = 140, g = 70, b = 20 },
	{ r = 255, g = 0, b = 0 },
	{ r = 100, g = 100, b = 100 },
	{ r = 124, g = 252, b = 0 },
	{ r = 0, g = 250, b = 150 },
	{ r = 255, g = 20, b = 147 },
}

gTeams = { };

--- Static Teams ---

function Team.create(info)
	local id = #gTeams + 1;
	local team = createTeam(info.name, info.color.r, info.color.b, info.color.g);-- createElement("team");
	setData(team, "ID", id);
	setData(team, "Name", info.name);
	setData(team, "FounderID", info.founder);
	setData(team, "Members", { });
	setData(team, "Applications", { });
	gTeams[id] = team;
	return team;
end

function Team.getByID(id)
	return gTeams[id];
end

function Team.getID(team)
	return getData(team, "ID");
end

function Team.getName(team)
	return getData(team, "Name");
end

function Team.getFounderID(team)
	return getData(team, "FounderID");
end

function Team.applyPlayer(team, player)
	local applications = getData(team, "Applications");
	local userID = SQLPlayer.getUserID(player);
	if (not applications[userID]) then
		applications[userID] = getPlayerName(player);
		local founder = getUserPlayerElement(Team.getFounderID(team));
		if (isValid(founder)) then
			--exports.notifications:showNotifier(founder, "Info", "Application", getPlayerName(player).." applicated for your Team:\n"..tostring(Team.getName(team)).."!", false);
			--exports.notifications:showNotifier(player, "Info", "Application", "You successfully applicated for the Team:\n"..tostring(Team.getName(team)).."!", true);
		end
	else
		--exports.notifications:showNotifier(player, "Warning", "Application", "You already applicated for this Team!", true);
	end
end

function Team.declinePlayer(team, userID)
	local applications = getData(team, "Applications");
	if (applications[userID]) then
		applications[userID] = nil;
		local player = getUserPlayerElement(userID);
		if (isValid(player)) then
			--exports.notifications:showNotifier(player, "Info", "Arena", msg, false, false);	
		end
	end
end

function Team.acceptPlayer(team, userID)
	local applications = getData(team, "Applications");
	if (applications[userID]) then
		Team.insertPlayer(team, userID);
		applications[userID] = nil;
	end
end

function Team.insertPlayer(team, userID)
	local teamID = Team.getID(team);
	local members = getData(team, "Members");
	members[userID] = true;
	local player = getUserPlayerElement(userID);
	if (isValid(player)) then
		Player.setStaticTeam(player, team);
	end
	SQL:queryExec("UPDATE carball SET StaticTeamID = ? WHERE userid = ?", teamID, userID);
end

addEventHandler("onCarballPlayerLogin", root,
	function ()
		local team = Team.getByID(getData(source, "StaticTeamID") or 0);
		if (isValid(team)) then
			setPlayerTeam(source, team);
			setData(source, "Team", team, true);
		end
	end
);

addEventHandler("onTeamMemberAction", root,
	function (action, info)
		if (action == "ManageApplication") then
			local team = getData(source, "Team");
			if (isValid(team) and Team.getFounderID(team) == getData(source, "UserID")) then
				if (info.accept) then
					Team.acceptPlayer(team, info.userID);
				else
					Team.declinePlayer(team, info.userID);
				end
			end
		elseif (action == "Apply") then
			Team.applyPlayer(info, source);
		end
	end
);

--- MatchTeams ---

function MatchTeam.create(arena, id, info)
	local team = createElement("matchteam");
	setElementArena(team, arena);
	setData(team, "ID", id, true);
	if (isElement(info) and getElementType(info) == "team" and false) then
		
		--setData(team, "JoinRestriction", info, true);
	else
		local name = info and info.name or ((id == 1) and "RED" or "BLUE");
		local color = info and info.color or ((id == 1) and { r = 255, g = 64, b = 54 } or { r = 54, g = 64, b = 255 });
		local teamElement = createTeam(name, color.r, color.b, color.g);

		setData(team, "Name", name, true);
		setData(team, "Color", { r = color.r, g = color.g, b = color.b }, true);
		setData(team, "Size", info and info.size or (getData(arena, "TeamSize") or 3), true);
		setData(team, "Team", teamElement);
	end
	setData(team, "Players", { }, true);
	setData(team, "Score", 0, true);

	return team;
end

function MatchTeam.addPlayer(team, player)
	local players = getData(team, "Players");
	if (not players[player]) then
		players[player] = true;
		setData(team, "Players", players, true);
		setPlayerTeam(player, getData(team, "Team"));
	end
end

function MatchTeam.removePlayer(team, player)
	local players = getData(team, "Players");
	if (players[player]) then
		players[player] = nil;
		setData(team, "Players", players, true);
	end
end