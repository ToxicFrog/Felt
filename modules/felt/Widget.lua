local super = class(..., "felt.Object")

x,y,z = 0,0,0
w,h = 16,16
alpha = 1.0
scale = 1.0
z_sort = L 'lhs,rhs -> lhs.z > rhs.z'
visible = true
focused = false
id = false

mixin "serialize" ("x", "y", "z", "w", "h", "alpha", "scale", "visible", "focused", "children")

function __init(self, ...)
    super.__init(self, ...)
    
    local children = self.children or {}
	self.children = {}
    for _,child in pairs(children) do
    	print("add child", child)
    	self:add(child)
    end
end

function __tostring(self)
    return (self.name or self.title or super.__tostring(self))..":"..self._ID
end

-- recieve an event
-- event handling rules are as follows:
-- - parent's "before" or "event_before"
-- - all children in Z-order
-- - parent's event handler or event()
function dispatchEvent(self, evt, x, y, ...)
    local function callhandler(key, ...)
        local eventhandler = self[key]
        if eventhandler then
            local result = eventhandler(self, ...)
            assert(result ~= nil, "event handler "..self._NAME..":"..key.." did not return a value")
            return result
        end
    end
    
    local r = callhandler(evt.."_before", x, y, ...)
    	   or callhandler("event_before", evt, x, y, ...)
	if r then return r == true end

    for child in self:childrenFTB() do
        if child:inBounds(child:parentToChildCoordinates(x, y)) then
        	local x,y = child:parentToChildCoordinates(x,y)
            r = child:dispatchEvent(evt, x, y, ...)
            if r then return r end
        end
    end

    return callhandler(evt, x, y, ...) or callhandler("event", evt, x, y, ...)
end

-- translate coordinates in the parent's coordinate space to the child's.
function parentToChildCoordinates(self, x, y)
	return (x and x - self.x or nil), (y and y - self.y or nil)
end

-- return true if the specified coordinates are within the widget's bounding
-- box. Coordinates are relative to the widget's coordinate space, so by default
-- anything from (0,0) to (w,h) is in bounds.
-- If x or y is unspecified, return true.
function inBounds(self, x, y)
	return (not x or not y)
		or (x >= 0 and x <= self.w and y >= 0 and y <= self.h)
end

-- internal rendering function. Render self, then render all children in
-- reverse order
function render(self, cr)
    if not self.visible then return end
    
	cr:translate(self.x, self.y)
    cr:scale(self.scale, self.scale)
    
    self:draw(cr)
    
    for child in self:childrenBTF() do
    	cr:save()
    	child:render(cr)
    	cr:restore()
    end
end

function draw(self, cr)
	cr:set_source_rgba(1, 0, 0, 1)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end

-- returns an iterator over the children of this widget in front-to-back order
function childrenFTB(self)
	return coroutine.wrap(function()
		for i=1,#self.children do
			coroutine.yield(self.children[i])
		end
	end)
end

-- returns an iterator over the children of this widget in back to front order
function childrenBTF(self)
	return coroutine.wrap(function()
		for i=#self.children,1,-1 do
			coroutine.yield(self.children[i])
		end
	end)
end

-- add a new child widget
function client_add(self, child, x, y)
    if child.parent then
        child.parent:client_remove(child)
    end
    child.x = x or child.x
    child.y = y or child.y
    child.parent = self
    self.children[#self.children+1] = child
    self:sort()
    return child
end

-- remove a child widget
function client_remove(self, child)
    for i,c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            return c
        end
    end
    return nil
end

-- sort the children by Z-value
function sort(self)
    table.sort(self.children, self.z_sort)
end

-- raise this widget to the top of the stack
function client_raise(self)
	-- widgets pinned at top or bottom ignore raise
    if self.z == -math.huge or self.z == math.huge then return end
    
    local z = 0
    
    for sibling in self.parent:childrenFTB() do
    	if sibling.z == -math.huge then break end
    	if sibling.z < math.huge then
    		z = sibling.z + 1
    		break
    	end
    end
    
    self.z = z
    self.parent:sort()
end

function client_lower(self)
	-- widgets pinned at top or bottom ignore lower
    if self.z == -math.huge or self.z == math.huge then return end
    
    local z = 0
    
    for sibling in self.parent:childrenFTB() do
    	if sibling.z == math.huge then break end
    	if sibling.z > -math.huge then
    		z = sibling.z - 1
    		break
    	end
    end
    
    self.z = z
    self.parent:sort()
end



-----------------------------
-- old code
-----------------------------

--[==[
function Widget:setHidden() end

-- Widget:save "x" "y" "z" "w" "h" "id" "mixins" "__type" FIXME


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
        if child.id then
            i = i+1
            append(felt.serialize(i, child))
        end
    end
    append "t"
    append "l"
    
    return table.concat(buf, "")
end

function Widget:load(t, children)
    if t.id and felt.widgets[t.id] then
        assert(self._NAME == felt.widgets[t.id]._NAME
            , "type mismatch in ID-overlapped load: existing '"
                ..felt.widgets[t.id]._NAME
                .."', loading '"
                ..self._NAME
                .."'")
        return felt.widgets[t.id]
    end
    
    local w = self(t)
    print("load", self._NAME, t.id, felt.widgets[t.id])
    
    for i,c in ipairs(children or {}) do
        w:add(c)
    end
    
    w:sort()
    
    if w.menu then
	    print("done loading", w, w.menu, w.menu.__type, w.menu._NAME)
	end
    
    return w
end
--
-- functions for manipulating children
--

function Widget:hide()
    self:event("leave")
    self.parent:remove(self)
end

function Widget:show()
    assert(self.parent, "show called on unattached widget")
    self.parent:add(self)
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
    return x > 0
    and y > 0
    and x < self.w
    and y < self.h
end


-- find the child widget at the given coordinates
function Widget:find(x, y)
    for child in self:children() do
        if self:childInBounds(child, x, y) then
            return child
        end
    end
end

--
-- event handling
--

--
-- drawing functions
--

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
    	print("menu", self, self.name, self._NAME, self.__type)
        local _x,_y = self:trueXY()
    
        print(self._NAME, "menu", self.menu, self.menu.__type, self.menu._NAME, self.menu.show)

        self.menu:show(_x + x, _y + y)
        felt.log("display menu at (%d,%d)", _x+x, _y+y)
        return true
    end
    
    return false
end

function Widget:destroy()
    print("destroy", self, self.id, felt.widgets[self.id], felt.widgets[self.id] == self)
    if self.parent then
        self.parent:remove(self)
    end
    
    if felt.widgets[self.id] == self then
        felt.widgets[self.id] = nil
    end
    
    while #self.children > 0 do
        self.children[1]:destroy()
    end
    
    self.visible = false
end

function Widget:enter()
    self.focused = true
    return true
end

function Widget:leave()
    self.focused = false
    return false
end
--]==]--
