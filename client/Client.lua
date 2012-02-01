-- a client is fairly complicated; it needs to react to user input and to
-- messages from the server, providing both a socket interface to the server
-- and a graphical interface to the user.
-- Fortunately, a client.Client is quite simple. Basically all it needs to do
-- is maintain a world model for the view to look at.
require "socket"
require "box"

client = {}

local _break = false
local _socket,_game,_sendq,_objects
local _info

function client.connect(info)
    assert(not _socket, "Client already connected")
    assert(info.port and info.host, "Missing host or port")
    assert(info.name and info.r and info.g and info.b, "Missing name or colour")

    _sendq,_objects = {},{}
    _info = info

	local err
    _socket,err = socket.connect(info.host, info.port)

	if not _socket then
	    return nil,err
	end

    client.log("connected to %s", _socket:getpeername())

    _socket:settimeout(0.05)

    client.send {
        method = "login";
        info.name, info.pass, info.r, info.g, info.b;
    }
	
	return true
end

-- cleanly shut down the client.
-- send a message to the server, if possible, explaining why
function client.disconnect(message)
    client.log("Disconnecting: %s", tostring(message))

    if _socket:getpeername() then -- are we still connected?
        _socket:settimeout(0.2)

        local buf = box.pack {
            method = "chat";
            string.format("%s disconnecting: %s", tostring(_info.name), tostring(message));
        }

        _socket:send(string.format("%d\n%s", #buf, buf))
        _socket:close()
    end

    _socket = nil
    _break = true
end

function client.getInfo()
    return _info
end

function client.me()
    return _game:getPlayer(_info.name)
end

function client.send(msg)
    table.insert(_sendq, msg)
end

function client.log(fmt, ...)
    return print(string.format("[client] "..fmt, ...))
end

function client.chat(...)
    return client.send {
        method = "chat";
        string.format(...);
    }
end

-- mainloop function for the client. The UI is expected to call this frequently
-- (say, 5-30 times a second) to collect network traffic and process pending
-- events.
local ServerReader,ServerWriter
function client.step(timeout)
    _socket:settimeout(timeout or 0.05)
    ServerReader()
    ServerWriter()
    return not _break
end

function client.run(timeout)
    while not _break do
        client.step(timeout)
    end
    _break = nil
end

local function DispatchMessage(msg)
    if not msg.self then
        assert(client.api[msg.method], "no method "..tostring(msg.method).." in client API")
        client.api[msg.method](table.unpack(msg))
    else
        assert(msg.self[msg.method], "No method "..msg.method.." in "..tostring(msg.self))
        msg.self[msg.method](msg.self, table.unpack(msg))
    end
end

-- called every mainloop iteration to process messages from the server
function ServerReader(protected)
    if not protected then
        return xpcall(function()
            return ServerReader(true)
        end, function(message)
            client.log("Error receiving message from server: %s", message)
            client.log(debug.traceback("  Stack trace:"))
            client.disconnect("Receive error.")
        end)
    end
    
    local result,err = _socket:receive("*l")
    if result then
        assert(tonumber(result), "Malformed message header: "..tostring(result))
        client.log("<N %s %f", tostring(result), tonumber(result))
        _socket:settimeout(-1)
        local buf = assert(_socket:receive(tonumber(result)))
        local msg = box.unpack(buf, (_game and _game.objects))
        client.log("<< %s:%s()", tostring(msg.self), tostring(msg.method))
        DispatchMessage(msg)
    elseif err ~= "timeout" then
        error(err)
    end
end

local _sendbuf
function ServerWriter(protected)
    if not protected then
        return xpcall(function()
            return ServerWriter(true)
        end, function(message)
            client.log("Error sending message to server: %s", message)
            client.log(debug.traceback("  Stack trace:"))
            client.disconnect("Send error.")
        end)
    end
    
    if not _sendbuf and #_sendq > 0 then
        local msg = table.remove(_sendq, 1)
        local buf = box.pack(msg, _objects)
        
        client.log("Q> %s %s", tostring(msg.self), tostring(msg.method))
        _sendbuf = string.format("%d\n%s", #buf, buf)
    end
    
    if _sendbuf then
        local result,err,last = _socket:send(_sendbuf)
        client.log(">> %s %s", tostring(result), tostring(err))
        if result then
            _sendbuf = nil
        elseif err == "timeout" then
            _sendbuf = _sendbuf:sub(last+1)
        else
            error(err)
        end
    end
end

client.api = {}

function client.api.message(...)
    return ui.message(...)
end

function client.api.game(game)
    _game = game
end

function client.api.chat(who, message)
    ui.message("<%s> %s", tostring(who), tostring(message))
end
