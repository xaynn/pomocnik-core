local sx,sy = guiGetScreenSize ()
local scoreboardState = false
local font = dxCreateFont ("files/myriadproregular.ttf",13)
local data = {}
local slots = 64
local blurBoxElement = nil
local serverName = "Pomocnik 0.2b"
local g_oldControlStates
 

function loadScoreboardData ()
    data.ids = {}
    data.players = {}
    local players = getElementsByType ("player")
    for k,v in ipairs(players) do
        if v ~= getLocalPlayer() then
            local ID = getElementData (v,"p:playerID")
            table.insert(data.players,ID)
            data.ids[ID] = v
        end
    end
    local ID = getElementData(getLocalPlayer(),"p:playerID")
    data.ids[ID] = getLocalPlayer()
    table.insert(data.players,1,ID)
    data.length = #data.players
	 table.sort (data.players)

        
    --data.slots = maxP
    --data.serverName = sName
        
    data.maxHeight = 800
    if sy-200 <= data.maxHeight then
        data.maxHeight = sy-200
    end
end


function getWorldPlayer(player)
local world = getElementDimension(player)
if world > 0 then return "Other World" else return "0" end
end

function renderScoreboard ()
    local pHeight = 24
    local middleHeight = pHeight*data.length+20
    if middleHeight > data.maxHeight-128-32 then
        middleHeight = data.maxHeight-128-32
    end
    local totalHeight = data.maxHeight--128+middleHeight+32
	local contentY = sy/2-middleHeight/2
    local topY = contentY-128
    local contentX = sx/2-512/2
    local col = tocolor(255,255,255,255)
    
    local maxRows = math.floor(middleHeight/pHeight)--math.floor((data.maxHeight-128-32)/middleHeight)
    local maxRow = data.currentRow+maxRows-1
    -- exports.blur_box:setBlurBoxPosition(blurBoxElement,contentX,topY)
    dxDrawImage (contentX,topY,512,128,"files/top.png",0,0,0,col,true)
    dxDrawImage (contentX,contentY,512,middleHeight,"files/bg.png",0,0,0,col,true)
    dxDrawImage (contentX,contentY+middleHeight,512,32,"files/bottom.png",0,0,0,col,true)
	-- exports.blur_box:setBlurBoxPosition( blurBoxElement, contentX, topY )
	    -- exports.blur_box:setBlurBoxPosition(blurBoxElement,contentX,totalHeight)
		-- exports.blur_box:setBlurBoxSize(blurBoxElement,512,128)

	-- exports.blur_box:setBlurBoxSize( blurBoxElement, 469, middleHeight )
	
-- outputChatBox("nadano blur")	
    
    local nameY = topY+50
    local nameX = sx/2+512/2 - 45
    local countY = nameY+16
    local countX = nameX
    
    dxDrawText (serverName,0,nameY,nameX,0,tocolor(255,255,255,255),0.8,font,"right","top",false,false,true)
    dxDrawText ("" .. data.length .. "/" .. slots .. " graczy",0,countY,countX,0,tocolor(73,149,255,255),0.8,font,"right","top",false,false,true,true)
    
    local idX = 43
    local nameX = 75
    local gpX = 373
    local pingX = 456
	local rankX = 185
	local worldX = 280
    local lineX = 23
    local n = 0
    
    for k,v in ipairs(data.players) do
        if k >= data.currentRow then
            if k <= maxRow then
                local ID = v
                local player = data.ids[ID]
                if player and isElement(player) then
                    n = n+1
                    local name = getPlayerName (player)
                    local r,g,b = getPlayerNametagColor (player)
					local rr,gg,bb = 150,150,150
                    local ping = getPlayerPing (player)
					local rankplayer = exports.p_admin:getAdminTitle(player)
					-- rankplayer = "Administrator"
					-- print(rankplayer)
					-- local world = getElementData(player,"World") or "?"
					local world = getWorldPlayer(player)
                    local playtime = getElementData(player,"Play Time") or "?"
                    if name and r and ping and rankplayer and world and playtime then
					if string.len(name) > 14 then
					name = name:sub(1, -6).."(..)"
					end
					if rankplayer == "Admin" then
							rr,gg,bb = 255,0,0
							elseif rankplayer == "Ekipa" then
							rr,gg,bb = 44,83,195
							elseif getElementData(player,"VIP") then
							rr,gg,bb = 255,187,23
							else
							rr,gg,bb = 150,150,150
						end
                        local cY = contentY+(pHeight*(n-1))
                        --local path = "files/line.png"
                        if n/2 ~= math.floor(n/2) then
                            --path = "files/line2.png"
                            dxDrawImage (contentX+lineX,cY,512-lineX*2,32,"files/line2.png",0,0,0,col,true)
							
                        end
                        
                        dxDrawText (ID,contentX+idX,cY,0,0,tocolor(150,150,150,150),0.9,font,"left","top",false,false,true)
                        dxDrawText (string.gsub(name,"_"," "),contentX+nameX,cY,0,0,tocolor(r,g,b,255),0.9,font,"left","top",false,false,true,true)
                        dxDrawText (playtime,contentX+gpX,cY,0,0,tocolor(73,149,255,255),0.9,font,"left","top",false,false,true)
                        dxDrawText (ping,contentX+pingX,cY,0,0,tocolor(150,150,150,150),0.9,font,"left","top",false,false,true)
						dxDrawText (rankplayer,contentX+rankX,cY,0,0,tocolor(rr,gg,bb),0.9,font,"left","top",false,false,true)
						dxDrawText (world,contentX+worldX,cY,0,0,tocolor(150,150,150,150),0.9,font,"left","top",false,false,true)
                    end
                end
            else
                break
            end
        end
    end
