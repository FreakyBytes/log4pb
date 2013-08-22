
Structure log_msgpart_format
  name.s
  length.i
  type.a
EndStructure

Structure Struc_Appender
  vtable.i
  
  threshold.a
  mutex.i
  Map prop.s()
EndStructure

Structure Struc_FormattedAppender Extends Struc_Appender
  formatParser.FormatParser
EndStructure

Structure Struc_Logger
  vtable.i
  
  threshold.a
  mutex.i
  List appender.Appender()
  List messageparts.log_msgpart_format()
  
EndStructure

Structure Struc_Logging
  vtable.i
  
  mutext.i
  Map *logger.Struc_Logger()
  
EndStructure

;------------------------------------------------------------------------------

Structure StringArray
  c.c[0]
EndStructure

Structure formatParser_Part
  type.l
  Map content.s()
EndStructure

Structure Struc_FormatParser
  vtable.i
  
  List parts.formatParser_Part()
  meta.s
EndStructure

; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 45
; FirstLine = 10
; EnableXP
; EnableUser
; CompileSourceDirectory