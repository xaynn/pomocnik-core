

function findPlayer(player, partialNick)
	if not partialNick and not isElement(player) and type(player) == "string" then
		partialNick = player
		player = nil
	end
	
	local candidates = {}
	local matchPlayer = nil
	local matchNick = nil
	local matchNickAccuracy = -1
	local partialNick = string.lower(partialNick)
	
	if player and partialNick == "*" then
		return player, string.gsub(getPlayerName(player), "_", " ")
	elseif tonumber(partialNick) then
		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "p:loggedIn") and getElementData(v, "p:playerID") == tonumber(partialNick) then
				matchPlayer = v
				break
			end
		end
		candidates = {matchPlayer}
	else
		partialNick = string.gsub(partialNick, "-", "%%-")
		
		for k, v in ipairs(getElementsByType("player")) do
			if isElement(v) then
				local playerName = string.lower(string.gsub(getElementData(v, "visibleName") or getPlayerName(v), "_", " "))

				if playerName and string.find(playerName, tostring(partialNick)) then
					local posStart, posEnd = string.find(playerName, tostring(partialNick))
					
					if posEnd - posStart > matchNickAccuracy then
						matchNickAccuracy = posEnd - posStart
						matchNick = playerName
						matchPlayer = v
						candidates = {v}
					elseif posEnd - posStart == matchNickAccuracy then
						matchNick = nil
						matchPlayer = nil
						table.insert(candidates, v)
					end
				end
			end
		end
	end
	
	if not matchPlayer or not isElement(matchPlayer) then
		if isElement(player) then
			if #candidates == 0 then
				outputChatBox("#32b3ef>> pomocnik: #FFFFFF Nie znaleziono gracza#d75959.", player, 255, 255, 255, true)
			else
				outputChatBox("#32b3ef>> pomocnik: #d75959" .. #candidates .. " #FFFFFFznaleziono graczy:", player, 255, 255, 255, true)
			
				for k = 1, #candidates do
					local v = candidates[k]

					if isElement(v) then
						outputChatBox("#cdcdcd>> #32b3ef(" .. tostring(getElementData(v, "p:playerID")) .. ") #fffffff" .. string.gsub(getPlayerName(v), "_", " "), player, 255, 255, 255, true)
					end
				end
			end
		end
		
		return false
	else
		if getElementData(matchPlayer, "p:loggedIn") then
			return matchPlayer, string.gsub(getElementData(matchPlayer, "visibleName") or getPlayerName(matchPlayer), "_", " ")
		else
			outputChatBox("#32b3ef>> roleGaming: #FFFFFFA Gracz nie jest zalogowany.", player, 255, 255, 255, true)
			return false
		end
	end
end
local ids = { }

function playerJoin()
	local slot = nil
	
	for i = 1, 1024 do
		if (ids[i]==nil) then
			slot = i
			break
		end
	end
	
	ids[slot] = source 

	setElementData(source,"p:playerID", slot)

end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function playerQuit()
	local slot = getElementData(source, "p:playerID")
	
	if (slot) then
		ids[slot] = nil
	end
end
addEventHandler("onPlayerQuit", getRootElement(), playerQuit)

function resourceStart()
	local players = getElementsByType ( "player" )
	
	for key, value in ipairs(players) do
		ids[key] = value
		setElementData(value,"p:playerID", key)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), resourceStart)
function getRankFromAdmin(typ)
    local tablica = {}
    tablica[1] = {"Ekipa"}
    tablica[2] = {"Admin"}
    if (type(tablica[typ]) == "table") then
        return tablica[typ][1], tablica[typ][2]
    else
        return "Gracz"
    end
end

function getAdminPowerTable(typ)
    local tablica = {}
    tablica[1] = {1}
    tablica[2] = {2}
    if (type(tablica[typ]) == "table") then
        return tablica[typ][1], tablica[typ][2]
    else
        return 0
    end
end

function getAdminPower(player)
local power = getAdminPowerTable(getElementData(player,"p:adminlevel"))
return power
end


function getAdminTitle(player)
local rank =  getRankFromAdmin(getElementData(player,"p:adminlevel"))
return rank
end
    DBConnection = dbConnect( "mysql", "dbname=pomocnik;host=127.0.0.1;charset=utf8", "root", "", "share=1" )


function banUser(player, typeBan, adminBanning, reason, seconds)
    if player then
        if typeBan == 1 then
            banPlayer(player, true, true, true, adminBanning, reason, seconds) -- funkcja banowania na serial, ip., TODO; wlasna funkcja na ban konta.
        elseif typeBan == 2 then
            local guid = getElementData(player, "p:GUID")
            local now = getRealTime().timestamp
            local final = now + seconds
			local db = dbQuery(DBConnection,"UPDATE users SET banTimeStamp = ?, banReason = ? WHERE id = ?",final,reason.." przez "..getPlayerName(adminBanning):gsub("_", " "),guid)
            dbFree(db)
            kickPlayer(player,adminBanning,"[BAN] " .. reason .. " (aby dowiedzieć się więcej, wejdz ponownie na serwer)")
        end
    end
