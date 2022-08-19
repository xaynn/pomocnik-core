-- Protect greenzone'd players from getting attacked etcetera
function onDamage()
	if getElementData (source, "greenzone") then
		cancelEvent()
	end
end
addEventHandler ("onClientPlayerDamage", localPlayer, onDamage)

-- Prevent people from being knifed while in greenzone
function onStealthKill(target)
	if getElementData (target, "greenzone") then
		cancelEvent()
	end
end
addEventHandler ("onClientPlayerStealthKill", localPlayer, onStealthKill)

-- Render the "Greenzone protected" text above their heads
function renderGreenzoneTag()
	local streamedPlayers = getElementsByType ("player", root, true)
	if streamedPlayers and #streamedPlayers ~= 0 then
		local lpos = {getElementPosition(localPlayer)}
		for _,p in ipairs (streamedPlayers) do
			if p and isElement (p) then
				if getElementData (p, "greenzone") then
					local ppos = {getElementPosition(p)}
					if getDistanceBetweenPoints3D (lpos[1], lpos[2], lpos[3], ppos[1], ppos[2], ppos[3]) <= 20 then
						local x, y = getScreenFromWorldPosition (ppos[1], ppos[2], ppos[3]+1.2)
						if x and y then
							dxDrawText ("Greenzone", x+1, y+1, x, y, tocolor (0, 0, 0), 0.5, "bankgothic", "center")
							dxDrawText ("Greenzone", x, y, x, y, tocolor (0, 220, 0), 0.5, "bankgothic", "center")
						end
					end
				end
			end
		end
	end
end
-- addEventHandler ("onClientRender", root, renderGreenzoneTag)


-- The next 4 functions are for ghostmode (vehicles ramming greenzone'd players on foot, lifting them off, etcetera)
-- This protection is important; they usually try to forklift you out of greenzone, spawn a vehicle on you and catch you inside, then TP off to a clear zone to kill you, etcetera.

function onStreamIn()
	if not getElementData(localPlayer,"greenzone") then return end
		if getElementType(source) == "vehicle" then
			setElementCollidableWith(localPlayer,source,false)
	    end
end
addEventHandler("onClientElementStreamIn",root,onStreamIn)

function cleanUp()
	if not getElementData(source,"greenzoneveh") then return end
		if getElementType(source) == "vehicle" and isElementCollidableWith(localPlayer,source) == false then
			setElementCollidableWith(localPlayer, source, true)
		end
end
addEventHandler("onClientElementStreamOut",resourceRoot,cleanUp)

function enterGreenzone()
local x, y, z = getElementPosition(localPlayer)
local nearbyVehicles = getElementsWithinRange(x, y, z, 300, "vehicle")

	for i,v in ipairs(nearbyVehicles) do
		setElementCollidableWith(localPlayer,v,false)
	end
end
addEvent("onEnterGreenzone", true)
addEventHandler("onEnterGreenzone", localPlayer, enterGreenzone)


function leaveGreenzone(p)
local x, y, z = getElementPosition(localPlayer)
local nearbyVehicles = getElementsWithinRange(x, y, z, 300, "vehicle")

		for i,v in ipairs(nearbyVehicles) do
		   setElementCollidableWith(localPlayer,v,true)
		end
end
addEvent("onLeaveGreenzone", true)
addEventHandler("onLeaveGreenzone", localPlayer, leaveGreenzone)

-- This 'bug' is not expected to happen without some sort of interference, but is a generic safeguard.
-- If player exits the greenzone after incidentally having the bugfix applied to them, all controls will be automatically re-enabled anyways (that mechanism is in serverside).
function antiGreenzoneBug()
	if getElementData (localPlayer, "greenzone") then
        toggleControl ("fire", false)
		toggleControl ("action", false)
		toggleControl ("aim_weapon", false)
		toggleControl ("vehicle_fire", false)
		toggleControl ("vehicle_secondary_fire", false)	
	end
end
addEventHandler ("onClientPlayerWeaponFire", localPlayer, antiGreenzoneBug)