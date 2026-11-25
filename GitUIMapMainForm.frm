object frmGitUIMapMain: TfrmGitUIMapMain
  Left = 370
  Height = 397
  Top = 184
  Width = 1033
  Caption = 'Git UI Map'
  ClientHeight = 397
  ClientWidth = 1033
  Constraints.MinHeight = 397
  Constraints.MinWidth = 1033
  LCLVersion = '8.4'
  OnCreate = FormCreate
  object lbeRepoPath: TLabeledEdit
    Left = 8
    Height = 27
    Hint = 'Full path to the repository directory'
    Top = 24
    Width = 408
    EditLabel.Height = 19
    EditLabel.Width = 408
    EditLabel.Caption = 'Repo path'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object vstMap: TVirtualStringTree
    Cursor = 63
    Left = 8
    Height = 192
    Top = 88
    Width = 592
    Anchors = [akTop, akLeft, akBottom]
    DefaultNodeHeight = 19
    DefaultText = 'Node'
    Header.AutoSizeIndex = 0
    Header.Columns = <    
      item
        MinWidth = 30
        Position = 0
        Text = 'Idx'
      end    
      item
        MinWidth = 100
        Position = 1
        Text = 'ID'
        Width = 100
      end    
      item
        MinWidth = 130
        Position = 2
        Text = 'Timestamp'
        Width = 130
      end    
      item
        MinWidth = 100
        Position = 3
        Text = 'Author'
        Width = 100
      end    
      item
        MinWidth = 150
        Position = 4
        Text = 'E-mail'
        Width = 150
      end    
      item
        MinWidth = 500
        Position = 5
        Text = 'Message'
        Width = 500
      end>
    Header.DefaultHeight = 21
    Header.Height = 21
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Indent = 4
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstMapGetText
    OnMouseUp = vstMapMouseUp
  end
  object lblCommits: TLabel
    Left = 8
    Height = 19
    Top = 64
    Width = 58
    Caption = 'Commits:'
  end
  object vstFiles: TVirtualStringTree
    Left = 608
    Height = 304
    Top = 88
    Width = 416
    Anchors = [akTop, akLeft, akRight, akBottom]
    DefaultNodeHeight = 19
    DefaultText = 'Node'
    Header.AutoSizeIndex = 0
    Header.Columns = <>
    Header.MainColumn = -1
    TabOrder = 2
  end
  object lblFiles: TLabel
    Left = 608
    Height = 19
    Top = 64
    Width = 31
    Caption = 'Files:'
  end
  object btnBrowseRepo: TButton
    Left = 424
    Height = 25
    Top = 24
    Width = 24
    Caption = '...'
    TabOrder = 3
    OnClick = btnBrowseRepoClick
  end
  object btnGetMap: TButton
    Left = 464
    Height = 25
    Top = 8
    Width = 75
    Caption = 'Get map'
    TabOrder = 4
    OnClick = btnGetMapClick
  end
  object memLog: TMemo
    Left = 8
    Height = 109
    Hint = 'Log'
    Top = 280
    Width = 592
    Anchors = [akLeft, akBottom]
    ParentShowHint = False
    ReadOnly = True
    ScrollBars = ssVertical
    ShowHint = True
    TabOrder = 5
    WordWrap = False
  end
  object SelectDirectoryDialog1: TSelectDirectoryDialog
    Left = 494
    Top = 48
  end
end
