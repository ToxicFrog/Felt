ui.fields = {}

function ui.field(field)
	local win = gtk.Builder.new_from_file("ui/field.glade")
	
    for _,event in ipairs { "EXPOSURE", "POINTER_MOTION", "BUTTON_MOTION",
    	"BUTTON_PRESS", "KEY_PRESS", "ENTER_NOTIFY", "LEAVE_NOTIFY"
    } do
    	win.surface:add_events(gdk[event.."_MASK"])
    end

    --[[
    obj:connect("motion-notify-event", felt.Table.motion, obj)
    obj:connect("enter-notify-event", felt.Table.enterleave, obj)
    obj:connect("leave-notify-event", felt.Table.enterleave, obj)
    --]]
    
    function win.surface:realize()
    	if field.w and field.h then
    		self:set("width-request", field.w, "height-request", field.h)
    	else
    		local size = math.max(self:get_size())
    		self:set("width-request", size, "height-request", size)
    	end
	end

    function win.surface:expose_event()
    	local cr = gdk.cairo_create(self:get_window())
    	local w,h = self:get_size()
    	
    	cr:set_source_rgba(0, 0.5, 0, 1)
    	cr:rectangle(0, 0, w, h)
    	cr:fill()
    	
    	-- FIXME set the transformation matrix
    	cr:translate(0, 0)
    	cr:scale(1, 1)
    	cr:rotate(0)
    	
    	-- draw the underlying field
    	field:draw(cr)
    	
    	cr:destroy()
    end

	return win;
end

--[[
function felt.Table:motion(evt)
    local _,x,y = gdk.Event.get_coords(evt)
    getmetatable(self).x = x
    getmetatable(self).y = y
    self:queue_draw()
end

function felt.Table:enterleave(evt)
    local mt = getmetatable(self)
    mt.mouse = true
end
-- Test program

local window = gtk.Window.new()

window:set("title", "Felt", "window-position", gtk.WIN_POS_CENTER)
window:connect("delete-event", gtk.main_quit)
window:set("width-request", 200, "height-request", 200)

window:add(felt.Table.new())
window:show_all()
gtk.main()
--]]
