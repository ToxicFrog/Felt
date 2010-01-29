local Table = require("Widget"):subclass "Table"

local DrawOverlay = require("Widget"):subclass "DrawOverlay"
do
    DrawOverlay:defaults {
        visible = false;
    }
    
    function DrawOverlay:__init()
        self.lines = {}
    end
    
    function DrawOverlay:key_d()
        self.visible = not self.visible
    end
    
    function DrawOverlay:key_e()
        self.lines = {}
    end
    
    function DrawOverlay:draw(scale, x, y, w, h)
        
    end
end

function Table:save()
    felt.screen:add(new 'SettingsWindow' {
        "Save As", self.name;
        call = function(win)
            local name = win:get("Save As"):gsub('[^%w_/]', '_')
            if #name == 0 then
                felt.log("invalid savename")
                return
            end
            local r,err = pcall(love.filesystem.write, "save/"..name, felt.serialize(self))
            if not r then
                felt.log("save failed: %s", err)
            else
                felt.log("%s saved to %s", self.title, name)
            end
        end;
    })
end

function Table:rename()
    felt.screen:add(new 'SettingsWindow' {
        "Name", self.name;
        call = function(win)
            self:setTitle(win:get "Name")
        end;
    })
end

Table:defaults {
    w = 128, h = 128;
    
    -- scale of the contents of this table
    scale = 1.0;
        
    -- location of the origin of the contents relative to upper left, px
    ox = 0, oy = 0;
    
    id = true;
    title = "(untitled table)";
}

Table.menu = {
    title = "Table";
    "Rename...", Table.rename;
    "Save...", Table.save;
}

Table:persistent "name" "visibleTo"
Table:sync "setTitle" "setVis"

function Table:add(child, ...)
    Widget.add(self, child, ...)
    child:setHidden(not self.visibleTo[felt.config.name])
    return child
end

function Table:__init(...)
    Widget.__init(self, ...)
    
    self.visibleTo = self.visibleTo or { [felt.config.name] = true }
end

function Table:click_right(x, y)
    self.mx, self.my = x,y
    return Widget.click_right(self, x, y)
end

-- convert grid coordinates to screen coordinates
function Table:toScreen(x, y)
    local _x,_y = self:trueXY()
    return x * self.scale + self.ox + _x
        ,  y * self.scale + self.oy + _y
end

-- convert screen coordinates to grid coordinates
function Table:toGrid(x, y)
    -- turn screen coordinates into viewport coordinates
    return (x - self.ox)/self.scale
        ,  (y - self.oy)/self.scale
end

function Table:childInBounds(child, x, y)
    x,y = self:toGrid(x,y)
    return child:inBounds(x - child.x, y - child.y)
end
    
function Table:pan(ox, oy)
    self.ox = ox
    self.oy = oy
end

-- set zoom factor
function Table:zoom(scale)
    self.scale = scale
end

function Table:clear()
    self.items = {}
end

function Table:grab()
    return self
end

function Table:drag_right(x, y, dx, dy)
    self:pan(self.ox + dx, self.oy + dy)
    return true
end
Table.drag_middle = Table.drag_right

function Table:click_wheeldown()
    self:zoom(self.scale * 0.9)
    return true
end

function Table:click_wheelup()
    self:zoom(self.scale * 1.1)
    return true
end

function Table:drop(x, y, item)
    felt.held = nil
    item:moveto(self, x - item.w/2, y - item.h/2)
    item:raise()
    
    return true
end

function Table:key_c()
    self:pan(0,0)
    return true
end

function Table:key_v()
    if self.closevis then
        self:closevis()
    else
        self:openvis()
    end
    return true
end

function Table:openvis()
    local buttons = {}
    local y = 20
    for name in pairs(felt.players) do
        local button = new "ToggleButton" { text = name, set = self.visibleTo[name] }
        self.parent:add(button, 10, y)
        y = y + button.h + 2
        buttons[button] = true
        button:raise()
    end
    function self:closevis()
        for button in pairs(buttons) do
            if button.set ~= self.visibleTo[button.text] then
                self:setVis(button.text, button.set)
            end
            self.parent:remove(button)
        end
        self.closevis = nil
    end
end

function Table:setVis(name, value)
    if value then
        felt.log("%s reveals %s to %s", felt.config.name, tostring(self), name)
    else
        felt.log("%s hides %s from %s", felt.config.name, tostring(self), name)
    end
    self.visibleTo[name] = value
    if name == felt.config.name then
        for child in self:children() do
            child:setHidden(not value)
        end
    end
end

function Table:setTitle(name)
    felt.log("%s renames %s to %s", felt.config.name, tostring(self), title)
    self.name = name
end

function Table:key_z()
    self:zoom(1.0)
    return true
end

function Table:draw(scale, x, y)
    love.graphics.pushClip(x, y, self.w, self.h)
    love.graphics.setColour(0, 64, 0, 255)
    love.graphics.rectangle("fill", x, y, self.w, self.h)
    
    for i=#self.children,1,-1 do
        local child = self.children[i]
        local x,y = self:toScreen(child.x, child.y)
        child:render(self.scale, x, y, child.w * self.scale, child.h * self.scale)
    end
    
    love.graphics.popClip()
    
    return true
end

function Table:event(type, x, y, ...)
    x,y = self:toGrid(x,y)
    return Widget.event(self, type, x, y, ...)
end

function Table:click_left()
    return false
end

