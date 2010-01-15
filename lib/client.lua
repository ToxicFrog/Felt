client = {}

local sock

function client.log(...)
    felt.log("[client] %s", string.format(...))
end

function client.connect(host, port)
    local err
    sock,err = socket.connect(host, port)
    
    if not sock then
        client.log("unable to connect to %s:%d: %s", host, port, tostring(err))
        return
    end
    
    sock:settimeout(0)
    client.log("connected to %s:%d", host, port)
    
    client.write(0, "playerjoin", felt.config.name, felt.config.colour)
    client.log("sent handshake")
    
    net.client = true
end

function client.disconnect(reason)
    client.log("disconnecting: %s", tostring(reason))
    pcall(net.write, sock, 0, "quit")
    sock:close()
    sock = nil
    net.client = false
    
    -- FIXME clean up player information structures
end

function client.dispatch(id, msg, ...)
    client.log("<< %s %s (%d args)", tostring(id), msg, select('#', ...))

    felt.dispatch(id, msg, ...)
end

function client.update(dt)
    if sock:receive(0) then
        client.dispatch(client.read())
    end
end

function client.write(...)
    return L 'r,e -> r or client.disconnect(e)' (net.write(sock, ...))
end

function client.read(...)
    return (function(...)
        local r,e = ...
        if r then
            return ...
        else
            client.disconnect(e)
            return nil,e
        end
    end)(net.read(sock, ...))
end
