local system = {};

function felt.dispatch(widget, msg, ...)
    print("client.dispatch", widget, msg, ...)
    if widget == 0 then
        return felt[msg](...)
    end
    
    if type(widget) == "number" then
        widget = felt.widgets[widget]
    end
    
    if not widget then
        felt.log("warning: message '%s' received for nonexistent widget", msg)
        return
    end
    
    if not widget[msg] then
        felt.log("warning: widget %s has no receptor for message '%s'", tostring(widget), msg)
        return
    end
    
    local log = felt.log
    function felt.log() end
    local result = widget[msg](widget, ...)
    felt.log = log
    return result
end

function felt.disconnect(reason)
    client.disconnect(reason)
end

function felt.playerjoin(name, colour)
    felt.log("player %s (%s) joins", name, colour)
    felt.players[name] = colour
end

function felt.playerleave(name)
    felt.log("player %s leaves", name)
    felt.players[name] = nil
end

