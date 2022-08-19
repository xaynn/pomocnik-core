local devScreenX = 1920
local devScreenY = 1080
local ce=exports.p_editbox
function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end
	local screenX, screenY = guiGetScreenSize()
local scaleValue = screenY / devScreenY
	local offSetX, offsetY = 50 * scaleValue, 50 * scaleValue
local changelogs = {}




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
	
loginGui = {}
loginGui.isPlayerLogging = true
loginGui.rememberme = false
loginGui.alpha = 1
loginGui.image =  dxCreateTexture( "files/logowanie.png", "argb", true, "clamp" ) 
loginGui.width = 690
loginGui.height = 488
loginGui.x, loginGui.y = getScreenStartPositionFromBox(loginGui.width, loginGui.height, 0, 0, "center", "center")
loginGui.background = dxCreateTexture( "files/1.png", "argb", true, "clamp" )
loginGui.imageRememberme = dxCreateTexture( "files/login_remember_checked.png", "argb", true, "clamp" ) 
loginGui.imageRemembermefalse = dxCreateTexture( "files/login_remember_unchecked.png", "argb", true, "clamp" ) 

 
startX, startY = getScreenStartPositionFromBox(201, 23, 13, 15, "center", "center")

loginGui.editbox = ce:createCustomEdit("",startX + 110,startY - 105 ,400 * scaleValue,23 * scaleValue,true,"",false,"font2",{255,0,0,255},{255,255,255,255},{0,0,0,150},{255,255,255,255},true,false,false)
ce:editSetVisible(loginGui.editbox, false)
ce:editMaxLength(loginGui.editbox, 45)

loginGui.editboxsecond = ce:createCustomEdit("",startX+ 110,startY - 20,400 * scaleValue,23 * scaleValue,true,"",false,"font2",{255,0,0,255},{255,255,255,255},{0,0,0,150},{255,255,255,255},true,false,false)
ce:editSetVisible(loginGui.editboxsecond, false)
ce:editMaxLength(loginGui.editboxsecond, 40)

ce:editSetMasked(loginGui.editboxsecond,false)



myRenderTarget = dxCreateRenderTarget(291, 318, true)  -- Create a render target texture which is 80 x 100 pixels
-- 640, 396, 291, 318

function drawLoginPanel()
		dxDrawImage(0,0,screenX,screenY, loginGui.background, 0, 0, 0, tocolor(255, 255, 255, 255), false)
		dxDrawImage(loginGui.x,loginGui.y,loginGui.width,loginGui.height, loginGui.image, 0, 0, 0, tocolor(255, 255, 255, loginGui.alpha), false)
		if loginGui.rememberme then
		dxDrawImage(startX + 95 ,startY + 70,64 * scaleValue,64*scaleValue,loginGui.imageRememberme, 0, 0, 0, tocolor(255, 255, 255, loginGui.alpha), false)
		else
		dxDrawImage(startX + 95 ,startY + 70,64 * scaleValue,64*scaleValue,loginGui.imageRemembermefalse, 0, 0, 0, tocolor(255, 255, 255, loginGui.alpha), false)
		end
			-- dxDrawRectangle ( startX - 210, startY - 150, 260 * scaleValue, 300 * scaleValue, tocolor(0, 150, 0), false )
			    dxDrawText ( ce:editGetText(loginGui.editbox), startX + 115,startY - 100 ,300 * scaleValue,23 * scaleValue, tocolor ( 255, 255, 255, loginGui.alpha ), 1, "default-bold-small" )
			    dxDrawText ( string.gsub ( ce:editGetText(loginGui.editboxsecond), ".", "*" ) , startX+ 115,startY - 20 ,300 * scaleValue,23 * scaleValue, tocolor ( 255, 255, 255, loginGui.alpha ), 1, "default-bold-small" )



end




savedCredentials = {}
savedCredentials.login = ""
savedCredentials.password = ""


