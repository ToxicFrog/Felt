-- public API to the server subsystem

server.is_running = false

function server.start(port, pass, file)
	assert(not server.is_running, "Server is already running!")
	local game
	
	if file then
		-- load game from file
		game = deserialize_file(file)
	else
		game = new "Game" {}
	end
	
	server.server = new "server.Server" {
		game = game;
		port = port;
		pass = pass;
	}
	
	server.server:start()
	
	server.is_running = true	
end

function server.stop()
	assert(server.is_running, "Server is already stopped")
	
	server.server:stop()
	server.server = nil
end
