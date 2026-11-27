object frmGitUIMapPlugins: TfrmGitUIMapPlugins
  Left = 373
  Height = 240
  Top = 185
  Width = 609
  Caption = 'Git UI Map - Plugins'
  ClientHeight = 240
  ClientWidth = 609
  LCLVersion = '8.4'
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object vstPlugins: TVirtualStringTree
    Left = 8
    Height = 172
    Top = 8
    Width = 504
    Anchors = [akTop, akLeft, akRight, akBottom]
    DefaultText = 'Node'
    Header.AutoSizeIndex = 0
    Header.Columns = <>
    Header.MainColumn = -1
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstPluginsGetText
    OnInitNode = vstPluginsInitNode
    OnMouseUp = vstPluginsMouseUp
  end
  object btnAddPlugin: TButton
    Left = 525
    Height = 25
    Top = 8
    Width = 75
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Add'
    TabOrder = 1
    OnClick = btnAddPluginClick
  end
  object btnUpdatePlugin: TButton
    Left = 525
    Height = 25
    Top = 40
    Width = 75
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Update'
    TabOrder = 2
    OnClick = btnUpdatePluginClick
  end
  object btnRemovePlugin: TButton
    Left = 525
    Height = 25
    Top = 72
    Width = 75
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Remove'
    TabOrder = 3
    OnClick = btnRemovePluginClick
  end
  object lbePluginPath: TLabeledEdit
    Left = 8
    Height = 23
    Top = 208
    Width = 472
    Anchors = [akLeft, akRight, akBottom]
    EditLabel.Height = 15
    EditLabel.Width = 472
    EditLabel.Caption = 'Plugin path'
    TabOrder = 4
  end
  object btnBrowsePlugin: TButton
    Left = 485
    Height = 25
    Top = 208
    Width = 27
    Anchors = [akRight, akBottom]
    Caption = '...'
    TabOrder = 5
    OnClick = btnBrowsePluginClick
  end
  object btnOK: TButton
    Left = 525
    Height = 25
    Top = 178
    Width = 75
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 525
    Height = 25
    Top = 208
    Width = 75
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
end
