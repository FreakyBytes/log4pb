

Macro notNull(__value)
  If Not __value
    RaiseError(#PB_OnError_IllegalInstruction)
    ProcedureReturn #False
  EndIf
EndMacro

Macro notNullStrRet(__value)
  If Not __value
    RaiseError(#PB_OnError_IllegalInstruction)
    ProcedureReturn ""
  EndIf
EndMacro
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP
; EnableUser
; CompileSourceDirectory