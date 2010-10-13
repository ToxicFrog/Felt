-- establish a connection to the server and send a message saying who
-- we are. The server will reply either telling us to shut up (and closing
-- the connection) or by telling us to set up a game.
function client.connect(host, port, pass)
	assert(not client.server, "Already connected to "..tostring(client.server))
	client.client = new "client.Client" {
		server = new "client.RemoteServer" {
			host = host;
			port = port;
		}
	}
	if 
	client.client.server:newPlayer(felt.config.name, felt.config.colour, pass)
end

-- this is a bit different; the server is running in the same process as the
-- client. We need to push our join event into the server's event queue
-- directly.
function client.connectlocal(pass)
	client.client = new "client.Client" {
		server = new "client.LocalServer" { server = server.server };
		name = felt.config.get "name";
		colour = felt.config.get "colour";
		pass = pass;
	}
end
