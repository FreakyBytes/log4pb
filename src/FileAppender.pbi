
XIncludeFile "../src/impl.pb"

;- Delcare FileAppender

DeclareDLL FileAppender()
Declare _FAp_set( *appender.Struc_Appender, property.s, value.s )
Declare.s _FAp_get( *appender.Struc_Appender, property.s )
Declare _FAp_setThreshold( *appender.Struc_Appender, threshold.a )
Declare.a _FAp_getThreshold( *appender.Struc_Appender )
Declare _FAp_append( *appender.Struc_Appender, *message.log_msg )

;-Impl FileAppender

DataSection
  
  vtbl_FileAppender:
  Data.i @_FAp_set(), @_FAp_get(), @_FAp_setThreshold(), @_FAp_getThreshold(), @_FAp_append()
  
EndDataSection

;------------------------------------------------------------------------------

ProcedureDLL FileAppender()
  Protected *appender.Struc_Appender
  
  *appender = AllocateMemory( SizeOf(Struc_Appender) )
  InitializeStructure( *appender, Struc_Appender )
  
  *appender\vtable = ?vtbl_SimpleTestAppender
  *appender\threshold = #Log_ALL
  *appender\mutex = CreateMutex()
  
  ProcedureReturn *appender
  
EndProcedure

Procedure _FAp_set( *appender.Struc_Appender, property.s, value.s )
  notNull(*appender)
  
  LockMutex( *appender\mutex )
  *appender\prop(property) = value
  UnlockMutex( *appender\mutex )
  
EndProcedure

Procedure.s _FAp_get( *appender.Struc_Appender, property.s )
  notNullStrRet(*appender)
  
  ProcedureReturn *appender\prop(property)
  
EndProcedure

Procedure _FAp_setThreshold( *appender.Struc_Appender, threshold.a )
  notNull(*appender)
  
  *appender\threshold = threshold
  
EndProcedure

Procedure.a _FAp_getThreshold( *appender.Struc_Appender )
  notNull(*appender)
  
  ProcedureReturn *appender\threshold
  
EndProcedure

Procedure _FAp_append( *appender.Struc_Appender, *message.log_msg )
  Protected output.s = ""
  
  notNull(*appender)
  notNull(*message)
  
  LockMutex( *appender\mutex )
  
  UnlockMutex( *appender\mutex )
EndProcedure
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP
; EnableUser
; CompileSourceDirectory