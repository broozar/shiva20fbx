-- FBX IMPORTER
-- August 2018
-- Felix Caffier

--------------------------------------------------------------------------------

function onMainViewUpdateMenuFile ( hView, hMenu )

end

--------------------------------------------------------------------------------

function onWebLicenseFBX ( hView, hMenu )
	
	log.message ( "Opening FBX SDK license PDF..." )
	system.openURL( module.getRootDirectory ( this.getModule() ) .."resources/FBX_SDK_2019_About_Box_Final.pdf" )
	
end

function onWebAutodesk ( hView, hMenu )
	
	log.message ( "Visiting Autodesk Developer Network..." )
	system.openURL( "www.autodesk.com/developer-network/overview" )
	
end

function onWebTris ( hView, hMenu )
	
	log.message ( "Visiting trisymphony website..." )
	system.openURL( "www.trisymphony.com" )
	
end
