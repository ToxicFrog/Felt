-- previous recorded mouse position
local mx,my = love.mouse.getPosition()

-- click-x,y,button
local cx,cy,cbutton

-- currently grabbed widget
local grabbed

function love.mousepressed(x, y, button)
    -- only one button is allowed to be pressed at a time; ignore others
    if cbutton then return end
    
    -- record where and what was pressed
    cx,cy,cbutton = x,y,button
    
    -- grab the widget under the window, if it permits this
    grabbed = felt.screen:grab(x, y, button)
    print("grab", grabbed)
end

function love.mousereleased(x, y, button)
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
    felt.screen:event("click_"..love.buttons[button], cx, cy)
    
    -- clear the saved information about the mouse
    cbutton,cx,cy = nil,nil,nil
    grabbed = nil
end

function love.update(dt)
    local x,y = love.mouse.getPosition()
    
    if cx and math.abs(cx - x) > 1
    or cy and math.abs(cy - y) > 1
    then
        cx,cy = nil,nil
    end
    
    if grabbed and not cx then
        grabbed:event("drag_"..love.buttons[cbutton], x - mx, y - my)
    end
    
    if felt.screen:find(mx,my) ~= felt.screen:find(x,y) then
        felt.screen:event("leave", mx, my)
        felt.screen:event("enter", x, y)
    end
        
    
    mx,my = x,y
end

function love.keypressed(key)
    key = love.keys[key]
    
    if felt.focus then
        felt.focus:event(key, mx, my)
    else
        felt.screen:event(key, mx, my)
    end
end

