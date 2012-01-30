-- set up library search paths
package.path = "lib/?.lua;lib/?/init.lua;"..package.path

-- are we on windows?
if arg[-1]:match("%.exe$") then
    package.cpath = "lib/win32/?.dll;"..package.cpath
else
    package.cpath = "lib/linux/?.so;"..package.cpath
end

debug._traceback = debug.traceback
--require "debugger"
require "util"
require "lfs"

-- initialize RNG
math.randomseed(os.time())
