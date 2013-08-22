
XIncludeFile "../include/interface.pbi"
XIncludeFile "../include/interface_FormatParser.pbi"
XIncludeFile "constants.pbi"
XIncludeFile "structure.pbi"

Declare _setFormat( *parser.Struc_FormatParser, formatString.s )

Procedure.s _MsgPartToString( *dat.log_msgpart, length = -1 )
  
  If length = -1
    length = *dat\length
  EndIf
  
  If *dat\type = #PB_String
    ProcedureReturn *dat\string
    
  ElseIf *dat\type = #PB_Integer
    ProcedureReturn Str(*dat\integer)
    
  ElseIf *dat\type = #PB_Long
    ProcedureReturn Str(*dat\long)
    
  ElseIf *dat\type = #PB_Word
    ProcedureReturn Str(*dat\word)
    
  ElseIf *dat\type = #PB_Quad
    ProcedureReturn Str(*dat\quad)
    
  ElseIf *dat\type = #PB_Byte
    ProcedureReturn Str(*dat\byte)
    
  ElseIf *dat\type = #PB_Ascii
    ProcedureReturn StrU(*dat\ubyte, #PB_Ascii)
    
  ElseIf *dat\type = #PB_Float
    If *dat\length >= 0
      ProcedureReturn StrF(*dat\float, length)
    Else
      ProcedureReturn Str(*dat\float)
    EndIf
    
  ElseIf *dat\type = #PB_Double
    If *dat\length >= 0
      ProcedureReturn StrD(*dat\double, length)
    Else
      ProcedureReturn StrD(*dat\double)
    EndIf
    
  Else
    ProcedureReturn ""
    
  EndIf
  
EndProcedure

Procedure.s _LogLevelToString( level.a )
  
  If level = #Log_Trace
    ProcedureReturn #LogLevelName_Trace
  ElseIf level = #Log_Debug
    ProcedureReturn #LogLevelName_Debug
  ElseIf level = #Log_Info
    ProcedureReturn #LogLevelName_Info
  ElseIf level = #Log_Warn
    ProcedureReturn #LogLevelName_Warn
  ElseIf level = #Log_Error
    ProcedureReturn #LogLevelName_Error
  ElseIf level = #Log_Fatal
    ProcedureReturn #LogLevelName_Fatal
  EndIf
  
  ProcedureReturn ""  
EndProcedure

;{date,%hh:%ii:%ss};{value.msg};{value.val}

Procedure.s _ParseFormatStringPart( format.s, *message.log_msg )
  Protected command.s, datafield.s, param1.s
  Protected length
  
  If CountString( format, #ParseFormatString_ParamSeparator ) > 0
    command = LCase(Trim( StringField( format, 1, #ParseFormatString_ParamSeparator ) ))
  Else
    command = LCase(Trim(format))
  EndIf
  
  If command = #ParseFormatString_OpenChar
    ProcedureReturn #ParseFormatString_OpenChar
    
  ElseIf command = ""
    ProcedureReturn #ParseFormatString_CloseChar
    
  ElseIf command = #ParseFormatString_DateCommand
    param1 = Trim(StringField( format, 2, #ParseFormatString_ParamSeparator ))
    ProcedureReturn FormatDate( param1, Date() )
    
  ElseIf command = #ParseFormatString_LevelCommand
    ProcedureReturn _LogLevelToString( *message\level )
    
  ElseIf Left( command, Len(#ParseFormatString_ValueCommand) ) = #ParseFormatString_ValueCommand
    datafield = Trim(StringField( command, 2, #ParseFormatString_DataSeparator ))
    param1 = Trim(StringField( format, 2, #ParseFormatString_ParamSeparator ))
    
    If FindMapElement( *message\messages(), datafield ) 
      
      If Not param1 = ""
        length = Val(param1)
      Else
        length = -1
      EndIf
      
      ProcedureReturn _MsgPartToString( *message\messages(datafield), length)
    EndIf
    
  Else
    ProcedureReturn ""
    
  EndIf
  
EndProcedure


Procedure.s ParseFormatString( format.s, *message.log_msg )
  Protected startPos = 0, endPos = 0
  Protected part.s, newpart.s
  
  Repeat
    startPos = FindString( format, #ParseFormatString_OpenChar, endPos )
    If startPos = 0
      ProcedureReturn format
    EndIf
    
    endPos = FindString( format, #ParseFormatString_CloseChar, startPos )
    If endPos = 0
      ProcedureReturn format
    EndIf
    
    part = Mid( format, startPos+1, (endPos-startPos)-1 )
    Debug part
    newpart = _ParseFormatStringPart( part, *message )
    format = ReplaceString( format, #ParseFormatString_OpenChar + part + #ParseFormatString_CloseChar, newpart, #PB_String_CaseSensitive, startPos )
    Debug format
    endPos = startPos + Len(newpart)
    
  Until endPos >= Len(format)
  
  Debug "----"
  ProcedureReturn format
  
EndProcedure

Declare.s _FP_setFormat( *parser.Struc_FormatParser, formatString.s )
Declare _FP_setMetaCharacters( *parser.Struc_FormatParser, openBracket.s, closeBracket.s, openQuoate.s, closeQuote.s, paramSeparator.s, escape.s, equal.s )
Declare.s _FP_parse( *parser.Struc_FormatParser, *message.log_msg )

DataSection
  
  vtbl_FormatParser:
  Data.i @_FP_setFormat(), @_FP_setMetaCharacters(), @_FP_parse()
  
EndDataSection

ProcedureDLL FormatParser()
  Protected *formatParser.Struc_FormatParser
  
  *formatParser = AllocateMemory( SizeOf(Struc_FormatParser) )
  If Not *formatParser
    ProcedureReturn #False
  EndIf
  
  InitializeStructure( *formatParser, Struc_FormatParser )
  *formatParser\vtable = ?vtbl_FormatParser
  *formatParser\meta = #ParseFormatString_OpenChar + #ParseFormatString_CloseChar + #ParseFormatString_QuotesChar + #ParseFormatString_QuotesChar +
                       #ParseFormatString_ParamSeparator + #ParseFormatString_EscapeChar + #ParseFormatString_EqualChar
  ClearList( *formatParser\parts() )
  
  ProcedureReturn *formatParser
  
EndProcedure
;( openBracket.s, closeBracket.s, openQuoate.s, closeQuote.s, paramSeparator.s, escape.s, equal.s )

Procedure.s _FP_EscapedChar( char.c )
  
  Select char
    Case 'a' : ProcedureReturn #BEL$    ; bel
    Case 'b' : ProcedureReturn #BS$     ; backspace
    Case 't' : ProcedureReturn #TAB$    ; Tab
    Case 'l' : ProcedureReturn #LF$     ; linefeed #LF$
    Case 'f' : ProcedureReturn #FF$     ; formfeed
    Case 'r' : ProcedureReturn #CR$     ; return #CR$
    Case 'n' : ProcedureReturn #CRLF$   ; carriage return #CRLF$
    Default : ProcedureReturn Chr(char)
  EndSelect
  
EndProcedure

Procedure _FP_IsCharNumeric( char.c )
  
  Select char
    Case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      ProcedureReturn #True
    Default
      ProcedureReturn #False
  EndSelect
  
EndProcedure

Enumeration
  #FPM_OpenBracket = 0
  #FPM_CloseBracket
  #FPM_OpenQuotes
  #FPM_CloseQuotes
  #FPM_ParamSeparator
  #FPM_Escape
  #FPM_Equal
EndEnumeration

Enumeration
  #FPVS_BeforeEqual
  #FPVS_AfterEqual
  #FPVS_AfterEqualInQuotes
  #FPVS_AfterEqualAfterQuotes
EndEnumeration


Procedure.s _FP_setFormat( *parser.Struc_FormatParser, formatString.s )
  
  Protected *string.StringArray = @formatString
  Protected *left.StringArray = @formatString
  Protected *meta.StringArray = @*parser\meta
  
  Protected formatLen, pos, valueState
  Protected valueText.s = ""
  valueState = #FPVS_BeforeEqual
  
  
  ClearList( *parser\parts() )
  AddElement( *parser\parts() )
  *parser\parts()\type = #ApdFormatPart_None
  
  formatLen = Len(formatString)
  For pos = 0 To formatLen-1
    
    Select *string\c
      Case *meta\c[#FPM_Escape]
        
        If *left\c = *meta\c[#FPM_Escape] And *string - *left = 1
          
          If *parser\parts()\type = #ApdFormatPart_String Or *parser\parts()\type = #ApdFormatPart_None
            ;aktueller Part ist nicht Value -> String + \
            *parser\parts()\content("content") + Chr(*string\c)
            
          ElseIf *parser\parts()\type = #ApdFormatPart_String And valueState = #FPVS_AfterEqualInQuotes
            ;aktueller Part ist Value und innerhalb von Quotes
            valueText + Chr(*string\c)
            
          Else
            ;sonst -> Fehler
            Debug "Syntax-Error: Unexpected \\ at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        EndIf
        
      Case *meta\c[#FPM_OpenBracket]
        
        If *parser\parts()\type = #ApdFormatPart_None And Not *left\c = *meta\c[#FPM_Escape]
          ;erster Part ist Value
          
          *parser\parts()\type = #ApdFormatPart_Value
          valueState = #FPVS_BeforeEqual
          valueText  = ""
          
        ElseIf *parser\parts()\type = #ApdFormatPart_String And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist ein String und Klammer ist escaped
          
          *parser\parts()\content("content") + Chr(*string\c)
          
        ElseIf *parser\parts()\type = #ApdFormatPart_String And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist String, nächster wird ein Value -> Umbruch
          
          ;Part abschließen und neuen anlegen
          LastElement( *parser\parts() )
          AddElement( *parser\parts() )
          *parser\parts()\type = #ApdFormatPart_Value
          valueState = #FPVS_BeforeEqual
          valueText  = ""
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value, mit internen öffnenden Klammern -> Fehler
          Debug "Syntax-Error: unexpeted OpenBracket at [" + Str(pos+1) + "] : " + formatString
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Klammer ist escaped
          
          If valueState = #FPVS_AfterEqualInQuotes
            ;Nach dem Gleichheitszeichen und in Quotes
            valueText + Chr(*string\c)
            
          Else
            ;an anderer Stelle z.B. vor dem Gleichheitszeichen, oder nach ihm aber ohne Quotes
            Debug "Syntax-Error: escaped OpenBrackets are not allowed at [" + Str(pos+1) + "] : " + formatString
            
          EndIf 
        EndIf
        
      Case *meta\c[#FPM_CloseBracket]
        
        If ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String ) And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist nicht Value und CloseBracket ist nicht escaped -> Fehler
          Debug "Syntax-Error: unexpeted CloseBracket at [" + Str(pos+1) + "] : " + formatString
          
        ElseIf *parser\parts()\type = #ApdFormatPart_String And  *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist String und CloseBracket ist escaped
          *parser\parts()\content("content") + Chr(*string\c)
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und CloseBracket ist nicht escaped -> Umruch
          ;Part abschließen...
          *parser\parts()\content() = valueText
          
          ;...und neuen anlegen
          LastElement( *parser\parts() )
          AddElement( *parser\parts() )
          *parser\parts()\type = #ApdFormatPart_String
          
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und CloseBracket ist escaped
          If valueState = #FPVS_AfterEqualInQuotes
            ;Nach dem Gleichheitszeichen und in Quotes
            valueText + Chr(*string\c)
            
          Else
            ;an anderer Stelle z.B. vor dem Gleichheitszeichen, oder nach ihm aber ohne Quotes
            Debug "Syntax-Error: escaped CloseBrackets are not allowed at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        EndIf
        
      Case *meta\c[#FPM_OpenQuotes], *meta\c[#FPM_CloseQuotes]
        
        If ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String )
          ;aktueller Part ist nicht Value -> egal ob escaped, oder nicht
          *parser\parts()\type = #ApdFormatPart_String
          *parser\parts()\content("content") + Chr(*string\c)
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Quote ist escaped
          If valueState = #FPVS_AfterEqualInQuotes
            ;Escaped Quotes sind in Quotes (Quote-ception)
            valueText + Chr(*string\c)
            
          Else
            ;Escape Quotes sind irgenwo anders, wo sie nicht hingehören -> Fehler
            Debug "Syntax-Error: Even escaped Quotes are not allowed here at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        ElseIf  *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Quote ist nicht escaped
          
          If valueState = #FPVS_AfterEqual And valueText = ""
            ;direkt nach dem Equal -> in AfterEqual in Quotes umschalten
            valueState = #FPVS_AfterEqualInQuotes
            
          ElseIf valueState = #FPVS_AfterEqual And Not valueText = ""
            ;Quotes irgendwo im Text -> SyntaxFehler
            Debug "Syntax-Error: Unexpected Quotes at [" + Str(pos+1) + "] : " + formatString
            
          ElseIf valueState = #FPVS_AfterEqualInQuotes
            ;Ouotes abgeschlossen -> Zu Ende
            
            *parser\parts()\content() = valueText
            valueState = #FPVS_AfterEqualAfterQuotes
            ;valueText = ""
            
          ElseIf valueState = #FPVS_AfterEqualAfterQuotes
            ;Quotes nachdem abgeschlossen -> Fehler
            Debug "Syntax-Error: Expecting ParamSeparator, not Quotes at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        EndIf
        
      Case *meta\c[#FPM_ParamSeparator]
        
        If ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String )
          ;aktueller Part ist nicht Value -> egal ob escaped, oder nicht
          
          *parser\parts()\type = #ApdFormatPart_String
          *parser\parts()\content("content") + Chr(*string\c)
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und ParamSeparator ist escaped
          
          If valueState = #FPVS_AfterEqualInQuotes
            ;Escaped ParamSeparator ist in Quotes
            valueText + Chr(*string\c)
            
          Else
            ;Escape ParamSeparator ist irgenwo anders, wo sie nicht hingehören -> Fehler
            Debug "Syntax-Error: Even escaped ParamSeparator is not allowed at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        ElseIf  *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Quote ist nicht escaped
          
          If valueState = #FPVS_AfterEqual Or valueState = #FPVS_AfterEqualAfterQuotes
            ;aktueller Param ist zu Ende
            *parser\parts()\content() = valueText
            valueText = ""
            valueState = #FPVS_BeforeEqual
            
          Else
            ;irgendwo anders -> Fehler
            Debug "Syntax-Error: ParamSeparator is not allowed at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        EndIf
        
      Case *meta\c[#FPM_Equal]
        
        If ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String )
          ;aktueller Part ist nicht Value -> egal ob escaped, oder nicht
          
          *parser\parts()\type = #ApdFormatPart_String
          *parser\parts()\content("content") + Chr(*string\c)
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Quote ist escaped
          
          If valueState = #FPVS_AfterEqualInQuotes
            ;Escaped Equal ist in Quotes
            valueText + Chr(*string\c)
            
          Else
            ;Escape Equal ist irgenwo anders, wo sie nicht hingehören -> Fehler
            Debug "Syntax-Error: Even escaped Equal is not allowed at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        ElseIf  *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Equal ist nicht escaped
          
          If valueState = #FPVS_BeforeEqual
            ; ValueName ist abegeschlossen, umschalten auf AfterEqual
            valueState = #FPVS_AfterEqual
            
            ; Trim + toLower und neues Element in der content-Map anlegen
            valueText = Trim(LCase( valueText ))
            AddMapElement( *parser\parts()\content(), valueText )
            valueText = ""
            
          ElseIf valueState = #FPVS_AfterEqualInQuotes
            ;Equal in Quotes -> muss nicht escaped werden
            
            *parser\parts()\content() + Chr(*string\c)
            
          Else
            Debug "Syntax-Error: Unexpected Equal at [" + Str(pos+1) + "] : " + formatString
            
          EndIf
          
        EndIf
        
      Default
        
        If ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String ) And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist nicht Value und nicht escaped -> Zeichen anhängen
          *parser\parts()\content("content") + Chr(*string\c)
          *parser\parts()\type = #ApdFormatPart_String
          
        ElseIf ( *parser\parts()\type = #ApdFormatPart_None Or *parser\parts()\type = #ApdFormatPart_String ) And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist nicht Value und Zeichen ist escaped -> Parsen
          *parser\parts()\content("content") + _FP_EscapedChar( *string\c )
          *parser\parts()\type = #ApdFormatPart_String
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And Not *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Zeichen ist nicht escaped
          
          If valueState = #FPVS_BeforeEqual
            
            If Not *string\c = ' '
              valueText + LCase( Chr(*string\c) )
            EndIf
            
          ElseIf valueState = #FPVS_AfterEqual
            
            If Not *string\c = ' '            
              If _FP_IsCharNumeric( *string\c )
                valueText + Chr(*string\c)
              EndIf
            EndIf
            
          ElseIf valueState = #FPVS_AfterEqualInQuotes
            valueText + Chr(*string\c)
            
          Else
            Debug "Syntax-Error: Unexpected Character after Quotes at [" + Str(pos+1) + "] : " + formatString
            
          EndIf  
          
        ElseIf *parser\parts()\type = #ApdFormatPart_Value And *left\c = *meta\c[#FPM_Escape]
          ;aktueller Part ist Value und Zeichen ist escaped
          
          If valueState = #FPVS_BeforeEqual
            Debug "Syntax-Error: Escaped Chars are not allowed before Equal at [" + Str(pos+1) + "] : " + formatString
            
          ElseIf valueState = #FPVS_AfterEqual Or valueState = #FPVS_AfterEqualAfterQuotes
            Debug "Syntax-Error: Escaped Chars are only allowed in Quotes at [" + Str(pos+1) + "] : " + formatString
            
          ElseIf valueState = #FPVS_AfterEqualInQuotes
            valueText + _FP_EscapedChar( *string\c )
            
          EndIf
          
        EndIf
        
    EndSelect
    
    *left = *string
    *string + #Character_Length
  Next
  
  If *parser\parts()\type = #ApdFormatPart_Value
    ;letzter Part ist Value -> muss evtl. noch nachbearbeitet werden
    
    If valueState = #FPVS_AfterEqualInQuotes
      Debug "Syntax-Error: Unexpected End at [" + Str(pos+1) + "] : " + formatString
      
    EndIf
    
  EndIf
  
    
  
  Debug "End at " + Str(pos) + " from " + Str(formatLen)
  Debug "----"
EndProcedure

Procedure _FP_setMetaCharacters( *parser.Struc_FormatParser, openBracket.s, closeBracket.s, openQuote.s, closeQuote.s, paramSeparator.s, escape.s, equal.s )
  ;( openBracket.s, closeBracket.s, openQuoate.s, closeQuote.s, paramSeparator.s, escape.s, equal.s )
  
  openBracket     = Left(openBracket, 1)
  closeBracket    = Left(closeBracket, 1)
  openQuote       = Left(openQuote, 1)
  closeQuote      = Left(closeQuote, 1)
  paramSeparator  = Left(paramSeparator, 1)
  escape          = Left(escape, 1)
  equal           = Left(equal, 1)
    
  If Not openBracket : openBracket = #ParseFormatString_OpenChar : EndIf
  If Not closeBracket : closeBracket = #ParseFormatString_CloseChar : EndIf
  If Not openQuote : openQuote = #ParseFormatString_QuotesChar : EndIf
  If Not closeQuote : closeQuote = #ParseFormatString_QuotesChar : EndIf
  If Not paramSeparator : paramSeparator = #ParseFormatString_ParamSeparator : EndIf
  If Not escape : escape = #ParseFormatString_EscapeChar : EndIf
  If Not equal : equal = #ParseFormatString_EqualChar : EndIf
  
  *formatParser\meta = openBracket + closeBracket + openQuote + closeQuote + paramSeparator + escape + equal
  
EndProcedure

Procedure.s _FP_parse( *parser.Struc_FormatParser, *message.log_msg )
  
  
  
EndProcedure


CompilerIf Defined(ParseTest, #PB_Constant)
  Define test.log_msg
  InitializeStructure( test, log_msg )
  
  test\level = #Log_Info
  test\messages("msg")\type = #PB_String
  test\messages("msg")\string = "Hello World"
  test\messages("val")\type = #PB_Integer
  test\messages("val")\integer = 42
  
  ;   Debug ParseFormatString( "{date,%hh:%ii:%ss};[{level}];{{}{};{value.msg};{value.val}", test )
  
  Define *fparser.Struc_FormatParser = FormatParser()
  
  _FP_setFormat( *fparser, "Hell\\o \'World{test=123, flubber = 'sieben'}Ho\{hoho; {   Hello =   'World'}" )
  
  ForEach *fparser\parts()
    Debug "Type: " + *fparser\parts()\type
    ForEach *fparser\parts()\content()
      Debug MapKey(*fparser\parts()\content()) + ": " + *fparser\parts()\content()
    Next
    Debug "----"
    
  Next
  
    
  
CompilerEndIf

; IDE Options = PureBasic 4.60 (Windows - x64)
; CursorPosition = 36
; FirstLine = 26
; Folding = --
; EnableXP
; EnableUser
; CompileSourceDirectory