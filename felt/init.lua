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

function sendmsg(sock, msg)
	print(">>>>", msg)
	sock:send(string.format("%d\n%s", #msg, msg))
end

function recvmsg(sock)
	local len
	local buf,err = sock:receive()
	if not buf then return nil,err end
	
	len = tonumber(buf)
	if not len then
		return nil,"corrupt message header '"..buf.."'"
	end
	
	-- we set a ten second grace period here, as otherwise it is possible with
	-- large messages to receive the size before the message is fully buffered
	sock:settimeout(10)
	buf,err = sock:receive(len)
	sock:settimeout(0)
	
	if not buf and err == "timeout" then
		return nil,"truncated message"
	end
	
	print("<<<<", buf)
	
	return buf,err
end
