-- FBX IMPORTER
-- August 2018
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

        -- now do the DAE import job
        local hOutImp = gui.getComponent ( "ffbx.output.folder.import" )
        if ( hOutImp and gui.getCheckBoxState ( hOutImp ) == gui.kCheckStateOn ) then
            log.message ( "FFBX: starting DAE import process..." )
            onImportDAE()
        end
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


    -- prepare combo boxes
    local hConSwa = gui.getComponent ( "ffbx.convert.swapyz" )
    if ( hConSwa ) and ( gui.getComboBoxItemCount ( hConSwa ) == 0 ) then
        gui.appendComboBoxItem ( hConSwa, "None" ) --0
        gui.appendComboBoxItem ( hConSwa, "Everything" ) --1
        gui.appendComboBoxItem ( hConSwa, "Skeleton only" ) --2
        gui.appendComboBoxItem ( hConSwa, "Animation only" ) --3
        gui.appendComboBoxItem ( hConSwa, "Skeleton and Animation only" ) --4
    end

    onConfigLoad ( )
    refreshTargetList ( )

end

function onMainViewDestroy ( )

    --FFBX_destroy ( )

end

--------------------------------------------------------------------------------
-- STARTUP CONFIG
--------------------------------------------------------------------------------

function onConfigLoad ( )

    local sMID = this.getModuleIdentifier ( )

    local hOutPat = gui.getComponent ( "ffbx.output.folder.path" )
    local hOutClr = gui.getComponent ( "ffbx.output.folder.clear" )
    local hOutImp = gui.getComponent ( "ffbx.output.folder.import" )

    local hImpMat = gui.getComponent ( "ffbx.import.material" )
    local hImpTex = gui.getComponent ( "ffbx.import.texture" )
    local hImpLnk = gui.getComponent ( "ffbx.import.link" )
    local hImpShp = gui.getComponent ( "ffbx.import.shape" )
    local hImpAni = gui.getComponent ( "ffbx.import.animation" )
    local hImpGlo = gui.getComponent ( "ffbx.import.global" )

    local hExpMat = gui.getComponent ( "ffbx.export.material" )
    local hExpTex = gui.getComponent ( "ffbx.export.texture" )
    local hExpEmb = gui.getComponent ( "ffbx.export.embed" )
    local hExpShp = gui.getComponent ( "ffbx.export.shape" )
    local hExpAni = gui.getComponent ( "ffbx.export.animation" )
    local hExpGlo = gui.getComponent ( "ffbx.export.global" )

    local hConSca = gui.getComponent ( "ffbx.convert.prescale" )
    local hConTrX = gui.getComponent ( "ffbx.convert.transX" )
    local hConTrY = gui.getComponent ( "ffbx.convert.transY" )
    local hConTrZ = gui.getComponent ( "ffbx.convert.transZ" )
    local hConRoX = gui.getComponent ( "ffbx.convert.rotX" )
    local hConRoY = gui.getComponent ( "ffbx.convert.rotY" )
    local hConRoZ = gui.getComponent ( "ffbx.convert.rotZ" )
    local hConTrXs = gui.getComponent ( "ffbx.convert.transXs" )
    local hConTrYs = gui.getComponent ( "ffbx.convert.transYs" )
    local hConTrZs = gui.getComponent ( "ffbx.convert.transZs" )
    local hConRoXs = gui.getComponent ( "ffbx.convert.rotXs" )
    local hConRoYs = gui.getComponent ( "ffbx.convert.rotYs" )
    local hConRoZs = gui.getComponent ( "ffbx.convert.rotZs" )
    local hConSkel = gui.getComponent ( "ffbx.convert.skelscale" )
    local hConRoXa = gui.getComponent ( "ffbx.convert.rotXa" )
    local hConRoYa = gui.getComponent ( "ffbx.convert.rotYa" )
    local hConRoZa = gui.getComponent ( "ffbx.convert.rotZa" )
    local hConRela = gui.getComponent ( "ffbx.convert.animRelative" )

    local sOutPat = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.path" )
    local bOutClr = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.clear" )
    local bOutImp = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.import" )

    local bImpMat = project.getUserProperty ( nil, sMID ..".config.ffbx.import.material" )
    local bImpTex = project.getUserProperty ( nil, sMID ..".config.ffbx.import.texture" )
    local bImpLnk = project.getUserProperty ( nil, sMID ..".config.ffbx.import.link" )
    local bImpShp = project.getUserProperty ( nil, sMID ..".config.ffbx.import.shape" )
    local bImpAni = project.getUserProperty ( nil, sMID ..".config.ffbx.import.animation" )
    local bImpGlo = project.getUserProperty ( nil, sMID ..".config.ffbx.import.global" )

    local bExpMat = project.getUserProperty ( nil, sMID ..".config.ffbx.export.material" )
    local bExpTex = project.getUserProperty ( nil, sMID ..".config.ffbx.export.texture" )
    local bExpEmb = project.getUserProperty ( nil, sMID ..".config.ffbx.export.embed" )
    local bExpShp = project.getUserProperty ( nil, sMID ..".config.ffbx.export.shape" )
    local bExpAni = project.getUserProperty ( nil, sMID ..".config.ffbx.export.animation" )
    local bExpGlo = project.getUserProperty ( nil, sMID ..".config.ffbx.export.global" )

    local nConSca = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.prescale" )
    local nConTrX = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transX" )
    local nConTrY = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transY" )
    local nConTrZ = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transZ" )
    local nConRoX = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotX" )
    local nConRoY = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotY" )
    local nConRoZ = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZ" )
    local nConTrXs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transXs" )
    local nConTrYs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transYs" )
    local nConTrZs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transZs" )
    local nConRoXs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotXs" )
    local nConRoYs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotYs" )
    local nConRoZs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZs" )
    local nConSkel = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.skelscale" )
    local nConRoXa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotXa" )
    local nConRoYa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotYa" )
    local nConRoZa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZa" )
    local bConRela = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.animRelative" )

    if ( hOutPat ) then gui.setEditBoxText ( hOutPat, sOutPat or "" ) end
    if ( hOutClr ) then gui.setCheckBoxState ( hOutClr, bOutClr and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hOutImp ) then gui.setCheckBoxState ( hOutImp, bOutImp and gui.kCheckStateOn or gui.kCheckStateOff ) end

    if ( hImpMat ) then gui.setCheckBoxState ( hImpMat, bImpMat and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpTex ) then gui.setCheckBoxState ( hImpTex, bImpTex and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpLnk ) then gui.setCheckBoxState ( hImpLnk, bImpLnk and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpShp ) then gui.setCheckBoxState ( hImpShp, bImpShp and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpAni ) then gui.setCheckBoxState ( hImpAni, bImpAni and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hImpGlo ) then gui.setCheckBoxState ( hImpGlo, bImpGlo and gui.kCheckStateOn or gui.kCheckStateOff ) end

    if ( hExpMat ) then gui.setCheckBoxState ( hExpMat, bExpMat and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hExpTex ) then gui.setCheckBoxState ( hExpTex, bExpTex and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hExpEmb ) then gui.setCheckBoxState ( hExpEmb, bExpEmb and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hExpShp ) then gui.setCheckBoxState ( hExpShp, bExpShp and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hExpAni ) then gui.setCheckBoxState ( hExpAni, bExpAni and gui.kCheckStateOn or gui.kCheckStateOff ) end
    if ( hExpGlo ) then gui.setCheckBoxState ( hExpGlo, bExpGlo and gui.kCheckStateOn or gui.kCheckStateOff ) end

    if ( hConSca ) then gui.setNumberBoxValue ( hConSca, nConSca or 1.0 ) end
    if ( hConTrX ) then gui.setNumberBoxValue ( hConTrX, nConTrX or 0 ) end
    if ( hConTrY ) then gui.setNumberBoxValue ( hConTrY, nConTrY or 0 ) end
    if ( hConTrZ ) then gui.setNumberBoxValue ( hConTrZ, nConTrZ or 0 ) end
    if ( hConRoX ) then gui.setNumberBoxValue ( hConRoX, nConRoX or 0 ) end
    if ( hConRoY ) then gui.setNumberBoxValue ( hConRoY, nConRoY or 0 ) end
    if ( hConRoZ ) then gui.setNumberBoxValue ( hConRoZ, nConRoZ or 0 ) end
    if ( hConTrXs ) then gui.setNumberBoxValue ( hConTrXs, nConTrXs or 0 ) end
    if ( hConTrYs ) then gui.setNumberBoxValue ( hConTrYs, nConTrYs or 0 ) end
    if ( hConTrZs ) then gui.setNumberBoxValue ( hConTrZs, nConTrZs or 0 ) end
    if ( hConRoXs ) then gui.setNumberBoxValue ( hConRoXs, nConRoXs or 0 ) end
    if ( hConRoYs ) then gui.setNumberBoxValue ( hConRoYs, nConRoYs or 0 ) end
    if ( hConRoZs ) then gui.setNumberBoxValue ( hConRoZs, nConRoZs or 0 ) end
    if ( hConSkel ) then gui.setNumberBoxValue ( hConSkel, nConSkel or 1.0 ) end
    if ( hConRoXa ) then gui.setNumberBoxValue ( hConRoXa, nConRoXa or 0 ) end
    if ( hConRoYa ) then gui.setNumberBoxValue ( hConRoYa, nConRoYa or 0 ) end
    if ( hConRoZa ) then gui.setNumberBoxValue ( hConRoZa, nConRoZa or 0 ) end
    if ( hConRela ) then gui.setCheckBoxState ( hConRela, bConRela and gui.kCheckStateOn or gui.kCheckStateOff ) end

