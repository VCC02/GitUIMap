object frmGitUIMapPlugins: TfrmGitUIMapPlugins
  Left = 373
  Height = 240
  Top = 185
  Width = 320
  Caption = 'Git UI Map - Plugins'
  ClientHeight = 240
  ClientWidth = 320
  LCLVersion = '8.4'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object vstPlugins: TVirtualStringTree
    Left = 8
    Height = 100
    Top = 8
    Width = 296
    DefaultText = 'Node'
    Header.AutoSizeIndex = 0
    Header.Columns = <>
    Header.MainColumn = -1
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstPluginsGetText
    OnInitNode = vstPluginsInitNode
  end
end
