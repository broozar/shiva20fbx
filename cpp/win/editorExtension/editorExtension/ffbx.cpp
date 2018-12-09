#include "stdafx.h"
#include "ffbx.h"

namespace FFBX {

	// ------------------------------------------------------------------
	// GLOBALS
	// ------------------------------------------------------------------

	std::vector<std::string> _sInputFilenames;

	lua_State* _pLua = nullptr;

	FbxManager* lSdkManager = nullptr;

	struct optionsOutput_t {
		fs::path path;
		bool clearFolder;
		bool importAfter;
	} _optionsOutput;

	struct optionsImport_t {
		bool Material;
		bool Texture;
		bool Link;
		bool Shape;
		bool Gobo;
		bool Animation;
		bool Global;
	} _optionsImport;

	struct optionsExport_t {
		bool Material;
		bool Texture;
		bool Embedded;
		bool Shape;
		bool Gobo;
		bool Animation;
		bool Global;
	} _optionsExport;

	struct optionsConvert_t {
		float prescale = 1.f;
	} _optionsConvert;

	struct errCodes_t {
		const char * initialize = "0";
		const char * alreadyRunning = "1";
		const char * outpathVerify = "2";
		const char * outpathEmpty = "3";
		const char * createScene = "4";
		const char * importScene = "5";
		const char * importInitialize = "6";
		const char * sdkMismatch = "7";
		const char * exportInitialize = "8";
		const char * exportFunction = "9";
	} errCodes;

	struct msgCodes_t {
		const char * msg = "0";
		const char * warn = "1";
		const char * err = "2";
	} msgCodes;

	// threading
	std::atomic_bool _abWorking;

	// ------------------------------------------------------------------
	// PUBLIC FUNCTIONS
	// ------------------------------------------------------------------

	bool init(lua_State* L) {
		// store Lua pointer
		_pLua = L;

		// 64 imports seems reasonable
		FFBX::_sInputFilenames.reserve(64);

		return true;
	}

	bool setOptionsOutput(const char * path, bool clearFolder, bool importAfter) {
		if ((path == nullptr) || (path[0] == '\0')) {
			exitError(errCodes.outpathEmpty, "output path appears to be empty");
			return false;
		}

		_optionsOutput.path = path;
		_optionsOutput.clearFolder = clearFolder;
		_optionsOutput.importAfter = importAfter;

		addTrailingDelimiter(_optionsOutput.path);

		return true;
	}

	bool setOptionsImport(bool bMaterial, bool bTexture, bool bLink, bool bShape, bool bGobo, bool bAnimation, bool bGlobal) {
		/*if (!_lSdkManager) return false;*/

		_optionsImport.Material = bMaterial;
		_optionsImport.Texture = bTexture;
		_optionsImport.Link = bLink;
		_optionsImport.Shape = bShape;
		_optionsImport.Gobo = bGobo;
		_optionsImport.Animation = bAnimation;
		_optionsImport.Global = bGlobal;

		return true;
	}

