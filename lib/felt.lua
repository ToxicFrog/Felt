felt = {
    log = function() end;
    widgets = {};
    tables = {};
    players = {};
}

function felt.id(widget)
    local id = #felt.widgets + 1
    print("id", widget._NAME, widget.id, id)

    if type(widget.id) == 'number' then
        if felt.widgets[widget.id] then
            print("id collision", widget.id, widget._NAME, felt.widgets[widget.id])
            felt.log("warning: %s wants id %d, which is already in use by %s"
                , tostring(widget)
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

function felt.new(init, name)
    init = init or {}
    name = name or init.name or "table-"..tostring(math.random(1, 2^30))
    
    if felt.tables[name] then
        return felt.tables[name]
    end
    
    local t = felt.add(new "Table" (init), name)
    felt.broadcast(0, "remoteadd", felt.serialize(t, name))
    --felt.broadcast(0, "add", t, name)
    return t
end

function felt.remoteadd(buf)
    return felt.add(felt.deserialize(buf))
end

function felt.add(t, name)
    assert(t and name, "spurious call to add")
    
    local x = love.graphics.getWidth()/2 - t.w/2
    local y = love.graphics.getHeight()/2 - t.h/2
    
    local w = new "Window" {
        x = x;
        y = y;
        content = t;
    }
    felt.screen:add(w)
--    felt.tables[t] = name
    felt.tables[name] = t
    
    return t
end

function felt.remove(name) -- FIXME this function is a mess
    -- FIXME broadcast
    felt.tables[name].parent:destroy()
    felt.tables[name] = nil
    -- FIXME save table for later recall
end

function felt.pickup(item)
    felt.hand:pickup(item)
end

function felt.loadmodule(name)
    if love.filesystem.exists("modules/"..name:gsub("%.","/").."/init.win") then
        -- FIXME should probably scrap init.win entirely
        -- felt.add(felt.deserialize(love.filesystem.read("modules/"..name.."/init.win")))
    elseif love.filesystem.exists("modules/"..name:gsub("%.","/").."/init.lua") then
        require("modules."..name..".init")
    else
        -- FIXME load individual module classes for use
    end
end

function felt:byID(id)
    return felt.widgets[id]
end

function felt.savestate()
    return felt.serialize(felt.background,felt.tables)
end

function felt.loadstate(state)
    for name,t in pairs(felt.tables) do
        felt.remove(name)
    end
    felt.background:destroy()
    
    local bg,tables = felt.deserialize(state)
    
    bg.w = love.graphics.getWidth()
    bg.h = love.graphics.getHeight()
    felt.background = bg
    felt.screen:add(bg)
    
    for name,t in pairs(tables) do
        felt.add(t, name)
    end
end

function felt.load(buf)
    for name,t in pairs(felt.deserialize(buf)) do
        felt.add(t, name)
        felt.broadcast(0, "remoteadd", felt.serialize(t, name))
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
        local buf = love.filesystem.read("save/"..self:get "Name")
        felt.loadstate(buf)
        felt.broadcast(0, "loadstate", buf)
    end
    felt.screen:add(new "SettingsWindow" {
        "Name", "";
        call = call;
    })
end

return felt
