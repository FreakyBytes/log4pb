
XIncludeFile "impl.pb"

Structure messdaten
  aTemp.f
  kollektorTemp.f
  waermetauscherTemp.f
EndStructure

Global messdaten.messdaten

Global logging.Logging = Logging()
Global messdatenLogger.Logger = logging\createLogger( "messdaten", #Log_ALL )
messdatenLogger\setFormat("Float aTemp; Float kollektorTemp; Float waemetauscherTemp")

appender.Appender = SimpleTestAppender()
appender\setThreshold(#Log_ALL)
appender\set("layout", "")

Procedure Messe()
  
  messdaten\aTemp = 29.4
  messdaten\kollektorTemp = 60
  messdaten\waermetauscherTemp = 29
  
  messdatenLogger\trace(@messdaten)
EndProcedure

Procedure OfenSchalten( status )
  
  ; mach irgendwas....
  
EndProcedure

Procedure handleEvents()
  
  If messdaten\aTemp < 10 And messdaten\waermetauscherTemp < 25
    OfenSchalten(#True) 
  EndIf
  
EndProcedure

Procedure main()
  
  
  Repeat
    Messe()
    
    handleEvents()
  ForEver
  
EndProcedure
main()
; IDE Options = PureBasic 4.61 (Windows - x64)
; CursorPosition = 52
; FirstLine = 9
; Folding = -
; EnableXP