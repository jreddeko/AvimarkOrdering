unit EmailOrdering.Models.Config;

interface

uses
  REST.Json, DCPcrypt2, IdSMTP, DCPsha1, DCPrc4;

type
  /// config file for storing information related to this application
  ///  password in encypted using the below key and the DCPcrypt2 library
  TConfig = class
    private
      FsmtpPort: Word;
      FsmtpPassword: string;
      FsmtpUsername: string;
      FsmtpAuthType: string;
      FsmtpHost: string;
      FmemberNumber: string;
      FrequestAcceptCharset: string;
      FrequestResource: string;
      FrequestBaseUrl: string;
      FrequestAccept: string;
      FapiKey: string;
      FrequestConfirmationURL: string;
      FserverPort: string;
      procedure SetsmtpHost(const Value: string);
      procedure SetsmtpPassword(const Value: string);
      procedure SetsmtpPort(const Value: Word);
      procedure SetsmtpUsername(const Value: string);
      function GetsmtpPassword: string;
      procedure SetmemberNumber(const Value: string);
      procedure SetrequestAccept(const Value: string);
      procedure SetrequestAcceptCharset(const Value: string);
      procedure SetrequestBaseUrl(const Value: string);
      procedure SetrequestResource(const Value: string);
      procedure SetapiKey(const Value: string);
      procedure SetrequestConfirmationURL(const Value: string);
      procedure SetserverPort(const Value: string);
    public
      property requestBaseUrl: string read FrequestBaseUrl write SetrequestBaseUrl;
      property requestAccept: string read FrequestAccept write SetrequestAccept;
      property requestAcceptCharset: string read FrequestAcceptCharset write SetrequestAcceptCharset;
      property requestResource: string read FrequestResource write SetrequestResource;
      property requestConfirmationURL: string read FrequestConfirmationURL write SetrequestConfirmationURL;
      property smtpHost: string read FsmtpHost write SetsmtpHost;
      property smtpPort: Word read FsmtpPort write SetsmtpPort;
      property smtpAuthType: string read FsmtpAuthType write FsmtpAuthType;
      property smtpUsername: string read FsmtpUsername write SetsmtpUsername;
      property smtpPassword: string read GetsmtpPassword write SetsmtpPassword;
      property memberNumber: string read FmemberNumber write SetmemberNumber;
      property apiKey: string read FapiKey write SetapiKey;
      property serverPort: string read FserverPort write SetserverPort;
      function GetAuthType: IdSMTP.TIdSMTPAuthenticationType;
      function GetPasswordAst(): string;
      procedure Save;
      class function GetInstance : TConfig; static;
      class function Decrypt(value: string): string; static;
      class function Encrypt(value: string): string; static;
  end;
implementation

uses
  System.JSON, System.SysUtils, EmailOrdering.Models.ConfigKey,
  EmailOrdering.SharedData, System.IOUtils;

{ TConfig }

class function TConfig.Encrypt(value: string): string;
var
  Cipher: TDCP_rc4;
begin
    Cipher:= TDCP_rc4.Create(nil);
    Cipher.InitStr(TConfigKey.Value,TDCP_sha1);
    Result := Cipher.EncryptString(value);
    Cipher.Burn;
    Cipher.Free;
end;

function TConfig.GetsmtpPassword: string;
begin
  if (self.FsmtpPassword = '') then
    raise Exception.Create('Password is blank');
  Result := TConfig.Decrypt(self.FsmtpPassword);
end;

function TConfig.GetAuthType: IdSMTP.TIdSMTPAuthenticationType;
begin
  if self.FsmtpAuthType = 'satNone' then
    Result:= TIdSMTPAuthenticationType.satNone
  else if self.FsmtpAuthType = 'satDefault' then
    Result:= TIdSMTPAuthenticationType.satDefault
  else if self.FsmtpAuthType = 'satSASL' then
    Result:= TIdSMTPAuthenticationType.satSASL
  else
    Result:= TIdSMTPAuthenticationType.satNone;
end;

class function TConfig.Decrypt(value: string): string;
var
  Cipher: TDCP_rc4;
begin
    Cipher:= TDCP_rc4.Create(nil);
    Cipher.InitStr(TConfigKey.Value,TDCP_sha1);
    // initialize the cipher with a hash of the passphrase
    Result := Cipher.DecryptString(value);
    Cipher.Burn;
    Cipher.Free;
end;

class function TConfig.GetInstance : TConfig;
begin
  if fileexists(TSharedData.ConfigFilePath) then
  begin
    Result := TJson.JsonToObject<TConfig>(TFile.ReadAllText(TSharedData.ConfigFilePath));
    exit;
  end;
  Result:= TConfig.Create;
  //set default values
  Result.requestBaseUrl:= 'http://10.1.1.15:7778';
  Result.requestAccept:= 'application/json';
  Result.requestAcceptCharset := '';
  Result.requestResource := 'api/orders';
  Result.requestConfirmationURL := 'http://10.1.1.15:7778/orders/confirmation/';
end;

procedure TConfig.Save;
begin
  forcedirectories(System.SysUtils.ExtractFilePath(TSharedData.ConfigFilePath));
  TFile.WriteAllText(TSharedData.ConfigFilePath, TJson.ObjectToJsonString(self));
end;

function TConfig.GetPasswordAst(): string;
var
  I: Integer;
begin
  Result:= '';
  for I := 0 to self.smtpPassword.Length - 1 do
    Result:= Result + '*';
end;

{$region 'Getters and Setters'}

procedure TConfig.SetserverPort(const Value: string);
begin
  FserverPort := Value;
end;

procedure TConfig.SetsmtpHost(const Value: string);
begin
  FsmtpHost := Value;
end;

procedure TConfig.SetapiKey(const Value: string);
begin
  FapiKey := Value;
end;

procedure TConfig.SetmemberNumber(const Value: string);
begin
  FmemberNumber := Value;
end;

procedure TConfig.SetrequestAccept(const Value: string);
begin
  FrequestAccept := Value;
end;

procedure TConfig.SetrequestAcceptCharset(const Value: string);
begin
  FrequestAcceptCharset := Value;
end;

procedure TConfig.SetrequestBaseUrl(const Value: string);
begin
  FrequestBaseUrl := Value;
end;

procedure TConfig.SetrequestConfirmationURL(const Value: string);
begin
  FrequestConfirmationURL := Value;
end;

procedure TConfig.SetrequestResource(const Value: string);
begin
  FrequestResource := Value;
end;

procedure TConfig.SetsmtpPassword(const Value: string);
begin
  FsmtpPassword := TConfig.Encrypt(Value);
end;

procedure TConfig.SetsmtpPort(const Value: Word);
begin
  FsmtpPort := Value;
end;

procedure TConfig.SetsmtpUsername(const Value: string);
begin
  FsmtpUsername := Value;
end;
{$endregion}

end.
