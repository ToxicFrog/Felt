local super = class(..., "game.felt.Object")

pack = {
    "x", "y", "z", "w", "h";
    "name", "game", "face";
    "children"; -- we don't broadcast "parent" and instead construct it on the client to avoid circularity
    "actions";
}

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

-- size of this object
w,h = 16,16

-- the game box this object originated from - used to search for graphics on the client
game = false

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
    child:moveto(self, x, y)
end

function remove(self, child)
    child.parent = nil
    for i=1,#self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            return
        end
    end
end

-- relocate an entity
function moveto(self, parent, x, y)
    if parent and self.parent and self.parent ~= parent then
        self.parent:remove(self)
    end

    self.x = x or self.x
    self.y = y or self.y

    if parent and self.parent ~= parent then
        self.parent = parent or self.parent
        parent.children[#parent.children+1] = self
    end

    self:send("moveto", parent, x, y)
end

function destroy(self)
    for child in self:childrenFTB() do
        child:destroy()
    end
    super.destroy(self)
end
