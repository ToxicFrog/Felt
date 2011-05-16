-- the "ui.actions" mixin
--[[
	This is where the magic happens. It's passed a table of actions supported
	by the host object, of the form:
	{
		{ "method name", "action name" [, "suggested binding" ...] };
		...
	}
	The UI is required to make -all- of these actions accessible by the user.
	The easiest way is to add them all to a right-click menu or equivalent, but
	the object is allowed to suggest binds that it thinks would make sense for
	a keyboard/mouse interface.
]]

_CLASS[".actions"] = _CLASS[".actions"] or {}
local actions = _CLASS[".actions"]

for _,v in pairs(...) do
	local method,action = unpack(v)
	local keys = {unpack(v, 3)}
	
	-- add it to the right-click menu
	table.insert(actions, v)

	-- if it has a suggested keybind, add that, too
	if #keys > 0 then for _,key in ipairs(keys) do
		-- FIXME - check against configuration file for bindings
		if _CLASS[key] then
			ui.message("Type %s overriding superclass's binding for %s with %s", _CLASS._NAME, key, action)
		end
		
		-- when performing the actual call, we use self rather than _CLASS because
		-- some methods, like the RMI stubs, don't exist until after the constructor
		-- runs
		_CLASS[key] = function(self, ...)
			local rv = self[method](self, ...)
			if rv == nil then return true end
			return rv
		end
	end end
end

if #actions > 0 then
	-- create GtkMenu holding action handlers
	local menu = gtk.menu_new()
	local active_object -- HACK HACK HACK - upvalue for object currently displaying menu
	local x,y -- HACK HACK HACK - coordinates of activation
	
	for _,action in ipairs(actions) do 
		local method,name,key = unpack(action)
		local item = gtk.menu_item_new_with_label(name)
		item:connect("activate", function()
			active_object[method](active_object, x, y)
		end)
		menu:append(item)
	end
	
	menu:show_all()
	
	-- connect menu display function
	function click_right(self, _x, _y)
		active_object,x,y = self,_x,_y
		menu:popup(nil, nil, nil, nil, 3, gtk.get_current_event_time())
		return true
	end
end
