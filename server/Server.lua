local Server = require "Object" : subclass "Server"

Server:defaults {
	poll_delay = 0;
	accept_queue = 10;
	id = "S";
}

-- start the server running, ready for connections
function Server:start()
	self.sockets = {}
	self.events = {}
	self.socket = socket.bind('*', self.port, self.accept_queue)
end

-- shut down the server cleanly
function Server:stop()
end

-- mainloop tick function, called every frame by main
function Server:update()
	-- check for new connections
	local csock = self.socket:accept()
	while csock do
		self:addClient(csock)
		csock = self.socket:accept()
	end	
	
	-- read events from sockets into event queue
	for message in self:messages() do
		self:pushEvent(message)
	end
	for client in self:clientsReady() do
		for message in client:messages() do
			self:pushEvent(message)
		end
	end
	
	-- process event queue
	local i=1
	while self.events[i] do
		self.dispatch(self.events[i])
		i = i+1
	end
	self.events = {}
end

-- add a new client. sock is the connected TCP socket. We don't know if this
-- is a *player* yet, just a client - messages received will either promote
-- it to a player, or cause it to be disconnected
function Server:addClient(sock)
	table.insert(self.clients, new "Client" { sock=sock })
	table.insert(self.sockets, sock)
end

-- push a new event onto the event queue. Used internally by the event pump,
-- and externally by local clients (to push events without hitting the network)
function Server:pushEvent(event)
	table.insert(self.events, event)
end

-- return an iterator over all ready...clients? messages? need to think this over
function Server:messages()
	local function iter()
		local ready = socket.select(self.sockets, nil, self.poll_delay)
		for i=1,#self.sockets do
			if ready[i] then
				local msg,err = net.read(ready[i])
				while msg do
					coroutine.yield(msg)
				end
				if err ~= "timeout" then
					-- FIXME - we should generate a quit event for this user
					coroutine.yield { self, "socketClosed", i }
				end
			end
		end
	end
	return coroutine.wrap(iter)
end

function Server:dispatch(event)
	local obj = event[1]
	local meth = event[2]
	return obj[meth](obj, unpack(event, 3))
end

return Server
