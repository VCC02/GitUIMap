{
    Copyright (C) 2026 VCC
    creation date: 27 Nov 2026
    initial release date: 27 Nov 2026

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


unit GitUIMapUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TAddToLog = procedure(AMsg: string);
  TAppProcMsg = procedure;


procedure ExecApp(AApp, AAppCurentDir: string; AAppParams, AAppOutput: TStringList; AAppProcMsg: TAppProcMsg);
procedure ExecGit(ARepoPath: string; AGitParams, AGitOutput: TStringList; AAddToLog: TAddToLog; AAppProcMsg: TAppProcMsg);


implementation


uses
  Process;


procedure ExecApp(AApp, AAppCurentDir: string; AAppParams, AAppOutput: TStringList; AAppProcMsg: TAppProcMsg);
var
  Prc: TProcess;
  TempBuffer: array of Byte;
  MemStream: TMemoryStream;
  tk: QWord;
begin
  Prc := TProcess.Create(nil);
  try
    Prc.Executable := AApp;

    Prc.CurrentDirectory := AAppCurentDir;
    if Prc.CurrentDirectory = '' then
      Prc.CurrentDirectory := ExtractFileDir(Prc.CurrentDirectory);

    Prc.Parameters.Assign(AAppParams);
    Prc.Options := [poUsePipes, poStderrToOutPut, poNoConsole];

    Prc.Execute;
    MemStream := TMemoryStream.Create;
    try
      tk := GetTickCount64;
      repeat
        AAppProcMsg;
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

        AAppProcMsg;
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
      AAppOutput.LoadFromStream(MemStream);
    finally
      MemStream.Free;
    end;
  finally
    Prc.Free;
  end;
end;


procedure ExecGit(ARepoPath: string; AGitParams, AGitOutput: TStringList; AAddToLog: TAddToLog; AAppProcMsg: TAppProcMsg);
begin
  ExecApp('git', ARepoPath, AGitParams, AGitOutput, AAppProcMsg);

  if AGitOutput.Count = 0 then
  begin
    AAddToLog('Git output is empty.');
    Exit;
  end;

  if Pos('fatal: not a git repository', AGitOutput.Strings[0]) > 0 then
  begin
    AAddToLog('Error getting list of commits. ' + AGitOutput.Strings[0]);
    Exit;
  end;
end;


end.

