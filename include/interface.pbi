
Enumeration
  #Log_ALL
  #Log_Trace
  #Log_Debug
  #Log_Info
  #Log_Warn
  #Log_Error
  #Log_Fatal
  #Log_OFF
EndEnumeration

Structure log_msgpart
  type.a
  length.i
  
  string.s
  StructureUnion
    integer.i
    long.l
    quad.q
    word.w
    
    double.d
    float.f
    
    byte.b
    ubyte.a
  EndStructureUnion
EndStructure

Structure log_msg
  level.a
  Map messages.log_msgpart()
EndStructure

Interface Appender
  set( property.s, value.s )
  get.s( property )
  
  setThreshold( threshold.a )
  getThreshold.a()
  
  append( message.log_msg )
EndInterface

Interface Logger
  addAppender( appender.Appender )
  setFormat( format.s )
  
  trace( *message )
  dbg( *message )
  info( *message )
  warn( *message )
  error( *message )
  fatal( *message )
  Log( *message, level.a )
EndInterface

Interface Logging
  createLogger( name.s, threshold.a )
  
  getLogger( name.s )
EndInterface
; IDE Options = PureBasic 5.11 (Windows - x64)
; EnableXP
; EnableUser
; CompileSourceDirectory