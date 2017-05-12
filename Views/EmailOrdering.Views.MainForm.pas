unit EmailOrdering.Views.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  EmailOrdering.Controllers.MainControllerInt, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Menus, Vcl.AppEvnts, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    TrayIcon1: TTrayIcon;
    ApplicationEvents1: TApplicationEvents;
    PopupMenu1: TPopupMenu;
    e1: TMenuItem;
    N2: TMenuItem;
    Exit2: TMenuItem;
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure e1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure ShowBalloonMessage(title, hint: string;
        flags: TBalloonFlags; orderId:integer);
    procedure TrayIcon1BalloonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FOrderID: integer;
  public
    { Public declarations }
    Controller: IMainController;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.e1Click(Sender: TObject);
begin
  controller.ShowMessageForm;
end;

procedure TMainForm.Exit2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  self.TrayIcon1.BalloonTitle := 'AviMark Email Ordering';
  self.TrayIcon1.BalloonHint := 'Application is running in the system tray';
  self.TrayIcon1.ShowBalloonHint;
end;

procedure TMainForm.ShowBalloonMessage(title, hint: string;
  flags: TBalloonFlags; orderId:integer);
begin
  self.TrayIcon1.BalloonHint := '';
  self.TrayIcon1.BalloonTitle := title;
  self.TrayIcon1.BalloonHint := hint;
  self.TrayIcon1.BalloonFlags := flags;
  self.TrayIcon1.BalloonTimeout := 99999999;
  self.TrayIcon1.ShowBalloonHint;
  self.FOrderID := orderId;
end;

procedure TMainForm.TrayIcon1BalloonClick(Sender: TObject);
begin
  if self.TrayIcon1.BalloonTitle = 'AviMark Email Ordering' then
    controller.ShowMessageForm
  else if self.TrayIcon1.BalloonTitle = 'Failure' then
    self.Controller.OpenFailure
  else if self.TrayIcon1.BalloonTitle = 'Order successful' then
    self.Controller.OpenSuccess;
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  controller.ShowMessageForm;
end;

end.
