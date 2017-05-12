unit EmailOrdering.Controllers.MainController;

interface

uses
  System.SysUtils, EmailOrdering.Controllers.Controller,
  Wddc.API.OrderApi,  Wddc.Inventory.OrderDetail,
  IdMessage, EmailOrdering.Controllers.MainControllerInt,
  Wddc.AVIMark.ParseOrder, IdAttachmentFile, EmailOrdering.Views.MessageForm,
  EmailOrdering.Views.MainForm, EmailOrdering.Models.EmailMsg,
  Wddc.Inventory.Order, REST.Client, System.Classes, Windows,
  EmailOrdering.Models.EmailServer, EmailOrdering.Models.Config, System.UITypes,
  ShellApi;

type
  TMainController = class(TInterfacedObject, IMainController)
  private
    Fform: TMainForm;
    FConfig: TConfig;
    EmailServer: TEmailServer;
    MsgForm: TMessageForm;
    procedure SetupEmailServer();
    function ValidateSettings(): TStringList;
    procedure Success(order:TOrder);
    procedure Failure(msg:string; errors:TStringList; order:TOrder);
  public
    property MainForm: TMainForm read Fform write Fform;
    procedure NewOrder(const msg: TEmailMsg);
    procedure ShowMessageForm();
    procedure OpenSuccess();
    procedure OpenFailure();
    procedure StartEmailServer(portNumber: string);
    procedure StopEmailServer();
    procedure ClearOrderLog();
    procedure UpdateConfig();
    procedure ShowHelp();
    procedure OpenSettingsForm();
    procedure OpenConfirmation(orderId: integer);
    function GetApi(): TOrderApi;
    class function GetInstance(MainForm: TMainForm): IMainController; static;
  end;

implementation

uses

  Vcl.Dialogs, Vcl.Forms, IdAttachment, REST.Json,
  REST.Types, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  EmailOrdering.Views.ErrorForm, EmailOrdering.Views.SettingsForm, System.Math,
  EmailOrdering.SharedData;

{ TMainController }

function TMainController.GetApi: TOrderApi;
begin
  Result := TOrderApi.Create(FConfig.requestBaseUrl, FConfig.requestResource, FConfig.requestAccept);
end;

class function TMainController.GetInstance(MainForm: TMainForm): IMainController;
var
  LController: TMainController;
  LIcon: TIcon;
begin
  LController := TMainController.Create;
  LIcon:= TIcon.Create;
  try
    LIcon.LoadFromFile('symbol.ico');
    LController.MainForm := mainForm;
    LController.MainForm.TrayIcon1.Visible := True;
    LController.MainForm.TrayIcon1.Icon := LIcon;
    LController.MainForm.Hide;
    LController.FConfig := TConfig.GetInstance;
    LController.MsgForm := TMessageForm.Create(LController.MainForm);
    LController.MsgForm.PopupParent := LController.MainForm;
    LController.MsgForm.Icon := LIcon;
    LController.MsgForm.Controller := LController;
    LController.SetupEmailServer();
    Result := LController;
  finally
    LIcon.Free;
  end;
end;

/// New Email Message found.
procedure TMainController.NewOrder(const msg: TEmailMsg);
var
  LOrder : TOrder;
  LErrorList : TStringList;
  LApi: TOrderApi;
