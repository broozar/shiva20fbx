# shiva20fbx
FBX, 3DS, OBJ, DAE and DXF model importer module for ShiVa 2.0 based on the Autodesk SDK 2019.0

# Components

## Folder "cpp"

### win
Contains the VS2017 project for your own experiments. Requires C++17 with (experimental) FileSystem headers. 

Excludes Autodesk FBX SDK source files for license reasons. FBXSDK is statically linked, Lua is dynamically linked. See Lua DLL installation isntructions below.

### linux
Contains a Code::Blocks project for your own experiments. Was created on Debian 9 for GCC 6.3. Requires (experimental) FileSystem headers, and also linking them. 

Excludes Autodesk FBX SDK source files for license reasons. Both FBXSDK and Lua are statically linked.

### mac
TODO

## Folder "module"
Contains the full ready-to-use editor module.

# Module installation
For the time being, the module is delivered as separate files. 

## Windows
Copy module/com.tris.fbximport to AppData/Local/ShiVa/Editor/Modules

Note: lua52.dll is no longer required. The library has been statically linked inside ffbx.dll

## Mac
Copy module/com.tris.fbximport to ~/Library/Application Support/ShiVa/Editor/Modules

## Linux
Copy module/com.tris.fbximport to ~/.shiva/ShiVa/Editor/Modules

# Screenshot
![alt text](http://somepic.someserver.de/pics/big/328842c53811c77049407d294d99bbd5.png)