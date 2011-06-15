-- simple argument parsing library
-- behaves like dd's argument parser, ie, accepts key=value arguments
-- rather than -k value or --key=value

function ddgetopts(defaults, ...)
    local opts = table.copy(defaults)
    local args
    
    if type((...)) == "table" then
        args = (...)
    else
        args = table.pack(...)
    end
    
    for i=1,args.n do
        local k,v = args[i]:match("([^=]+)=(.*)")
        if k then
            opts[k] = v
        else
            opts[args[i]] = true
        end
    end
    
    return opts
end