end

addEvent ("onScoreboardDataLoad",true)
addEventHandler ("onScoreboardDataLoad",getRootElement(),
    function (maxP,sName)
        --[[if scoreboardState == false then
            loadScoreboardData (maxP,sName)
            data.currentRow = 1
            scoreboardState = true
            addEventHandler ("onClientRender",getRootElement(),renderScoreboard)
        end]]
        --data.slots = maxP
        --data.serverName = sName
        slots = maxP
        serverName = sName
    end
)

function scoreboardCMD (key,state)
    --outputChatBox ("key: " .. key .. " state: " .. tostring(state))
    if state == "down" then
	if not getElementData(localPlayer,"p:loggedIn") then return end
        if scoreboardState == false then
          
            --triggerServerEvent ("onCallForData",getLocalPlayer())
            loadScoreboardData (maxP,sName)
            data.currentRow = 1
            scoreboardState = true
			-- contentX,topY
			-- blurBoxElement = exports.blur_box:createBlurBox( 1,1,512,128, 255, 255, 255, 255, true )
			-- exports.blur_box:setScreenResolutionMultiplier(blurBoxElement, 10,10 )
            addEventHandler ("onClientRender",getRootElement(),renderScoreboard)
        end
    elseif state == "up" then
        if scoreboardState == true then
			-- blurBoxElement = not exports.blur_box:destroyBlurBox( blurBoxElement )

            removeEventHandler ("onClientRender",getRootElement(),renderScoreboard)
            scoreboardState = false
            data = {}
        end
    end
end
bindKey ("tab","both",scoreboardCMD)


function playerPressedKey(button, press)
    if scoreboardState then
        if button == "mouse_wheel_up" then
            if data.currentRow > 1 then
                data.currentRow = data.currentRow-10
            end
        elseif button == "mouse_wheel_down" then
            local maxRows = data.length
            local middleHeight = data.maxHeight-128-32--pHeight*data.length+20
            local pHeight = 24
            local maxVisRows = math.floor(middleHeight/pHeight)
            local maxRows = maxRows-maxVisRows
            if data.currentRow < maxRows then
                data.currentRow = data.currentRow+10
            end
        end
    end
end
addEventHandler("onClientKey", getRootElement(), playerPressedKey)

--[[♠addEventHandler ("onClientResourceStart",getResourceRootElement(),
    function ()
        triggerServerEvent ("onCallForData",getLocalPlayer())
    end
)]]--

addEventHandler("onClientPlayerJoin", getRootElement(), 
    function ()
        if scoreboardState then
            setTimer (loadScoreboardData,100,1)
        end
    end
)

addEventHandler("onClientPlayerQuit", getRootElement(), 
    function ()
        if scoreboardState then
            setTimer (loadScoreboardData,100,1)
        end
    end
)
if fileExists("sourceC.lua") then
fileDelete("sourceC.lua") 
end
