program EmailOrdering;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  System.UITypes,
  Winapi.Windows,
  Winapi.ActiveX,
  EmailOrdering.Views.MainForm in 'Views\EmailOrdering.Views.MainForm.pas' {MainForm},
  EmailOrdering.Views.MessageForm in 'Views\EmailOrdering.Views.MessageForm.pas' {MessageForm},
  EmailOrdering.Controllers.MainController in 'Controllers\EmailOrdering.Controllers.MainController.pas',
  EmailOrdering.Models.EmailMsg in 'Models\EmailOrdering.Models.EmailMsg.pas',
  EmailOrdering.Controllers.Controller in 'Controllers\EmailOrdering.Controllers.Controller.pas',
  EmailOrdering.Controllers.MainControllerInt in 'Controllers\EmailOrdering.Controllers.MainControllerInt.pas',
  EmailOrdering.Models.Config in 'Models\EmailOrdering.Models.Config.pas',
  EmailOrdering.Models.ConfigKey in 'Models\EmailOrdering.Models.ConfigKey.pas',
  EmailOrdering.Views.SettingsForm in 'Views\EmailOrdering.Views.SettingsForm.pas' {SettingsForm},
  EmailOrdering.Models.EmailServer in 'Models\EmailOrdering.Models.EmailServer.pas',
  Wddc.Inventory.Order in '..\wddc\inventory\Wddc.Inventory.Order.pas',
  Wddc.Inventory.Product in '..\wddc\inventory\Wddc.Inventory.Product.pas',
  Wddc.Inventory.Member in '..\wddc\Inventory\Wddc.Inventory.Member.pas',
  Wddc.API.OrderAPI in '..\wddc\API\Wddc.API.OrderAPI.pas',
  Wddc.AVIMark.ParseOrder in '..\wddc\AVIMark\Wddc.AVIMark.ParseOrder.pas',
  Wddc.Inventory.OrderDetail in '..\wddc\inventory\Wddc.Inventory.OrderDetail.pas',
  EmailOrdering.Views.ErrorForm in 'Views\EmailOrdering.Views.ErrorForm.pas' {ErrorForm},
  EmailOrdering.SharedData in 'EmailOrdering.SharedData.pas', Vcl.Graphics;

{$R *.res}

begin
  try
    if CreateMutex(nil, True, '{D7C87766-47EC-4C12-A609-27D0BFCA8B30}') = 0 then
      RaiseLastOSError;

    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      messagedlg('Application already running, check the system tray',mtError, [mbOk], 0);
      Exit;
    end;

    Application.Initialize;
    Application.Icon.LoadFromFile('symbol.ico');
    Application.ShowMainForm := false;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TMainForm, MainForm);
    mainForm.Controller := TMainController.GetInstance(MainForm);
    Application.Run;

  except
    on E:Exception do
      ShowMessage(E.ToString);
  end;
end.
