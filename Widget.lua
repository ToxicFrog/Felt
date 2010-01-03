local Widget = require("Object"):subclass "Widget"

Widget:defaults {
    x = 0,
    y = 0,
    z = 0,
    w = 16,
    h = 16,
    z_sort = L 'lhs,rhs -> lhs.z > rhs.z';
    visible = true;
}

function Widget:__init(...)
    self._children = {}
    Object.__init(self, ...)
end

function Widget:__tostring()
    return self.__super._NAME
end

--
-- functions for manipulating children
--

-- add a new child widget
function Widget:add(child)
    child.parent = self
    self._children[#self._children+1] = child
    self:sort()
    return child
end

-- remove a child widget
function Widget:remove(child)
    for i,c in ipairs(self._children) do
        if c == child then
            table.remove(self._children, i)
            return c
        end
    end
    return nil
end

-- iterate over all children of this widget, in order
function Widget:children()
    local i = 0
    return function()
        i = i+1
        return self._children[i]
    end
end

--
-- geometric functions
--

-- return the true (ie, screen) coordinates of the upper left corner of this
-- widget
function Widget:trueXY()
    local x,y
    if self.parent then
        x,y = self.parent:trueXY()
        if self.x < 0 then x = x + self.parent.w end
        if self.y < 0 then y = y + self.parent.h end
    else
        x,y = 0,0
    end
    
    return x+self.x,y+self.y
end

-- return true if the given child is within these x,y coordinates relative
-- to our origin
function Widget:inBounds(child, x, y)
    local _x = child.x + (child.x < 0 and self.w or 0)
    local _y = child.y + (child.y < 0 and self.h or 0)
    
    assert("inbounds", self, child, x, y
     , _x <= x
        and x < _x + child.w
        and _y <= y
        and y <= _y + child.h)
     return _x <= x
        and x < _x + child.w
        and _y <= y
        and y <= _y + child.h
end

-- raise this widget to the top of the stack
function Widget:raise(n)
    n = n or self.parent._children[1].z +1
    self.z = n
    self.parent:sort()
end

-- find the child widget at the given coordinates
function Widget:find(x, y)
    for child in self:children() do
        if self:inBounds(child, x, y) then
            return child
        end
    end
end

-- sort the children by Z-value
function Widget:sort()
    table.sort(self._children, self.z_sort)
end

--
-- event handling
--

-- attempt to grab a widget. Called on mouse-down and used for dragging.
-- by default, ask all elegible children if they are grabbable and if one
-- is, return that
-- overloads should return the widget that actually gets grabbed (ie, the
-- widget that will recieve drag events)
function Widget:grab(x, y, button)
    local child = self:find(x,y)
    if child then
        return child:grab(x - child.x, y - child.y, button)
    end
    return nil
end

do -- event dispatching internals

    -- map of button numbers to button names
    local buttons = setmetatable({ [-1] = "none" }, { __index = L '_,k -> tostring(k)' })  
    for k,v in pairs(love) do
        if k:match("^mouse_%w+$") then
            buttons[v] = k:match("^mouse_(%w+)")
        end
    end

    -- recieve an event
    -- first, we see if we have an event handler for it, and if so call it
    -- if it returns true, the event stops there
    -- otherwise, dispatch it also to our children, with the same rules   
    function Widget:event(type, x, y, button, ...)
        local preeventhandler = self[type.."_"..buttons[button].."_before"]
        if preeventhandler and preeventhandler(self, x, y, ...) then
            return true
        end

        for child in self:children() do
            if self:inBounds(child, x, y)
            and child:event(type, x - child.x, y - child.y, button, ...)
            then
                return true
            end
        end

        local posteventhandler = self[type.."_"..buttons[button]]
        if posteventhandler and posteventhandler(self, x, y, ...) then
            return true
        end
        
    end
end

--
-- drawing functions
--

-- internal rendering function. Render self, then render all children in
-- reverse order
function Widget:render(scale, x, y, w, h)
    if self:draw(scale, x, y, w, h) then return end
    
    for i=#self._children,1,-1 do
        local child = self._children[i]
        
        child:render(scale
            , child.x + x + (child.x < 0 and self.w or 0)
            , child.y + y + (child.y < 0 and self.h or 0)
            , child.w
            , child.h)
    end
end

-- overloadable drawing function. Draw this widget to the screen at the specified
-- coordinates and scale
function Widget:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 0, 0, 255)
    
    love.graphics.rectangle(love.draw_outline, x, y, w, h)
end

return Widget