function HandleTheRendering()
	showChat(false)
	setAmbientSoundEnabled( "gunfire", false )
    local XMLSettings = xmlLoadFile("files/userSettings.xml")

    if XMLSettings then
        local nick = xmlFindChild(XMLSettings, "login", 0)
        local pass = xmlFindChild(XMLSettings, "password", 0)
        if nick and pass then
            savedCredentials.login = xmlNodeGetValue(nick)
            savedCredentials.password = xmlNodeGetValue(pass)
			local decrypt = teaDecode ( savedCredentials.password, "M6SRdED8mta4DckG" )
            ce:editSetText(loginGui.editbox, savedCredentials.login)
            ce:editSetText(loginGui.editboxsecond, decrypt)
            loginGui.rememberme = true
        end
        xmlSaveFile(XMLSettings)
        xmlUnloadFile(XMLSettings)
    else
        XMLSettings = xmlCreateFile("files/userSettings.xml", "settings")

        xmlNodeSetValue(xmlCreateChild(XMLSettings, "login"), "")
        xmlNodeSetValue(xmlCreateChild(XMLSettings, "password"), "")

        xmlSaveFile(XMLSettings)
        xmlUnloadFile(XMLSettings)
    end

    fadeCamera(true, 5)
    showCursor(true)
    addEventHandler("onClientRender", root, drawLoginPanel)
end
addEventHandler("onClientResourceStart", resourceRoot, HandleTheRendering)

Tick = getTickCount()


function onSuccessfulLogin()
loginGui.isPlayerLogging = false
showChat(true)
removeEventHandler("onClientRender", root, drawLoginPanel)
stopSound(sound)
ce:destroyCustomEdit(loginGui.editbox)
ce:destroyCustomEdit(loginGui.editboxsecond)
showCursor(false)
-- exports["p_box"]:addNotification("Witaj na serwerze Gang Wars, nie panują tutaj żadne zasady i możesz być kim chcesz...")
setCameraTarget (localPlayer)


end
addEvent("onSuccesfulLogin", true)
addEventHandler("onSuccesfulLogin", root, onSuccessfulLogin)


function SaveCredentials()
 local XMLSettings = xmlLoadFile("files/userSettings.xml")
local nick = xmlFindChild(XMLSettings, "login", 0)
 local pass = xmlFindChild(XMLSettings, "password", 0)
local crypt = teaEncode (ce:editGetText(loginGui.editboxsecond), "M6SRdED8mta4DckG")
xmlNodeSetValue(nick, ce:editGetText(loginGui.editbox))
 xmlNodeSetValue(pass, crypt)
xmlSaveFile(XMLSettings)
xmlUnloadFile(XMLSettings)
end

function onTryLoginButton(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if state == "down" and loginGui.isPlayerLogging == true then
	if isMouseInPosition(startX + 300, startY + 80, 110, 45) then
		if ce:editGetText(loginGui.editbox) == "" or ce:editGetText(loginGui.editboxsecond) == "" then return exports["p_box"]:addNotification("Podaj dane do zalogowania.") end
		if  string.match(ce:editGetText(loginGui.editbox), "%p")  then return exports["p_box"]:addNotification("Twój login posiada specjalny znak, nie możesz się zalogować [@!#$%^&*()?<>].") end

	end
	local cant = getTickCount() - Tick < 3000 
	Tick = getTickCount()
	if cant and isMouseInPosition(startX + 300, startY + 80, 110, 45) then return exports["p_box"]:addNotification("Musisz poczekać przed ponowną próbą do zalogowania.") end
        if isMouseInPosition(startX + 300, startY + 80, 110, 45) then
            -- outputChatBox("Klikniety.")
            triggerServerEvent("onTryLogin",localPlayer,ce:editGetText(loginGui.editbox),ce:editGetText(loginGui.editboxsecond))
            if loginGui.rememberme == true then
                SaveCredentials()
            end
        elseif isMouseInPosition(startX + 120, startY + 90, 20, 20) then -- remember me
            -- outputChatBox("zapamiteja mnie")
            if loginGui.rememberme == true then
                loginGui.rememberme = false
            else
                loginGui.rememberme = true
            end
        end
    end
end
addEventHandler("onClientClick", root, onTryLoginButton)


function LoginWithEnterKey()
if loginGui.isPlayerLogging == true then
-- outputChatBox(ce:editGetText(loginGui.editbox))
if  string.match(ce:editGetText(loginGui.editbox), "%p")  then return exports["p_box"]:addNotification("Twój login posiada specjalny znak, nie możesz się zalogować [@!#$%^&*()?<>].") end

local cant = getTickCount() - Tick < 3000 
if cant then return exports["p_box"]:addNotification("Musisz poczekać przed ponowną próbą do zalogowania.") end
triggerServerEvent("onTryLogin",localPlayer,ce:editGetText(loginGui.editbox),ce:editGetText(loginGui.editboxsecond))
SaveCredentials()
Tick = getTickCount()
end
end

bindKey ( "ENTER", "down", LoginWithEnterKey ) 

