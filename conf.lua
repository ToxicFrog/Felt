function love.conf(t)
    t.author = "ToxicFrog"
    t.title  = "Felt"
    
    t.screen.fullscreen = false
    t.screen.width = 640
    t.screen.height = 480

    t.modules.joystick = false
    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
end

function love.errhand(msg)
    print "Error:"
    print(msg)
end

