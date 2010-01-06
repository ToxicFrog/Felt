local Widget = require("Object"):subclass "Widget"

Widget:defaults {
    x = 0,
    y = 0,
    z = 0,
    w = 16,
    h = 16,
    z_sort = L 'lhs,rhs -> lhs.z > rhs.z';
    visible = true;
    _persistent = {};
}

function Widget:__init(...)
    self._children = {}
    Object.__init(self, ...)
    
    print(self.menu)
    
    if self.menu and self.menu._NAME ~= "Menu" then
        self.menu = require "Menu" (self.menu)
        self.menu.context = self
    end
    
    felt.log("Created %s%s", self._NAME, self.menu and " with menu" or "")
end

function Widget:__tostring()
    return self.__super._NAME
end

function Widget:__save()
    local buf = { self._NAME..":load {" }
    
    for k in pairs(self._persistent) do
        buf[#buf+1] = string.format("\t[%s] = %s;", felt.repr(k), felt.repr(self[k]))
    end
    
    buf[#buf+1] = "}"
    
    return table.concat(buf, "\n")
end

function Widget:load(t)
    local children = t._children; t._children = nil
    local w = self(t)
    for i,c in ipairs(children or {}) do
        w:add(c)
    end
    w:sort()
    return w
end

function Widget:persistent(...)
    if self._persistent == self.__super._persistent then
        self._persistent = {}
        for k in pairs(self.__super._persistent) do
            self._persistent[k] = true
        end
    end
    
    local function aux(key, ...)
        if not key then
            return aux
        end
        
        if type(key) == "table" then
            aux(unpack(key))
        else
            self._persistent[key] = true
        end
        return aux(...)
    end
    
    return aux(...)
end

Widget:persistent "x" "y" "z" "w" "h" "_children"

function Widget:transitory(...)
    if self._persistent == self.__super._persistent then
        self._persistent = {}
        for k in pairs(self.__super._persistent) do
            self._persistent[k] = true
        end
    end
    
    local function aux(key, ...)
        if not key then
            return aux
        end
        
        if type(key) == "table" then
            aux(unpack(key))
        else
            self._persistent[key] = nil
        end
        return aux(...)
    end
    
    return aux(...)
end

--
-- functions for manipulating children
--

-- add a new child widget
function Widget:add(child, x, y)
    print("add", self, child, x, y)
    child.x = x or child.x
    child.y = y or child.y
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
function Widget:childInBounds(child, x, y)
    local _x = child.x + (child.x < 0 and self.w or 0)
    local _y = child.y + (child.y < 0 and self.h or 0)
    
    return child:inBounds(x - _x, y - _y)
end

function Widget:inBounds(x, y)
    return x > 0 and y > 0 and x < self.w and y < self.h
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
        if self:childInBounds(child, x, y) then
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

-- recieve an event
-- first, we see if we have an event handler for it, and if so call it
-- if it returns true, the event stops there
-- otherwise, dispatch it also to our children, with the same rules   
function Widget:event(type, x, y, ...)
    if not self.visible then return end
    
    local function callhandler(key, ...)
        local eventhandler = self[key]
        if eventhandler then
            local result = eventhandler(self, x, y, ...)
            assert(result == true or result == false, "event handler "..self._NAME..":"..key.." did not return a value")
            return result
        end
    end
    
    if callhandler(type.."_before", ...) then
        return true
    end

    for child in self:children() do
        if self:childInBounds(child, x, y)
        and child:event(type, x - child.x, y - child.y, ...)
        then
            return true
        end
    end

    if callhandler(type, ...) then
        return true
    end
    
end

--
-- drawing functions
--

-- internal rendering function. Render self, then render all children in
-- reverse order
function Widget:render(scale, x, y, w, h)
    if not self.visible then return end
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
    
    love.graphics.rectangle("line", x, y, w, h)
end

function Widget:click_right(x, y)
    felt.log("%s right click (%d,%d) menu=%s", tostring(self), x, y, tostring(self.menu))
    if self.menu then
        local _x,_y = self:trueXY()
        self.menu:show(_x + x, _y + y)
        felt.log("display menu at (%d,%d)", _x+x, _y+y)
    end
    
    return true
end

function Widget:destroy()
    if self.parent then
        self.parent:remove(self)
    end
    
    self.visible = false
end

return Widget

