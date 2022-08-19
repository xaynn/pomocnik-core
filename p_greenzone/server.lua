-- Format is: {x = 0, y = 0, z = 0, width = 0, depth = 0, height = 0},
local greenzones = {
	{x = 2098.35, y = -1786.78, z = 13, width = 37, depth = 20, height = 15},
	{x = 2151.0380859375, y = -1815.2275390625, z = 13.549902915955, width = 75, depth = 65, height = 15}, -- spawn
}
--2201.2607421875, -1180.6484375, 25.890625

-- Initialize all zones on resource start
local z = {}
function initGreenzones()
	if greenzones and #greenzones ~= 0 then
		for _,v in ipairs (greenzones) do
			if v then
				if v.x and v.y and v.z and v.width and v.depth and v.height then
					local c = createColCuboid (v.x, v.y, v.z, v.width, v.depth, v.height)
					local rarea = createRadarArea (v.x, v.y, v.width, v.depth, 0, 255, 0, 150)
					setElementParent (rarea, c)
					if c then
						z[c] = true
						for _,p in ipairs (getElementsWithinColShape(c, "player")) do
							setElementData (p, "greenzone", true)
						end
						addEventHandler ("onElementDestroy", c,
							function()
								if z[source] then
									z[source] = nil
								end
							end
						)
						addEventHandler ("onColShapeHit", c,
							function (h, d)
								if h and d and isElement(h) and getElementType (h) == "player" then
									if getElementData(h, "colShapeFix_OUT") then
										removeElementData(h, "colShapeFix_OUT")
										return
									end

									if getElementData(h, "greenzone") then
										setElementData(h, "colShapeFix_IN", true)
									else
										setElementData (h, "greenzone", true)
										toggleControl (h, "fire", false)
										toggleControl (h, "aim_weapon", false)
										toggleControl (h, "vehicle_fire", false)
										toggleControl (h, "vehicle_secondary_fire", false)
										triggerClientEvent(h,"onEnterGreenzone",h)
									end
								end
							end
						)
						addEventHandler ("onColShapeHit", c,
							function (h, d)
								if h and d and isElement(h) and getElementType (h) == "vehicle" then
									setElementData(h, "greenzoneveh",true)
								end
							end
						)
						addEventHandler ("onColShapeLeave", c,
							function (h, d)
								if h and d and isElement(h) and getElementType (h) == "player" then
									if getElementData(h, "colShapeFix_IN") then
										removeElementData(h, "colShapeFix_IN")
										return
									end

									if getElementData(h, "greenzone") then
										removeElementData (h, "greenzone")
										toggleControl (h, "fire", true)
										toggleControl (h, "aim_weapon", true)
										toggleControl (h, "vehicle_fire", true)
										toggleControl (h, "vehicle_secondary_fire", true)
										triggerClientEvent(h,"onLeaveGreenzone",h)
									else
										setElementData(h, "colShapeFix_OUT", true)
									end
								end
						    end
					    )
							addEventHandler ("onColShapeLeave", c,
							function (h, d)
								if h and d and isElement(h) and getElementType (h) == "vehicle" then
									setTimer(removeElementData, 350, 1, h, "greenzoneveh")
								end
							end
						)
					end
				end
			end
		end
	end
end
addEventHandler ("onResourceStart", resourceRoot, initGreenzones)

function resetGreenzoneData()
	for _,p in ipairs (getElementsByType("player")) do
		if isElement(p) then
			removeElementData (p, "greenzone")
		end
	end
end
addEventHandler ("onResourceStop", resourceRoot, resetGreenzoneData)