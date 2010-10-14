-- implementation of "join game" tab.

-- widgets:
--  join_host     - the server's hostname or IP address
--  join_port     - the server's port number
--  join_password - the game password, if reuired (server will ignore it if it's not)
--  join_ok       - the button that makes the magic happen

-- automatically save configuration settings on page change
function ui.win.main_notebook:switch_page(...)
	local host = ui.win.join_host:get("text")
	local port = tonumber(ui.win.join_port:get("text"))
	
	felt.config.set("join:host", host, "join:port", port)
end

-- connect to a game
function ui.win.join_ok:clicked()
	local host = ui.win.join_host:get("text")
	local port = tonumber(ui.win.join_port:get("text"))
	local pass = ui.win.join_password:get("text")
	
	if #host == 0 then
		return ui.error("You must specify a host to connect to.")
	elseif not port or port <= 0 or port > 65535 or port % 1 ~= 0 then
		return ui.error("You must specify a valid numeric port.")
	end
	
	client:connect(host, port, pass)
end
