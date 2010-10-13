-- implementation of "join game" tab.

-- widgets:
--  host_port     - the server's port number
--  host_require_password
--  host_password - the game password, if reuired (server will ignore it if it's not)
--  host_restore_game
--  host_game_file
--  host_ok       - the button that makes the magic happen

local file = nil

-- automatically save configuration settings on page change
-- FIXME: do we want to save more settings than just these?
function ui.win.main_notebook:switch_page(...)
	local port = tonumber(ui.win.host_port:get("text"))
	
	felt.config.set("host:port", port)
end

-- start a new game
function ui.win.host_ok:clicked()
	local port = tonumber(ui.win.host_port:get("text"))
	local pass
	local file
	
	if ui.win.host_require_password:get_active() then
		pass = ui.win.host_password:get("text")
		if #pass == 0 then
			return ui.error("If passwords are enabled, you must specify one.")
		end
	end
	
	if ui.win.host_restore_game:get_active() then
		file = ui.win.host_game_file:get_file()
		if not file then
			return ui.error("If restoring a game, you must select a game file.")
		end
		file = file:get_path()
	end
	
	if not port or port <= 0 or port > 65535 or port % 1 ~= 0 then
		return ui.error("You must specify a valid numeric port.")
	end
	
	server.start(port, pass, file)
	client.connectlocal(pass)
end
