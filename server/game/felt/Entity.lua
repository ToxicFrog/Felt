class(..., "game.felt.Object")

pack = {
    "x", "y", "z";
    "name";
    "children";
}

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

-- sorting function to use for children; defaults to sort by descending Z order
-- do we actually ever need to sort on the server? Z-order is pretty much used
-- only for UI event dispatch and rendering order, so it needs to be preserved
-- on the server but the server doesn't actually use it for anything.
z_sort = f 'lhs,rhs -> lhs.z > rhs.z'

local _init = __init
function __init(self, ...)
    _init(self, ...)
    
    assert(self.name, "Attempted to create a widget (%s) without a name" % tostring(self))
    
    local children = self.children or {}
	self.children = {}
    for _,child in pairs(children) do
    	print("add child", child)
    	self:add(child)
    end
end

function __tostring(self)
	if _DEBUG then
		return "%s (%s: %s)" % { self.name, self._NAME, self._ID }
	end
	if self.concealed and self.__tostring_concealed then
		return self:__tostring_concealed()
	end
	return self.name
end

-- returns an iterator over the children of this widget in front-to-back order
function childrenFTB(self)
	return coroutine.wrap(function()
		for i=1,#self.children do
			coroutine.yield(self.children[i])
		end
	end)
end

-- add a new child widget
function add(self, child, x, y)
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
function remove(self, child)
    for i,c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            return c
        end
    end
    return nil
end

-- move the widget to a new parent
-- moveto(nil) can be used to remove a widget from the object heirarchy entirely
-- without deleting it
function moveto(self, parent, x, y)
	-- add() will automatically remove it from the previous parent if needed
	if parent then
		parent:add(self, x, y)
	else
		self.parent:remove(self)
	end
end

-- sort the children by Z-value
function sort(self)
    table.sort(self.children, self.z_sort)
end

-- raise this widget to the top of the stack
function raise(self)
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

function lower(self)
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
