unit EmailTests;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TEmailTests = class(TObject)
  public
    [Test]
    [TestCase('T1', 'C:\Users\jreddekopp\Documents\AviMarkTests\Brentwood Animal Hospital Purchase Order.msg,True')]
    [TestCase('T1', '../../data/T1 - Not AVI Email.txt,False')]
    procedure TestIfAviEmail(emailFile, isAviEmail: string);

    [Test]
    [TestCase('T1', '../../data/T1 - Not AVI Email.txt')]
    procedure TestRelayEmail(emailFile: string);
  end;

implementation

uses
  IdMessage, System.SysUtils,
  EmailOrdering.Models.Config, IdSMTP, IdExplicitTLSClientServerBase;

{ TEmailTests }

procedure TEmailTests.TestIfAviEmail(emailFile, isAviEmail: string);
var
  LIdMessage: TIdMessage;
begin
  LIdMessage := TIdMessage.Create(nil);
  try
    LIdMessage.LoadFromFile(emailFile);
    inttostr(LIdMessage.MessageParts.Count);
  finally
    LIdMessage.Free;
  end;
end;

procedure TEmailTests.TestRelayEmail(emailFile: string);
var
  LIdMessage: TIdMessage;
  LConfig: TConfig;
  LOldConfig: TConfig;
begin
  LIdMessage := TIdMessage.Create(nil);
  LOldConfig := TConfig.GetInstance;
  LConfig := TConfig.Create;
  try
    LConfig.smtpHost := 'smtp.gmail.com';
    LConfig.smtpPort := 587;
    LConfig.smtpAuthType := 'satSASL';
    LConfig.smtpUsername := 'wddcTestFeb2017@gmail.com';
    LConfig.smtpPassword := 'BHuKvR6GTCGp4ZwRtgCW';

    LConfig.Save;
    LIdMessage.LoadFromFile(emailFile);
  finally
    LIdMessage.Free;
    LOldConfig.Save;
    LConfig.Free;
  end;

end;

initialization
  TDUnitX.RegisterTestFixture(TEmailTests);
end.
