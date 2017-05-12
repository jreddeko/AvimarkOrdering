unit EmailOrdering.Views.SettingsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.ComCtrls,
  EmailOrdering.Models.Config, EmailOrdering.Controllers.MainControllerInt,
  Vcl.StdCtrls;

type
  TSettingsForm = class(TForm)
    PageControlSettings: TPageControl;
    Email: TTabSheet;
    API: TTabSheet;
    ValueListEditorSettingsEmail: TValueListEditor;
    ValueListEditorSettingsApi: TValueListEditor;
    Member: TTabSheet;
    ValueListEditorSettingsMember: TValueListEditor;
    Button1: TButton;
    TabSheet1: TTabSheet;
    ValueListEditorApplication: TValueListEditor;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    FController: IMainController;
    procedure SetController(const Value: IMainController);
    { Private declarations }
  public
    { Public declarations }
    property Controller: IMainController read FController write SetController;
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.dfm}

procedure TSettingsForm.Button1Click(Sender: TObject);
var
  LConfig: TConfig;
  password: string;
begin
  LConfig := TConfig.GetInstance;
  try
    password := InputBox('Change Password', #31'New Password:', '');
    LConfig.smtpPassword := password;
    LConfig.Save;
  finally
    LConfig.Free;
  end;
end;

procedure TSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  LConfig: TConfig;
begin
LConfig := TConfig.GetInstance;
  try
    LConfig.smtpHost := self.ValueListEditorSettingsEmail.Values['smtpHost'];
    LConfig.smtpPort := StrToInt(self.ValueListEditorSettingsEmail.Values['smtpPort']);
    LConfig.smtpAuthType := self.ValueListEditorSettingsEmail.Values['smtpAuthType'] ;
    LConfig.smtpUsername := self.ValueListEditorSettingsEmail.Values['smtpUsername'];
    LConfig.requestBaseUrl := self.ValueListEditorSettingsApi.Values['requestBaseUrl'];
    LConfig.requestAccept := self.ValueListEditorSettingsApi.Values['requestAccept'];
    LConfig.requestAcceptCharset := self.ValueListEditorSettingsApi.Values['requestAcceptCharset'];
    LConfig.requestResource := self.ValueListEditorSettingsApi.Values['requestResource'];
    LConfig.requestConfirmationURL := self.ValueListEditorSettingsApi.Values['requestConfirmationURL'];
    LConfig.memberNumber := self.ValueListEditorSettingsMember.Values['memberNumber'];
    LConfig.apiKey := self.ValueListEditorSettingsMember.Values['apiKey'];
    LConfig.serverPort := self.ValueListEditorApplication.Values['serverPort'];
    LConfig.Save;
  finally
    LConfig.Free;
  end;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  LConfig: TConfig;
begin
  LConfig := TConfig.GetInstance;
  try
    self.ValueListEditorSettingsEmail.Values['smtpHost'] := LConfig.smtpHost;
    self.ValueListEditorSettingsEmail.Values['smtpPort'] := LConfig.smtpPort.ToString;
    self.ValueListEditorSettingsEmail.Values['smtpAuthType'] := LConfig.smtpAuthType;
    self.ValueListEditorSettingsEmail.Values['smtpUsername'] := LConfig.smtpUsername;
    self.ValueListEditorSettingsApi.Values['requestBaseUrl'] := LConfig.requestBaseUrl;
    self.ValueListEditorSettingsApi.Values['requestAccept'] := LConfig.requestAccept;
    self.ValueListEditorSettingsApi.Values['requestAcceptCharset'] := LConfig.requestAcceptCharset;
    self.ValueListEditorSettingsApi.Values['requestResource'] := LConfig.requestResource;
    self.ValueListEditorSettingsApi.Values['requestConfirmationURL'] := LConfig.requestConfirmationURL;
    self.ValueListEditorSettingsMember.Values['memberNumber'] := LConfig.memberNumber;
    self.ValueListEditorSettingsMember.Values['apiKey'] := LConfig.apiKey;
    self.ValueListEditorApplication.Values['serverPort'] := LConfig.serverPort;
    Left:=(Screen.Width-Width)  div 2;
    Top:=(Screen.Height-Height) div 2;
  finally
    LConfig.Free;
  end;
end;

procedure TSettingsForm.SetController(const Value: IMainController);
begin
  FController := Value;
end;

end.
