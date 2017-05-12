unit EmailOrdering.Models.EmailServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdCustomTCPServer, IdTCPServer,
  IdCmdTCPServer, IdExplicitTLSClientServerBase, IdSMTPServer, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTPBase,
  IdSMTP, EmailOrdering.Models.EmailMsg, IdContext, IdAttachment, IdMessage,
  DateUtils;

type
  TEmailEvent = procedure(const msg: TEmailMsg) of object;

type
  TEmailServer = class(TThread)
    private
      FLastEmailDateTime: TDateTime;
      FIdSMTPServer1: TIdSMTPServer;
      FIdSMTP1: TIdSMTP;
      procedure IdSMTPServer1MsgReceive(ASender: TIdSMTPServerContext;
          AMsg: TStream; var VAction: TIdDataReply);
      procedure RelayEmail(IdMessage: TIdMessage);
      procedure IdSMTPServer1RcptTo(ASender: TIdSMTPServerContext;
          const AAddress: string; AParams: TStrings; var VAction: TIdRCPToReply;
          var VForward: string);
      procedure IdSMTPServer1UserLogin(ASender: TIdSMTPServerContext;
          const AUsername, APassword: string; var VAuthenticated: Boolean);
      function IsAviEmail(Msg: TIdMessage): boolean;
      procedure SetIdSMTP1(const Value: TIdSMTP);
      procedure SetIdSMTPServer1(const Value: TIdSMTPServer);
    public
      OnAviEmail : TEmailEvent;
      property IdSMTP1: TIdSMTP read FIdSMTP1 write SetIdSMTP1;
      property IdSMTPServer1: TIdSMTPServer read FIdSMTPServer1 write SetIdSMTPServer1;
      constructor Create(port: integer);
      destructor Destroy; override;
      procedure Execute(); override;
  end;

implementation

uses
  EmailOrdering.Models.Config;

constructor TEmailServer.Create(port: integer);
begin
  inherited Create(True);
  Self.FreeOnTerminate := False;
  FIdSMTPServer1 := TIdSMTPServer.Create(nil);
  FIdSMTPServer1.DefaultPort := port;
  FIdSMTPServer1.ListenQueue := 15;
  FIdSMTPServer1.TerminateWaitTime :=5000;
  FIdSMTPServer1.OnMsgReceive := IdSMTPServer1MsgReceive;
  FIdSMTPServer1.OnRcptTo := IdSMTPServer1RcptTo;
  FIdSMTPServer1.OnUserLogin := IdSMTPServer1UserLogin;
  FLastEmailDateTime := now;
end;

destructor TEmailServer.Destroy;
begin
  inherited;
  self.FIdSMTPServer1.Free;
  self.FIdSMTP1.Free;
end;

procedure TEmailServer.Execute;
begin
  inherited;
  FIdSMTP1 := TIdSMTP.Create(nil);
  FIdSMTPServer1.Active := True;
  FIdSMTP1.Host := '127.0.0.1';
  FIdSMTP1.Port := IdSMTPServer1.DefaultPort;
  if not FIdSMTP1.Connected then
    FIdSMTP1.Connect;
end;

procedure TEmailServer.IdSMTPServer1MsgReceive(ASender: TIdSMTPServerContext;
  AMsg: TStream; var VAction: TIdDataReply);
var
  LMsg: TIdMessage;
  emsg: TEmailMsg;
begin
  LMsg := TIdMessage.Create;
  emsg := TEmailMsg.Create;
  try
    LMsg.LoadFromStream(AMsg);

    if (SecondsBetween(Now, FLastEmailDateTime) < 15) then
      exit;

    FLastEmailDateTime := now;

    if (self.IsAviEmail(LMsg)) then
    begin
      emsg.Contents := LMsg;
      self.OnAviEmail(emsg);
    end
    else
    begin
      self.RelayEmail(LMsg);
    end;
  finally
    LMsg.Free;
    emsg.Free;
  end;
end;

procedure TEmailServer.RelayEmail(IdMessage: TIdMessage);
var
  SMTP: TIdSMTP;
  LConfig : TConfig;
begin
  SMTP := TIdSMTP.Create(nil);
  try
    LConfig := LConfig.GetInstance;
    SMTP.Host := LConfig.smtpHost;
    SMTP.Port := LConfig.smtpPort;
    SMTP.AuthType := LConfig.GetAuthType;
    SMTP.Username := LConfig.smtpUsername;
    SMTP.Password := LConfig.smtpPassword;
    SMTP.Connect;
    SMTP.Send(IdMessage);
  finally
    SMTP.Free;
  end;
end;

procedure TEmailServer.IdSMTPServer1RcptTo(ASender: TIdSMTPServerContext;
  const AAddress: string; AParams: TStrings; var VAction: TIdRCPToReply;
  var VForward: string);
begin
  VAction := rAddressOk;
end;

procedure TEmailServer.IdSMTPServer1UserLogin(ASender: TIdSMTPServerContext;
  const AUsername, APassword: string; var VAuthenticated: Boolean);
begin
  VAuthenticated := True;
end;

function TEmailServer.IsAviEmail(Msg: TIdMessage): boolean;
var
  I: Integer;
begin
  Result:= False;
  for I := 0 to Msg.Recipients.Count - 1 do
    if LowerCase(Msg.Recipients[I].Address) = 'avimark@wddc.com' then
      Result:= True;

  if not Result then
    exit;

  if Msg.MessageParts.Count < 2 then
    Result := false
  else if AnsiCompareText(Msg.MessageParts[1].filename, 'AVIPO.TXT') <> 0 then
    Result := False
  else
    Result := True;
end;

{$region 'Getters and Setters'}
procedure TEmailServer.SetIdSMTP1(const Value: TIdSMTP);
begin
  FIdSMTP1 := Value;
end;

procedure TEmailServer.SetIdSMTPServer1(const Value: TIdSMTPServer);
begin
  FIdSMTPServer1 := Value;
end;
{$endregion}

end.
