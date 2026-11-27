{
    Copyright (C) 2026 VCC
    creation date: 25 Nov 2026
    initial release date: 25 Nov 2026

    author: VCC
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}


unit GitUIMapMainForm;

{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, VirtualTrees, GitUIMapPlugins;

type
  TCommit = record
    ID: string;
    Timestamp: string;
    Author: string;
    EMail: string;
    Message: string;
  end;

  TCommitArr = array of TCommit;

  TPlugin = record
    PluginHandle: THandle;
    InitPluginProc: TInitPlugin;
    ExecPluginProc: TExecPlugin;
    DonePluginProc: TDonePlugin;
  end;

  TPluginArr = array of TPlugin;


  { TfrmGitUIMapMain }

  TfrmGitUIMapMain = class(TForm)
    btnBrowseRepo: TButton;
    btnGetMap: TButton;
    btnPlugins: TButton;
    btnBatchRun: TButton;
    grpBatchExecution: TGroupBox;
    lblCommands: TLabel;
    lblCommits: TLabel;
    lbeRepoPath: TLabeledEdit;
    lblFiles: TLabel;
    memLog: TMemo;
    memCommands: TMemo;
    prbBatchRun: TProgressBar;
    rdgrpBatchExecDir: TRadioGroup;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    vstFiles: TVirtualStringTree;
    vstMap: TVirtualStringTree;
    procedure btnBatchRunClick(Sender: TObject);
    procedure btnBrowseRepoClick(Sender: TObject);
    procedure btnGetMapClick(Sender: TObject);
    procedure btnPluginsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstFilesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstMapGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstMapKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure vstMapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FCommits: TCommitArr;
    FFilesPerCommit: TStringArray;
    FListOfPlugins: TStringList;

    procedure AddToLog(AMsg: string);
    procedure GetMap;
    procedure GetFilesPerCommit(ACommitShortHash: string; AListOfFiles: TStringList);
    procedure GetCommitFiles(ACommitShortHash: string);
    function GetPluginIndexByName(APluginName: string): Integer;
    procedure ExecPlugin(var AAllPlugins: TPluginArr; APluginName: string; ACommitIdx: Integer);
    procedure ExecuteAllCommands(var AAllPlugins: TPluginArr; ACommitIndex: Integer);
  public

  end;

var
  frmGitUIMapMain: TfrmGitUIMapMain;

{ToDo:
  - be able to check out a specific commit: "git switch --detach <commit-hash>" or "git checkout <commit-hash>"
  - Load/Save settings
}

implementation

{$R *.frm}

uses
  GitUIMapPluginsForm, GitUIMapUtils;

const
  CParamDelim = '||||';

{ TfrmGitUIMapMain }


procedure TfrmGitUIMapMain.AddToLog(AMsg: string);
begin
  memLog.Lines.Add(DateTimeToStr(Now) + '  ' + AMsg);
end;


procedure LocalAddToLog(AMsg: string);
begin
  frmGitUIMapMain.AddToLog(AMsg);
end;


procedure AppProcMsg;
begin
  Application.ProcessMessages;
end;


procedure TfrmGitUIMapMain.GetMap;
var
  GitParams, GitOutput: TStringList;
  s: string;
  i: Integer;
begin
  vstMap.RootNodeCount := 0;
  SetLength(FCommits, 0);

  GitOutput := TStringList.Create;
  GitParams := TStringList.Create;
  try
    GitParams.Add('--no-pager');
    GitParams.Add('log');
    GitParams.Add('--pretty=format:''%h' + CParamDelim + '%ad' + CParamDelim + '%an' + CParamDelim + '%ae' + CParamDelim + '%s''');
    GitParams.Add('--date=iso');

    ExecGit(lbeRepoPath.Text, GitParams, GitOutput, @LocalAddToLog, @AppProcMsg);

    if GitOutput.Count = 0 then
      Exit;

    //Parsing GitOutput
    //AddToLog('Git output:');
    //AddToLog(#13#10 + GitOutput.Text);

    SetLength(FCommits, GitOutput.Count);
    for i := 0 to Length(FCommits) - 1 do
    begin
      s := GitOutput.Strings[i];

      if (s > '') and (s[1] = '''') then
        Delete(s, 1, 1);

      if (s > '') and (s[Length(s)] = '''') then
        Delete(s, Length(s), 1);

      FCommits[i].ID := Copy(s, 1, Pos(CParamDelim, s) - 1);
      Delete(s, 1, Pos(CParamDelim, s) + Length(CParamDelim) - 1);

      FCommits[i].Timestamp := Copy(s, 1, Pos(CParamDelim, s) - 1);
      Delete(s, 1, Pos(CParamDelim, s) + Length(CParamDelim) - 1);

      FCommits[i].Author := Copy(s, 1, Pos(CParamDelim, s) - 1);
      Delete(s, 1, Pos(CParamDelim, s) + Length(CParamDelim) - 1);

      FCommits[i].EMail := Copy(s, 1, Pos(CParamDelim, s) - 1);
      Delete(s, 1, Pos(CParamDelim, s) + Length(CParamDelim) - 1);

      FCommits[i].Message := s; //Copy(s, 1, Pos(CParamDelim, s) - 1);
      //Delete(s, 1, Pos(CParamDelim, s) + Length(CParamDelim) - 1);
    end;
  finally
    GitOutput.Free;
    GitParams.Free;
  end;

  vstMap.RootNodeCount := Length(FCommits);
end;


procedure TfrmGitUIMapMain.GetFilesPerCommit(ACommitShortHash: string; AListOfFiles: TStringList);
var
  GitParams, GitOutput: TStringList;
begin
  GitOutput := TStringList.Create;
  GitParams := TStringList.Create;
  try
    GitParams.Add('--no-pager');
    GitParams.Add('ls-tree');
    GitParams.Add('-r');
    GitParams.Add('--name-only');
    //GitParams.Add('-z');
    GitParams.Add(ACommitShortHash);

    ExecGit(lbeRepoPath.Text, GitParams, GitOutput, @LocalAddToLog, @AppProcMsg);

    if GitOutput.Count = 0 then
      Exit;

    //Parsing GitOutput
    //AddToLog('Git output:');
    //AddToLog(#13#10 + GitOutput.Text);

    AListOfFiles.Assign(GitOutput);
  finally
    GitOutput.Free;
    GitParams.Free;
  end;
end;


procedure TfrmGitUIMapMain.GetCommitFiles(ACommitShortHash: string);
var
  i: Integer;
  ListOfFiles: TStringList;
begin
  vstFiles.RootNodeCount := 0;
  SetLength(FFilesPerCommit, 0);

  ListOfFiles := TStringList.Create;
  try
    GetFilesPerCommit(ACommitShortHash, ListOfFiles);

    SetLength(FFilesPerCommit, ListOfFiles.Count);
      for i := 0 to Length(FFilesPerCommit) - 1 do
        FFilesPerCommit[i] := ListOfFiles.Strings[i];
  finally
    ListOfFiles.Free;
  end;

  vstFiles.RootNodeCount := Length(FFilesPerCommit);
end;


procedure TfrmGitUIMapMain.btnBrowseRepoClick(Sender: TObject);
var
  SelDir: TSelectDirectoryDialog;
begin
  SelDir := TSelectDirectoryDialog.Create(nil);
  try
    SelDir.InitialDir := lbeRepoPath.Text;
    if not SelDir.Execute then
      Exit;

    lbeRepoPath.Text := SelDir.FileName;
  finally
    SelDir.Free;
  end;
end;


function TfrmGitUIMapMain.GetPluginIndexByName(APluginName: string): Integer; //index of - without case sensitive, without path, without ext
var
  i: Integer;
  FileNameOnly: string;
begin
  Result := -1;
  APluginName := UpperCase(APluginName);
  if Pos('.', APluginName) > 0 then
    Delete(APluginName, Pos('.', APluginName), MaxInt);   //remove extension, just in case

  for i := 0 to FListOfPlugins.Count - 1 do
  begin
    FileNameOnly := UpperCase(ExtractFileName(FListOfPlugins.Strings[i]));
    if Pos('.', FileNameOnly) > 0 then
      Delete(FileNameOnly, Pos('.', FileNameOnly), MaxInt);   //remove extension, just in case

    if FileNameOnly = APluginName then
    begin
      Result := i;
      Exit;
    end;
  end;
end;


procedure PluginOutputCallback(AAOutput: Pointer; AAOutputLen: DWord); cdecl;
var
  s: string;
begin
  if AAOutputLen > 10000000 then
    AAOutputLen := 10000000;

  SetLength(s, AAOutputLen);
  Move(AAOutput^, s[1], AAOutputLen);

  LocalAddToLog('[Plugin]: ' + s);
end;


procedure TfrmGitUIMapMain.ExecPlugin(var AAllPlugins: TPluginArr; APluginName: string; ACommitIdx: Integer);
var
  Idx: Integer;
  Repo, ListOfFilesStr: string;
  ListOfFiles: TStringList;
begin
  Idx := GetPluginIndexByName(APluginName);
  if Idx = -1 then
  begin
    AddToLog('Error executing plugin "' + APluginName + '". It can''t be found by name. Plese verify the name and format.');
    Exit;
  end;

  Repo := lbeRepoPath.Text;

  ListOfFiles := TStringList.Create;
  try
    GetFilesPerCommit(FCommits[ACommitIdx].ID, ListOfFiles);
    ListOfFilesStr := ListOfFiles.Text;

    AAllPlugins[Idx].ExecPluginProc(@Repo[1], Length(Repo),
                                    @FCommits[ACommitIdx].ID, Length(FCommits[ACommitIdx].ID),
                                    @FCommits[ACommitIdx].Timestamp, Length(FCommits[ACommitIdx].Timestamp),
                                    @FCommits[ACommitIdx].Author, Length(FCommits[ACommitIdx].Author),
                                    @FCommits[ACommitIdx].EMail, Length(FCommits[ACommitIdx].EMail),
                                    @FCommits[ACommitIdx].Message, Length(FCommits[ACommitIdx].Message),
                                    @ListOfFilesStr, Length(ListOfFilesStr), @PluginOutputCallback);

  finally
    ListOfFiles.Free;
  end;
end;


procedure TfrmGitUIMapMain.ExecuteAllCommands(var AAllPlugins: TPluginArr; ACommitIndex: Integer);
var
  i, j: Integer;
  TempCmd, s, PluginName: string;
  AppParams, AppParamsBlanks, AppOutput: TStringList;
begin
  for i := 0 to memCommands.Lines.Count - 1 do
  begin
    s := memCommands.Lines.Strings[i];
    if s = '' then
      Continue;

    if Pos('PLUGIN.', UpperCase(s)) = 1 then
    begin
      PluginName := Copy(s, Length('PLUGIN.') + 1, MaxInt);
      ExecPlugin(AAllPlugins, PluginName, ACommitIndex);
    end
    else
    begin  //plain command
      if Pos(' ', s) > 0 then
        TempCmd := Copy(s, 1, Pos(' ', s) - 1)
      else
        TempCmd := s;

      AppParams := TStringList.Create;
      AppParamsBlanks := TStringList.Create;
      AppOutput := TStringList.Create;
      try
        AppParamsBlanks.LineBreak := ' '; //empty items will result if there are "multi-blanks", like '  ' or '   ' etc.
        if Pos(' ', s) > 0 then
        begin
          AppParamsBlanks.Text := Copy(s, Pos(' ', s) + 1, MaxInt);

          for j := 0 to AppParamsBlanks.Count - 1 do
            AppParams.Add(AppParamsBlanks.Strings[j]); //convert from #32 to #13#10 (or #10)
        end;

        try
          AddToLog('[App ' + TempCmd + ' params (' + IntToStr(AppParams.Count) + ')]: ' + AppParams.Text);
          ExecApp(TempCmd, lbeRepoPath.Text, AppParams, AppOutput, @AppProcMsg);
          AddToLog('[App ' + TempCmd + ']: ' + AppOutput.Text);
        except
          on E: Exception do
            AddToLog('[App ' + TempCmd + ' ex]: ' + E.Message);
        end;
      finally
        AppParams.Free;
        AppParamsBlanks.Free;
        AppOutput.Free;
      end;
    end;
  end;
end;


procedure TfrmGitUIMapMain.btnBatchRunClick(Sender: TObject);
var
  AllPlugins: TPluginArr;
  FailedLoading: Boolean;
  i: Integer;

  procedure UnloadAllPlugins;
  var
    i: Integer;
  begin
    for i := 0 to Length(AllPlugins) - 1 do
      if AllPlugins[i].PluginHandle <> 0 then
        FreeLibrary(AllPlugins[i].PluginHandle);
  end;
begin
  btnBatchRun.Enabled := False;
  try
    SetLength(AllPlugins, FListOfPlugins.Count);
    for i := 0 to Length(AllPlugins) - 1 do
      AllPlugins[i].PluginHandle := 0;

    FailedLoading := False;
    for i := 0 to Length(AllPlugins) - 1 do
    begin
      if not FileExists(FListOfPlugins.Strings[i]) then
      begin
        FailedLoading := True;
        AddToLog('Plugin not found at: ' + FListOfPlugins.Strings[i]);
        Break;
      end;

      AllPlugins[i].PluginHandle := LoadLibrary(FListOfPlugins.Strings[i]);
      if AllPlugins[i].PluginHandle = 0 then
      begin
        FailedLoading := True;
        AddToLog('Error loading plugin at: ' + FListOfPlugins.Strings[i]);
        Break;
      end;
    end;

    if FailedLoading then
    begin
      UnloadAllPlugins;
      Exit;
    end;

    for i := 0 to Length(AllPlugins) - 1 do
    begin
      AllPlugins[i].InitPluginProc := TInitPlugin(GetProcAddress(AllPlugins[i].PluginHandle, 'InitPlugin'));
      AllPlugins[i].ExecPluginProc := TExecPlugin(GetProcAddress(AllPlugins[i].PluginHandle, 'ExecPlugin'));
      AllPlugins[i].DonePluginProc := TDonePlugin(GetProcAddress(AllPlugins[i].PluginHandle, 'DonePlugin'));

      if AllPlugins[i].InitPluginProc = nil then
      begin
        AddToLog('Error getting address of InitPlugin at ' + FListOfPlugins.Strings[i]);
        FailedLoading := True;
        Break;
      end;

      if AllPlugins[i].ExecPluginProc = nil then
      begin
        AddToLog('Error getting address of ExecPlugin at ' + FListOfPlugins.Strings[i]);
        FailedLoading := True;
        Break;
      end;

      if AllPlugins[i].DonePluginProc = nil then
      begin
        AddToLog('Error getting address of DonePlugin at ' + FListOfPlugins.Strings[i]);
        FailedLoading := True;
        Break;
      end;
    end;

    if FailedLoading then
    begin
      UnloadAllPlugins;
      Exit;
    end;

    for i := 0 to Length(AllPlugins) - 1 do
    begin
      try
        AllPlugins[i].InitPluginProc;
      except
        on E: Exception do
        begin
          AddToLog('Error initializing plugin at ' + FListOfPlugins.Strings[i]);
          FailedLoading := True;
          Break;
        end;
      end;
    end;

    if FailedLoading then
    begin
      UnloadAllPlugins;
      Exit;
    end;

    try
      try
        prbBatchRun.Max := Length(FCommits);

        if rdgrpBatchExecDir.ItemIndex = 1 then  //last commit to first
        begin
          for i := 0 to Length(FCommits) - 1 do   //last commit is at index 0
          begin
            ExecuteAllCommands(AllPlugins, i);
            prbBatchRun.Position := i;
          end;
        end
        else                                     //first commit to last
        begin
          for i := Length(FCommits) - 1 downto 0 do   //last commit is at index 0
          begin
            ExecuteAllCommands(AllPlugins, i);
            prbBatchRun.Position := prbBatchRun.Max - i + 1;
          end;
        end;
      finally
        for i := 0 to Length(AllPlugins) - 1 do
        begin
          try
            AllPlugins[i].DonePluginProc;
          except
            on E: Exception do
            begin
              AddToLog('Error finalizing plugin at ' + FListOfPlugins.Strings[i]);
              //Break;  //Do not break, continue with the oters.
            end;
          end;
        end;
      end;
    finally
      UnloadAllPlugins;
    end;
  finally
    btnBatchRun.Enabled := True;
  end;
end;


procedure TfrmGitUIMapMain.btnGetMapClick(Sender: TObject);
var
  ErrMsg: string;
begin
  btnGetMap.Enabled := False;
  vstMap.BeginUpdate;
  try
    try
      AddToLog('Get map from: ' + lbeRepoPath.Text);
      GetMap;
      AddToLog('Done getting map.');
    except
      on E: Exception do
      begin
        ErrMsg := E.Message;
        if Pos('Failed to execute', ErrMsg) > 0 then
          ErrMsg := ErrMsg + #13#10 + 'Is git installed?';

        AddToLog('GetMap Ex: ' + ErrMsg);
      end;
    end;
  finally
    btnGetMap.Enabled := True;
    vstMap.EndUpdate;
  end;
end;


procedure TfrmGitUIMapMain.btnPluginsClick(Sender: TObject);
begin
  if not EditPlugins(FListOfPlugins) then
    Exit;
end;


procedure TfrmGitUIMapMain.FormCreate(Sender: TObject);
begin
  SetLength(FCommits, 0);
  SetLength(FFilesPerCommit, 0);
  FListOfPlugins := TStringList.Create;
end;


procedure TfrmGitUIMapMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FListOfPlugins);
end;


procedure TfrmGitUIMapMain.vstMapGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  try
    case Column of
      0: CellText := IntToStr(Length(FCommits) - Node^.Index - 1);
      1: CellText := FCommits[Node^.Index].ID;
      2: CellText := FCommits[Node^.Index].Timestamp;
      3: CellText := FCommits[Node^.Index].Author;
      4: CellText := FCommits[Node^.Index].EMail;
      5: CellText := FCommits[Node^.Index].Message;
    end;

  except
    on E: Exception do
      CellText := E.Message;
  end;
end;


procedure TfrmGitUIMapMain.vstMapKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node: PVirtualNode;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END] then
  begin
    Node := vstMap.GetFirstSelected;
    if Node = nil then
      Exit;

    GetCommitFiles(FCommits[Node^.Index].ID);
  end;
end;


procedure TfrmGitUIMapMain.vstMapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
begin
  Node := vstMap.GetFirstSelected;
  if Node = nil then
    Exit;

  GetCommitFiles(FCommits[Node^.Index].ID);
end;


procedure TfrmGitUIMapMain.vstFilesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  try
    CellText := FFilesPerCommit[Node^.Index];
  except
    on E: Exception do
      CellText := E.Message;
  end;
end;


end.

