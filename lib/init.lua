math.randomseed(os.time())

-- an xpcall that permits varargs
function va_xpcall(f, e, ...)
    local argc = select('#', ...)
    local argv = {...}
    
    return xpcall(function() return f(unpack(argv,1,argc)) end, e)
end

-- converse of unpack
function table.pack(...)
    return { n = select('#', ...), ... }
end

-- instantiate something on all nodes simultaneously
function new(type)
    return function(...)
        local obj = require(type)(...)
        if obj.id then
            felt.broadcast(0, "newobject", felt.serialize(obj))
        end
        return obj
    end
end

-- replace default error handler
do
    local _errhand = love.errhand
    function love.errhand(...)
        print("Error:", ...)
        print(debug.traceback())
        return _errhand
    end
end

-- converse of assert
function tressa(result, ...)
    if not result then
        return nil,...
    else
        return ...
    end
end

-- fix love.filesystem.load
do
    local _fs_load = love.filesystem.load
    function love.filesystem.load(name)
        return tressa(pcall(_fs_load, name))
    end
end

-- set up require() to work with love2d
package.lovepath = "lib/?.lua;ui/?.lua;?.lua;modules/?.lua;"
table.insert(package.loaders, function(path)
    local err = ""
    
    path = path:gsub('%.', '/')
    
    for pattern in package.lovepath:gmatch('[^;]+') do
        local truepath = pattern:gsub('%?', path)
        local f,e = love.filesystem.load(truepath)
        if not f then
            err = err.."\tcan't load '"..truepath.."':"..e.."\n"
        else
            return f
        end
    end
    
    return err
end)

-- fix function names
for k,v in pairs(love.graphics) do
    if k:match('Color') then
        love.graphics[k:gsub('Color', 'Colour')] = v
    end
end

-- fast lambda creation
function L(src)
    return assert(loadstring(src:gsub("%s+%-%>%s+", " = ...; return ")))
end

-- stacked clipping rectangles
do
    local clip = {}
    
    function love.graphics.pushClip(x, y, w, h)
        local cx,cy,cw,ch = unpack(clip[#clip] or {x-1,y-1,w,h})
        cx = cx +1
        cy = cy +1
        w = math.min(x + w, cx + cw)
        h = math.min(y + h, cy + ch)
        x = math.max(x,cx)
        y = math.max(y,cy)
        w = w - x
        h = h - y
        
        love.graphics.setColour(0, 255, 0, 255)
        love.graphics.setScissor(x-1, y-1, w, h)
        clip[#clip+1] = { x-1, y-1, w, h }
    end
    
    function love.graphics.popClip()
        clip[#clip] = nil
        if #clip == 0 then
            love.graphics.setScissor()
        else
            love.graphics.setScissor(unpack(clip[#clip]))
        end
    end
end

-- keycode -> name mapping
love.keys = {}
for k,v in pairs(love) do
    if k:match("^key_") then
        love.keys[v] = k
    end
end

love.buttons = {
    wd = "wheeldown";
    wu = "wheelup";
    l = "left";
    r = "right";
    m = "middle";
    x1 = "x1";
    x2 = "x2";
}

do
    -- fix broken rectangle handling
    local _rect = love.graphics.rectangle
    
    function love.graphics.rectangle(mode, x, y, w, h)
        if mode == "fill" then
            return _rect(mode, x-1, y-1, w, h)
        else
            local x2,y2 = x+w-1,y+h-1
            love.graphics.line(x, y, x2, y)
            love.graphics.line(x2, y, x2, y2)
            love.graphics.line(x2, y2, x, y2)
            love.graphics.line(x, y2, x, y)
        end
    end
end

-- an alpha-preserving version of setcolour
do
    local alpha = select(4, love.graphics.getColour())
    local _setColour = love.graphics.setColour
    
    function love.graphics.setColour(r, g, b, a)
        alpha = a or alpha
        return _setColour(r, g, b, alpha)
    end
end

