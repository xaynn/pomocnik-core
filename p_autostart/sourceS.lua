
local loaded = false
function startAllResources ( res )
if loaded == true then return end
local resources = getResources()
loaded = true
for i,v in ipairs(resources) do
-- iprint(resources)
-- iprint(v)
if string.find(getResourceName(v), "p_") then
startResource(v)
outputDebugString("[P] resource loaded ["..getResourceName(v).."]")

end
end
end
addEventHandler ( "onResourceStart", root, startAllResources )