function playMusic()
    local rand = math.random(1, 3)
    sound = playSound("files/" .. rand .. ".mp3")
    setSoundEffectEnabled(sound, "compressor", true)
end
addEventHandler("onClientResourceStart", resourceRoot, playMusic)

local x = 0
function setSoundEffectRG()
    if sound then
        x = x + 0.001
        loginGui.alpha = loginGui.alpha + 1
        if x > 3 or loginGui.alpha > 254 then
            removeEventHandler("onClientRender", root, setSoundEffectRG)
        end
		if isElement(sound) then
        setSoundVolume(sound, x)
		end
    end
end
addEventHandler("onClientRender", root, setSoundEffectRG)

function StopMusic(key, keystate)
    if loginGui.isPlayerLogging == true then
        if keystate == "down" then
            -- print("klikniety")
            if (isSoundPaused(sound)) then
                setSoundPaused(sound, false)
            else
                setSoundPaused(sound, true)
            end
        end
    end
end
bindKey("end", "down", StopMusic)
