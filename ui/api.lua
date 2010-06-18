function ui.run()
	ui.mainwindow.window:show_all()
	
	gtk.main()
end

function ui.message(str)
	local buf = ui.mainwindow.messages:get_buffer()
	
	buf:insert_at_cursor(str.."\n", #str+1)

	local mark = buf:get_mark "scroller"
	if not mark then
		local iter = gtk.TextIter.new()
		buf:get_end_iter(iter)
		mark = buf:create_mark("scroller", iter, false)
	end
	ui.mainwindow.messages:scroll_to_mark(mark)
end

function ui.set_info(text, image)
	-- FIXME
	ui.message("STUB: set_info")
end

function ui.add_field(field)
	--FIXME update field list
	ui.fields[field] = ui.field(field)
end

function ui.remove_field(field)
	-- FIXME update field list
	ui.fields[field]:destroy()
	ui.fields[field] = nil
end
