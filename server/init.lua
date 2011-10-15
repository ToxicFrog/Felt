-- set up the object system - this doesn't just load common.Object, but also
-- the class() and new() functions
require "common.Object"

-- this ensures that new "Server" will instantiate server.Server automatically
package.path = "server/?.lua;"..package.path

