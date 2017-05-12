unit EmailOrdering.Models.EmailMsg;

interface

uses
  System.Generics.Collections,
  IdMessage, Wddc.Inventory.Order, System.Classes;

type
  TEmailMsg = class(TObject)
  private
    FContents: TIdMessage;
  public
    function GetTextFromAttachment(Index: integer): TStringList;
    property Contents: TIdMessage read FContents write FContents;
  end;

implementation

uses
  System.SysUtils, IdAttachment;

{ TEmailMsg }

/// Returns an email attachment as a TStringList.
function TEmailMsg.GetTextFromAttachment(Index: integer): TStringList;
var
  LMStream: TMemoryStream;
begin
  LMStream := TMemoryStream.Create;
  Result := TStringList.Create;
  try
    if (self.Contents.MessageParts.Count < Index + 1) then
      raise Exception.Create('Attachment does not exist');

    // load attachment into LStringList.
    (self.Contents.MessageParts[Index] as TIdAttachment).SaveToStream(LMStream);
    LMStream.Position := 0;
    Result.LoadFromStream(LMStream);
  finally
    LMStream.Free;
  end;

end;

end.
