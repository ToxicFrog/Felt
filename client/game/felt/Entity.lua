class(..., "game.felt.Object")

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

-- width and height of this object. Used for mouse collision detection, mostly.
w,h = 16,16

-- sorting function to use for children; defaults to sort by descending Z order
z_sort = f 'lhs,rhs -> lhs.z > rhs.z'

-- object name - used for pickup messages and the like
name = "(FIXME - nameless object)"

if not _DEBUG then
    function __tostring(self)
        if self.concealed and self.__tostring_concealed then
            return self:__tostring_concealed()
        end
        return self.name
    end
end

-- recieve an event
-- event handling rules are as follows:
-- - parent's "before" or "event_before"
-- - all children in Z-order
-- - parent's event handler or event()
function dispatchEvent(self, evt, x, y, ...)
	-- invisible widgets do not process events
	if self.invisible then return end
	
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

mixin "ui.render.default" ()

-- returns an iterator over the children of this widget in front-to-back order
function childrenFTB(self)
	return coroutine.wrap(function()
		for i=1,#self.children do
			coroutine.yield(self.children[i])
		end
	end)
end

function top_child(self)
    return self.children[1]
end

-- returns an iterator over the children of this widget in back to front order
function childrenBTF(self)
	return coroutine.wrap(function()
		for i=#self.children,1,-1 do
			coroutine.yield(self.children[i])
		end
	end)
end

function bottom_child(self)
    return self.children[#self.children]
end

-- recursively update visibility status
function client_conceal(self, concealed)
	self.concealed = concealed
	
	for child in self:childrenFTB() do
		child:client_conceal(concealed)
	end
end

-- add a new child widget
function client_add(self, child, x, y)
    if child.parent then
        child.parent:client_remove(child)
    end
    
    -- update visibility flags
    if self.concealed ~= child.concealed then
    	child:client_conceal(self.concealed)
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
