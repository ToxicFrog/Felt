love.filesystem.include("init.lua")

love.graphics.setBackgroundColour(64, 128, 64)
love.graphics.setFont(love.graphics.newFont(love.default_font, 10))

local Screen = require "Screen"

felt = {
    screen = Screen {
        x = 0;
        y = 0;
        w = love.graphics.getWidth();
        h = love.graphics.getHeight();
    };
}

function felt.addWindow(t)
    return felt.screen:add(require "Window" (t))
end

local W = felt.addWindow { x=200, y=200, w=100, h=100, title="Test" }
    W.table:add(require "Disc" { x=0, y=0 })
    W.table:add(require "Disc" { x=50, y=50 })
    W.table:add(require "Disc" { x=70, y=30 })
    W.table:add(require "Disc" { x=200, y=100 })

function draw()
    felt.screen:render(1.0, felt.screen.x, felt.screen.y, felt.screen.w, felt.screen.h)
    if felt.menu then
        felt.menu:render(1.0, felt.menu.x, felt.menu.y, felt.menu.w, felt.menu.h)
    end
end

do -- MOUSE HANDLING --
    -- previous recorded mouse position
    local mx,my = love.mouse.getPosition()
    
    -- click-x,y,button
    local cx,cy,cbutton
    
    -- currently grabbed widget
    local grabbed
    
    function mousepressed(x, y, button)
        -- only one button is allowed to be pressed at a time; ignore others
        if cbutton then return end
        
        -- record where and what was pressed
        cx,cy,cbutton = x,y,button
        
        -- grab the widget under the window, if it permits this
        grabbed = felt.screen:grab(x, y, button)
        print("grab", grabbed)
    end
    
    function mousereleased(x, y, button)
        -- only one button is allowed to be pressed at a time; ignore others
        if button ~= cbutton then return end
        
        if grabbed then
            -- release grabbed object?
        end
        
        -- if we remember the button but not where it was pressed, that means
        -- the mouse has moved far enough to no longer be considered a "click"
        if not cx then
            cbutton = nil
            grabbed = nil
            return
        end
    
        -- emit a click event for whatever the mouse was over
        felt.screen:event("click", cx, cy, button)
        
        -- clear the saved information about the mouse
        cbutton,cx,cy = nil,nil,nil
        grabbed = nil
    end
    
    function update(dt)
        local x,y = love.mouse.getPosition()
        
        if cx and math.abs(cx - x) > 1
        or cy and math.abs(cy - y) > 1
        then
            cx,cy = nil,nil
        end
        
        if grabbed and not cx then
            grabbed:event("drag", x - mx, y - my, cbutton)
        end
        
        mx,my = x,y
    end
end -- MOUSE HANDLING --

