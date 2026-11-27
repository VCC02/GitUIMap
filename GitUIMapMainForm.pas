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
  LCLType, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  VirtualTrees;

type
  TCommit = record
    ID: string;
    Timestamp: string;
    Author: string;
    EMail: string;
    Message: string;
  end;

  TCommitArr = array of TCommit;


  { TfrmGitUIMapMain }

  TfrmGitUIMapMain = class(TForm)
    btnBrowseRepo: TButton;
    btnGetMap: TButton;
    btnPlugins: TButton;
    grpBatchExecution: TGroupBox;
    lblCommands: TLabel;
    lblCommits: TLabel;
    lbeRepoPath: TLabeledEdit;
    lblFiles: TLabel;
    memLog: TMemo;
    memCommands: TMemo;
    rdgrpBatchExecDir: TRadioGroup;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    vstFiles: TVirtualStringTree;
    vstMap: TVirtualStringTree;
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
    procedure ExecGit(AGitParams, AGitOutput: TStringList);
    procedure GetMap;
    procedure GetCommitFiles(ACommitShortHash: string);
  public

  end;

var
  frmGitUIMapMain: TfrmGitUIMapMain;

{ToDo:
  - be able to check out a specific commit: "git switch --detach <commit-hash>" or "git checkout <commit-hash>"
}

implementation

{$R *.frm}

uses
  Process, GitUIMapPluginsForm;

const
  CParamDelim = '||||';

{ TfrmGitUIMapMain }


procedure TfrmGitUIMapMain.AddToLog(AMsg: string);
begin
  memLog.Lines.Add(DateTimeToStr(Now) + '  ' + AMsg);
end;


procedure TfrmGitUIMapMain.ExecGit(AGitParams, AGitOutput: TStringList);
var
  Prc: TProcess;
  TempBuffer: array of Byte;
  MemStream: TMemoryStream;
  tk: QWord;
begin
  Prc := TProcess.Create(nil);
  try
    Prc.Executable := 'git';

    Prc.CurrentDirectory := lbeRepoPath.Text;
    if Prc.CurrentDirectory = '' then
      Prc.CurrentDirectory := ExtractFileDir(Prc.CurrentDirectory);

    Prc.Parameters.Assign(AGitParams);
    Prc.Options := [poUsePipes, poStderrToOutPut, poNoConsole];

    Prc.Execute;
    MemStream := TMemoryStream.Create;
    try
      tk := GetTickCount64;
      repeat
        Application.ProcessMessages;
        Sleep(10);

        //Wait a bit for output
        if (Prc.Output <> nil) and (Prc.Output.NumBytesAvailable > 0) then
          Break;
      until (GetTickCount64 - tk > 500);

      repeat
        if (Prc.Output <> nil) and (Prc.Output.NumBytesAvailable > 0) then
        begin
          SetLength(TempBuffer, Prc.Output.NumBytesAvailable);
          if Length(TempBuffer) > 0 then
          begin
            Prc.Output.Read(TempBuffer[0], Length(TempBuffer));
            MemStream.Write(TempBuffer[0], Length(TempBuffer));
          end;
        end;

        Application.ProcessMessages;
        Sleep(10);
      until not Prc.Active;

      Sleep(200);

      //Verify again, maybe there is more content left:
      if (Prc.Output <> nil) and (Prc.Output.NumBytesAvailable > 0) then
      begin
        SetLength(TempBuffer, Prc.Output.NumBytesAvailable);
        if Length(TempBuffer) > 0 then
        begin
          Prc.Output.Read(TempBuffer[0], Length(TempBuffer));
          MemStream.Write(TempBuffer[0], Length(TempBuffer));
        end;
      end;

      MemStream.Position := 0;
      AGitOutput.LoadFromStream(MemStream);

      if AGitOutput.Count = 0 then
      begin
        AddToLog('Git output is empty.');
        Exit;
      end;

      if Pos('fatal: not a git repository', AGitOutput.Strings[0]) > 0 then
      begin
        AddToLog('Error getting list of commits. ' + AGitOutput.Strings[0]);
        Exit;
      end;
    finally
      MemStream.Free;
    end;
  finally
    Prc.Free;
  end;
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

    ExecGit(GitParams, GitOutput);

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


procedure TfrmGitUIMapMain.GetCommitFiles(ACommitShortHash: string);
var
  GitParams, GitOutput: TStringList;
  i: Integer;
begin
  vstFiles.RootNodeCount := 0;
  SetLength(FFilesPerCommit, 0);

  GitOutput := TStringList.Create;
  GitParams := TStringList.Create;
  try
    GitParams.Add('--no-pager');
    GitParams.Add('ls-tree');
    GitParams.Add('-r');
    GitParams.Add('--name-only');
    //GitParams.Add('-z');
    GitParams.Add(ACommitShortHash);

    ExecGit(GitParams, GitOutput);

    if GitOutput.Count = 0 then
      Exit;

    //Parsing GitOutput
    //AddToLog('Git output:');
    //AddToLog(#13#10 + GitOutput.Text);

    SetLength(FFilesPerCommit, GitOutput.Count);
    for i := 0 to Length(FFilesPerCommit) - 1 do
      FFilesPerCommit[i] := GitOutput.Strings[i];
  finally
    GitOutput.Free;
    GitParams.Free;
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

  FListOfPlugins.Add('abc');
  FListOfPlugins.Add('def');
  FListOfPlugins.Add('ghi');
  FListOfPlugins.Add('jkl');
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

