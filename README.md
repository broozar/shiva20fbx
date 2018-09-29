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

## File lua52.dll
Dependency for Windows

# Installation
For the time being, the module is delivered as separate files. Eventually, there will be a simple STE release.

## Windows
Copy module/com.tris.fbximport to AppData/Local/ShiVa/Editor/Modules,  
then put the lua52.dll into the ShiVa 2.0 root directory, next to all the Qt libs

## Mac
No mac build available yet. Once there is:  
Copy module/com.tris.fbximport to ~/Library/Application Support/ShiVa/Editor/Modules

## Linux
No mac build available yet. Once there is:  
Copy module/com.tris.fbximport to ~/.ShiVa/Editor/Modules
