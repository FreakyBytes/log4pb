
#Integer_Length = SizeOf(Integer)
#Character_Length = SizeOf(Character)

Enumeration ;-AppenderFormatPartTypes
  #ApdFormatPart_None
  #ApdFormatPart_String
  #ApdFormatPart_Value
EndEnumeration

;-LogLevel Names
#LogLevelName_Trace = "Trace"
#LogLevelName_Debug = "Debug"
#LogLevelName_Info  = "Info"
#LogLevelName_Warn  = "Warning"
#LogLevelName_Error = "Error"
#LogLevelName_Fatal = "Fatal"

;-ParseFormat Strings
#ParseFormatString_OpenChar       = "{"
#ParseFormatString_CloseChar      = "}"
#ParseFormatString_ParamSeparator = ","
#ParseFormatString_DataSeparator  = "."
#ParseFormatString_EqualChar      = "="
#ParseFormatString_QuotesChar     = "'"
#ParseFormatString_EscapeChar     = "\"

#ParseFormatString_DateCommand    = "date"
#ParseFormatString_LevelCommand   = "level"
#ParseFormatString_ValueCommand   = "value"
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 2
; EnableXP
; EnableUser
; CompileSourceDirectory