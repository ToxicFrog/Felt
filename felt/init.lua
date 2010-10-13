-- the central library of the game
-- this contains a variety of useful global functions, as well as globals
-- important to the operation of the game itself such as the game state
-- and configuration subsystem

require "lfs"

function felt.log(...)
	ui.message(string.format(...))
end

function felt.init()
	felt.userdir =  os.getenv "HOME" and (os.getenv "HOME" .. "/.felt/")
	             or os.getenv "APPDATA" and (os.getenv "APPDATA" .. "/Felt/")
	             or "./"
	lfs.mkdir(felt.userdir)
	
	felt.config.init()
end

require "felt.config"
require "felt.serialize"
require "felt.deserialize"
