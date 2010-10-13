require "glib"
require "gtk"
require "gdk"
require "cairo"

ui = {}

function ui.loadFile(file)
	local builder = gtk.builder_new()
	
	local success,code,err = builder:add_from_file(file, gnome.NIL)
	assert(success, err)
	
	local function wrapwidget(widget)
		local old_newindex = getmetatable(widget).__newindex
		getmetatable(widget).__newindex = function(self, key, value)
			if type(value) ~= "function" then
				return old_newindex(self, key, value)
			end
			self:connect(key:gsub("_", "-"), value, self)
		end
		return widget
	end
	
	return setmetatable({}, {
		__index = function(self, key)
			return wrapwidget(builder:get_object(key) or error("No widget "..key.." in GtkBuilder!"))
		end;
	})
end

require "ui.api"
require "ui.field"
require "ui.mainwindow"
