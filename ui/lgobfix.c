#include <gdk/gdk.h>
#include <lua.h>
#include <luaconf.h>
#include <lauxlib.h>

int key_event_unpack(lua_State * L)
{
	const GdkEvent * evt = *(GdkEvent**)lua_topointer(L, 1);
	lua_pushinteger(L, evt->key.keyval);
	lua_pushinteger(L, evt->key.state);
	return 2;
}

int button_event_unpack(lua_State * L)
{
	const GdkEvent * evt = *(GdkEvent**)lua_topointer(L, 1);
	lua_pushinteger(L, evt->button.button);
	lua_pushinteger(L, evt->button.state);
	return 2;
}

int scroll_event_unpack(lua_State * L)
{
	const GdkEvent * evt = *(GdkEvent**)lua_topointer(L, 1);
	lua_pushinteger(L, evt->scroll.direction);
	lua_pushinteger(L, evt->scroll.state);
	return 2;
}

int luaopen_ui_lgobfix(lua_State * L)
{
	lua_getglobal(L, "gdk");
	lua_getfield(L, -1, "Event");
	
	lua_pushcfunction(L, key_event_unpack);
	lua_setfield(L, -2, "keys");
	
	lua_pushcfunction(L, button_event_unpack);
	lua_setfield(L, -2, "buttons");
	
	lua_pushcfunction(L, scroll_event_unpack);
	lua_setfield(L, -2, "scroll");
	
	return 0;
}

