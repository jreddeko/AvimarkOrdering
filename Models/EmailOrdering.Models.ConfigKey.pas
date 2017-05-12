unit EmailOrdering.Models.ConfigKey;

interface

type
  /// Encryption Key
  TConfigKey = class
   private
     class function GetValue: string; static;
   public
     class property Value : string read GetValue;
  end;

implementation

{ TConfigKey }

class function TConfigKey.GetValue: string;
begin
  Result := 'XiklNjfu2svgX7vhUrLh';
end;

end.
