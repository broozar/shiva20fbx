// editorExtension.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "lua.hpp"

#include "ffbx.h"

// ------------------------------------------------------------------
// LUA communication
// ------------------------------------------------------------------

// local nReturnType, sReturnMessage = init()
int flua_init(lua_State* L) {
	return 2;
}

// local bOK = clearImportFilenames()
int flua_resetImportFilenames(lua_State* L) {

	auto res = FFBX::resetImportFilenames();

	lua_pushboolean(L, res);
	return 1;
}

// local bOK = addImportFilename(sFilename)
int flua_addImportFilename(lua_State* L) {

	auto s = luaL_checkstring(L, 1);
	auto res = false; 

	if ((s != nullptr) && (s[0] != '\0')) {
		res = FFBX::addImportFilename(s);
	}	

	lua_pushboolean(L, res);
	return 1;
}

// local bOK = setOptionsOutput(sPath,nClear,nImport)
int flua_setOptionsOutput(lua_State* L) {

	auto s1 = luaL_checkstring(L, 1);
	auto b2 = static_cast<bool>(luaL_checkint(L, 2));
	auto b3 = static_cast<bool>(luaL_checkint(L, 3));

	auto res = FFBX::setOptionsOutput(s1, b2, b3);

	lua_pushboolean(L, res);
	return 1;
}

// local bOK = setOptionsImport(nMaterial,nTexture,nLink,nShape,nAnimation,nGlobal) ?
int flua_setOptionsImport(lua_State* L) {

	auto b1 = static_cast<bool>(luaL_checkint(L, 1));
	auto b2 = static_cast<bool>(luaL_checkint(L, 2));
	auto b3 = static_cast<bool>(luaL_checkint(L, 3));
	auto b4 = static_cast<bool>(luaL_checkint(L, 4));
	auto b5 = static_cast<bool>(luaL_checkint(L, 5));
	auto b6 = static_cast<bool>(luaL_checkint(L, 6));

	auto res = FFBX::setOptionsImport(b1, b2, b3, b4, false, b5, b6);

	lua_pushboolean(L, res);
	return 1;
}

// local bOK = setOptionsExport(nMaterial,nTexture,nEmbedded,nShape,nAnimation,nGlobal) ?
int flua_setOptionsExport(lua_State* L) {

	auto b1 = static_cast<bool>(luaL_checkint(L, 1));
	auto b2 = static_cast<bool>(luaL_checkint(L, 2));
	auto b3 = static_cast<bool>(luaL_checkint(L, 3));
	auto b4 = static_cast<bool>(luaL_checkint(L, 4));
	auto b5 = static_cast<bool>(luaL_checkint(L, 5));
	auto b6 = static_cast<bool>(luaL_checkint(L, 6));

	auto res = FFBX::setOptionsExport(b1, b2, b3, b4, false, b5, b6);

	lua_pushboolean(L, res);
	return 1;
}

// local bOK = setOptionsConversion () ?
//int flua_setOptionsConversion(lua_State* L) {
//
//	//lua_pushboolean(L, res);
//	//return 1;
//	return 0;
//}

// local bOK = runConversion ()
int flua_runConversion(lua_State* L) {

	auto res = FFBX::runConversion(L);

	lua_pushboolean(L, res);
	return 1;
}

// destroy ()
//int flua_destroy(lua_State* L) {
//
//	FFBX::destroy();
//
//	return 0;
//}

// ------------------------------------------------------------------
// LUA function name registration
// ------------------------------------------------------------------

extern "C" {

	int __declspec(dllexport) libinit(lua_State* L) {
		
		// register function callbacks
		lua_register(L, "FFBX_resetImportFilenames", flua_resetImportFilenames);
		lua_register(L, "FFBX_addImportFilename", flua_addImportFilename);
		lua_register(L, "FFBX_setOptionsOutput", flua_setOptionsOutput);
		lua_register(L, "FFBX_setOptionsImport", flua_setOptionsImport);
		lua_register(L, "FFBX_setOptionsExport", flua_setOptionsExport);
		//lua_register(L, "FFBX_setOptionsConversion", flua_setOptionsConversion);
		lua_register(L, "FFBX_runConversion", flua_runConversion);

		// auto init
		FFBX::init(L);

		return 0;
	}

}