begin
  if (msg = nil) then
    raise Exception.Create('Not a valid AVIMark Order');

  // parse email message attachment into order.
  try
    LOrder :=  TParseOrder.GetAviItems(msg.GetTextFromAttachment(1));
  except
   on E: Exception do
   begin
      LErrorList := TStringList.Create;
      LErrorList.Add(E.ToString);
      Failure('Critical application failure', LErrorList, nil);
      exit;
   end;
  end;
  LOrder.SourceCode := 'AVI';

  // check order for basic errors
  LErrorList := LOrder.Validate();
  try
    if (LErrorList.Count > 0) then
    begin
      Failure('Failure validating order', LErrorList, LOrder);
      exit;
    end;

    LApi := self.GetApi();
    try
      LApi.SendOrder(LOrder, FConfig.apiKey);
      if LApi.E <> nil then
      begin
        LErrorList.Text:= LApi.E.ToString;
        Failure('Failure sending order', LErrorList, LOrder);
        exit;
      end;
      LOrder := TJson.JsonToObject<TOrder>(LApi.Response);
      Success(Lorder);

    except
      On E: Exception do
      begin
        LErrorList.Add('Error sending request to web service, check request resource string in settings');
        LErrorList.Add(E.ToString);
        Failure('Critical application failure', LErrorList, LOrder );;
      end;
    end;
  finally
    LErrorList.Free;
  end;
end;

/// Opens the WDDC confirmation web page.
procedure TMainController.OpenConfirmation(orderId: integer);
begin
  TOrderApi.OpenOrderConfPage(FConfig.requestConfirmationURL, inttostr(orderId), FConfig.apiKey);
end;

/// Opens the failure error message.
procedure TMainController.OpenFailure;
var
  LErrorDForm: TErrorDForm;
  LIcon: TIcon;
begin
  LErrorDForm := TErrorDForm.Create(nil);
  LIcon:= TIcon.Create;
  try
    LIcon.LoadFromFile('symbol.ico');
    LErrorDForm.SetErrors(self.MsgForm.ClientDataSet1.FieldByName('Error').AsString);
    LErrorDForm.Icon := LIcon;
    LErrorDForm.Visible:= False;
    LErrorDForm.ShowModal;
  finally
    LErrorDForm.Free;
  end;
end;

/// Opens the settings form.
procedure TMainController.OpenSettingsForm;
var
  LSettingsForm: TSettingsForm;
begin
  LSettingsForm:= TSettingsForm.Create(self.MsgForm);
  try
    LSettingsForm.ShowModal;
    self.UpdateConfig;
  finally
  end;
end;

/// Opens a successful message.
procedure TMainController.OpenSuccess;
var
  LOrder : TOrder;
begin
  LOrder := TJson.JsonToObject<TOrder>(self.MsgForm.ClientDataSet1.FieldByName('Order').AsString);
  try
    TOrderApi.OpenOrderConfPage(FConfig.requestConfirmationURL, inttostr(LOrder.ID), FConfig.apiKey);
  finally
    LOrder.Free;
  end;
end;

/// Sets up the email
procedure TMainController.SetupEmailServer();
var
  LConfig: TConfig;
  LApi: TOrderApi;
begin
  LConfig := TConfig.GetInstance;
  LApi := self.GetApi;
  try
    if LConfig.serverPort = '' then
    begin
      LConfig.serverPort := '587';
      LConfig.Save;
    end;
    try
      LApi.CheckApiConntection;
      self.StartEmailServer(LConfig.serverPort);
      self.MsgForm.Connected := True;
    except
      on E: Exception do
      begin
        self.MsgForm.Connected := False;
        messagedlg(E.ToString, mtError, [mbyes], 0, mbYes);
      end;
    end;
  finally
    self.MsgForm.UpdateStatus;
    LConfig.Free;
    LApi.Free;
  end;
end;

/// Starts email server.
procedure TMainController.StartEmailServer(portNumber: string);
var
  LErrorList: TStringList;
begin
  // check if settings filled in
  LErrorList := self.ValidateSettings();
  try
    if (LErrorList.Count > 0) then
    begin
      Failure('Failure in settings', LErrorList, nil);
      exit;
    end;
    self.EmailServer := TEmailServer.Create(strtoint(portNumber));
    self.EmailServer.OnAviEmail := self.NewOrder;
    self.MsgForm.Connected := True;
    self.MsgForm.UpdateStatus;
    self.EmailServer.Execute;
  finally
    LErrorList.Free;
  end;
end;