end


-- sourcePlayer, commandname, targetPlayer, ...
-- notyfikacje z kickami/banami itd todo
addCommandHandler(
    "kick",
    function(sourcePlayer, commandName, targetPlayer, ...)
        if getElementData(sourcePlayer, "p:adminlevel") then
            if not targetPlayer or not ... then
                exports["p_box"]:addNotification(sourcePlayer, "Użycie: /kick [Nazwa gracza / ID] [Powód]")
            else
                targetPlayer = findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    if sourcePlayer ~= targetPlayer then
                        local reason = table.concat({...}, " ")

                        if utf8.len(reason) > 0 then
                            local adminNick = getPlayerName(sourcePlayer)
                            local targetName = getPlayerName(targetPlayer)

                            kickPlayer(targetPlayer, sourcePlayer, reason)
                            -- outputChatBox("kicked")
							 exports["p_box"]:ShowNewPenalty(root, "KICK", nil, adminNick, targetName, reason)

                        else
                            exports["p_box"]:addNotification(sourcePlayer, "Użycie: /kick [Nazwa gracza / ID] [Powód]")
                        end
                    else
                        exports["p_box"]:addNotification(sourcePlayer, "Nie możesz siebie wyrzucić.")
                    end
                end
            end
        end
    end
)

function banPlayerHandler(sourcePlayer, commandname, targetPlayer, hours, tryb, ...)
    -- Get player element from the name
    if getElementData(sourcePlayer, "p:adminlevel") then
        if not (...) or not (hours) then
            exports.p_box:addNotification(
                sourcePlayer,
                "Uzycie: /" .. commandname .. " [NICK/ID] [CZAS] [TYP/d/h/m] [POWOD]"
            )
        else
            local reason = table.concat({...}, " ")
            local seconds = hours
            local type = tostring(tryb)
            if type == "" or not type == "d" or not type == "h" or not type == "m" then
                return exports.p_box:addNotification(
                    sourcePlayer,
                    "Uzycie: /" .. commandname .. " [NICK/ID] [CZAS] [TYP/d/h/m] [POWOD]"
                )
            end
            if type == "d" then
                seconds = tonumber(hours * 86400)
            end
            if type == "h" then
                seconds = tonumber(hours * 3600)
            end
            if type == "m" then
                seconds = tonumber(hours * 60)
            end

            local adminsupp = getPlayerName(sourcePlayer):gsub("_", " ")
            hours = tonumber(hours)

            targetPlayer = findPlayer(sourcePlayer, targetPlayer)
            if targetPlayer then
                local globalName = getPlayerName(targetPlayer):gsub("_", " ")
                local thePlayerPower = getAdminPower(sourcePlayer)
                local targetPlayerPower = getAdminPower(targetPlayer)

                if sourcePlayer == targetPlayer then
                    return exports.p_box:addNotification(sourcePlayer, "Nie mozesz zbanowac samego siebie.")
                end
                if hours > 9999 then
                    exports.p_box:addNotification(sourcePlayer, "TIP: /ban moze wynosic max 9999, 0 to perm.")
                    return
                end
                if (targetPlayerPower <= thePlayerPower) then
                    local idacc = getElementData(targetPlayer, "p:GUID")
                    exports.p_box:ShowNewPenalty(root, "BAN", hours .. type, adminsupp, globalName, reason)
					banUser(targetPlayer,2,sourcePlayer, reason, seconds)
                    -- banPlayer(targetPlayer, true, true, true, sourcePlayer, reason, seconds) -- funkcja banowania na serial, ip., TODO; wlasna funkcja na ban konta.
                -- exports["ls_webhook"]:webhook("`[BAN]` Admin/Support `"..accName.."` zbanowal gracza `" ..targetPlayerName.."`. z powodem `"..reason.."` na " ..hours.. ":" ..type.. ".", "test")
                -- exports.ls_logger:addLogEntry("`[BAN]` Admin/Support `"..accName.."` zbanowal gracza `"..targetPlayerName.."` z powodem "..reason.. " na  " ..hours.. ":"..type..".","banyikicki")
                -- exports.ls_mysql:AddForPlayerPenalty(targetPlayerName,reason,"BAN",hours..type,idacc,date,adminsupp)
                end
            end
        end
    end
end
addCommandHandler("ban", banPlayerHandler, false, false)


