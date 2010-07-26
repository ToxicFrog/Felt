ui.fields = {}

-- events are:
-- click_{left,center,right}
-- drag_{left,center,right}
-- key_*
-- move
-- enter
-- leave

local buttonnames = { "left", "middle", "right" }

local dirnames = {
	[0] = "up",
	[1] = "down",
	[2] = "left",
	[3] = "right",
}

local function keystate(n)
	local state = {}

	for _,key in ipairs { "shift", "lock", "ctrl", "alt" } do
		if n % 2 == 1 then
			state[key] = true
			n = n - 1
		end
		n = n/2
	end
	
	return state
end

function ui.field(field)
	local win = gtk.Builder.new_from_file("ui/field.glade")
	
	local mouse_x,mouse_y = 0,0
	local _,x,y = nil,0,0
	
	local events = {}
	
	local function dispatch(...)
		if field:dispatchEvent(...) then
			win.surface:queue_draw()
		end
	end
	
	function events:motion_notify(evt)
		_,x,y = gdk.Event.get_coords(evt)
			
		dispatch("motion", x, y)
	end
	
	function events:button_press(evt)
		local button,state = gdk.Event.buttons(evt)
		_,x,y = gdk.Event.get_coords(evt)
		
		button = buttonnames[button]
		state = keystate(state)
		
		dispatch("click_"..button, x, y, state)
	end
	
	function events:scroll(evt)
		local direction,state = gdk.Event.scroll(evt)
		_,x,y = gdk.Event.get_coords(evt)
			
		direction = dirnames[direction]
		state = keystate(state)
		
		dispatch("scroll_"..direction, x, y, state)
	end
	
	function events:key_press(evt)
		local key,state = gdk.Event.keys(evt)
		if key <= 0 or key > 255 then return end
		
		-- key events in GTK don't have mouse coordinates attached
		-- fortunately the x and y upvalues were updated last time a mouse
		-- event happened
		
		key = string.char(key)
		state = keystate(state)
		
		dispatch("key_"..key, x, y, state)
	end

    for _,event in ipairs { "motion-notify", "key-press", "button-press", "scroll" } do
    	win.surface:connect(event.."-event", events[event:gsub("-", "_")], field)
    end
    
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
    	field:render(cr)
    	
    	cr:destroy()
    end

	return win;
end
