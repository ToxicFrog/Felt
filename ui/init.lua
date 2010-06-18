require "lgob.gdk"
require "lgob.gtk"
require "lgob.cairo"

ui = {}

function gtk.Builder.new_from_file(file, root)
	local builder = gtk.Builder.new()

	local success,code,err = builder:add_from_file(file)
	local seen_err = {}
	while not success do
		if err:match("^Invalid object type") and not seen_err[err] then
			seen_err[err] = true
			gtk[err:match("Invalid object type `Gtk(.*)'")].new()
			success,code,err = builder:add_from_file(file)
		else
			error(err)
		end
	end
	
	local function wrapwidget(widget)
		if getmetatable(widget).__newindex then return widget end
		getmetatable(widget).__newindex = function(self, key, value)
			if type(value) ~= "function" then
				self[key] = value; return
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
