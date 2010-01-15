server = {}

local sock
local password
local clients,names = {},{}
local system = {}

function system.playerjoin(client, name, colour, pass)
    if password and pass ~= password then
        server.disconnect(client, "incorrect password")
        return true
    end
    
    if names[name] then
        server.disconnect(client, "name already in use")
        return true
    end
    
    server.log("player '%s' joins game from %s", name, client.name)
    client.name = name
    client.colour = colour
    names[name] = client
    
    
    -- send player list
    for otherclient in pairs(clients) do
        if client ~= otherclient then
            server.write(client, 0, "playerjoin", otherclient.name, otherclient.colour, nil)
        end
    end
    
    -- send game state
    if name ~= felt.config.name then
        server.log("sending game state to %s", name)
        -- FIXME
        server.write(client, 0, "loadstate", felt.savestate())
    end
end

function system.quit(client)
    server.disconnect(client, "client disconnected")
end

function server.start(port, pass)
    if sock then
        server.log("server already running on port %d", select(2, sock:getsockname()))
        return
    end
    
    local err
    sock,err = socket.bind('*', port)
    if not sock then
        server.log("cannot bind socket for server: %s", err)
        return
    end
    
    sock:settimeout(0)
    net.server = true
    server.log("started on port %d", port)
end

function server.stop()
    server.log("shutting down")
    sock:close()
    sock = nil
    
    for client in pairs(clients) do
        server.disconnect(client, "server shutting down")
    end
    
    -- FIXME clean up
    net.server = false
    server.log("shutdown complete")
end

function server.disconnect(client, reason)
    server.log("disconnecting %s: %s", client.name, tostring(reason))
    pcall(net.write, client.socket, 0, "disconnect", tostring(reason))
    client.socket:close()
    
    names[client.name] = nil
    clients[client] = nil
end

function server.dispatch(client, id, msg, ...)
    server.log("%s >> %s %s (%d args)", client.name, tostring(id), msg, select('#', ...))

    if id == 0 and system[msg] and system[msg](client, ...) then
        return
    end
    
    server.broadcast(client, id, msg, ...)
end

function server.update(dt)
    local newsock = sock:accept()
    
    if newsock then
        local host,port = newsock:getpeername()
        server.log("client connected from %s:%d", host, port)
        clients[{ socket = newsock, name = "<"..host..":"..port..">" }] = true
    end
    
    for client in pairs(clients) do
        if client.socket:receive(0) then
            server.dispatch(client, server.read(client))
        end
    end
end

function server.write(client, ...)
    return (function(...)
        local r,e = ...
        if r then
            return ...
        else
            server.disconnect(client, e)
            return nil,e
        end
    end)(net.write(client.socket, ...))
end

function server.broadcast(from, ...)
    for client in pairs(clients) do
        if client ~= from then
            server.write(client, ...)
        end
    end
end

function server.read(client)
    return (function(...)
        local r,e = ...
        if r then
            return ...
        else
            server.disconnect(client, e)
            return nil,e
        end
    end)(net.read(client.socket))
end

function server.log(...)
    felt.log("[server] %s", string.format(...))
end
