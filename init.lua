-- fix love.filesystem.load
--[[
do
    local _love_fs_load = love.filesystem.load
    function love.filesystem.load(path)
        local pass,result = pcall(_love_fs_load, path)
        if not pass then
            return nil,result
        end
        return result
    end
end
--]]

-- set up require() to work with love2d
package.lovepath = "lib/?.lua;?.lua;"
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
    
    function love.graphics.pushClip(...)
        love.graphics.setScissor(...)
        clip[#clip+1] = {...}
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

