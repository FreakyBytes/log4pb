
;- Declare Logger

Declare Logger( threshold.a )
Declare _Logger_addAppender( *logger.Struc_Logger, appender.Appender )
Declare _Logger_setFormat( *logger.Struc_Logger, format.s )
Declare message_parse( *message, List format.log_msgpart_format(), Map output.log_msgpart() )
Declare _Logger_log( *logger.Struc_Logger, *message, level.a )
Declare _Logger_trace( *logger.Struc_Logger, *message )
Declare _Logger_dbg( *logger.Struc_Logger, *message )
Declare _Logger_info( *logger.Struc_Logger, *message )
Declare _Logger_warn( *logger.Struc_Logger, *message )
Declare _Logger_error( *logger.Struc_Logger, *message )
Declare _Logger_fatal( *logger.Struc_Logger, *message )

;- Impl Logger

DataSection
  
  vtbl_Logger:
  Data.i @_Logger_addAppender(), @_Logger_setFormat(), @_Logger_trace(), @_Logger_dbg(), @_Logger_info(), @_Logger_warn(), @_Logger_error(), @_Logger_fatal(), @_Logger_log()
  
EndDataSection

;------------------------------------------------------------------------------

Procedure Logger( threshold.a )
  
  *logger.Struc_Logger = AllocateMemory( SizeOf(Struc_Logger) )
  If Not *logger
    ProcedureReturn #False
  EndIf
  
  InitializeStructure( *logger, Struc_Logger)
  *logger\vtable = ?vtbl_Logger
  *logger\threshold = threshold
  *logger\mutex = CreateMutex()
  
  ProcedureReturn *logger
  
EndProcedure

Procedure _Logger_addAppender( *logger.Struc_Logger, appender.Appender )
  notNull(*logger)
  
  LockMutex(*logger\mutex)
  
  LastElement(*logger\appender())
  AddElement(*logger\appender())
  *logger\appender() = appender
  
  UnlockMutex(*logger\mutex)
  
  ProcedureReturn #True
  
EndProcedure

Procedure _Logger_setFormat( *logger.Struc_Logger, format.s )
  Protected parts, p, bracketstart, bracketend
  Protected part.s, type.s, name.s, length.s
  notNull(*logger)
  
  LockMutex( *logger\mutex )
  
  ClearList( *logger\messageparts() )
  
  format = LCase(Trim(format))
  parts = CountString( format, ";" ) + 1
  For p = 1 To parts
    part = Trim(StringField( format, p, ";" ))
    If part = "" : Continue : EndIf
    
    type = Trim(StringField(part, 1, " "))
    name = Trim(StringField(part, 2, " "))
    
    bracketstart = FindString(type, "[")
    If bracketstart
      bracketend = FindString(type, "]", bracketstart)
      If bracketend - bracketstart > 0
        length.s = Trim(Mid(type, bracketstart, bracketend-bracketstart))
      EndIf
      type = Trim(Mid(type, 1, bracketstart))
    Else
      length = "-1"
    EndIf
    
    If type And name
      LastElement( *logger\messageparts() )
      AddElement( *logger\messageparts() )
      
      With *logger\messageparts()
        \name = LCase(name)
        \length = Val(length)
        
        Select type
          Case "string"     : \type = #PB_String
          Case "integer"    : \type = #PB_Integer
          Case "long"       : \type = #PB_Long
          Case "quad"       : \type = #PB_Quad
          Case "word"       : \type = #PB_Word
          Case "float"      : \type = #PB_Float
          Case "double"     : \type = #PB_Double
          Case "byte"       : \type = #PB_Byte
          Case "ubyte"      : \type = #PB_Ascii
        EndSelect
        
      EndWith
      
    EndIf
    
  Next
  
  UnlockMutex( *logger\mutex )
  
EndProcedure

Procedure message_parse( *message, List format.log_msgpart_format(), Map output.log_msgpart() )
  Protected pointer = 0
  Protected string.s
  
  ClearMap( output() )
  
  ForEach format()
    
    AddMapElement( output(), format()\name )
    output()\type = format()\type
    output()\length = format()\length
    
    Select format()\type
      Case #PB_String
        If format()\length > -1
          string = PeekS( PeekI(*message + pointer), format()\length )
          pointer + #Integer_Length;format()\length
        Else
          If ListSize(format()) > 1
            string = PeekS( PeekI(*message + pointer) )
          Else
            string = PeekS( *message + pointer )
          EndIf
          pointer + #Integer_Length;StringByteLength( string ) + #Character_Length
        EndIf
        
        output()\string = string
        
      Case #PB_Integer
        output()\integer = PeekI( *message + pointer )
        pointer + #Integer_Length
        
      Case #PB_Long
        output()\long = PeekL( *message + pointer )
        pointer + 4
        
      Case #PB_Quad
        output()\quad = PeekQ( *message + pointer )
        pointer + 8
        
      Case #PB_Word
        output()\word = PeekW( *message + pointer )
        pointer + 2
        
      Case #PB_Float
        output()\float = PeekF( *message + pointer )
        pointer + 4
        
      Case #PB_Double
        output()\double = PeekD( *message + pointer )
        pointer + 8
        
      Case #PB_Byte
        output()\byte = PeekB( *message + pointer )
        pointer + 1
        
      Case #PB_Ascii
        output()\ubyte = PeekA( *message + pointer )
        pointer + 1
        
    EndSelect
    
  Next
  
EndProcedure

Procedure _Logger_log( *logger.Struc_Logger, *message, level.a )
  Protected *output.log_msg
  
  notNull( *logger )
  notNull( *message )
  
  If *logger\threshold > level
    ProcedureReturn #False
  EndIf
  
  LockMutex( *logger\mutex )
  
  *output = AllocateMemory( SizeOf(log_msg) )
  InitializeStructure( *output, log_msg )
  
  message_parse( *message, *logger\messageparts(), *output\messages() )
  *output\level = level
  
  ForEach *logger\appender()
    
    If *logger\appender()\getThreshold() <= threshold
      *logger\appender()\append( *output )
    EndIf
    
  Next
  
  UnlockMutex( *logger\mutex )
  
EndProcedure

Procedure _Logger_trace( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Trace )
  
EndProcedure

Procedure _Logger_dbg( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Debug )
  
EndProcedure

Procedure _Logger_info( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Info )
  
EndProcedure

Procedure _Logger_warn( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Warn )
  
EndProcedure

Procedure _Logger_error( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Error )
  
EndProcedure

Procedure _Logger_fatal( *logger.Struc_Logger, *message )
  
  ProcedureReturn _Logger_log( *logger, *message, #Log_Fatal )
  
EndProcedure
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 2
; Folding = --
; EnableXP
; EnableUser
; CompileSourceDirectory