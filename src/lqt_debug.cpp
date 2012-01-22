#include <iostream>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#define LQT_PCALL "Registry PCall Pointer"

int lqtL_pcall_debug_custom (lua_State *L, int narg, int nres, int err) {
    int status = 0;
    status = lua_pcall(L, narg, nres, err);
    if (status != 0)
    {
        std::cerr << "pcall failed, status = " << status << std::endl;
        std::cerr << "error message: " << lua_tostring(L, -1) << std::endl;
        luaL_dostring(L, "print(debug.traceback())");
    }
    return status;
}

extern "C" int luaopen_lqt_debug(lua_State * L) {
    lua_pushlightuserdata(L, (void*)lqtL_pcall_debug_custom);
    lua_setfield(L, LUA_REGISTRYINDEX, LQT_PCALL);
    return 0;
}
