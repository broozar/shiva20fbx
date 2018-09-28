--Default options values
tModuleOptionDefaultValue=
{
    [ "optionCheck"  ]  = true,
    [ "optionNumber" ]  = 2,
    [ "optionText"   ]  = "text"
}

if ( module.getSettingValue ( this.getModule ( ), "optionCheck"  ) == nil ) then module.setSettingValue ( this.getModule ( ), "optionCheck" , tModuleOptionDefaultValue [ "optionCheck"  ] )  end
if ( module.getSettingValue ( this.getModule ( ), "optionNumber" ) == nil ) then module.setSettingValue ( this.getModule ( ), "optionNumber", tModuleOptionDefaultValue [ "optionNumber" ] )  end
if ( module.getSettingValue ( this.getModule ( ), "optionText"   ) == nil ) then module.setSettingValue ( this.getModule ( ), "optionText"  , tModuleOptionDefaultValue [ "optionText"   ] )  end

function onSettingPanelShow ( )

    gui.setLabelText ( gui.getComponentFromView ( hView, "optionCheck"    , "Title" ), "Option check:" )
    gui.setLabelText ( gui.getComponentFromView ( hView, "optionNumber"   , "Title" ), "Option number:" )
    gui.setLabelText ( gui.getComponentFromView ( hView, "optionText"     , "Title" ), "Option text:" )

    gui.setCheckBoxState        ( gui.getComponent ( "optionCheck" , "CheckBox"  ), module.getSettingValue ( this.getModule ( ), "optionCheck" , tModuleOptionDefaultValue [ "optionCheck"  ] ) )
    gui.setNumberBoxValue         ( gui.getComponent ( "optionNumber", "NumberBox" ), module.getSettingValue ( this.getModule ( ), "optionNumber", tModuleOptionDefaultValue [ "optionNumber" ] ) )
    gui.setNumberBoxRange         ( gui.getComponent ( "optionNumber", "NumberBox" ), 1, 10 )
    gui.setNumberBoxPrecision   ( gui.getComponent ( "optionNumber", "NumberBox" ), 0 )
    gui.setEditBoxText             ( gui.getComponent ( "optionText"  , "EditBox"   ), module.getSettingValue ( this.getModule ( ), "optionText",   tModuleOptionDefaultValue [ "optionText"   ] ) )

end

--------------------------------------------------------------------------------

function onOptionCheckChanged ( hView, hComponent )

    local kCheckState = gui.getCheckBoxState ( gui.getComponent ( "optionCheck" , "CheckBox"  ) )
    module.setSettingValue ( this.getModule ( ), "optionCheck", kCheckState == gui.kCheckStateOn  )
end

--------------------------------------------------------------------------------

function onOptionNumberChanged ( hView, hComponent, nValue )

    local nValue = gui.getNumberBoxValue ( gui.getComponent ( "optionNumber", "NumberBox"  ) )
    module.setSettingValue ( this.getModule ( ), "optionNumber", nValue  )
end

--------------------------------------------------------------------------------

function onOptionTextChanged ( hView, hComponent, sText )

    local sText = gui.getEditBoxText ( gui.getComponent ( "optionText"  , "EditBox" ) )
    module.setSettingValue ( this.getModule ( ), "optionText", sText )
end
