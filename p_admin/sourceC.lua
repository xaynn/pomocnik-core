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



function getAdminTitle(player)
local rank =  getRankFromAdmin(getElementData(player,"p:adminlevel"))
return rank
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