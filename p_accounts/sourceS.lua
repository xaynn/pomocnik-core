local weekDays = {"Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela"}

function formatDate(format, escaper, timestamp)
	escaper = escaper or "'"
	escaper = string.sub(escaper, 1, 1)

	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false

	time.year = time.year + 1900
	time.month = time.month + 1
	
	local datetime = {
		d = string.format("%02d", time.monthday),
		h = string.format("%02d", time.hour),
		i = string.format("%02d", time.minute),
		m = string.format("%02d", time.month),
		s = string.format("%02d", time.second),
		w = string.sub(weekDays[time.weekday + 1], 1, 2),
		W = weekDays[time.weekday + 1],
		y = string.sub(tostring(time.year), -2),
		Y = time.year
	}
	
	for char in string.gmatch(format, ".") do
		if char == escaper then
			escaped = not escaped
		else
			formattedDate = formattedDate .. (not escaped and datetime[char] or char)
		end
	end
	
	return formattedDate
end

function connect()
    DBConnection = dbConnect( "mysql", "dbname=pomocnik;host=127.0.0.1;charset=utf8", "root", "", "share=1" )
    if (not DBConnection) then
        outputDebugString("Error: Failed to establish connection to the MySQL database server")
    else
        outputDebugString("Success: Connected to the MySQL database server")
    end
end

addEventHandler("onResourceStart",resourceRoot, connect)

function check(pattern, ...)
	if type(pattern) ~= 'string' then check('s', pattern) end
	local types = {s = "string", n = "number", b = "boolean", f = "function", t = "table", u = "userdata"}
	for i=1, #pattern do
		local c = pattern:sub(i,i)
		local t = #arg > 0 and type(arg[i])
		if not t then error('got pattern but missing args') end
		if t ~= types[c] then error(("bad argument #%s to '%s' (%s expected, got %s)"):format(i, debug.getinfo(2, "n").name, types[c], tostring(t)), 3) end
	end
end
addEvent("onTryLogin", true)
addEventHandler(
    "onTryLogin",
    root,
    function(username, password)

        if string.len(password) < 4 or string.len(username) < 3 then
            return exports["p_box"]:addNotification(client, "Hasło lub login posiada za mało znaków..")
        end

        local qh = dbQuery(DBConnection, "SELECT * FROM users WHERE username = ?", username) --SELECT username,password FROM users WHERE username = '$login'"
        local result = dbPoll(qh, -1)
        dbFree(qh)
        if #result < 1 then
		return exports["p_box"]:addNotification(client, "Nie ma takiego konta w bazie danych.")
        end
        local hashedPassword
		local serial
		local username
		local GUID
		local adminlevel
		local banTimeStamp
		local banReason
		local premium
		-- secretkey = 1
        for i, row in ipairs(result) do
            hashedPassword = row["password"]
			username = row["username"]
			GUID = row["id"]
			adminlevel = row["adminlevel"]
			banTimeStamp = row["banTimeStamp"]
			banReason = row["banReason"]
			premium = row["premium"]
			serial = row["serial"]
			
        end
        local checkPass = passwordVerify(password, hashedPassword)
        if checkPass then
			-- if secretkey == "0" then
			-- local genSecret = base64Encode(math.random(1,255)..GUID..username..math.random(1,500))
			-- local qhh = dbQuery ( DBConnection, "UPDATE users SET secretKey = ?, serial = ?  WHERE username = ?", genSecret, getPlayerSerial(client), username)
			-- dbFree(qhh)
			-- end

			if serial == "0" then -- pierwsze logowanie po stworzeniu konta
			local genSecret = base64Encode(math.random(1,255)..GUID..username..math.random(1,500))
			local playerSerial = getPlayerSerial(client)
			local qhh = dbQuery ( DBConnection, "UPDATE users SET secretKey = ?, serial = ?  WHERE username = ?", genSecret, getPlayerSerial(client), username)
			dbFree(qhh)
			-- elseif serial == "1" then -- zresetowano przy uzyciu strony haslo do konta
			elseif serial ~= getPlayerSerial(client) then return exports["p_box"]:addNotification(client,"Serial nie zgadza się z przypisanym kontem, możliwe zresetowanie hasła tylko poprzez secretKey na stronie.") 

			end
			if banTimeStamp > getRealTime().timestamp then
			return exports["p_box"]:addNotification(client, "Konto zostało zbanowane z powodem "..banReason.." do "..formatDate("Y/m/d h:i:s", "'", tonumber(banTimeStamp)) )
			end
			if premium > getRealTime().timestamp then
			exports["p_box"]:addNotification(client, "Posiadasz konto premium do: "..formatDate("Y/m/d h:i:s", "'", tonumber(premium)).." dziękujemy za wsparcie :)")
			setElementData(client,"p:premium", true)
			end
            exports["p_box"]:addNotification(client, "Pomyślnie zalogowano, ekipa życzy miłej gry "..username.." (UID: "..GUID..")")
			triggerClientEvent(client,"onSuccesfulLogin",client)
			spawnPlayer(client, 2178.89941, -1770.78381, 13.54373, 0, 0)
			setElementData(client,"p:loggedIn", true)
			setElementData(client,"p:GUID",GUID)
			setPedWalkingStyle(client,118)
			if adminlevel > 0 then
			setElementData(client,"p:adminlevel", adminlevel)
			end

        else
            exports["p_box"]:addNotification(client, "Podane hasło jest nieprawidłowe.")
        end
    end
)
			function DajVipTest()
			print("funkcja")
			local now = getRealTime().timestamp
			local przeliczenie = 5 * 86400
			local final = now + przeliczenie
			dbQuery(DBConnection, "UPDATE users SET premium = ? WHERE username = ?",final,"insane")
			dbQuery(DBConnection, "UPDATE users SET banTimeStamp = ?, banReason = ? WHERE username = ?",final,"testowy ban", "insane")

			end
			addCommandHandler("xdd", DajVipTest)
			
