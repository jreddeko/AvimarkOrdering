unit EmailOrdering.SharedData;

interface

uses
  System.SysUtils;

type
  TSharedData = class
    private
      class function GetConfigFilePath: string; static;
      class function GetOrderLogPath: string; static;
      class function GetHelpUrl: string; static;
    public
      class property ConfigFilePath: string read GetConfigFilePath;
      class property OrderLogPath: string read GetOrderLogPath;
      class property HelpUrl: string read GetHelpUrl;
  end;
implementation

{ TSharedData }

class function TSharedData.GetHelpUrl: string;
begin
  Result := 'http://10.1.1.15:7778/applications/AVIMark/Help';
end;

class function TSharedData.GetOrderLogPath: string;
begin
  Result := format('%s\Wddc\EmailOrdering\%s', [System.SysUtils.GetEnvironmentVariable('ALLUSERSPROFILE')
        ,'orderlog.xml']);
end;

{ TSharedData }

class function TSharedData.GetConfigFilePath: string;
begin
  Result := format('%s\Wddc\EmailOrdering\%s', [System.SysUtils.GetEnvironmentVariable('ALLUSERSPROFILE')
        ,'emailordering.config.json']);
end;

end.
