local Widget = require("Object"):subclass "Widget"

local function set(init)
    local set = {}
    
    for k in pairs(init or {}) do
        set[k] = true
    end
    
    local function add(key)
        set[key] = true
        return add
    end
    
    local function remove(key)
        set[key] = nil
        return remove
    end
    
    return setmetatable(set, {
        __call = function(list, self, key)
            print("set-add",list, self, key)
            return add(key)
        end;
    }),function(self, key)
        print("set-remove", self, key)
        return remove(key)
    end
end

Widget:defaults {
    x = 0,
    y = 0,
    z = 0,
    w = 16,
    h = 16,
    z_sort = L 'lhs,rhs -> lhs.z > rhs.z';
    visible = true;
    focused = false;
    save = false;
    id = false;
}

Widget.persistent,Widget.transitory = set()
Widget.sync = set()

Widget:persistent "x" "y" "z" "w" "h" "id"

function Widget:__clone(child)
    child.persistent,child.transitory = set(self.persistent)
    child.sync = set(self.sync)
end

function Widget:__init(...)
    self.children = setmetatable({}, { __call = function() return self:ichildren() end })
    Object.__init(self, ...)
    
    if self.id then
        felt.id(self)
        print("id", self._NAME, self.id)
    end
    
    if self.menu and self.menu._NAME ~= "Menu" then
        self.menu = new "Menu" (self.menu)
        self.menu.context = self
    end
    
    for method in pairs(self.sync) do
        local key = method.."_actual"
        self[key] = self[method]
        self[method] = function(self, ...)
            local log = felt.log
            function felt.log(...)
                felt.broadcast(0, "log", ...)
                log(...)
            end
            self:broadcast(key, ...)
            local result = self[key](self, ...)
            felt.log = log
            return result
        end
    end
    
    felt.log("Created %s%s", self._NAME, self.menu and " with menu" or "")
end

function Widget:__tostring()
    return self._NAME
end

function Widget:__send()
    return string.format("L%sl"
        , felt.serialize("felt", "byID", self.id))
end

function Widget:__save()
    local buf = { "L" }
    
    local function append(s) buf[#buf+1] = s end
    
    append(felt.serialize(self._NAME, "load"))
    
    append "T"
    for k in pairs(self.persistent) do
        append(felt.serialize(k, self[k]))
    end
    append "t"
    
    append "T"
    local i = 0
    for child in self:children() do
        if child.save then
            i = i+1
            append(felt.serialize(i, child))
        end
    end
    append "t"
    append "l"
    
    return table.concat(buf, "")
end

function Widget:load(t, children)
    local w = self(t)

    for i,c in ipairs(children or {}) do
        w:add(c)
    end
    
    w:sort()
    
    return w
end
--
-- functions for manipulating children
--

-- add a new child widget
function Widget:add(child, x, y)
    if child.parent then
        child.parent:remove(child)
    end
    child.x = x or child.x
    child.y = y or child.y
    child.parent = self
    self.children[#self.children+1] = child
    self:sort()
    return child
end

-- remove a child widget
function Widget:remove(child)
    for i,c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            return c
        end
    end
    return nil
end

-- iterate over all children of this widget, in order
function Widget:ichildren()
    local i = 0
    return function()
        i = i+1
        return self.children[i]
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
    else
        x,y = 0,0
    end
    
    return x+self.x,y+self.y
end

-- return true if the given child is within these x,y coordinates relative
-- to our origin
function Widget:childInBounds(child, x, y)
    return child:inBounds(x - child.x, y - child.y)
end

function Widget:inBounds(x, y)
    return x > 0 and y > 0 and x < self.w and y < self.h
end

-- raise this widget to the top of the stack
function Widget:raise()
    local siblings = self.parent.children
    local z = 0
    
    for i=1,#siblings do
        if siblings[i].z == -math.huge then break end
        if siblings[i].z < math.huge then
            z = siblings[i].z + 1
            break
        end
    end
    self.z = z
    self.parent:sort()
end

function Widget:lower()
    local siblings = self.parent.children
    local z = 0
    
    for i=#siblings,1,-1 do
        if siblings[i].z == math.huge then break end
        if siblings[i].z > -math.huge then
            z = siblings[i].z - 1
            break
        end
    end
    self.z = z
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
    table.sort(self.children, self.z_sort)
end

--
-- event handling
--

-- recieve an event
-- first, we see if we have an event handler for it, and if so call it
-- if it returns true, the event stops there
-- otherwise, dispatch it also to our children, with the same rules   
function Widget:event(type, x, y, ...)
    if not self.visible then return end
    if type ~= "enter" and type ~= "leave" then 
        print("event", self, type, x, y, ...)
    end
    
    local function callhandler(key, ...)
        local eventhandler = self[key]
        if eventhandler then
            local result = eventhandler(self, x, y, ...)
            assert(result or result == false, "event handler "..self._NAME..":"..key.." did not return a value")
            return result
        end
    end
    
    local r = callhandler(type.."_before", ...)
    if r then return r end

    for child in self:children() do
        if not x or child:inBounds(x - child.x, y - child.y) then
            r = child:event(type, x and x - child.x, y and y - child.y, ...)
            if r then return r end
        end
    end

    return callhandler(type, ...)
end

--
-- drawing functions
--

-- internal rendering function. Render self, then render all children in
-- reverse order
function Widget:render(scale, x, y, w, h)
    if not self.visible then return end
    x = math.floor(x)
    y = math.floor(y)
    
    if self:draw(scale, x, y, w, h) then return end
    
    for i=#self.children,1,-1 do
        local child = self.children[i]
        
        child:render(scale
            , child.x * scale + x
            , child.y * scale + y
            , child.w * scale
            , child.h * scale)
    end
end

-- overloadable drawing function. Draw this widget to the screen at the specified
-- coordinates and scale
function Widget:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 0, 0, 255)
    
    love.graphics.rectangle("line", x, y, w, h)
end

function Widget:drawHidden(...)
    return self:draw(...)
end

function Widget:click_right(x, y)
    if self.menu then
        local _x,_y = self:trueXY()
        self.menu:show(_x + x, _y + y)
        felt.log("display menu at (%d,%d)", _x+x, _y+y)
        return true
    end
    
    return false
end

function Widget:destroy()
    if self.parent then
        self.parent:remove(self)
    end
    
    self.visible = false
end

function Widget:enter()
    self.focused = true
    return false
end

function Widget:leave()
    self.focused = false
    return false
end

function Widget:broadcast(...)
    return felt.broadcast(self, ...)
end

return Widget

