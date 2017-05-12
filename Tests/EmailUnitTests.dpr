program EmailUnitTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  EmailOrdering.Models.Config in '..\Models\EmailOrdering.Models.Config.pas',
  EmailOrdering.Models.ConfigKey in '..\Models\EmailOrdering.Models.ConfigKey.pas',
  EmailOrdering.Controllers.MainController in '..\Controllers\EmailOrdering.Controllers.MainController.pas',
  EmailOrdering.Controllers.Controller in '..\Controllers\EmailOrdering.Controllers.Controller.pas',
  EmailOrdering.Controllers.MainControllerInt in '..\Controllers\EmailOrdering.Controllers.MainControllerInt.pas',
  EmailOrdering.Models.EmailMsg in '..\Models\EmailOrdering.Models.EmailMsg.pas',
  EmailOrdering.Views.MainForm in '..\Views\EmailOrdering.Views.MainForm.pas',
  EmailOrdering.Views.SettingsForm in '..\Views\EmailOrdering.Views.SettingsForm.pas',
  EmailOrdering.Views.MessageForm in '..\Views\EmailOrdering.Views.MessageForm.pas',
  EmailOrdering.Models.EmailServer in '..\Models\EmailOrdering.Models.EmailServer.pas',
  EmailOrdering.Views.ErrorForm in '..\Views\EmailOrdering.Views.ErrorForm.pas',
  EmailOrdering.SharedData in '..\EmailOrdering.SharedData.pas',
  ConfigTests in 'ConfigTests.pas',
  EmailTests in 'EmailTests.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