/// Stops email server.
procedure TMainController.StopEmailServer;
begin
  self.EmailServer.Free;
  self.MsgForm.Connected := False;
  self.MsgForm.StatusBar1.Repaint;
  self.MsgForm.StatusBar1.Panels[1].Text := 'Offline';
  self.MsgForm.Connect1.Enabled:= True;
  self.MsgForm.Disconnect1.Enabled:= False;
end;

procedure TMainController.ShowHelp;
begin
  ShellExecute(0, 'open', PChar(TSharedData.HelpUrl), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainController.ShowMessageForm;
begin
  self.MsgForm.Show;
  self.MsgForm.WindowState := wsNormal;
end;

procedure TMainController.Success(order: TOrder);
var
  I: Integer;
  LStringList: TStringList;
begin
  LStringList:=  TStringList.Create;
  try
    self.MainForm.ShowBalloonMessage('Order successful','Click to view order confimation.',TBalloonFlags.bfInfo, order.ID);

    LStringList.Add(format('Order Successful:%sOrder Number:%d%s'
      ,[chr(9), order.ID, chr(9)]));
    LStringList.Add(format('%sTotal Items:%d%sTotal Price:%s'
      ,[chr(9), order.OrderTotalNumItems, chr(9), CurrToStrF(order.OrderTotalMoney, ffCurrency, 2)]));
    LStringList.Add(format('%sOrder Details:',[chr(9)]));
    for I := 0 to length(order.OrderDetails) - 1 do
    begin
      LStringList.Add(format('%s%sItem Number:%s%sQuantity:%d%sIndividual Price:%s'
        ,[ chr(9), chr(9),order.OrderDetails[I].Product.Id, chr(9), order.OrderDetails[I].UnitQty, chr(9)
        ,CurrToStrF(order.OrderDetails[I].UnitPrice, ffCurrency, 2)]));
    end;
    self.MsgForm.ClientDataSet1.InsertRecord([now
      , 1, 'Order successful', 'Order Number:' + inttostr(Order.ID), Order.ToJson]);

    self.MsgForm.ClientDataSet1.SaveToFile(TSharedData.OrderLogPath);
  finally
    LStringList.Free;
  end;
end;

procedure TMainController.UpdateConfig;
begin
  self.FConfig := TConfig.GetInstance;
end;

function TMainController.ValidateSettings :TStringList;
var
  LMissingMessage: string;
begin
  Result := TStringList.Create;
  LMissingMessage := '%s is blank.  Please open the settings and add a value.';
  if FConfig.requestBaseUrl = '' then
    Result.Add(LMissingMessage.Replace('%s', 'requestBaseUrl'));
  if FConfig.requestResource = '' then
    Result.Add(LMissingMessage.Replace('%s', 'requestResource'));
  if FConfig.requestConfirmationURL = '' then
    Result.Add(LMissingMessage.Replace('%s', 'requestConfirmationURL'));
  if FConfig.memberNumber = '' then
    Result.Add(LMissingMessage.Replace('%s', 'memberNumber'));
  if FConfig.apiKey = '' then
    Result.Add(LMissingMessage.Replace('%s', 'apiKey'));
end;

procedure TMainController.ClearOrderLog;
begin
  self.MsgForm.ClientDataSet1.DisableControls;
  self.MsgForm.ClientDataSet1.EmptyDataSet;
  self.MsgForm.ClientDataSet1.SaveToFile(TSharedData.OrderLogPath);;
  self.MsgForm.ClientDataSet1.EnableControls;
end;

procedure TMainController.Failure(msg: string; errors:TStringList; order: TOrder);
var
  LConfig: TConfig;
begin
  LConfig:= TConfig.GetInstance;
  try
    self.MainForm.ShowBalloonMessage('Failure',msg, bfError, 0);
    self.MsgForm.ClientDataSet1.InsertRecord([now
      , 0, 'Error', msg, nil , errors.Text]);
    self.MsgForm.ClientDataSet1.SaveToFile(TSharedData.OrderLogPath);
  finally
    LConfig.Free;
  end;
end;

end.
