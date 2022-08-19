function addNotification(player, ...)
    local msg = table.concat({...}, " ")
    if isElement(player) then
        triggerClientEvent(player, "ShowNewMessage", player, msg)
    end
end

function ShowNewPenalty(player, typepenalty, amount, admin, gracz, ...)
    local reason = table.concat({...}, " ")
	-- print("huj")
    if isElement(player) then
		-- print("xd")
        triggerClientEvent(player, "ShowNewPenalty", player, true, typepenalty, amount, admin, gracz, reason)
    end
end


function testServer(player, cmand, ...)
    addNotification(player,"MUSIZSZ OGARNAC SIE, DALSZE TAKIE ZACHOWANIE ZOSTANIE UKARANE")
	ShowNewPenalty(player,"KICK", nil, "Hammer", "Maciek400PL", "test")
	 -- triggerClientEvent(player, "ShowNewPenalty", player, true, "BAN", "365d", "Hammer", "Maciek400PL", "Cheater")

end
addCommandHandler("testowe", testServer)



local playerTimers = {}
function sendStats(player)
	if isElement(player) then
		local columns, rows = getPerformanceStats("Lua timing")
		triggerClientEvent(player, "receiveServerStat", player, columns, rows)
		playerTimers[player] = setTimer(sendStats, 1000, 1, player)
	end
end

addEvent("getServerStat", true)
addEventHandler("getServerStat", root, function()
	sendStats(client)
end)

addEvent("destroyServerStat", true)
addEventHandler("destroyServerStat", root, function()
	if isTimer(playerTimers[client]) then
		killTimer(playerTimers[client])
		playerTimers[client] = nil
	end
end)