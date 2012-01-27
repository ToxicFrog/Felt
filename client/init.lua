-- set up the object system - this doesn't just load Object, but also
-- the class() and new() functions
require "Object"

-- this ensures that new "Foo" will instantiate client.Foo automatically
package.path = "client/?.lua;"..package.path

