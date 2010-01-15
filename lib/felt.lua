felt = {
    log = print;
    widgets = {};
    tables = {};
    players = {};
}

function felt.id(widget)
    local id = #felt.widgets + 1

    if type(widget.id) == 'number' then
        if felt.widgets[widget.id] then
            felt.log("warning: %s wants id %d, which is already in use by %s"
                , widget._NAME
                , widget.id
                , tostring(felt.widgets[widget.id])
                , id)
        end
        id = widget.id
    end

    widget.id = id
    felt.widgets[id] = widget
end

-- table management

function felt.new(x, y)
    local t = felt.add(new "Table" {}, x, y)
    felt.broadcast(0, "remoteadd", felt.serialize(t, x, y))
    return t
end

function felt.remoteadd(buf, x, y)
    return felt.add(felt.deserialize(buf), x, y)
end

function felt.add(t, x, y)
    x = x or love.graphics.getWidth()/2 - t.w/2
    y = y or love.graphics.getHeight()/2 - t.h/2
    
    if not t then return end
    print("add", t.w, t.h)
    
    local w = new "Window" {
        x = x;
        y = y;
        content = t;
    }
    felt.screen:add(w)
    felt.tables[t] = true
    
    print("addw", w.w, w.h)
    
    return t
end

function felt.remove(t, ...)
    if not t then return end
    
    -- FIXME broadcast
    t.parent:destroy()
    felt.tables[t] = nil
    -- FIXME save table for later recall
    
    return felt.remove(...)
end

function felt.pickup(item)
    felt.hand:pickup(item)
end

function felt.loadmodule(name)
    if love.filesystem.exists("modules/"..name.."/init.win") then
        felt.add(felt.deserialize(love.filesystem.read("modules/"..name.."/init.win")))
    elseif love.filesystem.exists("modules/"..name.."/init.lua") then
        felt.add(require("modules."..name..".init"))
    else
        -- FIXME load individual module classes for use
    end
end

function felt:byID(id)
    felt.log("byID %d -> %s", id, tostring(felt.widgets[id]))
    return felt.widgets[id]
end

function felt.savestate()
    return felt.serialize(felt.tables)
end

function felt.loadstate(state)
    for t in pairs(felt.tables) do
        felt.remove(t)
    end
    felt.widgets = {}
    
    for t in pairs(felt.deserialize(state)) do
        felt.add(t)
    end
end

function felt.load(buf)
    for t in pairs(felt.deserialize(buf)) do
        felt.add(t)
        felt.broadcast(0, "remoteadd", felt.serialize(t))
    end
end

function felt.newobject(buf)
    felt.id(felt.deserialize(buf))
end

function felt.savegame()
    local function call(self)
        love.filesystem.write("save/"..self:get "Name", felt.savestate())
    end
    felt.screen:add(new "SettingsWindow" {
        "Name", "";
        call = call;
    })
end

function felt.loadgame()
    local function call(self)
        felt.load(love.filesystem.read("save/"..self:get "Name"))
    end
    felt.screen:add(new "SettingsWindow" {
        "Name", "";
        call = call;
    })
end

return felt
