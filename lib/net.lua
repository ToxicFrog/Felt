require "socket"
require "client"
require "server"

net = { clients = {} }

function felt.broadcast(...)
    if not net.client then return end
    
    print("broadcast", ...)
    
    client.write(...)
end

local function try(f, e)
    return select(2, xpcall(f, e))
end

function net.read(sock)
    local len,err = sock:receive(8)
    
    if not len then
        return nil,err
    else
        len = tonumber(len)
    end
    
    sock:settimeout(1)
    local buf,err = sock:receive(len)
    sock:settimeout(0)
    
    if not buf then
        return nil,err
    else
        local r = table.pack(felt.deserialize(buf))
        local s = {}
        for i=1,r.n do
            s[i] = tostring(r[i])
        end
        print("net.read", unpack(r, 1, r.n))
        return unpack(r, 1, r.n)
    end
end

function net.write(sock, ...)
    print("net.write", ...)
    local buf = net.serialize(...)

    return sock:send(string.format("%8d", #buf)..buf)
end

function net.host(port)
    server.connect('*', port)
end

function net.join(host, port)
    client.connect(host, port)
end

function net.update(dt)
    if net.server then
        server.update(dt)
    end
    if net.client then
        client.update(dt)
    end
end
