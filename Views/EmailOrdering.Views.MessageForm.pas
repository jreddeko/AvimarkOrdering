unit EmailOrdering.Views.MessageForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.Menus,
  Vcl.AppEvnts, Data.DB, Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient,
  System.ImageList, Vcl.ImgList, Data.Bind.EngExt, Vcl.Bind.DBEngExt,
  Vcl.Bind.Grid, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,Vcl.Buttons
  ,System.Math, Wddc.Inventory.Order,
  EmailOrdering.Controllers.MainControllerInt, Vcl.Mask, Vcl.ExtCtrls,
  System.Win.TaskbarCore, Vcl.Taskbar;

type
  TMessageForm = class(TForm)
    PageControl1: TPageControl;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    EmailSettings1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Orders: TTabSheet;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    ClientDataSet1Message: TStringField;
    ImageList1: TImageList;
    ClientDataSet1Type: TIntegerField;
    ClientDataSet1Order: TStringField;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    ClientDataSet1Details: TStringField;
    ClientDataSet1Error: TStringField;
    ButtonClearAll: TButton;
    ClientDataSet1Timestamp: TDateTimeField;
    StatusBar1: TStatusBar;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    procedure ClientDataSet1OrderGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ClientDataSet1AfterApplyUpdates(Sender: TObject;
      var OwnerData: OleVariant);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const [Ref] Rect: TRect);
    procedure EmailSettings1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ButtonClearAllClick(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    FController: IMainController;
    procedure SetController(const Value: IMainController);
  published
    { Private declarations }
  public
    Connected: boolean;
    property Controller: IMainController read FController write SetController;
    procedure CreateParams(var Params: TCreateParams) ; override;
    procedure UpdateStatus();
  end;

var
  MessageForm: TMessageForm;

implementation

uses
  REST.Json,
  Wddc.API.OrderAPI, EmailOrdering.Models.Config, EmailOrdering.SharedData;

{$R *.dfm}

procedure TMessageForm.ButtonClearAllClick(Sender: TObject);
begin
  self.Controller.ClearOrderLog;
end;

procedure TMessageForm.ClientDataSet1AfterApplyUpdates(Sender: TObject;
  var OwnerData: OleVariant);
var
  I: Integer;
  FixedWidth: Integer;
begin
  with self.StringGrid1 do
    if 1 >= FixedCols then
    begin
      FixedWidth := 0;
      for I := 0 to FixedCols - 1 do
        Inc(FixedWidth, ColWidths[I] + GridLineWidth);
      ColWidths[1] := ClientWidth - FixedWidth - GridLineWidth;
    end;
end;

procedure TMessageForm.ClientDataSet1OrderGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := Copy(Sender.AsString, 1, Sender.AsString.Length);
end;

procedure TMessageForm.Connect1Click(Sender: TObject);
begin
  self.Controller.SetupEmailServer;
end;

procedure TMessageForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := 0;
end;

procedure TMessageForm.Disconnect1Click(Sender: TObject);
begin
  self.Controller.StopEmailServer;
end;

procedure TMessageForm.EmailSettings1Click(Sender: TObject);
begin
  self.Controller.OpenSettingsForm;
end;

procedure TMessageForm.Exit1Click(Sender: TObject);
begin
  self.Close;
end;

procedure TMessageForm.FormCreate(Sender: TObject);
begin
  try
    Left:=(Screen.Width-Width)  div 2;
    Top:=(Screen.Height-Height) div 2;
    ClientDataSet1.CreateDataSet;
    ClientDataSet1.Active := True;
    if fileexists(TSharedData.OrderLogPath) then
      ClientDataSet1.LoadFromFile(TSharedData.OrderLogPath);
  finally

  end;
end;

procedure TMessageForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  Handled := True;
  if (Msg.CharCode = VK_F1) then
    self.Controller.ShowHelp
  else if (Msg.CharCode = VK_F2) and (not self.Connected) then
    self.Controller.SetupEmailServer
  else if (Msg.CharCode = VK_F3) and (self.Connected) then
    self.Controller.StopEmailServer
  else
    Handled:= False;
end;

procedure TMessageForm.SetController(const Value: IMainController);
begin
  FController := Value;
end;

procedure TMessageForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const [Ref] Rect: TRect);
var
  LIcon: TIcon;
begin
  LIcon := TIcon.Create;
  if self.Connected then
    LIcon.LoadFromFile('success.ico')
  else
    LIcon.LoadFromFile('error.ico');
  StatusBar.Canvas.Draw(Rect.Left + 2, Rect.Top + 2, LIcon);
end;

procedure TMessageForm.StringGrid1DblClick(Sender: TObject);
begin
  if (self.ClientDataSet1.FieldByName('Type').AsInteger = 0) then
    self.Controller.OpenFailure
  else if (self.ClientDataSet1.FieldByName('Type').AsInteger = 1) then
    self.Controller.OpenSuccess;
end;

procedure TMessageForm.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s: string;
  aCanvas: TCanvas;
  LIcon: TIcon;
  x,y: integer;
begin
  if (ACol <> 1) or (ARow = 0) then
    Exit;
  s := (Sender as TStringGrid).Cells[ACol, ARow];
  // Draw ImageX.Picture.Bitmap in all Rows in Col 1
  aCanvas := (Sender as TStringGrid).Canvas;  // To avoid with statement
  // Clear current cell rect
  aCanvas.FillRect(Rect);
  // Draw the image in the cell
  LIcon := TIcon.Create;
  x:=  System.Math.Floor((Rect.Left + Rect.Right)/2 - 8);
  y:=  System.Math.Floor((Rect.Top + Rect.Bottom)/2 - 8);
  if (s = '0') then
  begin
    LIcon.LoadFromFile('error.ico');
    aCanvas.Draw(x, y, LIcon)
  end
  else if (s='1') then

  begin
    LIcon.LoadFromFile('success.ico');
    aCanvas.Draw(x, y, LIcon);
  end;
end;

procedure TMessageForm.UpdateStatus;
begin
  if (self.Connected) then
  begin
    self.Connect1.Enabled := False;
    self.Disconnect1.Enabled := True;
    self.StatusBar1.Panels[1].Text := 'Connected';
  end
  else
  begin
    self.Connect1.Enabled := True;
    self.Disconnect1.Enabled := False;
    self.StatusBar1.Panels[1].Text := 'Disconnected';
  end;
  self.StatusBar1.Repaint;
end;

end.
