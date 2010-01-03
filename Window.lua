local Window = require("Widget"):subclass "Window"


local TitleBar = require("Widget"):subclass "TitleBar"
do
    function TitleBar:__init(win)
        Widget.__init(self, {
            x = 1;
            y = 1;
            w = win.w - 13;
            h = 10;
        })
    end
    
    function TitleBar:resize()
        self.w = self.parent.w - 13
    end
    
    function TitleBar:draw(scale, x, y)
        love.graphics.pushClip(x, y, self.w, self.h)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.rectangle(love.draw_fill, x, y, self.w, self.h)
        love.graphics.setColour(255, 255, 255, 255)
        love.graphics.draw(self.parent.title, x+1, y+9)
        love.graphics.popClip()
    end
    
    function TitleBar:grab()
        self.parent:raise()
        return self.parent
    end
    
    function TitleBar:click_right()
        if self.parent.folded then
            self.parent:unfold()
        else
            self.parent:fold()
        end
        return true
    end
end

local Resizer = require("Widget"):subclass "Resizer"
do
    function Resizer:__init(win)
        Widget.__init(self, {
            x = -11;
            y = 1;
            w = 10;
            h = 10;
        })
    end
    
    function Resizer:draw(scale, x, y)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.rectangle(love.draw_fill, x, y, self.w, self.h)
        love.graphics.setColour(128, 128, 128, 255)
        love.graphics.triangle(love.draw_fill,
            x + 2, y + 1,
            x + self.w - 1, y + 1,
            x + self.w - 1, y + self.h - 2
        )
    end
    
    function Resizer:grab()
        return self
    end
    
    function Resizer:drag_left(dx, dy)
        self.parent:resize(self.parent.w + dx, self.parent.h - dy)
        return true
    end
end

Window:defaults {
    folded = false;
    title = "(untitled)";
    owned_by = {};
    visible_to = {};
    w = 64;
    h = 64;
}

function Window:__init(...)
    Widget.__init(self, ...)
    
    self.titlebar = self:add(TitleBar(self))
    self.resizer = self:add(Resizer(self))
    self.table = self:add(require "Table" {
        x = 1,
        y = 12,
        w = self.w - 2,
        h = self.h - 13,
    })
    
    self.true_h = self.h
    if self.folded then
        self:fold()
    end
end

function Window:drag_left(dx, dy)
    self.x = math.max(0,
        math.min(self.x + dx, love.graphics.getWidth() - self.w))
    self.y = math.max(0,
        math.min(self.y + dy, love.graphics.getHeight() - self.h))
    return true
end

-- display window context menu
--  close window
--  move window contents
--  rename window
--  set permissions
--  set visibility
function Window:click_right()
end

function Window:resize(w, h)
    -- adjust width. This is easy.
    local maxwidth = love.graphics.getWidth() - self.x
    self.w = math.min(maxwidth, math.max(64, w))

    -- adjust height. This is hard.
    if not self.folded then
        local bottom = self.y + self.h
        
        self.h = math.max(64, h)
        self.y = bottom - self.h
        
        if self.y <= 0 then
            self.h = self.h + self.y
            self.y = 0
        end
        
        self.true_h = self.h
    end
    
    self.titlebar.w = self.w - 13
    self.table.w = self.w - 2
    self.table.h = self.h - 13
end

function Window:fold()
    self.folded = true
    self.h = self.titlebar.h + 2
end

function Window:unfold()
    self.folded = false
    self.h = self.true_h
end

function Window:draw(scale, x, y)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.rectangle(love.draw_fill, x, y, self.w, self.h)
end

