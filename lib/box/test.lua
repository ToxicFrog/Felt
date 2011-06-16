-- test suite for box serialization library

local box = require "box"

local function eq(x,y)
    if type(x) ~= type(y) then
        return false
        
    elseif type(x) == "table" then
        -- isomorphy test
        for k,v in pairs(x) do
            if not eq(v, y[k]) then return false end
        end
        for k,v in pairs(y) do
            if not eq(v, x[k]) then return false end
        end
        return true
    
    else
        return x == y
    end
end

local function test(title, object, data)
    print("%-60s%s" % { "%s (pack)" % title, eq(box.pack(object), data) and "PASS" or "FAIL" })
    print("%-60s%s" % { "%s (unpack)" % title, eq(box.unpack(data), object) and "PASS" or "FAIL" })
end

test("nil", nil, "n")
test("false", false, "f")
test("true", true, "t")
test("number", 1, "N1")
test("string", "foo", "Sfoo")
test("empty table", {}, "T0:")
test("full table", { a=true, b=false }, "T4:2:1:2:1:SatSbf")
