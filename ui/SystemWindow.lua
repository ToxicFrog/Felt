local SystemWindow = require("Window"):subclass "SystemWindow"

local SystemTextPane = new "Widget" {
    lines = {
    };
    offset = 0;
    name = "System Messages";
}

function felt.log(...)
    SystemTextPane.lines[#SystemTextPane.lines+1] = string.format(...)
end

function SystemTextPane:draw(scale, x, y, w, h)
    local lineheight = love.graphics.getFont():getHeight()
    local function getTextWidth(text)
        return love.graphics.getFont():getWidth(text)
    end
    local function getTextHeight(text, limit)
        local height = 1
        local width = 0
        for ws,word in text:gmatch("(%s*)(%S+)") do
            local wordwidth = getTextWidth(ws..word)
            if width + wordwidth > limit then
                height = height + 1
                width = getTextWidth(word)
            else
                width = width + getTextWidth(ws..word)
            end
        end
        
        return height * (lineheight+3)
    end
    
    local lines = self.lines

    love.graphics.pushClip(x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColour(255, 255, 255, 255)
    
    lx = x + 1
    ly = y + self.h
    
    for i=#lines - self.offset,math.max(1, #lines - self.offset - 256),-1 do
        if ly < y then break end
        ly = ly - getTextHeight(lines[i], w - 2) - 2
        
        love.graphics.printf(lines[i], lx, ly + lineheight, w - 2)
    end
    
    love.graphics.popClip()
end

function SystemTextPane:click_wheeldown()
    self.offset = math.max(0, self.offset - 1)
    return true
end

function SystemTextPane:click_wheelup()
    self.offset = math.min(#self.lines-1, self.offset + 1)
    return true
end

SystemWindow:defaults {
    saveable = false;
    x = 0;
    y = 0;
    w = 200;
    h = love.graphics.getHeight() - 200;
    content = SystemTextPane;
}

return SystemWindow

