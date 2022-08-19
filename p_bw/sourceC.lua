local screenX, screenY = guiGetScreenSize()
local devScreenX = 1920
local devScreenY = 1080
local scaleValue = screenY / devScreenY
local offSetX, offsetY = 50 * scaleValue, 50 * scaleValue
local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
        setElementCollisionsEnabled (sm.object1,false) 
	setElementCollisionsEnabled (sm.object2,false) 
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end
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

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end
local offSetX, offsetY = 50 * scaleValue, 50 * scaleValue

local x,y,z
local opponent
bw = {}
bw.havebw = false
bw.x, bw.y = 623, 946
bw.startX, bw.startY = getScreenStartPositionFromBox(bw.x, bw.y, 0, offsetY, "center", "bottom")
bw.opponentHP = nil
bw.opponentGun = "Deagle"
bw.opponentBodypart = "BodyPart"

function DeadPlayer ( killer, weapon, bodypart )
iprint(killer)
if killer then
bw.opponentHP = math.floor(getElementHealth(killer))
bw.opponentGun = getWeaponNameFromID ( weapon )
bw.opponentBodypart = getBodyPartName ( bodypart )
opponent = killer
else
opponent = localPlayer
end
bw.havebw = true
-- setCameraTarget(localPlayer)
addEventHandler ( "onClientRender", root, renderBWCamera )
-- smoothMoveCamera(2180.296875, -1768.9921875, 13.372227668762,2174.6435546875, -1756.3046875, 13.376874923706)
end

function renderBWCamera()
dxDrawText("Naciśnij przycisk #b50e0eE#ffffff aby się odrodzić.", bw.startX + 180,bw.startY + 850,724 * scaleValue,943 * scaleValue,tocolor(255, 255, 255, 255),1.00,"default","left","top",false,false,false,true,false)
if bw.opponentHP then
dxDrawText("HP przeciwnika: "..bw.opponentHP.." Broń: "..bw.opponentGun.." Zabił cię w: "..bw.opponentBodypart, bw.startX + 140,bw.startY + 820,724 * scaleValue,943 * scaleValue,tocolor(255, 255, 255, 255),1.00,"default","left","top",false,false,false,true,false)
end
if isElement(opponent) then
setCameraTarget(opponent)
else
setCameraTarget(localPlayer)
end
	 -- setCameraMatrix(x+1,y+1,z+1)
	 
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), DeadPlayer ) 



function respawnPlayer()
if bw.havebw then
triggerServerEvent("p:respawnPlayer", localPlayer)
removeEventHandler ( "onClientRender", root, renderBWCamera )
bw.opponentHP = nil
bw.havebw = false

end
end
bindKey (  "E", "down", respawnPlayer )  