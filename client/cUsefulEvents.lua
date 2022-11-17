
addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		outputDebugString("client download finished");
		--triggerServerEvent("onClientDownloadFinished", source, localPlayer);
	end
);


local pLastRenderTick = getTickCount();
addEventHandler("onClientRender", root, 
	function ()
		--outputDebugString("onClientDeltaRender: ");
		local delta = (getTickCount() - pLastRenderTick) / 1000;
		triggerEvent("onClientDeltaRender", root, delta);
		pLastRenderTick = getTickCount();
	end
);


local pLastPreRenderTick = getTickCount();
addEventHandler("onClientPreRender", root, 
	function ()
		local delta = (getTickCount() - pLastPreRenderTick) / 1000;
		triggerEvent("onClientDeltaPreRender", root, delta);
		pLastPreRenderTick = getTickCount();
	end
);
