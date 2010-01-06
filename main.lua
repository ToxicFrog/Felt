love.filesystem.load "init.lua" ()

felt = {
    log = print;
}

local function main()
    love.graphics.setBackgroundColour(64, 128, 64)
    love.graphics.setFont(10)
    love.graphics.setLineStyle("rough")

require "input"

print("main")
    local Screen = require "Screen"
    felt.screen = Screen {
        x = 0;
        y = 0;
        w = love.graphics.getWidth();
        h = love.graphics.getHeight();
    };
    felt.screen:add(require "SystemWindow" {})
    
    local W = felt.addWindow { x=200, y=200, w=100, h=100, title="Test", content = require "Table" {} }
        W.content:add(require "Token" { x=0, y=0 })
        W.content:add(require "Disc" { x=50, y=50 })
        W.content:add(require "Disc" { x=70, y=30 })
        W.content:add(require "Disc" { x=200, y=100 })
    felt.log("Initialization complete.")
    
    felt.screen:add(require "TextInput" { x = 300, y = 100 })
end

function felt.pickup(item)
    if not felt.held then
        felt.held = item
    end
end

function felt.addWindow(t)
    return felt.screen:add(require "Window" (t))
end

function love.draw()
    felt.screen:render(1.0, felt.screen.x, felt.screen.y, felt.screen.w, felt.screen.h)
    
    if felt.held then
        local x,y = love.mouse.getPosition()
        local w,h = felt.held.w,felt.held.h
        felt.held:render(1.0, x - w/2, y - h/2, w, h)
    end
end

function felt.repr(val)
    local repr = {}
    local function aux(t)
        if repr[type(t)] then
            return repr[type(t)](t)
        else
            return error("Attempt to save non-saveable type "..type(t))
        end
    end
    
    function repr.string(v)
        return string.format("%q", v)
    end
    
    function repr.number(v)
        return tostring(v)
    end
    repr.boolean = repr.number
    repr["nil"] = repr.number
    
    function repr.table(t)
        local mt = getmetatable(t)
        if mt and mt.__save then
            return mt.__save(t)
        end
        
        local buf = { "{" }
        for k,v in pairs(t) do
            buf[#buf+1] = string.format("[%s] = %s;", aux(k), aux(v))
        end
        buf[#buf+1] = "}"
        
        return table.concat(buf, " ")
    end

    return aux(val)
end

function felt.save(v)
    love.filesystem.write("save", "return "..felt.repr(v))
end

function felt.load()
    local win =  love.filesystem.load("save")()
    felt.screen:add(win)
end

return main(...)

