local super = class(..., "felt.Widget")

id = true
w = false
h = false
name = "(untitled field)"

mixin "mixins.serialize" ("name")
mixin "ui.actions" {
	maybe_drop = "click_left_before";
}

function __init(self, t)
    super.__init(self, t)
    
    self.vis = self.vis or { [felt.config.get "name"] = true }
end

-- no-op - fields are invisible
function draw(self) end

-- called when the user is possibly dropping something on the field.
-- we check if there's actually something to drop, and if so, re-emit it as
-- a "drop" event
function maybe_drop(self, x, y)
	if felt.me.held then
		return self:dispatchEvent("drop", x, y, felt.me.held)
	end
	return false
end

-- the event handler for the actual drop event
function drop(self, x, y, item)
	felt.me:drop(self, x, y)
    
    return true
end

do return end

function Table:childInBounds(child, x, y)
    x,y = self:toGrid(x,y)
    return child:inBounds(x - child.x, y - child.y)
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

function Table:event(type, x, y, ...)
    x,y = self:toGrid(x,y)
    return Widget.event(self, type, x, y, ...)
end

function Table:click_left()
    return false
end

