slothbot1 = exports [ "slothbot" ]:spawnBot ( 2090.24365, -1731.49634, 13.56143, 90, 10, 0, 0, 1, 24, "hunting", true )
function respawnEventPlayer()
	if client then 
	local x,y,z = getElementPosition(client)
	local world = getElementDimension(client)
	local skin = getElementModel(client)
	local interior = getElementInterior(client)
	spawnPlayer (client, x, y, z, 0, skin, interior, world) 
	setCameraTarget(client,client)
	end
end
addEvent("p:respawnPlayer", true)
addEventHandler("p:respawnPlayer", root, respawnEventPlayer)