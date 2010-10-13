-- public API to the server subsystem

function server.start(port, pass, file)
	assert(not server.server, "Server is already running!")
	local game
	
	if file then
		-- load game from file - FIXME
		game = deserialize_file(file)
	else
		game = new "felt.Game" {}
	end
	
	server.server = new "server.Server" {
		game = game;
		port = port;
		pass = pass;
	}
end

function server.stop(reason)
	assert(server.server, "Server is already stopped")
	
	server.server:shutdown(reason)
	server.server = nil
end

function server.update()
	if server.server then
		server.updating = true
		server.server:update()
		server.updating = false
	end
	return true
end

function server.broadcast(...)
	assert(server.server)
	server.server:broadcast(...)
end
