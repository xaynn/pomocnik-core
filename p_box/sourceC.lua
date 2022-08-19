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

local startX, startY 
messages = {}
penalties = {}

function addNotification(txt)
local sound = playSound("files/beep.mp3")
table.insert(messages,{txt=txt, startTime=getTickCount(),endTime=getTickCount()+5000})
outputConsole ( "[NOTI] "..txt )
end



addEvent( "ShowNewMessage", true )
addEventHandler( "ShowNewMessage", getRootElement(), addNotification )
boxGui = {}
boxGui.x, boxGui.y = 289, 77
penaltiesGui = {}
penaltiesGui.x, penaltiesGui.y = 260, 120
penaltiesGui.startX, penaltiesGui.startY = getScreenStartPositionFromBox(penaltiesGui.x, penaltiesGui.y, offSetX, 0, "right", "center")
penaltiesGui.typepenalty, penaltiesGui.admin, penaltiesGui.player, penaltiesGui.reason = 0,0,0,0
penaltiesGui.amount = nil
penaltiesGui.newHeight = 10
local newHeight = 0

startX, startY = getScreenStartPositionFromBox(boxGui.x, boxGui.y, offSetX, -30, "left", "bottom")
penaltiesGui.blurbox = exports.p_blurbox:createBlurBox( penaltiesGui.startX, penaltiesGui.startY, penaltiesGui.x + 25, penaltiesGui.y + penaltiesGui.newHeight, 255, 255, 255, 255, false )

exports.p_blurbox:setBlurBoxEnabled(penaltiesGui.blurbox, false)
exports.p_blurbox:setBlurIntensity(1)
function renderPenalty()
dxDrawRoundedRectangle(penaltiesGui.startX, penaltiesGui.startY, penaltiesGui.x + 25, penaltiesGui.y + penaltiesGui.newHeight, 5, tocolor(0, 0, 0, 200), false)
 -- dxDrawRectangle(penaltiesGui.startX, penaltiesGui.startY, penaltiesGui.x + 25, penaltiesGui.y + penaltiesGui.newHeight, tocolor(22, 22, 26, 255), false)
 dxDrawText(penaltiesGui.typepenalty.." "..penaltiesGui.amount, penaltiesGui.startX + 120, penaltiesGui.startY + 10, 1807 * scaleValue, 578 * scaleValue, tocolor(255, 3, 3, 231), 1.00, "default-bold-small", "left", "top", false, false, true, false, false)
 dxDrawText("Admin: "..penaltiesGui.admin, penaltiesGui.startX + 10, penaltiesGui.startY + 35, 1848, 591, tocolor(255, 255, 255, 255), 1.00, "default-bold-small", "left", "top", false, false, true, false, false)
 dxDrawText("Gracz: "..penaltiesGui.player, penaltiesGui.startX + 10, penaltiesGui.startY + 70, 1848, 624, tocolor(255, 255, 255, 255), 1.00, "default-bold-small", "left", "top", false, false, true, false, false)
 dxDrawText(penaltiesGui.reason, penaltiesGui.startX + 10, penaltiesGui.startY + 100, 1888 * scaleValue, 606 * scaleValue, tocolor(255, 255, 255, 255), 1.00, "default-bold-small", "left", "top", false, true, true, false, false)
end
function ShowNewPenalty(state, typepenalty, amount, admin, player, reason)
if state == true then
ShowNewPenalty(false)

exports.p_blurbox:setBlurBoxEnabled(penaltiesGui.blurbox, true)
addEventHandler ("onClientRender",getRootElement(),renderPenalty)
local textMaxWidth = penaltiesGui.x
local reasonWidth = dxGetTextWidth (reason,1,"default")
local reasonLines = math.ceil(reasonWidth/textMaxWidth)
local linesNumber = reasonLines + 1
local fontHeight = dxGetFontHeight (1,"default")
penaltiesGui.newHeight = fontHeight*linesNumber
penaltiesGui.typepenalty, penaltiesGui.admin, penaltiesGui.player, penaltiesGui.reason = typepenalty, admin, player, reason
exports.p_blurbox:setBlurBoxSize(penaltiesGui.blurbox,penaltiesGui.x + 25, penaltiesGui.y + penaltiesGui.newHeight)
if amount == nil then penaltiesGui.amount = "" else penaltiesGui.amount = "("..amount..")" end
setTimer ( ShowNewPenalty, 9000, 1, false )

elseif state == false then
exports.p_blurbox:setBlurBoxEnabled(penaltiesGui.blurbox, false)

removeEventHandler ("onClientRender",getRootElement(),renderPenalty)


end

