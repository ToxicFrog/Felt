function love.conf(t)
    t.author = "ToxicFrog"
    t.title  = "Felt"
    
--[[
    t.screen.fullscreen = false
    t.screen.width = 800
    t.screen.height = 600

    for _,module in ipairs { "joystick", "audio", "sound", "physics" } do
        modules[module] = false
    end
--]]
end

function love.errhand(msg)
    print(msg)
end

print(love.errhand)

