unit GitUIMapPluginsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, VirtualTrees;

type

  { TfrmGitUIMapPlugins }

  TfrmGitUIMapPlugins = class(TForm)
    vstPlugins: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstPluginsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstPluginsInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
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

end.

