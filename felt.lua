-- set up library search paths
package.path = "lib/?.lua;lib/?/init.lua;"..package.path
package.cpath = "lib/?.so;lib/?.dll;"..package.cpath

debug._traceback = debug.traceback
--require "debugger"
require "util"
require "lfs"

-- initialize RNG
math.randomseed(os.time())
