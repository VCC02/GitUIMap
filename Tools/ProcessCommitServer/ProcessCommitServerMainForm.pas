{
    Copyright (C) 2026 VCC
    creation date: 28 Nov 2026
    initial release date: 28 Nov 2026

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


unit ProcessCommitServerMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IdHTTPServer, IdCustomHTTPServer, IdContext,
  IdSync;

type

  TSyncLogObj = class(TIdSync)
    FMsg: string;
  protected
    procedure DoSynchronize; override;
  end;

  { TfrmProcessCommitServer }

  TfrmProcessCommitServer = class(TForm)
    chkActive: TCheckBox;
    IdHTTPServer1: TIdHTTPServer;
    memLog: TMemo;
    procedure chkActiveChange(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    procedure AddToLog(AMsg: string);
    procedure AddToLogFromThread(AMsg: string);
    procedure ExecFromPlugin(AParams: TStrings);
  public

  end;

var
  frmProcessCommitServer: TfrmProcessCommitServer;

implementation

{$R *.frm}


procedure TSyncLogObj.DoSynchronize;
begin
  frmProcessCommitServer.AddToLog(FMsg);
end;

{ TfrmProcessCommitServer }


procedure TfrmProcessCommitServer.AddToLog(AMsg: string);
begin
  memLog.Lines.Add(DateTimeToStr(Now) + '  ' + AMsg);
end;


procedure TfrmProcessCommitServer.AddToLogFromThread(AMsg: string);
var
  SyncLogObj: TSyncLogObj;
begin
  SyncLogObj := TSyncLogObj.Create;
  try
    SyncLogObj.FMsg := AMsg;
    SyncLogObj.Synchronize;
  finally
    SyncLogObj.Free;
  end;
end;


procedure TfrmProcessCommitServer.ExecFromPlugin(AParams: TStrings);
var
  RepoPath, CommitID, Timestamp, Author, EMail, CommitMessage, ListOfFiles: string;
  CommitTimestamp: TDateTime;
  TimestampOffset: string;
begin
  RepoPath := AParams.Values['RepoPath'];
  CommitID := AParams.Values['CommitID'];
  Timestamp := AParams.Values['Timestamp'];
  Author := AParams.Values['Author'];
  EMail := AParams.Values['EMail'];
  CommitMessage := AParams.Values['CommitMessage'];
  ListOfFiles := AParams.Values['ListOfFiles'];

  AddToLogFromThread('Exec: RepoPath=' + RepoPath +
                         '  CommitID=' + CommitID +
                         '  Timestamp=' + Timestamp +
                         '  Author=' + Author +
                         '  EMail=' + EMail +
                         '  CommitMessage=' + CommitMessage +
                         '  ListOfFiles=' + ListOfFiles);

  //Attempt to interpret the timestamp into a readable format:
  TimestampOffset := Copy(Timestamp, Pos('+', Timestamp) + 1, MaxInt);
  Timestamp := Trim(Copy(Timestamp, 1, Pos(' +', Timestamp) - 1));
  //ToDo: look also for '-', not only '+', and maybe other fine grained offsets.

  if not TryStrToDateTime(Timestamp, CommitTimestamp) then
    AddToLogFromThread('Bad timestamp: ' + Timestamp)
  else
    AddToLogFromThread('Converted timestamp: ' + DateTimeToStr(CommitTimestamp) + '  Offset=' + TimestampOffset);
end;


procedure TfrmProcessCommitServer.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Cmd: string;
begin
  Cmd := ARequestInfo.Document;
  ARequestInfo.Params.LineBreak := #13#10;
  AResponseInfo.ContentType := 'text/plain';

  AddToLogFromThread('Command: ' + Cmd);

  if Cmd = '/' + 'InitPlugin' then
  begin
    AResponseInfo.ResponseText := 'Initialized.';
    Exit;
  end;

  if Cmd = '/' + 'ExecPlugin' then
  begin
    ExecFromPlugin(ARequestInfo.Params);
    AResponseInfo.ResponseText := 'Executed.';
    Exit;
  end;
end;


procedure TfrmProcessCommitServer.chkActiveChange(Sender: TObject);
begin
  try
    IdHTTPServer1.Active := chkActive.Checked;
    if IdHTTPServer1.Active then
      AddToLog('Listening on port ' + IntToStr(IdHTTPServer1.DefaultPort))
    else
      AddToLog('Stopped listening on port ' + IntToStr(IdHTTPServer1.DefaultPort));
  except
    on E: Exception do
      AddToLog('Ex on server active: ' + E.Message);
  end;
end;

end.

