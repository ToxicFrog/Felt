local super = class(..., "felt.Widget")

id = true
w = false
h = false
name = "(untitled field)"

mixin "mixins.serialize" ("name")

function __init(self, t)
    super.__init(self, t)
    
    self.vis = self.vis or { [felt.config.get "name"] = true }
end

function draw(self)
	-- no-op
end

function click_left_before(self, x, y)
	if felt.me.held then
		return self:dispatchEvent("drop", x, y, felt.me.held)
	end
	return false
end

function drop(self, x, y, item)
	felt.me:drop(self, x, y)
    
    return true
end

do return end

Table:persistent "name" "visibleTo"

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

function Table:event(type, x, y, ...)
    x,y = self:toGrid(x,y)
    return Widget.event(self, type, x, y, ...)
end

function Table:click_left()
    return false
end

