unit ConfigTests;

interface
uses
  DUnitX.TestFramework, REST.Client, EmailOrdering.Models.Config,
  System.SysUtils;

type

  [TestFixture]
  TEmailOrderingTest = class(TObject)
  private
  public
    [Test]
    [TestCase('T1', 'config.json,member_number,123456')]
    procedure TestConfig(filename:string; nameOfValue, expectedValue: string);
  end;

implementation

uses
  IdMessage,
  IdAttachmentFile, Wddc.Inventory.Order, Data.DBXJSONCommon,
  REST.Types, REST.Json, System.JSON, Data.DBXJSONReflect, System.Rtti,
  EmailOrdering.Controllers.MainController, System.Classes, IdSMTP;


{ TEmailOrderingTest }

procedure TEmailOrderingTest.TestConfig(filename, nameOfValue, expectedValue: string);
var
  LConfig: TConfig;
begin
  LConfig := TConfig.Create;
  try
    LConfig.smtpHost := 'xcgsrv13.wddcho.com';
    LConfig.smtpPort := 25;
    LConfig.smtpAuthType := 'satNone';
    LConfig.smtpUsername := 'wddc\jreddekopp';
    LConfig.smtpPassword := 'test';
    LConfig.memberNumber := '123456';
    LConfig.requestBaseURL := 'http://localhost:8080';
    LConfig.requestAccept := 'application/json';
    LConfig.requestAcceptCharset := 'UTF-8';
    LConfig.requestResource := 'datasnap/rest/order/avimark';
    LConfig.Save;
    Lconfig := LConfig.GetInstance;
    Assert.IsTrue(LConfig.smtpHost = 'xcgsrv13.wddcho.com');
    Assert.IsTrue(LConfig.smtpPort = 25);
    Assert.IsTrue(LConfig.smtpAuthType = 'satNone');
    Assert.IsTrue(LConfig.smtpUsername = 'wddc\jreddekopp');
    Assert.IsTrue(LConfig.smtpHost = 'xcgsrv13.wddcho.com');
    Assert.IsTrue(LConfig.smtpPassword = 'test');
    Assert.IsTrue(LConfig.memberNumber = '123456');
    Assert.IsTrue(LConfig.requestBaseURL = 'http://localhost:8080');
    Assert.IsTrue(LConfig.requestAccept = 'application/json');
    Assert.IsTrue(LConfig.requestAcceptCharset = 'UTF-8');
    Assert.IsTrue(LConfig.requestResource = 'datasnap/rest/order/avimark');
  except
    on E: Exception do
    Assert.Fail(e.Message);
  end;

end;

initialization
  TDUnitX.RegisterTestFixture(TEmailOrderingTest);
end.
