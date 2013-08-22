
;- Delcare SimpleTestAppender

DeclareDLL SimpleTestAppender()
Declare _STA_set( *appender.Struc_Appender, property.s, value.s )
Declare.s _STA_get( *appender.Struc_Appender, property.s )
Declare _STA_setThreshold( *appender.Struc_Appender, threshold.a )
Declare.a _STA_getThreshold( *appender.Struc_Appender )
Declare _STA_append( *appender.Struc_Appender, *message.log_msg )

;-Impl SimpleTestAppender

DataSection
  
  vtbl_SimpleTestAppender:
  Data.i @_STA_set(), @_STA_get(), @_STA_setThreshold(), @_STA_getThreshold(), @_STA_append()
  
EndDataSection

;------------------------------------------------------------------------------

ProcedureDLL SimpleTestAppender()
  Protected *appender.Struc_Appender
  
  *appender = AllocateMemory( SizeOf(Struc_Appender) )
  InitializeStructure( *appender, Struc_Appender )
  
  *appender\vtable = ?vtbl_SimpleTestAppender
  *appender\threshold = #Log_ALL
  *appender\mutex = CreateMutex()
  
  ProcedureReturn *appender
  
EndProcedure

Procedure _STA_set( *appender.Struc_Appender, property.s, value.s )
  notNull(*appender)
  
  LockMutex( *appender\mutex )
  *appender\prop(property) = value
  UnlockMutex( *appender\mutex )
  
EndProcedure

Procedure.s _STA_get( *appender.Struc_Appender, property.s )
  notNullStrRet(*appender)
  
  ProcedureReturn *appender\prop(property)
  
EndProcedure

Procedure _STA_setThreshold( *appender.Struc_Appender, threshold.a )
  notNull(*appender)
  
  *appender\threshold = threshold
  
EndProcedure

Procedure.a _STA_getThreshold( *appender.Struc_Appender )
  notNull(*appender)
  
  ProcedureReturn *appender\threshold
  
EndProcedure

Procedure _STA_append( *appender.Struc_Appender, *message.log_msg )
  Protected output.s = ""
  
  notNull(*appender)
  notNull(*message)
  
  ForEach *message\messages()
    output + MapKey(*message\messages())
    output + " = "
    
    If *message\messages()\type = #PB_String
      output + *message\messages()\string
    Else
      output + Str(*message\messages()\integer)
    EndIf
    
    output + "  |  "
  Next
  
  Debug output
  
EndProcedure
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 19
; Folding = --
; EnableXP
; EnableUser
; CompileSourceDirectory