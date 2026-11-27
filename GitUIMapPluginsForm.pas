{
    Copyright (C) 2026 VCC
    creation date: 26 Nov 2026
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


unit GitUIMapPluginsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  VirtualTrees;

type

  { TfrmGitUIMapPlugins }

  TfrmGitUIMapPlugins = class(TForm)
    btnAddPlugin: TButton;
    btnUpdatePlugin: TButton;
    btnRemovePlugin: TButton;
    btnBrowsePlugin: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    lbePluginPath: TLabeledEdit;
    vstPlugins: TVirtualStringTree;
    procedure btnAddPluginClick(Sender: TObject);
    procedure btnBrowsePluginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnRemovePluginClick(Sender: TObject);
    procedure btnUpdatePluginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstPluginsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstPluginsInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstPluginsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FListOfPlugins: TStringList;
  public

  end;


function EditPlugins(AListOfPlugins: TStringList): Boolean;

implementation

{$R *.frm}

function EditPlugins(AListOfPlugins: TStringList): Boolean;
var
  frmGitUIMapPlugins: TfrmGitUIMapPlugins;
begin
  Result := False;
  Application.CreateForm(TfrmGitUIMapPlugins, frmGitUIMapPlugins);
  frmGitUIMapPlugins.FListOfPlugins.Assign(AListOfPlugins);
  frmGitUIMapPlugins.vstPlugins.RootNodeCount := AListOfPlugins.Count;

  frmGitUIMapPlugins.ShowModal;

  Result := frmGitUIMapPlugins.Tag = 1;
  if Result then
    AListOfPlugins.Assign(frmGitUIMapPlugins.FListOfPlugins);
end;

{ TfrmGitUIMapPlugins }

procedure TfrmGitUIMapPlugins.FormCreate(Sender: TObject);
begin
  FListOfPlugins := TStringList.Create;
end;


procedure TfrmGitUIMapPlugins.btnBrowsePluginClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.InitialDir := ExtractFileDir(ParamStr(0));
    OpenDialog.Filter := 'Plugins (*.dll)|*.dll|All files (*.*)|*.*';
    {$IFDEF UNIX}
      OpenDialog.Filter := StringReplace(OpenDialog.Filter, 'dll', 'so', [rfReplaceAll]);
    {$ENDIF}

    if not OpenDialog.Execute then
      Exit;
    Application.ProcessMessages;
    Sleep(500);

    lbePluginPath.Text := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;
end;


procedure TfrmGitUIMapPlugins.btnCancelClick(Sender: TObject);
begin
  Close;
end;


procedure TfrmGitUIMapPlugins.btnOKClick(Sender: TObject);
begin
  Tag := 1;
  Close;
end;


procedure TfrmGitUIMapPlugins.btnAddPluginClick(Sender: TObject);
begin
  FListOfPlugins.Add(lbePluginPath.Text);
  vstPlugins.RootNodeCount := FListOfPlugins.Count;
end;


procedure TfrmGitUIMapPlugins.btnUpdatePluginClick(Sender: TObject);
var
  Node: PVirtualNode;
begin
  Node := vstPlugins.GetFirstSelected;
  if Node = nil then
    Exit;

  FListOfPlugins.Strings[Node^.Index] := lbePluginPath.Text;
end;


procedure TfrmGitUIMapPlugins.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;


procedure TfrmGitUIMapPlugins.btnRemovePluginClick(Sender: TObject);
var
  Node: PVirtualNode;
begin
  Node := vstPlugins.GetFirstSelected;
  if Node = nil then
    Exit;

  if MessageDlg(Caption, 'Are you sure you want to remove the selected item?', mtConfirmation, mbYesNo, '') = mrNo then
    Exit;

  vstPlugins.RootNodeCount := vstPlugins.RootNodeCount - 1;
  FListOfPlugins.Delete(Node^.Index);
  vstPlugins.Repaint;
end;


procedure TfrmGitUIMapPlugins.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FListOfPlugins);
end;


procedure TfrmGitUIMapPlugins.vstPluginsGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
begin
  try
    CellText := FListOfPlugins.Strings[Node^.Index];
  except
    on E: Exception do
      CellText := E.Message;
  end;
end;


procedure TfrmGitUIMapPlugins.vstPluginsInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
begin
  Node^.CheckType := ctNone;
end;


procedure TfrmGitUIMapPlugins.vstPluginsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
begin
  Node := vstPlugins.GetFirstSelected;
  if Node = nil then
    Exit;

  lbePluginPath.Text := FListOfPlugins.Strings[Node^.Index];
end;

end.

