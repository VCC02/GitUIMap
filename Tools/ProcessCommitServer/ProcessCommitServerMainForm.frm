object frmProcessCommitServer: TfrmProcessCommitServer
  Left = 373
  Height = 240
  Top = 185
  Width = 320
  Caption = 'Process Commit Server'
  ClientHeight = 240
  ClientWidth = 320
  LCLVersion = '8.4'
  object memLog: TMemo
    Left = 8
    Height = 138
    Top = 96
    Width = 304
    Anchors = [akTop, akLeft, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object chkActive: TCheckBox
    Left = 8
    Height = 19
    Top = 64
    Width = 51
    Caption = 'Active'
    TabOrder = 1
    OnChange = chkActiveChange
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    DefaultPort = 54831
    KeepAlive = True
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 77
    Top = 7
  end
end
