

XIncludeFile "../include/interface.pbi"
XIncludeFile "../include/interface_FormatParser.pbi"
XIncludeFile "structure.pbi"
XIncludeFile "util_assert.pbi"
XIncludeFile "FormatParser.pbi"


;- Declare
DeclareDLL Logging()
Declare _Logging_createLogger( *logging.Struc_Logging, name.s, threshold.a )
Declare _Logging_getLogger( *logging.Struc_Logging, name.s )

;- FunctionTable
DataSection
  
  vtbl_Logging:
  Data.i @_Logging_createLogger(), @_Logging_getLogger()
  
EndDataSection

; CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
;   #Integer_Length = 8
; CompilerElse
;   #Integer_Length = 4
; CompilerEndIf

; CompilerIf #PB_Compiler_Unicode = #True
;   #Character_Length = 2
; CompilerElse
;   #Character_Length = 1
; CompilerEndIf

;------------------------------------------------------------------------------

XIncludeFile "Logger.pbi"
XIncludeFile "SimpleTestAppender.pbi"
XIncludeFile "FileAppender.pbi"

;------------------------------------------------------------------------------
;- Impl Logging


ProcedureDLL Logging()
  
  *logging.Struc_Logging = AllocateMemory( SizeOf(Struc_Logging) )
  If Not *logging
    ProcedureReturn #False
  EndIf
  
  InitializeStructure( *logging, Struc_Logging )
  *logging\vtable = ?vtbl_Logging
  *logging\mutext = CreateMutex()
  
  ProcedureReturn *logging
  
EndProcedure

Procedure _Logging_createLogger( *logging.Struc_Logging, name.s, threshold.a )
  notNull(*logging)
  
  LockMutex( *logging\mutext )
  
  name = LCase(name)
  If FindMapElement( *logging\logger(), name )
    *logger.Struc_Logger = *logging\logger(name)
    *logger\threshold = threshold
  Else
    *logger.Struc_Logger = Logger( threshold )
    If *logger
      *logging\logger("name") = *logger
    EndIf
  EndIf
  
  UnlockMutex( *logging\mutext )
  
  ProcedureReturn *logger
  
EndProcedure

Procedure _Logging_getLogger( *logging.Struc_Logging, name.s )
  notNull(*logging)
  
  name = LCase(name)
  
  LockMutex( *logging\mutext )
  *logger = *logging\logger(name)
  UnlockMutex( *logging\mutext )
  
  ProcedureReturn *logger
  
EndProcedure

; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 33
; Folding = -
; EnableXP
; EnableUser
; CompileSourceDirectory