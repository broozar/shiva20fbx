function displayShelfSampleMessage ( sText )
    
    gui.showMessageDialog ( sText )
end

displayShelfSampleMessage ( "Message from "..this.getModuleIdentifier ( ) )
