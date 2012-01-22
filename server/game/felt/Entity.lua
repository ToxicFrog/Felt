class(..., "game.felt.Object")

pack = {
    "x", "y", "z";
    "name";
    "children";
    "actions";
}

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

actions = {}
function ACTION(class, name, method, ...)
    if class.actions == class._SUPER.actions then
        class.actions = {unpack(class.actions)}
    end
    table.insert(class.actions, { name, method, ... })
end
            

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
    return child
end
