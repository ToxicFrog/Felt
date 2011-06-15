-- permit 'fmt % foo' and 'fmt % { foo, bar }'
getmetatable("").__mod = function(fmt, args)
	if type(args) == "table" then
		return fmt:format(unpack(args))
	else
		return fmt:format(args)
	end
end
