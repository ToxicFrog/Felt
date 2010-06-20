require "serialize"
require "deserialize"

felt = {}

function felt.savestate()
    return string.serialize(felt.game)
end

function felt.loadstate(state)
	felt.game:destroy()
	felt.game = string.deserialize(state)
end

function felt.log(...)
	print(string.format(...))
end

-- given a widget, assign it a unique id
-- if it requests a specific id, give it that one, or error if it's already
-- in use
-- otherwise, give it the next available id
function felt.id(widget)
    local id = #felt.widgets + 1

    if type(widget.id) == 'number' then
        if felt.widgets[widget.id] then
            felt.log("error: %s wants id %d, which is already in use by %s"
                , tostring(widget)
                , widget.id
                , tostring(felt.widgets[widget.id])
                , id)
            error("id collision")
        end
        id = widget.id
    end

    widget.id = id
    felt.widgets[id] = widget
end

function felt.pickup(item)
    felt.hand:pickup(item)
end

function felt.load(buf)
    for name,t in pairs(felt.deserialize(buf)) do
        felt.add(t, name)
    end
end

function felt.newobject(buf)
    felt.deserialize(buf)
end

function felt.savegame()
	love.filesystem.mkdir("save")
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
        local buf,err = love.filesystem.read("save/"..self:get "Name")
        if not buf then
        	felt.log("Can't load game: %s", err)
		end
        felt.loadstate(buf)
    end
    felt.screen:add(new "SettingsWindow" {
        "Name", "";
        call = call;
    })
end

return felt
