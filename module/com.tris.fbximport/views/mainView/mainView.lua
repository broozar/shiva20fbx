-- FBX IMPORTER
-- November 2018
-- Felix Caffier

--------------------------------------------------------------------------------
-- DLL HANDLERS
--------------------------------------------------------------------------------

function onLogDLL ( nType, sMessage )

    if nType == 1 then
        log.warning ( sMessage )
    elseif nType == 2 then
        log.error ( sMessage )
    else
        log.message ( sMessage )
    end

end

function onImportResult ( nErrorCode, sMessage )

    if nErrorCode == 0 then
        log.message ( "FFBX: DAE conversion successful" )

    else
        log.warning ( "FFBX: Error during DAE conversion (" ..nErrorCode ..")" )
        log.warning ( sMessage )

	end

end

--------------------------------------------------------------------------------
-- TOOLS
--------------------------------------------------------------------------------

function refreshTargetList ( )

    local hComboBox = gui.getComponent ( "ffbx.convert.target" )
    if not hComboBox then message.warning ( "FFBX: target profile ComboBox not found" ) return end

    local tTargetProfileList = project.getTargetProfileList ( )
    if  ( tTargetProfileList ) then
        if ( gui.getComboBoxItemCount ( hComboBox ) ~= #tTargetProfileList )
        then
            gui.removeAllComboBoxItems ( hComboBox )

            local tSortedProfiles       = { }
            local hDefaultTargetProfile = project.getDefaultTargetProfile ( )

            for i = 1, #tTargetProfileList do
                if  ( hDefaultTargetProfile ~= tTargetProfileList[i] ) then
                    table.insert ( tSortedProfiles, project.getTargetProfileName ( tTargetProfileList[i] ) )
                end
            end

            table.sort ( tSortedProfiles )
            gui.appendComboBoxItem ( hComboBox, project.getTargetProfileName ( hDefaultTargetProfile ) )

            for i = 1, #tSortedProfiles    do
                gui.appendComboBoxItem ( hComboBox, tSortedProfiles[i] )
            end
        end
    end

end

--------------------------------------------------------------------------------
-- INIT / DESTROY
--------------------------------------------------------------------------------

function onMainViewInit ( )

	if system.getOSType ( ) == system.kOSTypeWindows then
		local libinit, libmsg = package.loadlib( module.getRootDirectory ( this.getModule() ) .."resources/ffbx.dll", "libinit" )
		log.message("Loading FFBX DLL")
		if libinit == nil then
			log.warning ( "FFBX error: " ..libmsg )
		else
			libinit()
		end

	elseif system.getOSType ( ) == system.kOSTypeLinux then
		local libinit, libmsg = package.loadlib( module.getRootDirectory ( this.getModule() ) .."resources/libffbx.so", "libinit" )
		log.message("Loading FFBX SO")
		if libinit == nil then
			log.warning ( "FFBX error: " ..libmsg )
		else
			libinit()
		end
	
	elseif system.getOSType ( ) == system.kOSTypeMac then
		local libinit, libmsg = package.loadlib( module.getRootDirectory ( this.getModule() ) .."resources/libffbx.dylib", "libinit" )
		log.message("Loading FFBX DYLIB")
		if libinit == nil then
			log.warning ( "FFBX error: " ..libmsg )
		else
			libinit()
		end
	
	else
		log.warning ( "FFBX error: Operating system not recognized. FBX module will not be available." )
		
	end

    onConfigLoad ( )

end

function onMainViewDestroy ( )

end

--------------------------------------------------------------------------------
-- STARTUP CONFIG
--------------------------------------------------------------------------------

function onConfigLoad ( )

    local sMID = this.getModuleIdentifier ( )

    local hOutPat = gui.getComponent ( "ffbx.output.folder.path" )
    local hOutClr = gui.getComponent ( "ffbx.output.folder.clear" )

    local hImpMat = gui.getComponent ( "ffbx.import.material" )
    local hImpTex = gui.getComponent ( "ffbx.import.texture" )
    local hImpLnk = gui.getComponent ( "ffbx.import.link" )
    local hImpShp = gui.getComponent ( "ffbx.import.shape" )
    local hImpAni = gui.getComponent ( "ffbx.import.animation" )
    local hImpGlo = gui.getComponent ( "ffbx.import.global" )

    local sOutPat = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.path" )
    local bOutClr = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.clear" )

    local bImpMat = project.getUserProperty ( nil, sMID ..".config.ffbx.import.material" )
    local bImpTex = project.getUserProperty ( nil, sMID ..".config.ffbx.import.texture" )
    local bImpLnk = project.getUserProperty ( nil, sMID ..".config.ffbx.import.link" )
    local bImpShp = project.getUserProperty ( nil, sMID ..".config.ffbx.import.shape" )
    local bImpAni = project.getUserProperty ( nil, sMID ..".config.ffbx.import.animation" )
    local bImpGlo = project.getUserProperty ( nil, sMID ..".config.ffbx.import.global" )

    if ( hOutPat ) then gui.setEditBoxText ( hOutPat, sOutPat or "" ) end
    if ( hOutClr ) then gui.setCheckBoxState ( hOutClr, bOutClr and gui.kCheckStateOn or gui.kCheckStateOff ) end

    if ( hImpMat ) then gui.setCheckBoxState ( hImpMat, bImpMat and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpTex ) then gui.setCheckBoxState ( hImpTex, bImpTex and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpLnk ) then gui.setCheckBoxState ( hImpLnk, bImpLnk and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpShp ) then gui.setCheckBoxState ( hImpShp, bImpShp and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpAni ) then gui.setCheckBoxState ( hImpAni, bImpAni and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpGlo ) then gui.setCheckBoxState ( hImpGlo, bImpGlo and gui.kCheckStateOn or gui.kCheckStateOff ) end

end

function onConfigSave ( )

    local sMID = this.getModuleIdentifier ( )

    local hOutPat = gui.getComponent ( "ffbx.output.folder.path" )
    local hOutClr = gui.getComponent ( "ffbx.output.folder.clear" )

    local hImpMat = gui.getComponent ( "ffbx.import.material" )
    local hImpTex = gui.getComponent ( "ffbx.import.texture" )
    local hImpLnk = gui.getComponent ( "ffbx.import.link" )
    local hImpShp = gui.getComponent ( "ffbx.import.shape" )
    local hImpAni = gui.getComponent ( "ffbx.import.animation" )
    local hImpGlo = gui.getComponent ( "ffbx.import.global" )

    project.setUserProperty ( nil, sMID ..".config.ffbx.output.folder.path", gui.getEditBoxText ( hOutPat ) )
    project.setUserProperty ( nil, sMID ..".config.ffbx.output.folder.clear", gui.getCheckBoxState ( hOutClr ) == gui.kCheckStateOn )

    project.setUserProperty ( nil, sMID ..".config.ffbx.import.material", gui.getCheckBoxState ( hImpMat ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.texture", gui.getCheckBoxState ( hImpTex ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.link", gui.getCheckBoxState ( hImpLnk ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.shape", gui.getCheckBoxState ( hImpShp ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.animation", gui.getCheckBoxState ( hImpAni ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.global", gui.getCheckBoxState ( hImpGlo ) == gui.kCheckStateOn )

end

--------------------------------------------------------------------------------
-- INPUT
--------------------------------------------------------------------------------

function onInputAdd ( )

    local hTree = gui.getComponent ( "ffbx.input.resource.tree" )
    local cTree = gui.getTreeItemCount ( hTree )
    local tOldFiles = {}
    for j=1, cTree do
        table.insert ( tOldFiles, gui.getTreeItemText ( gui.getTreeItem ( hTree, j ) ) )
    end


    local tNewFiles = gui.showFileChooserDialog ( "Add files...", "", "3D Studio (*.3ds);;OBJ files (*.obj);;DXF files (*.dxf);;Autodesk FBX (*.fbx);;Collada (*.dae);;All files (*.*)", gui.kFileChooserDialogOptionOpenFiles )
    if ( tNewFiles and ( utils.getVariableType ( tNewFiles ) == utils.kVariableTypeTable ) and ( #tNewFiles > 0 ) ) then
        for i = 1, #tNewFiles do
            local it = tNewFiles[i]
            if ( cTree > 0 ) then
                if ( table.find ( tOldFiles, it ) ) then
                    log.message ( "FFBX: Ignoring duplicate file '" ..it .."'" )
                else
                    local item = gui.appendTreeItem ( hTree )
                    gui.setTreeItemData ( item, gui.kDataRoleDisplay, it )
                end
            else
                local item = gui.appendTreeItem ( hTree )
                gui.setTreeItemData ( item, gui.kDataRoleDisplay, it )
            end
        end
    end

end

function onInputRemoveAll ( )

    local hTree = gui.getComponent ( "ffbx.input.resource.tree" )
    local cTree = gui.getTreeItemCount ( hTree )
    if cTree < 1 then return end
    for j=cTree, 1, -1 do
        gui.removeTreeItem ( hTree, gui.getTreeItem ( hTree, j ) )
    end

end

function onInputRemove ( )

    local hTree = gui.getComponent ( "ffbx.input.resource.tree" )
    local cTree = gui.getTreeItemCount ( hTree )
    if cTree < 1 then return end

    for i=cTree, 1, -1 do
        local it = gui.getTreeItem ( hTree, i )
        if gui.isTreeItemSelected ( hTree, it ) then
            gui.removeTreeItem ( hTree, it )
        end
    end

end

--------------------------------------------------------------------------------
-- FBX EXPORT
--------------------------------------------------------------------------------

function onExportFBX ( )

    -- get file names from tree

    local hTree = gui.getComponent ( "ffbx.input.resource.tree" )
    local cTree = gui.getTreeItemCount ( hTree )
    if cTree < 1 then
        log.warning ( "FFBX: nothing to import..." )
        return
    end

    if not FFBX_resetImportFilenames() then
        log.warning ( "FFBX: Could not clear file name list" )
        return false
    end

    for i=1, cTree do
        local sFilename = gui.getTreeItemText ( gui.getTreeItem ( hTree, i ) )
        if not FFBX_addImportFilename ( sFilename ) then
            log.warning ( "FFBX: Error sending file name '" ..sFilename .."' to DLL"  )
            return false
        end
    end

    -- get options from corresponding sections
    local sMID = this.getModuleIdentifier ( )

    local sOutPat = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.path" )
    local bOutClr = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.clear" )  and 1 or 0

    local bI1 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.material" )  and 1 or 0
    local bI2 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.texture" )   and 1 or 0
    local bI3 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.link" )      and 1 or 0
    local bI4 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.shape" )     and 1 or 0
    local bI5 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.animation" ) and 1 or 0
    local bI6 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.global" )    and 1 or 0

    -- clear target folder if requested
    if bOutClr == 1 then

        local r = system.findFiles ( sOutPat, false )
        if (r) then
            for i=1, #r do
                local e = project.getFileExtension ( r[i] )
                if string.lower ( e ) == "dae" then
                    log.message ( "FFBX: deleting " ..sOutPat .."/" ..project.getFileFullName ( r[i] ) )
                    project.destroyFile ( r[i] )
                end
            end
        end
		
    end

    -- send options to DLL

    if not FFBX_setOptionsOutput( sOutPat, bOutClr, 0 ) then
        log.warning ( "FFBX: Could not send output options to DLL" )
        return false
    end

    if not FFBX_setOptionsImport( bI1, bI2, bI3, bI4, bI5, bI6 ) then
        log.warning ( "FFBX: Could not send import options to DLL" )
        return false
    end

    if not FFBX_setOptionsExport( bI1, bI2, bI3, bI4, bI5, bI6 ) then
        log.warning ( "FFBX: Could not send export options to DLL" )
        return false
    end

    -- TODO: maybe move TRS and skeleton transform to FBX SDK?

    -- start conversion thread

    if not FFBX_runConversion() then
        log.warning ( "FFBX: Launching conversion thread failed" )
        return false
    end
	log.message ( "FFBX: Running conversion thread, please stand by..." )
	
    return true
end

function onRunImport ( )

    onConfigSave ( )
    log.message ( "-------------------------------" )
    log.message ( "FFBX: Starting the import process" )

    onExportFBX ( )

end
