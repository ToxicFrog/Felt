-- the "ui.actions" mixin
--[[
	This is where the magic happens. It's passed a table of actions supported
	by the host object, of the form:
	{
		action = suggested_bind;
		action = suggested_bind;
		*
		"action";
		"action";
		*
	}
	The UI is required to make -all- of these actions accessible by the user.
	The easiest way is to add them all to a right-click menu or equivalent, but
	the object is allowed to suggest binds that it thinks would make sense for
	a keyboard/mouse interface.
]]

for k,v in pairs(...) do
	if type(k) == "number" then
		-- it's an unbound action - add it to the menu
		-- FIXME - no menu yet!
	else
		-- key is the action, value is the suggested bind
		-- FIXME - check against configuration file for bindings
		assert(not _CLASS[v], "bind collision")
		_CLASS[v] = function(...)
			return _CLASS[k](...)
		end
	end
end