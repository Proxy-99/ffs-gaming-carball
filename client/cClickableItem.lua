
--[[----Class-Main----||--

	Description:
		Is a helper class for gui-items

--||------------------]]--

TurningSelection = { };
ClickableItem = { };
Button = { };
EditField = { };

--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

function TurningSelection.create(x, y, width, height, options, renderFunc, caption, onSwitch, default)
	local current = 1;
	if (default) then 
		for i, data in ipairs(options) do
			if (data == default) then
				current = i;
				break;
			end
		end
	end
	local item = ClickableItem.create(x, y, width, height, "turningselection", 
					function (item, x, y, width, height, ...)
						local renderFunc = getData(item, "TS.Render");
						if (renderFunc) then
							renderFunc(item, x, y, width, height, ...);
						end
						local caption = getData(item, "TS.Caption");
						
						if (caption) then
							local fontHeight = dxGetFontHeight(LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
							dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y - fontHeight, width, fontHeight, tocolor(0, 0, 0, 100), false);
							dxDrawText(caption, x, y - fontHeight, x + width, y,
												tocolor(0, 60, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true);
						end
					end, 
					function (item, x, y, width, height, ...)
						local renderFunc = getData(item, "OnRender");
						renderFunc(item, x, y, width, height, ...);
						
						local size = math.min(width / 4, math.min(height, gScreenSizeY * 0.05));
						
						local x = x + width/2 - size*2;
						local y = y + height/2 - size/2;
						dxDrawImage(x, y, size * 4, size, "data/images/switcharrow.png", 0, 0, 0, tocolor(255, 255, 255, 100));
					end, 
					function (item)
						local options = getData(item, "TS.Options");
						local sel = getData(item, "TS.Current") + 1;
						if (sel > #options) then
							sel = 1;
						end
						setData(item, "TS.Current", sel);
						ClickableItem.setRenderParams(item, { options[sel] });
						local switchFunc = getData(item, "TS.OnSwitch");
						if (switchFunc) then
							switchFunc(item, options[sel]);
						end
					end, { options[current] }, { }, 
					function (item)
						local options = getData(item, "TS.Options");
						local sel = getData(item, "TS.Current") - 1;
						if (sel <= 0) then
							sel = #options;
						end
						setData(item, "TS.Current", sel);
						ClickableItem.setRenderParams(item, { options[sel] });
						local switchFunc = getData(item, "TS.OnSwitch");
						if (switchFunc) then
							switchFunc(item, options[sel]);
						end
					end);
	setData(item, "TS.Current", current);
	setData(item, "TS.Options", options);
	setData(item, "TS.Caption", caption);
	setData(item, "TS.Render", renderFunc);
	setData(item, "TS.OnSwitch", onSwitch);
	return item;
end

function TurningSelection.getValue(ts)
	return getData(ts, "TS.Options")[getData(ts, "TS.Current")];
end

function Button.create(text, x, y, width, height, onClick, clickParams, backColor, borderRadius)
	borderRadius = borderRadius	or 12;
	
	return ClickableItem.create(x, y, width, height, "button",
		function (item, x, y, width, height, text, backCol)
			--dxDrawImage(x, y, width, height, "data/images/roundBackground.png", 0, 0, 0, backCol and tocolor(backCol.r, backCol.g, backCol.b, 100) or tocolor(255, 255, 255, 100));
			--dxDrawBorderedRectangle(borderSize, backCol and tocolor(backCol.r, backCol.g, backCol.b, 255) or tocolor(0, 0, 0, 255), x, y, width, height, backCol and tocolor(backCol.r, backCol.g, backCol.b, 255) or tocolor(33, 33, 33, 200), false);
			dxDrawRoundedRectangle( x, y, width, height, borderRadius, backCol and tocolor(backCol.r, backCol.g, backCol.b, backCol.a or 255) or tocolor(33, 33, 33, 200) )
			dxDrawText(text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 
						LOBBY_MAIN_MENU_BUTTON_FONT_SIZE, LOBBY_MAIN_MENU_BUTTON_FONT, "center", "center", false, false, false, true);
		end,
		function (item, x, y, width, height, text, backCol)
			--dxDrawImage(x, y, width, height, "data/images/roundBackground.png", 0, 0, 0, backCol and tocolor(backCol.r, backCol.g, backCol.b, 200) or tocolor(255, 255, 255, 200));
			--dxDrawBorderedRectangle(borderSize, backCol and tocolor(backCol.r, backCol.g, backCol.b, 200) or tocolor(255, 137, 0), x, y, width, height, backCol and tocolor(backCol.r, backCol.g, backCol.b, 200) or tocolor(255, 137, 0, 255), false);
			dxDrawRoundedRectangle( x, y, width, height, borderRadius, backCol and tocolor(backCol.r, backCol.g, backCol.b, backCol.a or 200) or tocolor(255, 137, 0, 255) )
			dxDrawText(text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 
						LOBBY_MAIN_MENU_BUTTON_FONT_SIZE, LOBBY_MAIN_MENU_BUTTON_FONT, "center", "center", false, false, false, true);
		end, onClick, { text, backColor }, clickParams
	);
end

function EditField.create(x, y, width, height, text, caption)
	local item = ClickableItem.create(x, y, width, height, "editfield",
		function (item, x, y, width, height)
			local caption = getData(item, "EF.Caption");
			
			if (caption) then
				local fontHeight = dxGetFontHeight(LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
				dxDrawText(caption, x, y - fontHeight, x + width, y,
									tocolor(0, 60, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true);
			end
			local parent = getData(item, "EF.Parent");
			--dxDrawImage(x, y, width, height, "data/images/roundBackground.png", 0, 0, 0, tocolor(155, 155, 155, 100));
			dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(155, 155, 155, 100), false);
			local textWidth = dxGetTextWidth(guiGetText(parent), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
			dxDrawText(guiGetText(parent), x, y, x + width, y + height, tocolor(20, 20, 255, 200), 
						LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, (textWidth <= width) and "center" or "right", "center", true, false, false, false);
		end,
		function (item, x, y, width, height)
			local caption = getData(item, "EF.Caption");
			
			if (caption) then
				local fontHeight = dxGetFontHeight(LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
				dxDrawText(caption, x, y - fontHeight, x + width, y,
									tocolor(0, 60, 200, 255), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, "center", "center", true);
			end
			local parent = getData(item, "EF.Parent");
			--dxDrawImage(x, y, width, height, "data/images/roundBackground.png", 0, 0, 0, tocolor(155, 155, 155, 200));
			dxDrawBorderedRectangle(1, tocolor(0, 0, 0), x, y, width, height, tocolor(155, 155, 155, 200), false);
			local textWidth = dxGetTextWidth(guiGetText(parent), LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT);
			dxDrawText(guiGetText(parent), x, y, x + width, y + height, tocolor(20, 20, 255, 200), 
						LOBBY_ARENA_ITEM_HEADLINE_FONT_SIZE, LOBBY_ARENA_ITEM_HEADLINE_FONT, (textWidth <= width) and "center" or "right", "center", true, false, false, false);
		end, 
		function (item)
		
		end, { }, { }
	);
	local guiEdit = guiCreateEdit(x, y, width, height, text, false);
	guiSetAlpha(guiEdit, 0);
	guiSetEnabled(guiEdit, false);
	guiEditSetMaxLength(guiEdit, 25);
	setData(item, "EF.Parent", guiEdit);
	setData(item, "EF.Caption", caption);
	return item;
end

function EditField.getText(editField)
	return guiGetText(getData(editField, "EF.Parent"));
end

function EditField.setText(editField, text)
	guiSetText(getData(editField, "EF.Parent"), text);
end

-- Clickable Item --

function isCursorIn(lowX, lowY, highX, highY)
	local x, y = getCursorPosition();
	if (x) then
		x, y = x * gScreenSizeX, y * gScreenSizeY;
		return (x >= lowX and y >= lowY and x < highX and y < highY);
	end
	return false
end

function ClickableItem.setRenderParams(item, params)
	setData(item, "RenderParams", params);
end

function ClickableItem.create(x, y, width, height, ctype, onRender, onHover, onClick, renderParams, clickParams, onRightClick)
	local clickableItem = createElement("clickableitem");
	
	setData(clickableItem, "Body", { x = x, y = y, width = width, height = height });
	setData(clickableItem, "Type", ctype);
	
	setData(clickableItem, "OnRender", onRender);
	setData(clickableItem, "OnHover", onHover);
	setData(clickableItem, "OnClick", onClick);
	setData(clickableItem, "OnRightClick", onRightClick);
	
	setData(clickableItem, "RenderParams", renderParams);
	setData(clickableItem, "ClickParams", clickParams or { });
	
	setData(clickableItem, "Visible", true);
	
	return clickableItem;
end

addEventHandler("onClientLobbyRender", root,
	function ()
		for _, item in ipairs(getElementsByType("clickableitem")) do
			if (ClickableItem.isVisible(item)) then
				processItemRender(item);
			end
		end
	end, true, "high+10"
);

addEventHandler("onClientGameRender", root,
	function ()
		for _, item in ipairs(getElementsByType("clickableitem")) do
			if (getData(item, "NoLobbyGUI")) then
				processItemRender(item);
			end
		end
	end
);

function processItemRender(item)
	local body = getData(item, "Body");
	if (isCursorIn(body.x, body.y, body.x + body.width, body.y + body.height) and not isUserPanelActive()) then
		if (not getData(item, "Hovering")) then
			playSound("data/audio/buttonHover.mp3");
			setData(item, "Hovering", true);
		end
		local func = getData(item, "OnHover") or getData(item, "OnRender");
		if (func) then
			func(item, body.x, body.y, body.width, body.height, unpack(getData(item, "RenderParams")));
		end
	else
		setData(item, "Hovering", false);
		if (getData(item, "Active")) then
			local func = getData(item, "OnHover") or getData(item, "OnRender");
			if (func) then
				func(item, body.x, body.y, body.width, body.height, unpack(getData(item, "RenderParams")));
			end
		else
			local func = getData(item, "OnRender");
			if (func) then
				func(item, body.x, body.y, body.width, body.height, unpack(getData(item, "RenderParams")));
			end
		end
	end
end

function ClickableItem.isVisible(item)
	return getData(item, "Visible");
end

function ClickableItem.setVisible(item, set)
	if (getData(item, "Type") == "editfield") then
		local parent = getData(item, "EF.Parent");
		guiSetEnabled(parent, set);
		guiSetVisible(parent, set);
		if (set) then
			guiBringToFront(parent);
		end
	end
	if (not set) then
		setData(item, "Hovering", false);
		setData(item, "Active", false);
	end
	setData(item, "Visible", set);
end

addEventHandler("onClientClick", root,
	function (button, state)
		if (state == "down" and not isUserPanelActive()) then
		
			for _, item in ipairs(getElementsByType("clickableitem")) do
				if (ClickableItem.isVisible(item) and (getCurrentArena() == LOBBY_ARENA or getData(item, "NoLobbyGUI"))) then
					--local body = getData(item, "Body");
					--if (isCursorIn(body.x, body.y, body.x + body.width, body.y + body.height)) then
					if (getData(item, "Hovering")) then
						local func = getData(item, (button == "left") and "OnClick" or "OnRightClick");
						if (func) then
							func(item, unpack(getData(item, "ClickParams") or { }));
							playSound("data/audio/buttonSelect.mp3");
							
							for _, item in ipairs(getElementsByType("clickableitem")) do
								setData(item, "Active", false);
							end
							
							if (not getData(item, "NoLobbyGUI")) then
								setData(item, "Active", true);
							end
						end
					end
				end
			end
		end
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