function unbanPlayerHandler(sourcePlayer, commandname, login, ...)
    if getAdminPower(sourcePlayer) == 2 then
        if not (...) then
            return exports["p_box"]:addNotification(sourcePlayer, "/unban [login] [powodUnbana]")
        end
        local username = login
        local reason = table.concat({...}, " ")

        local qh = dbQuery(DBConnection, "SELECT * FROM users WHERE username = ?", username)
        local result = dbPoll(qh, -1)
        dbFree(qh)
        if #result < 1 then
            return exports["p_box"]:addNotification(sourcePlayer, "Nie ma takiego konta w bazie danych.")
        end
        local db = dbQuery(DBConnection,"UPDATE users SET banTimeStamp = ?, banReason = ? WHERE username = ?","0","0",username)
        dbFree(db)
        exports.p_box:addNotification(sourcePlayer, "Gracz " .. username .. " zostal odbanowany.")
    -- logi czemu ktos komus dal ub?
    end
end
addCommandHandler("unban", unbanPlayerHandler, false, false)

function blackListHandler(sourcePlayer, commandname, login, ...) -- banowanie seriali, nie moze wejsc nawet na serwer.
    if getAdminPower(sourcePlayer) == 2 then
        if not (...) then
            return exports["p_box"]:addNotification(sourcePlayer, "/blacklist [login] [powod]")
        end
        local qh = dbQuery(DBConnection, "SELECT * FROM users WHERE username = ?", login)
        local result = dbPoll(qh, -1)
        dbFree(qh)
        if #result < 1 then
            return exports["p_box"]:addNotification(sourcePlayer, "Nie ma takiego konta w bazie danych.")
        end
        local serial
        local reason = table.concat({...}, " ")

        for i, row in ipairs(result) do
            serial = row["serial"]
        end
        if serial == "0" then
            return exports["p_box"]:addNotification(sourcePlayer,"Nie możesz zbanować gracza który nigdy nie zalogował się na konto.")
        end

        addBan(nil, nil, serial, sourcePlayer, reason) 
    end
end
addCommandHandler("blacklist", blackListHandler, false, false)


function getCoordinates(sourcePlayer)
if getElementData(sourcePlayer,"p:adminlevel") then
local x,y,z = getElementPosition(sourcePlayer)
local r,o,t = getElementRotation(sourcePlayer)
outputChatBox("Pozycja: "..x.." "..y.." "..z ,sourcePlayer)
outputChatBox("Rotacja: "..r.." "..o.." "..t ,sourcePlayer)


end
end
addCommandHandler("getpos", getCoordinates, false, false)

function teleportToPlayer(sourcePlayer, commandname, target)
if getElementData(sourcePlayer,"p:adminlevel") then
if not (target) then return exports["p_box"]:addNotification(sourcePlayer,"Nie podałeś nicku/id gracza do którego chcesz się przeteleportować.") end
targetPlayer = findPlayer(sourcePlayer, target)
if targetPlayer then
local x,y,z = getElementPosition(targetPlayer)
local world = getElementDimension(targetPlayer)
local interior = getElementInterior(targetPlayer)
setElementDimension(sourcePlayer, world)
setElementPosition(sourcePlayer,x,y+1,z)
setElementInterior(sourcePlayer, interior)
outputChatBox("Przeteleportował się do ciebie "..getAdminTitle(sourcePlayer).." "..getPlayerName(sourcePlayer), targetPlayer, 160, 150, 100)
end

end
end
addCommandHandler("tp", teleportToPlayer, false, false)

function teleportPlayerToYou(sourcePlayer, commandname, target)
if getElementData(sourcePlayer,"p:adminlevel") then
if not (target) then return exports["p_box"]:addNotification(sourcePlayer,"Nie podałeś nicku/id gracza do którego chcesz się przeteleportować.") end
targetPlayer = findPlayer(sourcePlayer, target)
if targetPlayer then
local x,y,z = getElementPosition(sourcePlayer)
local world = getElementDimension(sourcePlayer)
local interior = getElementInterior(sourcePlayer)
setElementDimension(targetPlayer, world)
setElementInterior(targetPlayer, interior)
setElementPosition(targetPlayer,x,y+1,z)
outputChatBox("Przeteleportował cię do siebie "..getAdminTitle(sourcePlayer).." "..getPlayerName(sourcePlayer), targetPlayer, 160, 150, 100)
end

end
end
addCommandHandler("tphere", teleportPlayerToYou, false, false)

function checkMK(sourcePlayer, commandname, target)
if getElementData(sourcePlayer,"p:adminlevel") then
if not (target) then return exports["p_box"]:addNotification(sourcePlayer,"Nie podałeś nicku/id gracza którego chcesz sprawdzić.") end
targetPlayer = findPlayer(sourcePlayer, target)
if targetPlayer then
local serial = getPlayerSerial(targetPlayer)
  local qh = dbQuery(DBConnection, "SELECT * FROM users WHERE serial = ?", serial)
        local result = dbPoll(qh, -1)
        dbFree(qh)
		outputChatBox("Konta gracza:", sourcePlayer)
for i, row in ipairs(result) do
-- iprint(result)
            outputChatBox(row["username"], sourcePlayer)
        end
		
end

end
end
addCommandHandler("checkmk", checkMK, false, false)