end

function onConfigSave ( )

    local sMID = this.getModuleIdentifier ( )

    local hOutPat = gui.getComponent ( "ffbx.output.folder.path" )
    local hOutClr = gui.getComponent ( "ffbx.output.folder.clear" )
    local hOutImp = gui.getComponent ( "ffbx.output.folder.import" )

    local hImpMat = gui.getComponent ( "ffbx.import.material" )
    local hImpTex = gui.getComponent ( "ffbx.import.texture" )
    local hImpLnk = gui.getComponent ( "ffbx.import.link" )
    local hImpShp = gui.getComponent ( "ffbx.import.shape" )
    local hImpAni = gui.getComponent ( "ffbx.import.animation" )
    local hImpGlo = gui.getComponent ( "ffbx.import.global" )

    local hExpMat = gui.getComponent ( "ffbx.export.material" )
    local hExpTex = gui.getComponent ( "ffbx.export.texture" )
    local hExpEmb = gui.getComponent ( "ffbx.export.embed" )
    local hExpShp = gui.getComponent ( "ffbx.export.shape" )
    local hExpAni = gui.getComponent ( "ffbx.export.animation" )
    local hExpGlo = gui.getComponent ( "ffbx.export.global" )

    local hConSca = gui.getComponent ( "ffbx.convert.prescale" )
    local hConTrX = gui.getComponent ( "ffbx.convert.transX" )
    local hConTrY = gui.getComponent ( "ffbx.convert.transY" )
    local hConTrZ = gui.getComponent ( "ffbx.convert.transZ" )
    local hConRoX = gui.getComponent ( "ffbx.convert.rotX" )
    local hConRoY = gui.getComponent ( "ffbx.convert.rotY" )
    local hConRoZ = gui.getComponent ( "ffbx.convert.rotZ" )
    local hConTrXs = gui.getComponent ( "ffbx.convert.transXs" )
    local hConTrYs = gui.getComponent ( "ffbx.convert.transYs" )
    local hConTrZs = gui.getComponent ( "ffbx.convert.transZs" )
    local hConRoXs = gui.getComponent ( "ffbx.convert.rotXs" )
    local hConRoYs = gui.getComponent ( "ffbx.convert.rotYs" )
    local hConRoZs = gui.getComponent ( "ffbx.convert.rotZs" )
    local hConSkel = gui.getComponent ( "ffbx.convert.skelscale" )
    local hConRoXa = gui.getComponent ( "ffbx.convert.rotXa" )
    local hConRoYa = gui.getComponent ( "ffbx.convert.rotYa" )
    local hConRoZa = gui.getComponent ( "ffbx.convert.rotZa" )
    local hConRela = gui.getComponent ( "ffbx.convert.animRelative" )

    project.setUserProperty ( nil, sMID ..".config.ffbx.output.folder.path", gui.getEditBoxText ( hOutPat ) )
    project.setUserProperty ( nil, sMID ..".config.ffbx.output.folder.clear", gui.getCheckBoxState ( hOutClr ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.output.folder.import", gui.getCheckBoxState ( hOutImp ) == gui.kCheckStateOn )

    project.setUserProperty ( nil, sMID ..".config.ffbx.import.material", gui.getCheckBoxState ( hImpMat ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.texture", gui.getCheckBoxState ( hImpTex ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.link", gui.getCheckBoxState ( hImpLnk ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.shape", gui.getCheckBoxState ( hImpShp ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.animation", gui.getCheckBoxState ( hImpAni ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.import.global", gui.getCheckBoxState ( hImpGlo ) == gui.kCheckStateOn )

    project.setUserProperty ( nil, sMID ..".config.ffbx.export.material", gui.getCheckBoxState ( hExpMat ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.export.texture", gui.getCheckBoxState ( hExpTex ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.export.embed", gui.getCheckBoxState ( hExpEmb ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.export.shape", gui.getCheckBoxState ( hExpShp ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.export.animation", gui.getCheckBoxState ( hExpAni ) == gui.kCheckStateOn )
    project.setUserProperty ( nil, sMID ..".config.ffbx.export.global", gui.getCheckBoxState ( hExpGlo ) == gui.kCheckStateOn )

    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.prescale", gui.getNumberBoxValue ( hConSca ) or 1.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transX", gui.getNumberBoxValue ( hConTrX ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transY", gui.getNumberBoxValue ( hConTrY ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transZ", gui.getNumberBoxValue ( hConTrZ ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotX", gui.getNumberBoxValue ( hConRoX ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotY", gui.getNumberBoxValue ( hConRoY ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotZ", gui.getNumberBoxValue ( hConRoZ ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transXs", gui.getNumberBoxValue ( hConTrXs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transYs", gui.getNumberBoxValue ( hConTrYs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.transZs", gui.getNumberBoxValue ( hConTrZs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotXs", gui.getNumberBoxValue ( hConRoXs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotYs", gui.getNumberBoxValue ( hConRoYs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotZs", gui.getNumberBoxValue ( hConRoZs ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.skelscale", gui.getNumberBoxValue ( hConSkel ) or 1.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotXa", gui.getNumberBoxValue ( hConRoXa ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotYa", gui.getNumberBoxValue ( hConRoYa ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.rotZa", gui.getNumberBoxValue ( hConRoZa ) or 0.0 )
    project.setUserProperty ( nil, sMID ..".config.ffbx.convert.animRelative", gui.getCheckBoxState ( hConRela ) == gui.kCheckStateOn )

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
    local bOutImp = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.import" ) and 1 or 0

    local bI1 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.material" )  and 1 or 0
    local bI2 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.texture" )   and 1 or 0
    local bI3 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.link" )      and 1 or 0
    local bI4 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.shape" )     and 1 or 0
    local bI5 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.animation" ) and 1 or 0
    local bI6 = project.getUserProperty ( nil, sMID ..".config.ffbx.import.global" )    and 1 or 0

    local bE1 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.material" )  and 1 or 0
    local bE2 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.texture" )   and 1 or 0
    local bE3 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.embed" )     and 1 or 0
    local bE4 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.shape" )     and 1 or 0
    local bE5 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.animation" ) and 1 or 0
    local bE6 = project.getUserProperty ( nil, sMID ..".config.ffbx.export.global" )    and 1 or 0

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

    if not FFBX_setOptionsOutput( sOutPat, bOutClr, bOutImp ) then
        log.warning ( "FFBX: Could not send output options to DLL" )
        return false
    end

    if not FFBX_setOptionsImport( bI1, bI2, bI3, bI4, bI5, bI6 ) then
        log.warning ( "FFBX: Could not send import options to DLL" )
        return false
    end

    if not FFBX_setOptionsExport( bE1, bE2, bE3, bE4, bE5, bE6 ) then
        log.warning ( "FFBX: Could not send export options to DLL" )
        return false
    end

    -- TODO: maybe move TRS and skeleton transform to FBX SDK?

    -- start conversion thread

    if not FFBX_runConversion() then
        log.warning ( "FFBX: Launching conversion thread failed" )
        return false
    end

    return true
end

--------------------------------------------------------------------------------
-- DAE IMPORT
--------------------------------------------------------------------------------

function onImportDAE ( )

    -- get conversion options

    local iSwap = 0
    local hConSwa = gui.getComponent ( "ffbx.convert.swapyz" )
    if ( hConSwa ) then iSwap = gui.getComboBoxItemRow ( gui.getComboBoxSelectedItem ( hConSwa ) ) -1 end

    local sMID = this.getModuleIdentifier ( )

    local sPathDAE = project.getUserProperty ( nil, sMID ..".config.ffbx.output.folder.path" ) .."/"
    if not system.directoryExists ( sPathDAE ) then
        log.warning ( "FFBX: output path could not be verified" )
        return
    end

    local bImpMat = project.getUserProperty ( nil, sMID ..".config.ffbx.import.material" )
    local bImpTex = project.getUserProperty ( nil, sMID ..".config.ffbx.import.texture" )
    local bImpShp = project.getUserProperty ( nil, sMID ..".config.ffbx.import.shape" )
    local bImpAni = project.getUserProperty ( nil, sMID ..".config.ffbx.import.animation" )

    local nConSca = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.prescale" )
    local nConTrX = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transX" )
    local nConTrY = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transY" )
    local nConTrZ = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transZ" )
    local nConRoX = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotX" )
    local nConRoY = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotY" )
    local nConRoZ = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZ" )
    local nConTrXs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transXs" )
    local nConTrYs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transYs" )
    local nConTrZs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.transZs" )
    local nConRoXs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotXs" )
    local nConRoYs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotYs" )
    local nConRoZs = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZs" )
    local nConSkel = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.skelscale" )
    local nConRoXa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotXa" )
    local nConRoYa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotYa" )
    local nConRoZa = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.rotZa" )
    local bConRela = project.getUserProperty ( nil, sMID ..".config.ffbx.convert.animRelative" )

    local vConSca = table.pack ( nConSca, nConSca, nConSca )
    local vConTra = table.pack ( nConTrX, nConTrY, nConTrZ )
    local vConRot = table.pack ( nConRoX, nConRoY, nConRoZ )
    local vConScaS = table.pack ( nConSkel, nConSkel, nConSkel )
    local vConTraS = table.pack ( nConTrXs, nConTrYs, nConTrZs )
    local vConRotS = table.pack ( nConRoXs, nConRoYs, nConRoZs )
    local vConRotA = table.pack ( nConRoXa, nConRoYa, nConRoZa )

    -- generate file list

    local hTree = gui.getComponent ( "ffbx.input.resource.tree" )
    local cTree = gui.getTreeItemCount ( hTree )
    local tFilenames = {}

    for i=1, cTree do
        -- compose new filename
        local sFilename = gui.getTreeItemText ( gui.getTreeItem ( hTree, i ) )
        local daeName = sPathDAE ..string.extractFileName (sFilename) ..".dae"
        if ( system.fileExists ( daeName ) ) then
            table.insert ( tFilenames, daeName )
            log.message ( "FFBX DAE conversion job: Adding file " ..daeName )
        else
            log.warning ( "FFBX DAE conversion job: Trying to add file " ..daeName ..", but it does not exist!" )
        end
    end

    -- create a new job for every import

    for i=1, #tFilenames do

        local hImportJob = job.create ( "" )
        if not hImportJob then
            log.warning ( "FFBX DAE conversion job: Could not create Job for " ..tFilenames[i] )
            return
        end

        local sProjectRootPath = project.getRootDirectory ( )
        local sFileToImportPath = tFilenames[i]
        local sModelname = string.extractFileName ( sFileToImportPath )

        local hTarget
        local hSelectedItem = gui.getComboBoxSelectedItem ( gui.getComponent ( "ffbx.convert.target" ) )
        if  ( hSelectedItem ) then
            gui.getComboBoxItemUserData ( hSelectedItem )
        end

        job.setType     ( hImportJob, job.kTypeImportModel )
        job.setProperty ( hImportJob, job.kPropertyLogOutput,               true )
        job.setProperty ( hImportJob, job.kPropertyCompleteCallback,         onJobComplete )

        job.setProperty ( hImportJob, job.kPropertySourceFile,              sFileToImportPath )
        job.setProperty ( hImportJob, job.kPropertyDestinationName,         sModelname )
        job.setProperty ( hImportJob, job.kPropertyDestinationDirectory,    sProjectRootPath  )
        job.setProperty ( hImportJob, job.kPropertyDescription,             "FFBX DAE Model Import" )
        job.setProperty ( hImportJob, job.kPropertyDestinationTarget,       hTarget )

        job.setProperty ( hImportJob, job.kPropertyImportPrefixItemList, { sModelname .."_" } )

        local tbDummy = { job.kImportItemDummy, false }
        local tbMesh = { job.kImportItemMesh , biShp }
        local tbCamera = { job.kImportItemCamera , false }
        local tbLight = { job.kImportItemLight , false }
        local tbMaterial = { job.kImportItemMaterial , biMat }
        local tbTexture = { job.kImportItemTexture, biTex }
        local tbSkeleton = { job.kImportItemSkeleton , true }
        local tbAnimation = { job.kImportItemAnimation , biAni }
        job.setProperty ( hImportJob, job.kPropertyImportProcessItemList, { true, tbDummy, tbMesh, tbCamera, tbLight, tbMaterial, tbTexture, tbSkeleton, tbAnimation } )

        job.setProperty ( hImportJob, job.kPropertyImportGlobalTranslation, vConTra )
        job.setProperty ( hImportJob, job.kPropertyImportGlobalRotation, vConRot )
        job.setProperty ( hImportJob, job.kPropertyImportGlobalScale, vConSca )
        if ( iSwap == 1 ) then job.setProperty ( hImportJob, job.kPropertyImportGlobalZUp2YUp, true ) end

        job.setProperty ( hImportJob, job.kPropertyImportSkeletonTranslation, vConTraS )
        job.setProperty ( hImportJob, job.kPropertyImportSkeletonRotation, vConRotS )
        job.setProperty ( hImportJob, job.kPropertyImportSkeletonScale, vConScaS )
        if ( (iSwap == 2) or (iSwap == 4) ) then job.setProperty ( hImportJob, job.kPropertyImportSkeletonZUp2YUp, true ) end

        job.setProperty ( hImportJob, job.kPropertyImportAnimationRotation, vConRotA )
        if ( (iSwap == 3) or (iSwap == 4) ) then job.setProperty ( hImportJob, job.kPropertyImportAnimationZUp2YUp, true ) end

        job.setProperty ( hImportJob, job.kPropertyImportAnimationRelativeKeys, bConRela )

        -- Run the job (ASYNC)

        if ( job.run ( hImportJob, true ) ) then
            --addProjectFileDialogJob ( hImportJob, gui.getComponent ( "ProjectFileDialogModelImport" ), gui.getComponent ( "ProjectFileDialogModelImportCOLLADA.job" ) )
            log.message ( "FFBX: running import job for " ..tFilenames[i] )
        end

    end
end

function onJobComplete ( hJob )

    if ( not job.isCanceled ( hJob ) ) then
        local sOutputError = job.getErrorOutput ( hJob )

        local tErrorPositions = { }
        local tErrorDescriptions = { }

        if ( not string.isEmpty ( sOutputError ) ) then
            local tErrors = string.explode ( sOutputError, "\n", false, false )

            for nErrorLine = 1, #tErrors do
                local nLineMarkerIndex, nLineMarkerLength = string.findFirstMatchingRegEx ( tErrors[nErrorLine], ":(\\d)+:", 1 )

                if ( nLineMarkerIndex ~= nil ) then
                    table.insert ( tErrorPositions, string.toNumber ( string.getSubString ( tErrors[nErrorLine], nLineMarkerIndex+1, nLineMarkerLength-2 ) ) )
                    table.insert ( tErrorDescriptions, string.getSubString ( tErrors[nErrorLine], nLineMarkerIndex+nLineMarkerLength + 1, -1 ) )
                end

            end
        end

        --display search result in output
        local hLogModule = module.getModuleFromIdentifier ( "com.shiva.editor.log" )
        if ( hLogModule ) then
            local nBuildCategory = log.getCategoryIdFromName ( "Build", true )

            local sCurrentFileName = "FFBX: mainView"

            if ( #tErrorPositions == 0 ) then
                module.sendEvent ( hLogModule, "appendFind", nBuildCategory, false, "---"..sCurrentFileName.." (no error found)" )

            else
                module.sendEvent ( hLogModule, "appendFind", nBuildCategory, false, "---"..sCurrentFileName.." ("..#tErrorPositions.." error(s) found)" )
                for i=1, #tErrorPositions do
                    module.sendEvent ( hLogModule, "appendFind", nBuildCategory, true, "\tln "..tErrorPositions [i]..":\t".. string.trim ( tErrorDescriptions [i], "\r\n\t " ), FocusBuildResult, job.getProperty ( hJob, job.kPropertySourceFile ), tErrorPositions[i] )
                end

            end

            --module.sendEvent ( hLogModule, "onFocusCategory", nBuildCategory )
        end

        job.finalize ( hJob )
    end

end

function onRunImport ( )

    onConfigSave ( )
    log.message ( "-------------------------------" )
    log.message ( "FFBX: Starting the import process" )

    onExportFBX ( )

end

-- debugging!
function onRunImportDAE ( )

    onConfigSave ( )
    log.message ( "-------------------------------" )
    log.message ( "FFBX: Starting DAE import process (debugging)" )

    onImportDAE ( )

end