	bool setOptionsExport(bool bMaterial, bool bTexture, bool bEmbedded, bool bShape, bool bGobo, bool bAnimation, bool bGlobal) {
		//if (!_lSdkManager) return false;

		_optionsExport.Material = bMaterial;
		_optionsExport.Texture = bTexture;
		_optionsExport.Embedded = bEmbedded;
		_optionsExport.Shape = bShape;
		_optionsExport.Gobo = bGobo;
		_optionsExport.Animation = bAnimation;
		_optionsExport.Global = bGlobal;

		// Set the export states. By default, the export states are always set to
		// true except for the option eEXPORT_TEXTURE_AS_EMBEDDED. The code below
		// shows how to change these states.
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_MATERIAL, bMaterial); //t
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_TEXTURE, bTexture); //t
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_EMBEDDED, bEmbedded); //f
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_SHAPE, bShape); //t
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_GOBO, bGobo); //f always
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_ANIMATION, bAnimation); //t
		//(*(_lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_GLOBAL_SETTINGS, bGlobal); //t

		return true;
	}

	bool addImportFilename(const char * fn) {
		if ((fn == nullptr) || (fn[0] == '\0')) return false;

		FFBX::_sInputFilenames.push_back(fn);
		return true;
	}

	bool resetImportFilenames() {
		if (_abWorking) return false;

		FFBX::_sInputFilenames.clear();
		return true;
	}

	bool runConversion(lua_State* L) {

		if (!_abWorking) {
			_abWorking = true;
			sendMsg(msgCodes.msg, "starting conversion thread...");
			std::thread t(threadConversion);
			t.detach();
			return true;
		}
		// else
		exitError(errCodes.alreadyRunning, "conversion already running");
		return false;
	}

	// ------------------------------------------------------------------
	// HELPERS
	// ------------------------------------------------------------------

	void threadConversion() {
		// check if path exists
		if (!fs::exists(_optionsOutput.path)) {
			exitError(errCodes.outpathVerify, "output path could not be verified");
			return;
		}

		// ----------------------------
		// INIT SDK

		FbxScene* lScene = nullptr;
		FbxIOSettings* ioSettings = nullptr;

		//The first thing to do is to create the FBX Manager which is the object allocator for almost all the classes in the SDK
		lSdkManager = FbxManager::Create();
		if (!lSdkManager) {
			exitError(errCodes.initialize, "could not initialize FBX manager");
			return;
		}
		std::string lines("-----------------------------\n");
		std::string pre("Autodesk FBX SDK version ");
		std::string ver(lSdkManager->GetVersion());
		sendMsg(msgCodes.msg, (lines + pre + ver).c_str());

		// run for every file name
		for (const auto & file3d : _sInputFilenames) {

			sendMsg(msgCodes.msg, ("Processing " + file3d).c_str());

			//Create an IOSettings object. This object holds all import/export settings.
			ioSettings = FbxIOSettings::Create(lSdkManager, IOSROOT);
			lSdkManager->SetIOSettings(ioSettings);

			////Load plugins from the executable directory (optional)
			//FbxString lPath = FbxGetApplicationDirectory();
			//pManager->LoadPluginsDirectory(lPath.Buffer());

			//Create an FBX scene. This object holds most objects imported/exported from/to files.
			lScene = FbxScene::Create(lSdkManager, "TempScene");
			if (!lScene) {
				exitError(errCodes.createScene, "unable to create FBX scene");
				return;
			}

			// ----------------------------
			// LOAD SCENE

			int lFileMajor, lFileMinor, lFileRevision;
			int lSDKMajor, lSDKMinor, lSDKRevision;
			//int lFileFormat = -1;
			int i, lAnimStackCount;
			bool lStatus;

			// Get the file version number generate by the FBX SDK.
			FbxManager::GetFileFormatVersion(lSDKMajor, lSDKMinor, lSDKRevision);

			// Create an importer.
			FbxImporter* lImporter = FbxImporter::Create(lSdkManager, "");

			// Initialize the importer by providing a filename.
			const bool lImportStatus = lImporter->Initialize(file3d.c_str(), -1, lSdkManager->GetIOSettings());
			lImporter->GetFileVersion(lFileMajor, lFileMinor, lFileRevision);

			if (!lImportStatus) {
				FbxString errorChars = lImporter->GetStatus().GetErrorString();
				std::string temp("Call to FbxImporter::Initialize() failed. ");
				exitError(errCodes.importInitialize, (temp + errorChars.Buffer()).c_str());
				// return later

				if (lImporter->GetStatus().GetCode() == FbxStatus::eInvalidFileVersion) {
					std::string v1("File/SDK Version mismatch. SDK ");
					std::string v2("" + std::to_string(lSDKMajor) + "." + std::to_string(lSDKMinor) + "." + std::to_string(lSDKRevision));
					std::string v3(" vs ");
					std::string v4("" + std::to_string(lFileMajor) + "." + std::to_string(lFileMinor) + "." + std::to_string(lFileRevision));
					std::string v5(" in " + file3d);

					exitError(errCodes.sdkMismatch, (v1 + v2 + v3 + v4 + v5).c_str());
					// return later
				}

				return;
			}

			// ----------------------------
			// FBX specific import

			if (lImporter->IsFBX()) {
				std::string t("True FBX import: Working on " + file3d + " (FBX " + std::to_string(lFileMajor) + "." + std::to_string(lFileMinor) + "." + std::to_string(lFileRevision) + ")");
				sendMsg(msgCodes.msg, t.c_str());

				// animation
				sendMsg(msgCodes.msg, "Animation Stack Information");

				lAnimStackCount = lImporter->GetAnimStackCount();
				std::string s1("    Number of Animation Stacks: " + std::to_string(lAnimStackCount));
				std::string s2("    Current Animation Stack: " + lImporter->GetActiveAnimStackName());

				for (i = 0; i < lAnimStackCount; i++) {
					FbxTakeInfo* lTakeInfo = lImporter->GetTakeInfo(i);

					std::string t1("    Animation Stack ");
					sendMsg(msgCodes.msg, (t1 + std::to_string(i)).c_str());

					t1 = "         Name: ";
					sendMsg(msgCodes.msg, (t1 + lTakeInfo->mName.Buffer()).c_str());

					t1 = "         Description: ";
					sendMsg(msgCodes.msg, (t1 + lTakeInfo->mDescription.Buffer()).c_str());

					t1 = "         Import State: ";
					sendMsg(msgCodes.msg, (t1 + (lTakeInfo->mSelect ? "true" : "false")).c_str());
				}

				// Import options determine what kind of data is to be imported.
				// True is the default, but here we’ll set some to true explicitly, and others to false.
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_MATERIAL, _optionsImport.Material); //t
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_TEXTURE, _optionsImport.Texture); //t
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_LINK, _optionsImport.Link); //t
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_SHAPE, _optionsImport.Shape); //t
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_GOBO, _optionsImport.Gobo); //f always
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_ANIMATION, _optionsImport.Animation); //t
				(*(lSdkManager->GetIOSettings())).SetBoolProp(IMP_FBX_GLOBAL_SETTINGS, _optionsImport.Global); //t
			}

			// ----------------------------
			// Import the Scene

			lStatus = lImporter->Import(lScene);
			if (lStatus == false) {
				exitError(errCodes.importScene, lImporter->GetStatus().GetErrorString());
				return;
			}

			// Destroy the importer.
			lImporter->Destroy();


			// ----------------------------
			// EXPORTER

			// Create an exporter.
			FbxExporter* lExporter = FbxExporter::Create(lSdkManager, "");

			// exporter settings
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_MATERIAL, _optionsExport.Material); //t
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_TEXTURE, _optionsExport.Texture); //t
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_EMBEDDED, _optionsExport.Embedded); //t
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_SHAPE, _optionsExport.Shape); //t
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_GOBO, _optionsExport.Gobo); //f always
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_ANIMATION, _optionsExport.Animation); //t
			(*(lSdkManager->GetIOSettings())).SetBoolProp(EXP_FBX_GLOBAL_SETTINGS, _optionsExport.Global); //t

			// target filename
			auto fname = fs::path(file3d).filename().string();
			auto daefname = fname.substr(0, fname.find_last_of('.')) + ".dae";
			auto newfname = _optionsOutput.path.string() + daefname;

			// Initialize the DAE exporter.
			if (!lExporter->Initialize(newfname.c_str(), -1, lSdkManager->GetIOSettings())) {
				std::string e1("Call to FbxExporter::Initialize() failed. ");
				std::string e2(lExporter->GetStatus().GetErrorString());
				exitError(errCodes.exportInitialize, (e1 + e2).c_str());
				return;
			}
			else {
				// Export the scene.
				if (!lExporter->Export(lScene)) {
					exitError(errCodes.exportFunction, "Call to FbxExporter::Export() failed.");
					return;
				}
			}

			// Destroy the exporter.
			lExporter->Destroy();

		}

		// ----------------------------
		// CLEANUP

		if (lSdkManager) lSdkManager->Destroy();
		
		// signal OK
		exportOK();
	}

	void exitError(const char * errCode, const char * msg) {
		std::string c1("module.sendEvent ( module.getModuleFromIdentifier ( \"com.tris.fbximport\" ), \"onImportResult\", ");
		std::string c2(errCode);
		std::string c3(", \"FFBX DLL: ");
		std::string c4(msg);
		std::string c5("\" )");
		bool res = luaL_dostring(_pLua, (c1 + c2 + c3 + c4 + c5).c_str()) == 0;

		if (lSdkManager) lSdkManager->Destroy();

		_abWorking = false;
	}

	// types: 0 log, 1 warning, 2 error
	void sendMsg(const char * msgType, const char * msg) {
		std::string c1("module.sendEvent ( module.getModuleFromIdentifier ( \"com.tris.fbximport\" ), \"onLogDLL\", ");
		std::string c2(msgType);
		std::string c3(", \"FFBX DLL: ");
		std::string c4(msg);
		std::string c5("\" )");
		bool res = luaL_dostring(_pLua, (c1 + c2 + c3 + c4 + c5).c_str()) == 0;
	}

	void exportOK() {
		std::string c1("module.sendEvent( module.getModuleFromIdentifier ( \"com.tris.fbximport\" ), \"onImportResult\", 0, \"No errors.\" )");
		bool res = luaL_dostring(_pLua, c1.c_str()) == 0;
		_abWorking = false;
	}

	void addTrailingDelimiter(fs::path & path) {
		if (path.generic_string().back() != '/')
			path += '/';
	}

}