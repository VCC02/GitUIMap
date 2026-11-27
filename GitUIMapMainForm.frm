object frmGitUIMapMain: TfrmGitUIMapMain
  Left = 373
  Height = 397
  Top = 185
  Width = 1033
  Caption = 'Git UI Map'
  ClientHeight = 397
  ClientWidth = 1033
  Constraints.MinHeight = 397
  Constraints.MinWidth = 1033
  LCLVersion = '8.4'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object lbeRepoPath: TLabeledEdit
    Left = 8
    Height = 23
    Hint = 'Full path to the repository directory'
    Top = 24
    Width = 408
    EditLabel.Height = 15
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
    OnKeyUp = vstMapKeyUp
    OnMouseUp = vstMapMouseUp
  end
  object lblCommits: TLabel
    Left = 8
    Height = 15
    Top = 64
    Width = 52
    Caption = 'Commits:'
  end
  object vstFiles: TVirtualStringTree
    Left = 608
    Height = 192
    Top = 88
    Width = 416
    Anchors = [akTop, akLeft, akRight, akBottom]
    DefaultNodeHeight = 19
    DefaultText = 'Node'
    Header.AutoSizeIndex = 0
    Header.Columns = <>
    Header.MainColumn = -1
    TabOrder = 2
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstFilesGetText
  end
  object lblFiles: TLabel
    Left = 608
    Height = 15
    Top = 64
    Width = 26
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
  object btnPlugins: TButton
    Left = 949
    Height = 25
    Top = 8
    Width = 75
    Anchors = [akTop, akRight]
    Caption = 'Plugins...'
    TabOrder = 6
    OnClick = btnPluginsClick
  end
  object grpBatchExecution: TGroupBox
    Left = 608
    Height = 101
    Top = 288
    Width = 416
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Batch execution'
    ClientHeight = 81
    ClientWidth = 412
    TabOrder = 7
    object rdgrpBatchExecDir: TRadioGroup
      Left = 8
      Height = 72
      Top = 8
      Width = 160
      Anchors = [akLeft, akBottom]
      AutoFill = True
      Caption = 'Execution direction'
      ChildSizing.LeftRightSpacing = 6
      ChildSizing.EnlargeHorizontal = crsHomogenousChildResize
      ChildSizing.EnlargeVertical = crsHomogenousChildResize
      ChildSizing.ShrinkHorizontal = crsScaleChilds
      ChildSizing.ShrinkVertical = crsScaleChilds
      ChildSizing.Layout = cclLeftToRightThenTopToBottom
      ChildSizing.ControlsPerLine = 1
      ClientHeight = 52
      ClientWidth = 156
      ItemIndex = 0
      Items.Strings = (
        'First commit to last'
        'Last commit to first'
      )
      TabOrder = 0
    end
    object memCommands: TMemo
      Left = 184
      Height = 64
      Hint = 'Please type one command per line. It is usually <tool_name [list of arguments]>'#13#10#13#10'To call a plugin, tpye on a new line: "Plugin.<plugin name>" (without quotes, without path and extension, and without arguments).'#13#10'The plugin name should be the file name without path and without extension (not case sensitive), and must be in the list of installed plugins.'#13#10'All the installed plugins are initialized before the batch execution, regardless of them being called or not, then finalized after execution.'#13#10'Every plugin receives the repository path, commit ID (hash), timestamp, author, e-mail, message and list of files.'#13#10#13#10'All the other lines are used as command lines.'
      Top = 16
      Width = 224
      Anchors = [akLeft, akRight, akBottom]
      Font.CharSet = ANSI_CHARSET
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Quality = fqDraft
      ParentFont = False
      ParentShowHint = False
      ScrollBars = ssBoth
      ShowHint = True
      TabOrder = 1
      WordWrap = False
    end
    object lblCommands: TLabel
      Left = 184
      Height = 15
      Top = -7
      Width = 62
      Caption = 'Commands'
    end
  end
  object btnBatchRun: TButton
    Left = 949
    Height = 25
    Top = 40
    Width = 75
    Anchors = [akTop, akRight]
    Caption = 'Batch run'
    TabOrder = 8
    OnClick = btnBatchRunClick
  end
  object prbBatchRun: TProgressBar
    Left = 888
    Height = 20
    Top = 66
    Width = 136
    Anchors = [akTop, akRight]
    Smooth = True
    TabOrder = 9
  end
  object SelectDirectoryDialog1: TSelectDirectoryDialog
    Left = 494
    Top = 48
  end
end
