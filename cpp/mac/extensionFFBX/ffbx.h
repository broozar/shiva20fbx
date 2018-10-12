#pragma once

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#include "fbxsdk.h"
#include "lua.hpp"

#include <thread>
#include <atomic>
#include <string>
#include <vector>

// no FS support on macOS :(
//#include <experimental/filesystem> // C++14.
//namespace fs = std::experimental::filesystem; // C++14.
//#include <filesystem> // C++17.
//namespace fs = std::filesystem; // C++17.

namespace FFBX {

	// ------------------------------------------------------------------
	// PUBLIC FUNCTIONS
	// ------------------------------------------------------------------

	bool init(lua_State* L);

	bool setOptionsOutput(const char * path, bool clearFolder, bool importAfter);
	bool setOptionsImport(bool Material, bool Texture, bool Link, bool Shape, bool Gobo, bool Animation, bool Global);
	bool setOptionsExport(bool Material, bool Texture, bool Embedded, bool Shape, bool Gobo, bool Animation, bool Global);
	bool addImportFilename(const char* fn);
	bool resetImportFilenames();

	bool runConversion(lua_State* L);

	// ------------------------------------------------------------------
	// HELPERS
	// ------------------------------------------------------------------

	void threadConversion();

	void exitError(const char * errCode, const char * msg);
	void sendMsg(const char * msgType, const char * msg);
	void exportOK();
	
}
