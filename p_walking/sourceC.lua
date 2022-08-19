local screenX, screenY = guiGetScreenSize()
local devScreenX = 1920
local devScreenY = 1080
local scaleValue = screenY / devScreenY
local offSetX, offsetY = 50 * scaleValue, 50 * scaleValue

scaleValue = math.max(scaleValue, 0.65)
function getScreenStartPositionFromBox (width, height, offsetX, offsetY, startIndicationX, startIndicationY)
	
		if type(width) ~= "number" then
			width = 0
		end
		
		if type(height) ~= "number" then
			height = 0
		end
		
		if type(offsetX) ~= "number" then
			offsetX = 0
		end
		
		if type(offsetY) ~= "number" then
			offsetY = 0
		end
		
		local startX = offsetX 
		local startY = offsetY
		
		if startIndicationX == "right" then
			startX = screenX - (width + offsetX)
		elseif startIndicationX == "center" then
			startX = screenX / 2 - width / 2 + offsetX
		end
		
		if startIndicationY == "bottom" then
			startY = screenY - (height + offsetY)
		elseif startIndicationY == "center" then
			startY = screenY / 2 - height / 2 + offsetY
		end
		
		return startX, startY
	end

















walkingGui = {}
walkingGui.isWalking = false
walkingGui.x, walkingGui.y = 623, 946
walkingGui.startX, walkingGui.startY = getScreenStartPositionFromBox(walkingGui.x, walkingGui.y, 0, offsetY, "center", "bottom")
walkingGui.LimitClicks = 0

function EnableWalking(key, keystate)
    if walkingGui.isWalking then
        removeEventHandler("onClientRender", root, drawInfoAboutWalking)
        walkingGui.isWalking = false
        setPedControlState(localPlayer, "forwards", false)
    else
        addEventHandler("onClientRender", root, drawInfoAboutWalking)
        walkingGui.isWalking = true
    end
end

function EnableAlt(key, press)
    if (key == "w") then
        if (getKeyState("lalt")) then
            EnableWalking()
        end
    end
end
bindKey("w", "down", EnableAlt)


function drawInfoAboutWalking()
    setPedControlState(localPlayer, "forwards", true)
    dxDrawText("Nacisnij ALT + W, aby powrocic do normalnego trybu poruszania sie.", walkingGui.startX + 150,walkingGui.startY + 900,724 * scaleValue,943 * scaleValue,tocolor(255, 255, 255, 255),1.00,"default","left","top",false,false,false,false,false)
end




local sprintSpeed = 0.7 -- analog control state
local lastSpaceClick = 0
--local sprintTime = 20000 -- 20s
local sprintClicks = 0
local sprintClicksLimit = 20000 -- przerabiamy to na czas w MS





addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), 
	function ()
		local stat = getPedStat (getLocalPlayer(),22) -- sprint

		sprintClicksLimit = 20000 + 100000*(stat/999)--40 + 120*stat/999
	end
)


function onKey (button,press)
	if isCursorShowing () == false and isControlEnabled (button) == true then
		if press == "down" then
			local sprintKey = false
			for i,v in pairs(getBoundKeys ("sprint")) do
				if getKeyState (i) then
					sprintKey = true
					break
				end
			end
			if sprintKey == false then
				setControlState ("walk",true)
			end
		else
			local f = false
			local keys = {"forwards","backwards","left","right"}
			for k,v in ipairs(keys) do
				local bound = getBoundKeys (v)
				for i,key in pairs(bound) do
					if getKeyState (i) then
						f = true
						break
					end
				end
			end
			if f == false then
				--if isControlEnabled ("sprint") then
					setControlState ("walk",false)
				--end
			end
		end
	end
end

addEventHandler ("onClientResourceStart",getResourceRootElement(),
	function ()
		local keys = {"forwards","backwards","left","right"}
		for k,v in ipairs(keys) do
			bindKey (v,"both",onKey)
		end
		bindKey ("walk","both",
			function ()
				setControlState ("walk",true)
			end
		)
		bindKey ("sprint","both",
			function (button,press)
				if press == "down" then
					setControlState ("sprint",false)
					--setAnalogControlState ("sprint",0)
					if isControlEnabled ("sprint") then
						setControlState ("walk",false)
					end
					local cTick = getTickCount ()
					local delay = cTick - lastSpaceClick
					if delay <= 500 then
						--sprintClicks = sprintClicks+1
						sprintClicks = sprintClicks+delay
						if sprintClicks < sprintClicksLimit then
							if isControlEnabled ("sprint") then
								setControlState ("sprint",true)
								--setAnalogControlState ("sprint",sprintSpeed)
							end
						else
							sprintClicks = sprintClicksLimit
							setControlState ("sprint",false)
							--setAnalogControlState ("sprint",0)
						end
						
					end
					lastSpaceClick = getTickCount ()
				else
					if getTickCount()-lastSpaceClick > 500 then
						setControlState ("walk",true)
					else
						lastSpaceClick = getTickCount ()
					end
				end
			end
		)
		setTimer (
			function ()
				local st = false
				local keys = {"forwards","backwards","left","right"}
				for k,v in ipairs(keys) do
					if getControlState (v) then
						st = true
						break
					end
				end
				if st then
					local sprintKey = false
					for i,v in pairs(getBoundKeys ("sprint")) do
						if getKeyState (i) then
							sprintKey = true
							break
						end
					end
					local cTick = getTickCount ()
					local delay = cTick-lastSpaceClick
					if delay > 500 then
						if sprintKey == false then
							setControlState ("walk",true)
							setControlState ("sprint",false)
							--setAnalogControlState ("sprint",0)
						else
							setControlState ("sprint",false)
							if isControlEnabled ("sprint") == false then
								setControlState ("walk",true)
							end
							--setAnalogControlState ("sprint",0)
						end
					end
					
				end
			end
		,500,0)
		setTimer (
			function ()
				if sprintClicks > 0 then
					--sprintClicks = sprintClicks-1
					sprintClicks = sprintClicks-100
					if sprintClicks < 0 then
						sprintClicks = 0
					end
				end
			end
		,1000,0)
	end
)