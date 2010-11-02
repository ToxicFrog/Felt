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
	["GdkScrollDirection:GDK_SCROLL_UP"] = "up",
	["GdkScrollDirection:GDK_SCROLL_DOWN"] = "down",
	["GdkScrollDirection:GDK_SCROLL_UP"] = "left",
	["GdkScrollDirection:GDK_SCROLL_UP"] = "right",
}
local function dirname(dir)
	return tostring(dir):match("[^_]+$"):lower()
end

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
	local win = ui.loadFile("ui/field.glade")
	win.window:set_title(field.name)

	local x,y = 0,0
	local focus = false
	
	local events = {}
	
	local function dispatch(...)
		if field:dispatchEvent(...) then
--			win.surface:queue_draw() FIXME - currently this happens automatically every 100ms
			return
		end
	end
	
	function events:motion_notify(evt)
		x,y = evt.motion.x,evt.motion.y
			
		dispatch("motion", x, y)
	end
	
	function events:button_press(evt)
		local button,state = evt.button.button,evt.button.state
		x,y = evt.button.x,evt.button.y
		
		button = buttonnames[button]
		state = keystate(state)
		
		dispatch("click_"..button, x, y, state)
	end
	
	function events:enter_notify()
		focus = true
	end
	
	function events:leave_notify()
		focus = false
	end
	
	function events:scroll(evt)
		local direction,state = evt.scroll.direction,evt.scroll.state
		x,y = evt.scroll.x,evt.scroll.y
			
		direction = dirname(direction)
		state = keystate(state)
		
		dispatch("scroll_"..direction, x, y, state)
	end
	
	function events:key_press(evt)
		local key,state = evt.key.keyval,evt.key.state
		if key <= 0 or key > 255 then return end
		
		-- key events in GTK don't have mouse coordinates attached
		-- fortunately the x and y upvalues were updated last time a mouse
		-- event happened
		
		key = string.char(key)
		state = keystate(state)
		
		dispatch("key_"..key, x, y, state)
	end

    for _,event in ipairs { "motion-notify", "enter-notify", "leave-notify", "key-press", "button-press", "scroll" } do
    	win.surface:connect(event.."-event", events[event:gsub("-", "_")], field)
    end
    
    function win.surface:realize()
    	if field.w and field.h then
    		self:set("width-request", field.w, "height-request", field.h)
    	else
    		local size = math.max(self:get_window():get_size(0,0))
    		self:set("width-request", size, "height-request", size)
    	end
	end

    function win.surface:expose_event(evt)
    	local cr = gdk.cairo_create(self:get_window())
    	local w,h = self:get_window():get_size(0,0)
    	
    	cr:set_source_rgba(0, 0.5, 0, 1)
    	cr:rectangle(0, 0, w, h)
    	cr:fill()
    	
    	-- FIXME set the transformation matrix
    	cr:translate(0, 0)
    	cr:scale(1, 1)
    	cr:rotate(0)
    	
    	-- draw the underlying field
    	field:render(cr)
    	
    	-- if the player is holding something and the mouse is infield, draw that
    	if felt.me.held and focus then
    		local item = felt.me.held
    		cr:push_group()
    		cr:translate(-item.x+x-item.w/2, -item.y+y-item.h/2)
    		item:render(cr)
    		cr:pop_group_to_source()
    		cr:paint_with_alpha(0.5)
    	end
    	
    	cr:destroy()
    	
    	return false
    end
    
    print("adding redraw to ", field)
	function field._redraw()
		win.surface:queue_draw()
		return true
	end
	field._redraw_closure = gnome.closure(field._redraw)
	glib.timeout_add(50, field._redraw_closure, nil)
	
	return win;
end
