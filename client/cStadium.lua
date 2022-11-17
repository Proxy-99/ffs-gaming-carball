
--[[----Class-Main----||--

	Description:
		Controls Main Behaviour

--||------------------]]--


--[[----Legend----||--

	[*] = Gets saved to disk in intervals and on resourceStop
	[{}] = contents table information
	
--||--------------]]--

--[[----Player-Data----||--
	
	
--||-------------------]]--

--[[----General-Data----||--
	
	
--||--------------------]]--

addEventHandler("onClientArenaPlayerInit", resourceRoot, 
	function ()
		local stadium = Arena.getStadium(source);
		local dimension = Arena.getDimension(source);
		
		outputDebugString("Initalizing Stadium: "..tostring(getData(stadium, "Name")));
	
		setData(stadium, "Objects", getElementsByType("object", getData(stadium, "ResourceRoot")));
		setElementDimension(localPlayer, dimension);
		
		for _, object in ipairs(getElementsByType("object")) do
			if (not getData(object, "DimPos") and not getData(object, "BallObject")) then
				setElementDimension(object, 0);
				local x, y, z = getElementPosition(object);
				local dimPos = { x, y, z };
				setData(object, "DimPos", dimPos);
				setElementPosition(object, x, y, z + 10000.0);
			end
		end
			
		setTimer(function (stadium)
			outputDebugString("object amount: "..tostring(#getElementsByType("object", getData(stadium, "ResourceRoot"))));
			--for _, object in ipairs(getData(stadium, "Objects")) do
		
			local objects = getElementsByType("object", getData(stadium, "ResourceRoot"));
		
			if (Stadium.getName(stadium) == "F-22 Arena") then
				objects = table.lfilter(objects,
								function (object)
									local model = getElementModel(object);
									local x, y, z = getElementPosition(object);
									return (model ~= 16092 and ((model ~= 3452 and model ~= 3453) or z < 32));
								end);
			end
			for _, object in ipairs(objects) do
				local model = getElementModel(object);
				--[[local model = getElementModel(object);
				local x, y, z = getElementPosition(object);
				local rx, ry, rz = getElementPosition(object);
				local obj = createObject(model, x, y, z, rx, ry, rz);]]
				
				
				--[[local id = getLODModel(model);--getElementModel(object)
				if (id) then
					local x,y,z = getElementPosition(object)
					local rx,ry,rz = getElementRotation(object)
					local scale = getObjectScale(object)
					objLowLOD = createObject ( id, x,y,z,rx,ry,rz,true )
					setObjectScale(objLowLOD, scale)
					setLowLODElement ( object, objLowLOD )
					outputDebugString("lod cr "..tostr(model).." -> "..tostr(id));
					engineSetModelLODDistance ( id, 3000 )
					setElementStreamable ( object , false)
				end]]
				
				engineSetModelLODDistance ( model, 3000 )
				--engineSetModelLODDistance(model, 2000);
				setElementDimension(object, dimension);
				if (getData(object, "DimPos")) then
					local x, y, z = unpack(getData(object, "DimPos"));
					setElementPosition(object, x, y, z);
					setData(object, "DimPos", nil);
				end
			end
		
			outputDebugString("Number of good Map Objects: "..tostring(#objects), 0);
		end, 100, 1, stadium);
	end
);
--[[
addEventHandler("onClientRender", root,
	function ()
		for _, obj in ipairs(table.lfilter(getElementsByType("object"), isElementOnScreen)) do
			local text = "Model: "..tostring(getElementModel(obj)).."\nDim: "..tostring(getElementDimension(obj));
			local x, y, z = getElementPosition(obj);
			drawTextAtPosition(text, x, y, z, 2, 255, 0, 0, 255, "arial", 300);
		end
	end
);]]

addEventHandler("onClientArenaPlayerExit", resourceRoot, 
	function ()
		local stadium = Arena.getStadium(source);
		
		for _, object in ipairs(getElementsByType("object", getData(stadium, "ResourceRoot"))) do
			local model = getElementModel(object);
			setElementDimension(object, 0);
		end
	end
);

function Stadium.getCurrentLimits()
	return Stadium.getLimits(Arena.getStadium(getCurrentArena()));
end

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
	
	end
);

addEventHandler("onClientResourceStop", resourceRoot, 
	function ()
	
	end
);