end
-- ShowNewPenalty(true, "AJ", "300m", "insane", "cwe4l", "Testowe kolejna kara dla debila ASD ASD IUASHD UYASHDIU HASDI asd d9cgh u8idfghuys zuyi sduiygg duysg yusidfg Testowe kolejna kara dla debila ASD ASD IUASHD UYASHDIU HASDI asd d9cgh u8idf Testowe kolejna kara dla debila ASD ASD IUASHD UYASHDIU HASDI asd d9cgh u8idfghuys zuyi sduiygg duysg yusidfg ghuys zuyi sduiygg duysg yusidfg Testowe kolejna kara dla debila ASD ASD IUASHD UYASHDIU HASDI asd d9cgh u8idfghuys zuyi sduiygg duysg yusidfg ")

addEvent( "ShowNewPenalty", true )
addEventHandler( "ShowNewPenalty", getRootElement(), ShowNewPenalty )
	
function RenderBox ()
	offset=0
	for k,v in ipairs(messages)do
	if #messages > 3 then
	table.remove(messages,1)
	end
	local now = getTickCount()
	local elapsedTime = now - v.startTime
	local duration = v.endTime - v.startTime
	local progress = elapsedTime / duration
	
	local fAnimationTime = getEasingValue(progress, "Linear")
	
	local alpha = (1-fAnimationTime)*255
	if alpha<0 then
	table.remove(messages,1)
	end

	 -- dxDrawRectangle(skalowanie["rectangle"][1], skalowanie["rectangle"][2]+offset, skalowanie["rectangle"][3], skalowanie["rectangle"][4], tocolor(1, 0, 0, alpha), false)
     -- dxDrawText(v.txt, skalowanie["text"][1], skalowanie["text"][2]+offset, skalowanie["text"][3], skalowanie["text"][4]+offset, tocolor(255, 255, 255, alpha), 1.00, "default", "center", "center", true, true, false, false, false)
	 
	offset = offset+80
	dxDrawRectangle ( startX + 50, startY - 220 - offset, boxGui.x * scaleValue, boxGui.y * scaleValue, tocolor(22, 22, 26, alpha), true )
	dxDrawText(v.txt, startX + 60, startY - 210 - offset, 386 * scaleValue, 650 * scaleValue, tocolor(255, 255, 255, alpha), 1.00, "default", "left", "top", false, true, true, false, false)

end
end
addEventHandler ( "onClientRender", root, RenderBox )
addNotification("xddd adsfohi asdupiof hsadif hasdf hasdifo hsaiuf hadsf ih sdfg pohiusg iopdfshg iofdshg iodsfhg idfsohg idsfhgisdfg isdohg ")

-- boxGui.blurbox =  exports.p_blurbox:createBlurBox( startX + 50, startY - 220 - offset, boxGui.x * scaleValue, boxGui.y * scaleValue, 255, 255, 255, 255, false )




local sx,sy = guiGetScreenSize()
local resStat = false
local serverStats = nil
local serverColumns, serverRows = {}, {}

function isAllowed()
	return true
end

addCommandHandler("stat", function()
	if isAllowed() then
		resStat = not resStat
		if resStat then
			outputChatBox("Resource stats enabled", 0, 255, 0, true)
			addEventHandler("onClientRender", root, resStatRender)
			triggerServerEvent("getServerStat", localPlayer)
		else
			outputChatBox("Resource stats disabled", 255, 0, 0, true)
			removeEventHandler("onClientRender", root, resStatRender)
			serverStats = nil
			serverColumns, serverRows = {}, {}
			triggerServerEvent("destroyServerStat", localPlayer)
		end
	end
end)

addEvent("receiveServerStat", true)
addEventHandler("receiveServerStat", root, function(stat1,stat2)
	serverStats = true
	serverColumns, serverRows = stat1,stat2
end)

function resStatRender()
	local x = sx-300
	if #serverRows == 0 then
		x = sx-140
	end
	local columns, rows = getPerformanceStats("Lua timing")
	local height = (15*#rows)
	local y = sy/2-height/2
	if #serverRows == 0 then
		dxDrawText("Client",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
	else
		dxDrawText("Client",sx-235,y-20,sx-235,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
	end
	dxDrawRectangle(x-10,y,150,height,tocolor(0,0,0,150))
	y = y + 5
	for i, row in ipairs(rows) do
		local text = row[1]:sub(0,15)..": "..row[2]
		dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,"default_bold")
		dxDrawText(text,x,y,150,15,tocolor(255,255,255,255),1,"default_bold")
		y = y + 15
	end
	
	if #serverRows ~= 0 then
		local x = sx-140
		local height = (15*#serverRows)
		local y = sy/2-height/2
		dxDrawText("Server",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
		dxDrawRectangle(x-10,y,150,height+15,tocolor(0,0,0,150))
		y = y + 5
		for i, row in ipairs(serverRows) do
			local text = row[1]:sub(0,15)..": "..row[2]
			dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,"default_bold")
			dxDrawText(text,x,y,150,15,tocolor(255,255,255,255),1,"default_bold")
			y = y + 15
		end
	end
end