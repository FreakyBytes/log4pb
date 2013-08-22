
IncludePath "../src/"
XIncludeFile "impl.pb"

Structure myLog
  ;val.i
  nachricht.s
  messwert.i
EndStructure

logging.Logging = Logging()   ;
log.Logger = logging\createLogger( "daten", #Log_ALL )
log2.Logger = logging\createLogger( "event", #Log_ALL )

testAppender.Appender = SimpleTestAppender()
 
log\addAppender( testAppender )
log\setFormat( "String msg; Integer val" )

; testAppender\set( "layout", "${date,%hh:%ii:%ss};${data.msg};${data.val}")

log2\addAppender( testAppender )
log2\setFormat( "String msg" )

test.myLog
test\messwert = 42
test\nachricht = "Hello World"

; Debug @test
; Debug @test\msg
; Debug @test\val

log\trace( @test )
log2\trace( @"foobar" )

End
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 2
; EnableXP
; EnableUser
; CompileSourceDirectory